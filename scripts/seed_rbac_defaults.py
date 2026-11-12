import subprocess
from test_rbac_rules import roles, catalog, get_role_archetype, compute_permission

sql_lines = [
    "BEGIN;",
]

count = 0
for role_name, role_id in sorted(roles.items()):
    archetype = get_role_archetype(role_name)
    for item in catalog:
        kind = item['kind']
        code = item['code']
        item_id = item['id']
        cv, cm = compute_permission(archetype, kind, code)
        dcv, dcm = cv, cm
        
        sql = f"""
INSERT INTO auth.tbl_role_permissions (
    "Id", "RoleId", "ItemId", "ItemType", "CanView", "CanManage", "DefaultCanView", "DefaultCanManage", "CreatedAtUtc"
) VALUES (
    gen_random_uuid(), '{role_id}', '{item_id}', '{kind}', {cv}, {cm}, {dcv}, {dcm}, NOW()
)
ON CONFLICT ("RoleId", "ItemId") DO UPDATE SET
    "ItemType" = EXCLUDED."ItemType",
    "CanView" = EXCLUDED."CanView",
    "CanManage" = EXCLUDED."CanManage",
    "DefaultCanView" = EXCLUDED."DefaultCanView",
    "DefaultCanManage" = EXCLUDED."DefaultCanManage",
    "UpdatedAtUtc" = NOW();
"""
        sql_lines.append(sql.strip())
        count += 1

sql_lines.append("COMMIT;")

full_sql = "\n".join(sql_lines)

print(f"Generated {count} upsert statements. Executing via psql...")
p = subprocess.Popen(['docker', 'exec', '-i', 'pms_uat_db', 'psql', '-U', 'postgres', '-d', 'pms_uat_clean'],
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate(input=full_sql.encode('utf-8'))

if p.returncode != 0:
    print("Error executing SQL:")
    print(stderr.decode('utf-8'))
else:
    print("Execution completed successfully!")
    # Check count in DB
    verify = subprocess.check_output(['docker', 'exec', 'pms_uat_db', 'psql', '-U', 'postgres', '-d', 'pms_uat_clean', '-c', '''
SELECT 
    count(*) as total_rows,
    sum(case when "CanView" = 1 then 1 else 0 end) as can_view_count,
    sum(case when "CanManage" = 1 then 1 else 0 end) as can_manage_count,
    sum(case when "DefaultCanView" = 1 then 1 else 0 end) as default_can_view_count,
    sum(case when "DefaultCanManage" = 1 then 1 else 0 end) as default_can_manage_count
FROM auth.tbl_role_permissions;
''']).decode('utf-8')
    print(verify)

