import json
import urllib.request

url = "http://localhost:5194/api/v1/rbac/catalog-tree"
try:
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        print("HTTP Status:", resp.status)
        modules = data.get("data", [])
        print("Total modules returned:", len(modules))
        total_widgets = 0
        def count_sub_widgets(sub):
            cnt = len(sub.get("widgets", []))
            for child in sub.get("childSubmodules", []):
                cnt += count_sub_widgets(child)
            return cnt

        for m in modules:
            direct = len(m.get("directWidgets", []))
            sub_count = len(m.get("submodules", []))
            sub_widgets = sum(count_sub_widgets(s) for s in m.get("submodules", []))
            mod_widgets = direct + sub_widgets
            total_widgets += mod_widgets
            print(f" - Module: {m.get('name')} -> {sub_count} top subs, {direct} direct widgets, {sub_widgets} sub widgets (Total: {mod_widgets})")
        print("Total widgets in tree:", total_widgets)

        # Test with a role from roles API
        roles_req = urllib.request.Request("http://localhost:5194/api/v1/roles")
        with urllib.request.urlopen(roles_req) as r_resp:
            r_data = json.loads(r_resp.read().decode('utf-8'))
            roles = r_data.get("data", [])
            print(f"Total roles: {len(roles)}")
            if roles:
                test_role = roles[0]
                role_id = test_role['id']
                print(f"Testing permissions for role: {test_role['name']} ({role_id})")
                role_tree_req = urllib.request.Request(f"http://localhost:5194/api/v1/rbac/catalog-tree?roleId={role_id}")
                with urllib.request.urlopen(role_tree_req) as rt_resp:
                    rt_data = json.loads(rt_resp.read().decode('utf-8'))
                    first_mod = rt_data.get("data", [])[0]
                    first_w = first_mod.get("directWidgets", [])[0]
                    print(f"First widget '{first_w['name']}': CanView={first_w['canView']}, CanManage={first_w['canManage']}")

except Exception as e:
    import traceback
    traceback.print_exc()
