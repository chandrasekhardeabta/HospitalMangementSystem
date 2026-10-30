import sqlite3

con = sqlite3.connect(':memory:')
cur = con.cursor()

with open('backend/schema.sql', 'r', encoding='utf-8') as f:
    cur.executescript(f.read())

with open('backend/seeds.sql', 'r', encoding='utf-8') as f:
    cur.executescript(f.read())

tables = [r[0] for r in cur.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
print("SUCCESSFULLY INITIALIZED SQLITE SCHEMA & SEEDS!")
print("Tables:", tables)

for t in ['users', 'departments', 'doctors', 'patients', 'appointments', 'clinical_records', 'invoices', 'invoice_items', 'hospital_beds']:
    cnt = cur.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
    print(f"Table '{t}': {cnt} records")
