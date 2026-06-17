import csv
import os

BASE_DIR = r"f:\Project\toeic-test-simulator\data\downloads"
OUTPUT_SQL = r"f:\Project\toeic-test-simulator\database\script-migration\seed_postgres.sql"

def escape_sql(val):
    if val is None or str(val).strip() == "":
        return "NULL"
    # Convert literal \n string to actual newline
    val = str(val).strip().replace("\\n", "\n").replace("\\", "")
    # Escape single quotes for SQL
    val = val.replace("'", "''")
    return f"'{val}'"

def safe_get(row, keys):
    for k in keys:
        if k in row and row[k] is not None:
            return str(row[k]).strip()
    return ""

def main():
    os.makedirs(os.path.dirname(OUTPUT_SQL), exist_ok=True)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as out:
        # 1. Schema definition for PostgreSQL
        out.write("-- =========================================\n")
        out.write("-- PostgreSQL Database Schema for TOEIC App\n")
        out.write("-- =========================================\n")
        out.write("DROP TABLE IF EXISTS user_bookmarks CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS user_incorrect_questions CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS user_answers CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS test_attempts CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS users CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS questions CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS question_groups CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS test_parts CASCADE;;\n")
        out.write("DROP TABLE IF EXISTS tests CASCADE;\n\n")

        out.write("CREATE TABLE users (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    email VARCHAR(255) UNIQUE NOT NULL,\n")
        out.write("    password_hash VARCHAR(255) NOT NULL,\n")
        out.write("    full_name VARCHAR(255),\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE tests (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    title VARCHAR(255) NOT NULL,\n")
        out.write("    year INT,\n")
        out.write("    full_audio_url VARCHAR(500),\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE test_parts (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    test_id INT REFERENCES tests(id) ON DELETE CASCADE,\n")
        out.write("    part_number INT NOT NULL,\n")
        out.write("    name VARCHAR(255),\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE question_groups (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    test_part_id INT REFERENCES test_parts(id) ON DELETE CASCADE,\n")
        out.write("    audio_url VARCHAR(500),\n")
        out.write("    image_url VARCHAR(500),\n")
        out.write("    passage_text TEXT,\n")
        out.write("    transcript TEXT,\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE questions (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    question_group_id INT REFERENCES question_groups(id) ON DELETE CASCADE,\n")
        out.write("    question_number INT NOT NULL,\n")
        out.write("    question_text TEXT,\n")
        out.write("    option_a TEXT,\n")
        out.write("    option_b TEXT,\n")
        out.write("    option_c TEXT,\n")
        out.write("    option_d TEXT,\n")
        out.write("    correct_answer VARCHAR(5) NOT NULL,\n")
        out.write("    explanation TEXT,\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE test_attempts (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    user_id INT REFERENCES users(id) ON DELETE CASCADE,\n")
        out.write("    attempt_type VARCHAR(50) NOT NULL CHECK (attempt_type IN ('FULL', 'PART')),\n")
        out.write("    test_id INT REFERENCES tests(id) ON DELETE CASCADE,\n")
        out.write("    test_part_id INT REFERENCES test_parts(id) ON DELETE CASCADE,\n")
        out.write("    listening_score INT,\n")
        out.write("    reading_score INT,\n")
        out.write("    total_score INT,\n")
        out.write("    total_correct INT,\n")
        out.write("    total_incorrect INT,\n")
        out.write("    total_unanswered INT,\n")
        out.write("    duration_seconds INT,\n")
        out.write("    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n")
        out.write("    completed_at TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE user_answers (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    attempt_id INT REFERENCES test_attempts(id) ON DELETE CASCADE,\n")
        out.write("    question_id INT REFERENCES questions(id) ON DELETE CASCADE,\n")
        out.write("    selected_option CHAR(1),\n")
        out.write("    is_correct BOOLEAN\n")
        out.write(");\n\n")

        out.write("CREATE TABLE user_incorrect_questions (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    user_id INT REFERENCES users(id) ON DELETE CASCADE,\n")
        out.write("    question_id INT REFERENCES questions(id) ON DELETE CASCADE,\n")
        out.write("    attempt_id INT REFERENCES test_attempts(id) ON DELETE CASCADE,\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        out.write("CREATE TABLE user_bookmarks (\n")
        out.write("    id SERIAL PRIMARY KEY,\n")
        out.write("    user_id INT REFERENCES users(id) ON DELETE CASCADE,\n")
        out.write("    question_id INT REFERENCES questions(id) ON DELETE CASCADE,\n")
        out.write("    note TEXT,\n")
        out.write("    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n")
        out.write(");\n\n")

        # 2. Data Insertion
        out.write("-- =========================================\n")
        out.write("-- Insert Data\n")
        out.write("-- =========================================\n\n")

        test_id_counter = 1
        part_id_counter = 1
        group_id_counter = 1
        question_id_counter = 1
        
        part_names = [
            "Photographs", "Question-Response", "Conversations", "Talks",
            "Incomplete Sentences", "Text Completion", "Reading Comprehension"
        ]

        if os.path.exists(BASE_DIR):
            for year in sorted(os.listdir(BASE_DIR)):
                year_path = os.path.join(BASE_DIR, year)
                if not os.path.isdir(year_path): continue
                
                for test_folder in sorted(os.listdir(year_path), key=lambda x: int(x.replace('test', '')) if 'test' in x else 0):
                    test_path = os.path.join(year_path, test_folder)
                    if not os.path.isdir(test_path): continue
                    
                    csv_dir = os.path.join(test_path, "csv")
                    if not os.path.exists(csv_dir): continue

                    full_audio_url = "NULL"
                    audio_dir = os.path.join(test_path, "audio")
                    if os.path.exists(audio_dir):
                        audio_files = [f for f in os.listdir(audio_dir) if f.endswith('.mp3')]
                        if audio_files:
                            full_audio_url = f"'{year}/{test_folder}/audio/{audio_files[0]}'"
                    
                    title = f"{year} {test_folder.capitalize()}"
                    out.write(f"-- Insert Test {title}\n")
                    out.write(f"INSERT INTO tests (id, title, year, full_audio_url) VALUES ({test_id_counter}, '{title}', {year}, {full_audio_url});\n\n")
                    
                    out.write(f"-- Insert Parts for {title}\n")
                    for i, name in enumerate(part_names):
                        out.write(f"INSERT INTO test_parts (id, test_id, part_number, name) VALUES ({part_id_counter + i}, {test_id_counter}, {i+1}, '{name}');;\n")
                    out.write("\n")
                    
                    for part_num in range(1, 8):
                        file_path = os.path.join(csv_dir, f"{test_folder}-part{part_num}.csv")
                        if not os.path.exists(file_path):
                            continue
                        
                        test_part_id = part_id_counter + part_num - 1
                        
                        out.write(f"-- Data for {title} Part {part_num}\n")
                        with open(file_path, "r", encoding="utf-8-sig") as f:
                            reader = csv.DictReader(f, delimiter=';')
                            if reader.fieldnames:
                                reader.fieldnames = [k.strip() for k in reader.fieldnames]
                            else:
                                continue
                            
                            current_group_id = None
                            
                            for row in reader:
                                if not any(row.values()): continue
                                    
                                q_num = safe_get(row, ['Question Number'])
                                if not q_num.isdigit(): continue
                                    
                                audio = safe_get(row, ['Audio'])
                                image = safe_get(row, ['Image'])
                                text = safe_get(row, ['Text'])
                                transcript = safe_get(row, ['Transcript'])
                                
                                if audio:
                                    audio = f"{year}/{test_folder}/audio/{audio}"
                                if image:
                                    image = f"{year}/{test_folder}/image/{image}"
                                
                                question_txt = safe_get(row, ['Question'])
                                opt_a = safe_get(row, ['A'])
                                opt_b = safe_get(row, ['B'])
                                opt_c = safe_get(row, ['C'])
                                opt_d = safe_get(row, ['D'])
                                ans = safe_get(row, ['Answer'])
                                if ans.startswith('(') and ans.endswith(')'):
                                    ans = ans[1:-1]
                                explain = safe_get(row, ['Explain'])
                                
                                is_new_group = False
                                if part_num == 5:
                                    is_new_group = True
                                else:
                                    if audio or image or text or transcript:
                                        is_new_group = True
                                    if current_group_id is None:
                                        is_new_group = True
                                        
                                if is_new_group:
                                    current_group_id = group_id_counter
                                    group_id_counter += 1
                                    out.write(f"INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) ")
                                    out.write(f"VALUES ({current_group_id}, {test_part_id}, {escape_sql(audio)}, {escape_sql(image)}, {escape_sql(text)}, {escape_sql(transcript)});;\n")
                                
                                out.write(f"INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) ")
                                out.write(f"VALUES ({question_id_counter}, {current_group_id}, {q_num}, {escape_sql(question_txt)}, {escape_sql(opt_a)}, {escape_sql(opt_b)}, {escape_sql(opt_c)}, {escape_sql(opt_d)}, {escape_sql(ans)}, {escape_sql(explain)});;\n")
                                
                                question_id_counter += 1
                        out.write("\n")
                    
                    test_id_counter += 1
                    part_id_counter += 7

        # Reset sequences for serial primary keys
        out.write("-- Reset Sequences\n")
        out.write(f"SELECT setval('tests_id_seq', (SELECT MAX(id) FROM tests));;\n")
        out.write(f"SELECT setval('test_parts_id_seq', (SELECT MAX(id) FROM test_parts));;\n")
        out.write(f"SELECT setval('question_groups_id_seq', (SELECT MAX(id) FROM question_groups));;\n")
        out.write(f"SELECT setval('questions_id_seq', (SELECT MAX(id) FROM questions));;\n")
        
        print(f"Generated PostgreSQL seed file successfully at: {OUTPUT_SQL}")

if __name__ == '__main__':
    main()
