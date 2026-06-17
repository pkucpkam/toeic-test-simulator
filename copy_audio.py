import os
import shutil
import glob

base_dir = r"f:\Project\toeic-test-simulator\data"
src_dir = os.path.join(base_dir, "downloads_by_part")
dest_dir = os.path.join(base_dir, "downloads")

# Iterate over all mp3 files in downloads_by_part
for root, dirs, files in os.walk(src_dir):
    for file in files:
        if file.endswith(".mp3"):
            src_path = os.path.join(root, file)
            # root format: data\downloads_by_part\2022\test1\part1\audio
            # we want to extract year and test from root
            rel_path = os.path.relpath(src_path, src_dir)
            parts = rel_path.split(os.sep)
            # parts = ["2022", "test1", "part1", "audio", "test1_question_1.mp3"]
            if len(parts) >= 5:
                year = parts[0]
                test = parts[1]
                
                # Dest directory: data\downloads\2022\test1\audio
                target_audio_dir = os.path.join(dest_dir, year, test, "audio")
                os.makedirs(target_audio_dir, exist_ok=True)
                
                dest_path = os.path.join(target_audio_dir, file)
                if not os.path.exists(dest_path):
                    shutil.copy2(src_path, dest_path)
                    print(f"Copied {file} to {target_audio_dir}")

print("Done copying audio files.")
