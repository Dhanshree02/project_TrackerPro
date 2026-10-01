import psycopg2

conn = psycopg2.connect('postgresql://postgres:clockit@10.50.30.189:5432/trackerpro')
cur = conn.cursor()
cur.execute('SELECT "Id", "Name", "DisplayName", "Permissions" FROM roles WHERE "Name" ILIKE %s', ('%testing%team%member%',))
for row in cur.fetchall():
    print("Role:", row[1], "DisplayName:", row[2])
    print("Permissions:", row[3])
