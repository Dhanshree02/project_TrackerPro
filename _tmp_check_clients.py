import psycopg2

conn = psycopg2.connect(
    host="10.50.30.189", port=5432, dbname="trackerpro",
    user="postgres", password="clockit",
)
cur = conn.cursor()
cur.execute("SELECT COUNT(*) FROM clients")
print("Total clients in DB:", cur.fetchone()[0])
cur.execute("""
    SELECT "Name", "Id", "CreatedAtUtc"
    FROM clients
    WHERE "Name" ILIKE '%cust%' OR "Name" ILIKE '%test%'
    ORDER BY "CreatedAtUtc" DESC
    LIMIT 20
""")
rows = cur.fetchall()
print(f"\nMatching 'cust' or 'test' ({len(rows)}):")
for r in rows:
    print(f"  {r[0]} | {r[1]} | {r[2]}")
cur.execute("""
    SELECT "Name", "Id", "CreatedAtUtc"
    FROM clients
    ORDER BY "CreatedAtUtc" DESC
    LIMIT 5
""")
print("\nLatest 5 clients:")
for r in cur.fetchall():
    print(f"  {r[0]} | {r[1]} | {r[2]}")
conn.close()
