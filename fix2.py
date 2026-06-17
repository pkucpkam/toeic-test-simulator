import re
with open(r'f:\Project\toeic-test-simulator\database\script-migration\generate_postgres_db.py', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('val = str(val).strip().replace(\"\\\\n\", \"\\n\")', 'val = str(val).strip().replace(\"\\\\n\", \"\\n\").replace(\"\\\\\", \"\")')

with open(r'f:\Project\toeic-test-simulator\database\script-migration\generate_postgres_db.py', 'w', encoding='utf-8') as f:
    f.write(text)
