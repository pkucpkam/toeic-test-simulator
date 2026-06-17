import re
with open(r'f:\Project\toeic-test-simulator\backend\practice\src\main\resources\db\migration\V2__init_schema.sql', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('selected_option CHAR(1),', 'selected_option VARCHAR(5),')

with open(r'f:\Project\toeic-test-simulator\backend\practice\src\main\resources\db\migration\V2__init_schema.sql', 'w', encoding='utf-8') as f:
    f.write(text)
