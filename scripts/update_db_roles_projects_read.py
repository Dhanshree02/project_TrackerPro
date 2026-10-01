import psycopg2
import json

conn = psycopg2.connect('postgresql://postgres:clockit@10.50.30.189:5432/trackerpro')
cur = conn.cursor()

roles_to_update = [
    'Testing-Team Member',
    'Consulting-Team member',
    'SOC-Team Member',
    'R&D - Team member',
    'Intern',
    'employee'
]

for rname in roles_to_update:
    cur.execute('SELECT "Id", "Name", "Permissions" FROM roles WHERE "Name" ILIKE %s', (rname,))
    rows = cur.fetchall()
    for row in rows:
        rid, name, perms = row
        perms = list(perms or [])
        updated = False
        if 'projects:read' not in perms:
            perms.append('projects:read')
            updated = True
        if 'projects.view' not in perms:
            perms.append('projects.view')
            updated = True
        if updated:
            cur.execute('UPDATE roles SET "Permissions" = %s::jsonb WHERE "Id" = %s', (json.dumps(perms), rid))
            print(f"Updated role {name} with projects:read and projects.view")

conn.commit()
print("PostgreSQL roles table updated successfully.")
