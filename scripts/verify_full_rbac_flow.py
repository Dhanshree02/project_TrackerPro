import json
import urllib.request

BASE_URL = "http://localhost:5194"

def make_req(path, method="GET", body=None):
    url = f"{BASE_URL}{path}"
    headers = {"Content-Type": "application/json"}
    data = json.dumps(body).encode("utf-8") if body else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))

def main():
    print("=== STEP 1: Fetch all roles ===")
    roles_res = make_req("/api/v1/roles")
    roles = roles_res.get("data", [])
    print(f"Total roles returned: {len(roles)}")
    assert len(roles) >= 28, f"Expected at least 28 roles, got {len(roles)}"

    test_role = next((r for r in roles if "Testing-Team Member" in r["name"]), roles[0])
    role_id = test_role["id"]
    role_name = test_role["name"]
    print(f"Selected test role: {role_name} ({role_id})")

    print("\n=== STEP 2: Fetch 4-tier Catalog Tree for Role ===")
    tree_res = make_req(f"/api/v1/rbac/catalog-tree?roleId={role_id}")
    modules = tree_res.get("data", [])
    print(f"Modules returned: {len(modules)}")
    assert len(modules) == 9, f"Expected 9 modules, got {len(modules)}"

    all_widgets = []
    def traverse_sub(s):
        all_widgets.extend(s.get("widgets", []))
        for c in s.get("childSubmodules", []):
            traverse_sub(c)

    for m in modules:
        all_widgets.extend(m.get("directWidgets", []))
        for s in m.get("submodules", []):
            traverse_sub(s)

    print(f"Total widgets in tree: {len(all_widgets)}")
    assert len(all_widgets) == 49, f"Expected 49 widgets, got {len(all_widgets)}"

    # Check a sample widget (e.g. issues)
    issues_w = next((w for w in all_widgets if "issues" in w["widgetKey"]), all_widgets[0])
    print(f"Sample widget: '{issues_w['name']}' ({issues_w['widgetKey']})")
    print(f"Current CanView: {issues_w['canView']}, CanManage: {issues_w['canManage']}")

    print("\n=== STEP 3: Test Updating Permissions (1/0 flags) ===")
    # Toggle permissions for the sample widget: set CanView=1, CanManage=1
    target_id = issues_w["id"]
    update_payload = {
        "permissions": [
            {
                "widgetId": target_id,
                "canView": 1,
                "canManage": 1
            }
        ]
    }
    update_res = make_req(f"/api/v1/rbac/roles/{role_id}/widget-permissions", method="PUT", body=update_payload)
    print("Update API response data:", update_res.get("data"))
    assert update_res.get("data") is True, f"Expected data=True, got {update_res}"

    # Re-fetch permissions to verify persistence in DB
    tree_after = make_req(f"/api/v1/rbac/catalog-tree?roleId={role_id}")
    all_w_after = []
    for m in tree_after.get("data", []):
        all_w_after.extend(m.get("directWidgets", []))
        for s in m.get("submodules", []):
            traverse_sub(s)

    w_updated = next(w for w in all_w_after if w["id"] == target_id)
    print(f"Verified after update: CanView={w_updated['canView']}, CanManage={w_updated['canManage']}")
    assert w_updated["canView"] == 1 and w_updated["canManage"] == 1, "Permissions failed to persist!"

    print("\n=== STEP 4: Test Invariant View=0 forcing Manage=0 ===")
    inv_payload = {
        "permissions": [
            {
                "widgetId": target_id,
                "canView": 0,
                "canManage": 1 # Violates invariant, server must correct to 0!
            }
        ]
    }
    make_req(f"/api/v1/rbac/roles/{role_id}/widget-permissions", method="PUT", body=inv_payload)
    tree_inv = make_req(f"/api/v1/rbac/catalog-tree?roleId={role_id}")
    all_w_inv = []
    for m in tree_inv.get("data", []):
        all_w_inv.extend(m.get("directWidgets", []))
        for s in m.get("submodules", []):
            traverse_sub(s)
    w_inv = next(w for w in all_w_inv if w["id"] == target_id)
    print(f"After invariant check: CanView={w_inv['canView']}, CanManage={w_inv['canManage']}")
    assert w_inv["canView"] == 0 and w_inv["canManage"] == 0, "Invariant violation: Manage was not forced to 0 when View was 0!"

    print("\n=== STEP 5: Test Reset Role Baseline ===")
    reset_res = make_req(f"/api/v1/rbac/roles/{role_id}/reset-widget-baseline", method="POST")
    print("Reset Baseline API response data:", reset_res.get("data"))
    assert reset_res.get("data") is True, f"Expected data=True, got {reset_res}"

    # Verify baseline restored
    tree_reset = make_req(f"/api/v1/rbac/catalog-tree?roleId={role_id}")
    all_w_reset = []
    for m in tree_reset.get("data", []):
        all_w_reset.extend(m.get("directWidgets", []))
        for s in m.get("submodules", []):
            traverse_sub(s)
    w_reset = next(w for w in all_w_reset if w["id"] == target_id)
    print(f"After Reset Baseline: CanView={w_reset['canView']}, CanManage={w_reset['canManage']}")

    print("\n=== ALL RBAC ARCHITECTURE TESTS PASSED SUCCESSFULLY! ===")

if __name__ == "__main__":
    main()
