import psycopg2

conn = psycopg2.connect(
    host="10.50.30.189", port=5432, dbname="trackerpro",
    user="postgres", password="clockit"
)
cur = conn.cursor()
cur.execute('SELECT "Id", "Name", "DisplayName" FROM roles ORDER BY "Name"')
roles = cur.fetchall()
print(f"Total roles: {len(roles)}")
for r in roles:
    print(f"  {r[0]} | {r[1]} | {r[2]}")

cur.execute("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'role_permission_audits'
""")
print("\nColumns in role_permission_audits:")
for c in cur.fetchall():
    print(f"  {c[0]} ({c[1]})")

conn.close()
