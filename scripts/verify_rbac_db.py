import psycopg2

conn = psycopg2.connect(
    host="10.50.30.189", port=5432, dbname="trackerpro",
    user="postgres", password="clockit"
)
cur = conn.cursor()
cur.execute('SELECT COUNT(*) FROM vw_role_widget_matrix')
print('Total rows in vw_role_widget_matrix:', cur.fetchone()[0])

cur.execute("""
    SELECT "RoleName", "WidgetKey", "CanView", "CanManage" 
    FROM vw_role_widget_matrix 
    WHERE "RoleName" = 'Admin' 
    LIMIT 5
""")
print('Sample Admin rows:')
for r in cur.fetchall():
    print(" ", r)

cur.execute("""
    SELECT "RoleName", "WidgetKey", "CanView", "CanManage" 
    FROM vw_role_widget_matrix 
    WHERE "RoleName" = 'Testing-Team Member' AND "CanView" = 1
    LIMIT 5
""")
print('\nSample Testing-Team Member rows:')
for r in cur.fetchall():
    print(" ", r)

conn.close()
