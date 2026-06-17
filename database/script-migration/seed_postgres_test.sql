-- =========================================
-- PostgreSQL Database Schema for TOEIC App
-- =========================================
DROP TABLE IF EXISTS user_bookmarks CASCADE;
DROP TABLE IF EXISTS user_incorrect_questions CASCADE;
DROP TABLE IF EXISTS user_answers CASCADE;
DROP TABLE IF EXISTS test_attempts CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS question_groups CASCADE;
DROP TABLE IF EXISTS test_parts CASCADE;
DROP TABLE IF EXISTS tests CASCADE;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tests (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    year INT,
    full_audio_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE test_parts (
    id SERIAL PRIMARY KEY,
    test_id INT REFERENCES tests(id) ON DELETE CASCADE,
    part_number INT NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE question_groups (
    id SERIAL PRIMARY KEY,
    test_part_id INT REFERENCES test_parts(id) ON DELETE CASCADE,
    audio_url VARCHAR(500),
    image_url VARCHAR(500),
    passage_text TEXT,
    transcript TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    question_group_id INT REFERENCES question_groups(id) ON DELETE CASCADE,
    question_number INT NOT NULL,
    question_text TEXT,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_answer CHAR(1) NOT NULL,
    explanation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE test_attempts (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    attempt_type VARCHAR(50) NOT NULL CHECK (attempt_type IN ('FULL', 'PART')),
    test_id INT REFERENCES tests(id) ON DELETE CASCADE,
    test_part_id INT REFERENCES test_parts(id) ON DELETE CASCADE,
    listening_score INT,
    reading_score INT,
    total_score INT,
    total_correct INT,
    total_incorrect INT,
    total_unanswered INT,
    duration_seconds INT,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE user_answers (
    id SERIAL PRIMARY KEY,
    attempt_id INT REFERENCES test_attempts(id) ON DELETE CASCADE,
    question_id INT REFERENCES questions(id) ON DELETE CASCADE,
    selected_option CHAR(1),
    is_correct BOOLEAN
);

CREATE TABLE user_incorrect_questions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    question_id INT REFERENCES questions(id) ON DELETE CASCADE,
    attempt_id INT REFERENCES test_attempts(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_bookmarks (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    question_id INT REFERENCES questions(id) ON DELETE CASCADE,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- Insert Data
-- =========================================

-- Insert Test 2022 Test1
INSERT INTO tests (id, title, year, full_audio_url) VALUES (1, '2022 Test1', 2022, '2022-test1.mp3');

-- Insert Parts for 2022 Test1
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (1, 1, 1, 'Photographs');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (2, 1, 2, 'Question-Response');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (3, 1, 3, 'Conversations');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (4, 1, 4, 'Talks');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (5, 1, 5, 'Incomplete Sentences');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (6, 1, 6, 'Text Completion');
INSERT INTO test_parts (id, test_id, part_number, name) VALUES (7, 1, 7, 'Reading Comprehension');

-- Data for 2022 Test1 Part 1
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (1, 1, 'test1_question_1.mp3', 'test1-image-1.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (1, 1, 1, NULL, 'He''s parking a truck', 'He''s lifting some furniture', 'He''s starting an engine', 'He''s driving a car', 'B', 'A. Anh ấy đang đậu một chiếc xe tải
B. Anh ấy đang nâng một số đồ nội thất
C. Anh ấy đang khởi động một động cơ
D. Anh ấy đang lái một chiếc ô tô');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (2, 1, 'test1_question_2.mp3', 'test1-image-2.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (2, 2, 2, NULL, 'Some curtains have been closed', 'Some jackets have been laid on a chair', 'Some people are gathered around a desk', 'Someone is turning on a lamp', 'C', 'A. Một số rèm đã bị đóng lại
B. Một số áo khoác đã được đặt trên ghế
C. Một số người đang tụ tập quanh bàn làm việc
D. Ai đó đang bật đèn lamp');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (3, 1, 'test1_question_3.mp3', 'test1-image-3.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (3, 3, 3, NULL, 'One of the women is reaching into her bag', 'The women are waiting in a line', 'The man is leading a tour group', 'The man is opening a cash register', 'B', 'A. Một trong những người phụ nữ đang cúi xuống túi xách của mình
B. Các phụ nữ đang đợi xếp hàng
C. Người đàn ông đang dẫn một nhóm tham quan
D. Người đàn ông đang mở một quầy tiền');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (4, 1, 'test1_question_4.mp3', 'test1-image-4.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (4, 4, 4, NULL, 'The man is bending over a bicycle', 'A wheel has been propped against a stack of bricks', 'The man is collecting some pieces of wood', 'A handrail is being installed', 'A', 'A. Người đàn ông đang cúi người xuống một chiếc xe đạp
B. Một bánh xe đã được dựa vào một chồng gạch
C. Người đàn ông đang thu thập một số mảnh gỗ
D. Một lan can đang được lắp đặt');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (5, 1, 'test1_question_5.mp3', 'test1-image-5.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (5, 5, 5, NULL, 'An armchair has been placed under a window', 'Some reading materials have fallen on the floor', 'Some flowers are being watered', 'Some picture frames are hanging on a wall', 'D', 'A. Một chiếc ghế bành đã được đặt dưới cửa sổ
B. Một số tài liệu đọc đã rơi xuống sàn nhà
C. Một số hoa đang được tưới nước
D. Một số khung tranh đang treo trên tường');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (6, 1, 'test1_question_6.mp3', 'test1-image-6.jpg', NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (6, 6, 6, NULL, 'She''s adjusting the height of an umbrella', 'She''s inspecting the tires on a vending cart', 'There''s a mobile food stand on a walkway', 'There are some cooking utensils on the ground', 'C', 'A. Cô ấy đang điều chỉnh chiều cao của một chiếc ô
B. Cô ấy đang kiểm tra lốp xe trên một xe bán hàng
C. Có một quầy thức ăn di động trên lối đi bộ
D. Có một số dụng cụ nấu ăn trên mặt đất');

-- Data for 2022 Test1 Part 2
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (7, 2, 'test1_question_7.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (7, 7, 7, 'Why was this afternoon''s meeting canceled?', 'Room 206, I think', 'Because the manager is out of the office', 'Let''s review the itinerary for our trip.', NULL, 'B', 'Câu hỏi: Tại sao cuộc họp chiều nay bị hủy?
A. Phòng 206, tôi nghĩ vậy.
B. Bởi vì quản lý không có mặt tại văn phòng.
C. Hãy xem lại lịch trình cho chuyến đi của chúng ta.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (8, 2, 'test1_question_8.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (8, 8, 8, 'You use the company fitness center, don''t you?', 'Yes, every now and then.', 'Please center the text on the page', 'I think it fits you well', NULL, 'A', 'Câu hỏi: Bạn sử dụng trung tâm thể dục của công ty, phải không?
A. Vâng, thỉnh thoảng.
B. Làm ơn căn giữa văn bản trên trang.
C. Tôi nghĩ nó phù hợp với bạn.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (9, 2, 'test1_question_9.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (9, 9, 9, 'Do you have the images from the graphics department?', 'OK, that won''t be a problem', 'A high-definition camera', 'No, they''re not ready yet', NULL, 'C', 'Câu hỏi: Bạn có hình ảnh từ bộ phận đồ họa không?
A. OK, điều đó sẽ không thành vấn đề.
B. Một chiếc máy ảnh độ nét cao.
C. Không, chúng vẫn chưa sẵn sàng.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (10, 2, 'test1_question_10.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (10, 10, 10, 'When are you moving to your new office?', 'The office printer over there.', 'The water bill is high this month.', 'The schedule is being revised.', NULL, 'C', 'Câu hỏi: Khi nào bạn chuyển đến văn phòng mới của mình?
A. Máy in văn phòng ở kia.
B. Hóa đơn nước tháng này cao.
C. Lịch trình đang được sửa đổi.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (11, 2, 'test1_question_11.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (11, 11, 11, 'Would you like to sign up for the company retreat?', 'Sure, I''ll write my name down', 'Twenty people, maximum', 'Can I replace the sign', NULL, 'A', 'Câu hỏi: Bạn có muốn đăng ký tham gia buổi nghỉ dưỡng của công ty không?
A. Chắc chắn, tôi sẽ ghi tên mình xuống.
B. Hai mươi người, tối đa.
C. Tôi có thể thay thế biển hiệu không?');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (12, 2, 'test1_question_12.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (12, 12, 12, 'How often do I have to submit my time sheet?', 'Five sheets of paper', 'You need to do it once a week', 'No, I don''t usually wear a watch', NULL, 'B', 'Câu hỏi: Tôi phải nộp bảng chấm công của mình bao nhiêu lần?
A. Năm tờ giấy.
B. Bạn cần làm điều đó mỗi tuần một lần.
C. Không, tôi thường không đeo đồng hồ.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (13, 2, 'test1_question_13.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (13, 13, 13, 'I can buy a monthly gym membership, right?', 'A very popular exercise routine.', 'The exercise room is on your right', 'Yes, at the front desk', NULL, 'C', 'Câu hỏi: Tôi có thể mua thẻ thành viên phòng tập gym hàng tháng, phải không?
A. Một chế độ tập luyện rất phổ biến.
B. Phòng tập nằm ở bên phải bạn.
C. Vâng, tại quầy lễ tân.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (14, 2, 'test1_question_14.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (14, 14, 14, 'Have you put price tags on all the clearance items?', 'Yes, everything''s been labeled.', 'It is a little cloudy', 'Where is your name tag?', NULL, 'A', 'Câu hỏi: Bạn đã dán nhãn giá cho tất cả các mặt hàng giảm giá chưa?
A. Vâng, mọi thứ đã được dán nhãn.
B. Trời hơi nhiều mây.
C. Thẻ tên của bạn ở đâu?');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (15, 2, 'test1_question_15.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (15, 15, 15, 'Don''t we still need to change the newspaper layout?', 'Down the hall on your right', 'No, it''s already been changed', 'A new computer program.', NULL, 'B', 'Câu hỏi: Chẳng phải chúng ta vẫn cần thay đổi bố cục báo chí sao?
A. Hành lang bên phải bạn.
B. Không, nó đã được thay đổi rồi.
C. Một chương trình máy tính mới.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (16, 2, 'test1_question_16.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (16, 16, 16, 'What''s the total cost of the repair work?', 'It''s free because of the warranty', 'I have some boxes you can use', 'In a couple of hours', NULL, 'A', 'Câu hỏi: Tổng chi phí của công việc sửa chữa là bao nhiêu?
A. Nó miễn phí vì bảo hành.
B. Tôi có một số hộp bạn có thể sử dụng.
C. Trong vài giờ nữa.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (17, 2, 'test1_question_17.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (17, 17, 17, 'Where can I get a new filing cabinet?', 'All of the cabins have been rented', 'I''ll put the tiles in the corner', 'All furniture requests must be approved first.', NULL, 'C', 'Câu hỏi: Tôi có thể mua tủ hồ sơ mới ở đâu?
A. Tất cả các cabin đã được thuê.
B. Tôi sẽ đặt gạch ở góc.
C. Tất cả các yêu cầu về đồ nội thất phải được phê duyệt trước.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (18, 2, 'test1_question_18.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (18, 18, 18, 'How do I reset my password?', 'By the end of the month', 'You should call the help desk', 'Thanks for setting the table', NULL, 'B', 'Câu hỏi: Làm thế nào để tôi đặt lại mật khẩu?
A. Đến cuối tháng.
B. Bạn nên gọi bộ phận hỗ trợ.
C. Cảm ơn vì đã dọn bàn.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (19, 2, 'test1_question_19.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (19, 19, 19, 'Could you check to see if that monitor is plugged in?', 'I didn''t send them yet', 'A longer power cord', 'Do you want me to check them all?', NULL, 'C', 'Câu hỏi: Bạn có thể kiểm tra xem màn hình đó đã được cắm chưa?
A. Tôi vẫn chưa gửi chúng.
B. Một dây nguồn dài hơn.
C. Bạn có muốn tôi kiểm tra tất cả không?');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (20, 2, 'test1_question_20.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (20, 20, 20, 'Is the new inventory process more efficient?', 'It only took me an hour', 'Yes, she''s new here', 'Yes, I''ll have the fish', NULL, 'A', 'Câu hỏi: Quy trình kiểm kê mới có hiệu quả hơn không?
A. Nó chỉ mất một giờ.
B. Vâng, cô ấy mới ở đây.
C. Vâng, tôi sẽ có cá.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (21, 2, 'test1_question_21.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (21, 21, 21, 'Would you like some ice cream or cake for dessert?', 'Because I''m hungry', 'Yes, I liked it', 'I''m trying to avoid sugar', NULL, 'C', 'Câu hỏi: Bạn có muốn kem hoặc bánh ngọt làm tráng miệng không?
A. Bởi vì tôi đói.
B. Vâng, tôi đã thích nó.
C. Tôi đang cố tránh đường.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (22, 2, 'test1_question_22.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (22, 22, 22, 'Who''s doing the product demonstration this afternoon?', 'That bus station is closed, sorry', 'I''m leaving for New York at lunchtime', 'Let me show you a few more', NULL, 'B', 'Câu hỏi: Ai sẽ thực hiện buổi trình diễn sản phẩm chiều nay?
A. Trạm xe buýt đó đã đóng cửa, xin lỗi.
B. Tôi sẽ đi New York vào giờ ăn trưa.
C. Để tôi cho bạn xem thêm một vài cái.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (23, 2, 'test1_question_23.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (23, 23, 23, 'Your presentation''s being reviewed at today''s manager''s meeting.', 'I didn''t have much time to complete it', 'Next slide, please', 'That movie had great reviews', NULL, 'A', 'Câu hỏi: Bài thuyết trình của bạn đang được xem xét tại cuộc họp của quản lý hôm nay.
A. Tôi không có nhiều thời gian để hoàn thành nó.
B. Trang tiếp theo, làm ơn.
C. Bộ phim đó nhận được những đánh giá tuyệt vời.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (24, 2, 'test1_question_24.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (24, 24, 24, 'Don''t you carry these shoes in red?', 'I''ll lift from this end', 'There''s a new shipment coming tomorrow', 'I have time to read it now', NULL, 'B', 'Câu hỏi: Chẳng phải bạn mang những đôi giày này màu đỏ sao?
A. Tôi sẽ nâng từ đầu này.
B. Có một lô hàng mới đến vào ngày mai.
C. Tôi có thời gian để đọc nó bây giờ.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (25, 2, 'test1_question_25.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (25, 25, 25, 'Would you like to have lunch with the clients?', 'About a three-hour flight', 'The first stage of the project', 'Sure, we can go to the café downstairs', NULL, 'C', 'Câu hỏi: Bạn có muốn ăn trưa với khách hàng không?
A. Khoảng một chuyến bay ba giờ.
B. Giai đoạn đầu tiên của dự án.
C. Chắc chắn, chúng ta có thể đi đến quán cà phê phía dưới.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (26, 2, 'test1_question_26.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (26, 26, 26, 'How about hiring an event planner to organize the holiday party?', 'I think it''s on the lower shelf', 'Sure, I''d love to attend', 'There''s not much money in the budget', NULL, 'C', 'Câu hỏi: Thế nào nếu thuê một nhà lập kế hoạch sự kiện để tổ chức bữa tiệc lễ hội?
A. Tôi nghĩ nó ở kệ thấp hơn.
B. Chắc chắn, tôi rất muốn tham dự.
C. Ngân sách không có nhiều tiền.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (27, 2, 'test1_question_27.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (27, 27, 27, 'Isn''t that carmaker planning to start exporting electric cars?', 'Yes, I''ve heard that''s the plan', 'A ticket to next year''s car show', 'Congratulations on your promotion!', NULL, 'A', 'Câu hỏi: Chẳng phải nhà sản xuất ô tô đó đang lên kế hoạch xuất khẩu xe điện sao?
A. Vâng, tôi đã nghe đó là kế hoạch.
B. Một vé đến triển lãm ô tô năm tới.
C. Chúc mừng bạn được thăng chức!');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (28, 2, 'test1_question_28.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (28, 28, 28, 'David trained the interns to use the company database, didn''t he?', 'Actually, it was Hillary', 'An internal audit', 'He''s good company', NULL, 'A', 'Câu hỏi: David đã đào tạo các thực tập sinh sử dụng cơ sở dữ liệu của công ty, phải không?
A. Thực ra, đó là Hillary.
B. Một cuộc kiểm toán nội bộ.
C. Anh ấy là công ty tốt.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (29, 2, 'test1_question_29.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (29, 29, 29, 'Who''s responsible for researching the housing market in India?', 'The senior director is heading up that team', 'Every morning at ten o''clock', 'Yes, It''s on Main Street', NULL, 'A', 'Câu hỏi: Ai chịu trách nhiệm nghiên cứu thị trường nhà ở ở Ấn Độ?
A. Giám đốc cấp cao đang dẫn đầu nhóm đó.
B. Mỗi sáng lúc mười giờ.
C. Vâng, nó ở phố Main.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (30, 2, 'test1_question_30.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (30, 30, 30, 'Have you arranged a ride to take us to the convention center, or should I?', 'Unfortunately, there isn''t an extra bag', 'I don''t have the phone number for the taxi service', 'We''ve accepted credit cards before.', NULL, 'B', 'Câu hỏi: Bạn đã sắp xếp một chuyến đi đưa chúng ta đến trung tâm hội nghị chưa, hay tôi nên làm?
A. Thật không may, không có túi thêm.
B. Tôi không có số điện thoại của dịch vụ taxi.
C. Chúng tôi đã nhận thẻ tín dụng trước đây.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (31, 2, 'test1_question_31.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (31, 31, 31, 'These purchases should have entered on your expense report.', 'No thanks, I don''t need anything from the store.', 'The entrance is on Thirty-First Street', 'I thought I had until Friday to do that', NULL, 'C', 'Câu hỏi: Những mua sắm này lẽ ra đã được ghi vào báo cáo chi phí của bạn.
A. Không cảm ơn, tôi không cần gì từ cửa hàng.
B. Lối vào ở phố Thirty-First.
C. Tôi nghĩ tôi có thời hạn đến thứ Sáu để làm điều đó.');

-- Data for 2022 Test1 Part 3
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (32, 3, 'test1_question_32_34.mp3', NULL, 'W: Hi, it''s Marnita from Accounting. I''d like to reserve the main conference room for a meeting I''ll be leading on Friday with colleagues from our New York office.
M: Sure, that shouldn''t be a problem. What time is the meeting?
W: It''s from nine to eleven AM
M: OK - I''ll block off that time slot for you. Do you need any special equipment besides a laptop and project?
W: No, but I''ll need the key so I can go ina little early and set up. Can I pick that up on Friday morning?
M: Absolutely.', 'W: Xin chào, tôi là Marnita từ Kế toán. Tôi muốn đặt phòng hội nghị chính cho một cuộc họp mà tôi sẽ chủ trì vào thứ Sáu với các đồng nghiệp từ văn phòng New York của chúng tôi.
M: Chắc chắn rồi, đó không phải là vấn đề. Cuộc họp diễn ra lúc mấy giờ? 
W: Từ chín giờ đến mười một giờ sáng
M: OK - Tôi sẽ dành khoảng thời gian đó cho bạn. Bạn có cần bất kỳ thiết bị đặc biệt nào ngoài máy tính xách tay và dự án không? 
W: Không, nhưng tôi sẽ cần chìa khóa để có thể đến sớm một chút và thiết lập. Tôi có thể lấy nó vào sáng thứ Sáu không? 
M: Chắc chắn rồi.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (32, 32, 32, 'What is the woman preparing for?', 'A move to a new city', 'A business trip', 'A building tour', 'A meeting with visiting colleagues', 'D', 'Đáp án đúng là D (A meeting with visiting colleagues) vì:
1. Trong đoạn hội thoại, người phụ nữ nói "I''d like to reserve the main conference room for a meeting I''ll be leading on Friday with colleagues from our New York office" (Tôi muốn đặt phòng họp chính cho một cuộc họp tôi sẽ chủ trì vào thứ Sáu với các đồng nghiệp từ văn phòng New York).
2. Điều này cho thấy rõ ràng cô ấy đang chuẩn bị cho một cuộc họp với các đồng nghiệp đến thăm từ văn phòng khác.
3. Các đáp án khác không phù hợp với thông tin trong đoạn hội thoại:
A. Không được đề cập.
B. Cô ấy không đi đâu, mà đang tổ chức cuộc họp tại văn phòng của mình.
C. Không được đề cập.
Dịch các đáp án:
A. Chuyển đến một thành phố mới
B. Một chuyến công tác
C. Một chuyến tham quan tòa nhà
D. Một cuộc họp với các đồng nghiệp đến thăm');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (33, 3, 'test1_question_32_34.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (33, 33, 33, 'Who most likely is the man?', 'An accountant', 'An administrative assistant', 'A marketing director', 'A company president', 'B', 'Đáp án đúng là B (An administrative assistant) vì:
1. Người đàn ông trong đoạn hội thoại đang thực hiện các nhiệm vụ điển hình của một trợ lý hành chính:
- Giúp đặt phòng họp: "Sure, that shouldn''t be a problem. What time is the meeting?"
- Lên lịch cho phòng họp: "OK - I''ll block off that time slot for you."
- Hỗ trợ về thiết bị: "Do you need any special equipment besides a laptop and project?"
- Quản lý chìa khóa phòng họp: "Absolutely." (khi được hỏi về việc lấy chìa khóa)
2. Các đáp án khác không phù hợp với vai trò được thể hiện trong đoạn hội thoại:
A. Thường không phụ trách việc đặt phòng họp.
C. Không có dấu hiệu cho thấy người này ở vị trí quản lý cao cấp.
D. Không có khả năng chủ tịch công ty lại thực hiện các nhiệm vụ hành chính như vậy.
Dịch các đáp án:
A. Một kế toán viên
B. Một trợ lý hành chính
C. Một giám đốc tiếp thị
D. Một chủ tịch công ty');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (34, 3, 'test1_question_32_34.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (34, 34, 34, 'What does the woman want to pick up on Friday morning?', 'A building map', 'A room key', 'An ID card', 'A parking pass', 'B', 'Đáp án đúng là B (A room key) vì:
1. Trong đoạn hội thoại, người phụ nữ nói rõ: "I''ll need the key so I can go in a little early and set up. Can I pick that up on Friday morning?" (Tôi sẽ cần chìa khóa để có thể vào sớm một chút và chuẩn bị. Tôi có thể lấy nó vào sáng thứ Sáu được không?)
2. Người đàn ông đồng ý: "Absolutely." (Chắc chắn rồi.)
3. Các đáp án khác không được đề cập trong đoạn hội thoại:
A. Không được nhắc đến.
C. Không được đề cập.
D. Không được nhắc tới.
Dịch các đáp án:
A. Một bản đồ tòa nhà
B. Một chìa khóa phòng
C. Một thẻ nhận dạng
D. Một thẻ đỗ xe');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (35, 3, 'test1_question_35_37.mp3', NULL, 'W: Satoshi, have you already started working on the budget for next year?
M: Not yet... but I do plan to start it in the next day or so.
W: OK, perfect. I''d like to add some new engineers to my team next year if we can afford it. I thought one might be enough, but I realized we''ll probably need three to handle our company''s new contracts.
M: No problem. I can include that in the budget. I''ll just need the details about the positions, including the job titles and expected salaries. Could you send that to me?', 'W: Satoshi, bạn đã bắt đầu làm việc về ngân sách cho năm tới chưa? 
M: Chưa... nhưng tôi dự định bắt đầu vào ngày hôm sau hoặc lâu hơn.
W: OK, hoàn hảo. Tôi muốn thêm một số kỹ sư mới vào nhóm của mình vào năm tới nếu chúng tôi có đủ khả năng. Tôi nghĩ một cái là đủ, nhưng tôi nhận ra chúng tôi có thể sẽ cần ba cái để xử lý các hợp đồng mới của công ty chúng tôi.
M: Không vấn đề gì. Tôi có thể đưa điều đó vào ngân sách. Tôi sẽ chỉ cần thông tin chi tiết về các vị trí, bao gồm chức danh công việc và mức lương dự kiến. Bạn có thể gửi cái đó cho tôi được không?');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (35, 35, 35, 'What task is the man responsible for?', 'Writing a budget', 'Reviewing job applications', 'Organizing a company newsletter', 'Updating an employee handbook', 'A', 'Đáp án đúng là A (Writing a budget) vì:
1. Trong đoạn hội thoại, người phụ nữ hỏi: "Satoshi, have you already started working on the budget for next year?" (Satoshi, anh đã bắt đầu làm ngân sách cho năm tới chưa?)
2. Người đàn ông trả lời: "Not yet... but I do plan to start it in the next day or so." (Chưa... nhưng tôi dự định sẽ bắt đầu trong một hai ngày tới.)
3. Sau đó, anh ta nói: "I can include that in the budget." (Tôi có thể đưa điều đó vào ngân sách.)
Tất cả những điều này chỉ ra rằng người đàn ông có trách nhiệm viết ngân sách.
4. Các đáp án khác không phù hợp với nội dung đoạn hội thoại:
B. Không được đề cập.
C. Không được nhắc tới.
D. Không liên quan đến cuộc trò chuyện.
Dịch các đáp án:
A. Viết một ngân sách
B. Xem xét các đơn xin việc
C. Tổ chức một bản tin công ty
D. Cập nhật một sổ tay nhân viên');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (36, 3, 'test1_question_35_37.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (36, 36, 36, 'What does the woman want to do next year?', 'Organize a trade show', 'Open a new store', 'Redesign a product catalog', 'Hire some team members', 'D', 'Đáp án đúng là D (Hire some team members) vì:
1. Trong đoạn hội thoại, người phụ nữ nói: "I''d like to add some new engineers to my team next year if we can afford it." (Tôi muốn thêm một số kỹ sư mới vào nhóm của tôi vào năm tới nếu chúng ta có đủ khả năng.)
2. Cô ấy còn nói thêm: "I thought one might be enough, but I realized we''ll probably need three to handle our company''s new contracts." (Tôi nghĩ một người có thể đủ, nhưng tôi nhận ra chúng ta có thể cần ba người để xử lý các hợp đồng mới của công ty.)
3. Những câu này chỉ ra rõ ràng ý định thuê thêm nhân viên (cụ thể là kỹ sư) của người phụ nữ.
4. Các đáp án khác không được đề cập trong đoạn hội thoại:
A. Không được nhắc đến.
B. Không liên quan đến nội dung.
C. Không được đề cập.
Dịch các đáp án:
A. Tổ chức một hội chợ thương mại
B. Mở một cửa hàng mới
C. Thiết kế lại một danh mục sản phẩm
D. Thuê một số thành viên nhóm');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (37, 3, 'test1_question_35_37.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (37, 37, 37, 'What does the man ask the woman to do?', 'Order some business cards', 'Write a press release', 'Provide some additional details', 'Set up a meeting time', 'C', 'Đáp án đúng là C (Provide some additional details) vì:
1. Ở cuối đoạn hội thoại, người đàn ông nói: "I''ll just need the details about the positions, including the job titles and expected salaries. Could you send that to me?" (Tôi chỉ cần các chi tiết về các vị trí, bao gồm chức danh công việc và mức lương dự kiến. Bạn có thể gửi cho tôi những thông tin đó được không?)
2. Câu này chỉ ra rõ ràng rằng người đàn ông đang yêu cầu người phụ nữ cung cấp thêm thông tin chi tiết về các vị trí mới mà cô ấy muốn thêm vào ngân sách.
3. Các đáp án khác không phù hợp với nội dung đoạn hội thoại:
A. Không được đề cập.
B. Không liên quan đến cuộc trò chuyện.
D. Không được nhắc tới.
Dịch các đáp án:
A. Đặt một số danh thiếp
B. Viết một thông cáo báo chí
C. Cung cấp một số chi tiết bổ sung
D. Sắp xếp một thời gian họp');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (38, 3, 'test1_question_38_40.mp3', NULL, 'M: Welcome to the Business Suit Outlet. How can I help you?
W: Hello, I''m interviewing for a job next week, and I wanted to buy a new suit.
M: Congratulations! Do you have anything particular in mind?
W: Well, there''s one in your display window that looks nice. But I don''t really like the color...
M: That one only comes in black. But wedo have suits in other colors that arefashionable and appropriate for business. W: OK. I can only spend 150 dollars, andI''d like a style similar to the one in thewindow.
M: Let me show you some suits in that price range. By the way, any alterations needed for the suit are included in the price.', 'M: Chào mừng bạn đến với Business Suit Outlet. Tôi có thể giúp gì cho bạn? 
W: Xin chào, tôi sẽ phỏng vấn xin việc vào tuần tới và tôi muốn mua một bộ đồ mới.
M: Xin chúc mừng! Bạn có suy nghĩ gì đặc biệt không? 
W: Có một cái trong cửa sổ màn hình của bạn trông rất đẹp. Nhưng tôi không thực sự thích màu này...
M: Cái đó chỉ có màu đen. Nhưng chúng tôi có những bộ đồ có màu sắc khác hợp thời trang và phù hợp với công việc. W: Được rồi. Tôi chỉ có thể chi 150 đô la, và tôi muốn một kiểu tương tự như kiểu trong cửa sổ.
M: Để tôi cho bạn xem một số bộ đồ trong phạm vi giá đó. Nhân tiện, bất kỳ thay đổi nào cần thiết cho bộ đồ đều được bao gồm trong giá.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (38, 38, 38, 'What does the woman need a suit for?', 'A job interview', 'A fashion show', 'A family celebration', 'A television appearance', 'A', 'Đáp án đúng là A (A job interview) vì:
1. Trong đoạn hội thoại, người phụ nữ nói rõ: "I''m interviewing for a job next week, and I wanted to buy a new suit." (Tôi có buổi phỏng vấn xin việc vào tuần tới, và tôi muốn mua một bộ suit mới.)
2. Điều này chỉ ra rõ ràng mục đích của cô ấy khi mua suit là cho buổi phỏng vấn xin việc.
3. Các đáp án khác không được đề cập trong đoạn hội thoại và không phù hợp với ngữ cảnh.
Dịch các đáp án:
A. Một buổi phỏng vấn xin việc
B. Một buổi trình diễn thời trang
C. Một lễ kỷ niệm gia đình
D. Một buổi xuất hiện trên truyền hình');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (39, 3, 'test1_question_38_40.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (39, 39, 39, 'What does the woman dislike about a suit on display?', 'The fabric', 'The price', 'The style', 'The color', 'D', 'Đáp án đúng là D (The color) vì:
1. Trong đoạn hội thoại, người phụ nữ nói: "Well, there''s one in your display window that looks nice. But I don''t really like the color..." (Có một bộ trong cửa sổ trưng bày trông rất đẹp. Nhưng tôi không thực sự thích màu sắc...)
2. Câu này chỉ ra rõ ràng rằng màu sắc là điều cô ấy không thích về bộ suit được trưng bày.
3. Người đàn ông cũng xác nhận điều này khi nói: "That one only comes in black." (Bộ đó chỉ có màu đen.)
4. Các đáp án khác không được đề cập là vấn đề trong đoạn hội thoại.
Dịch các đáp án:
A. Chất liệu
B. Giá cả
C. Kiểu dáng
D. Màu sắc');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (40, 3, 'test1_question_38_40.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (40, 40, 40, 'What does the man say that the price includes?', 'Some accessories', 'Alterations', 'Sales tax', 'Delivery', 'B', 'Đáp án đúng là B (Alterations) vì:
1. Ở cuối đoạn hội thoại, người đàn ông nói: "By the way, any alterations needed for the suit are included in the price." (Nhân tiện, bất kỳ sự chỉnh sửa nào cần thiết cho bộ suit đều được bao gồm trong giá.)
2. Điều này chỉ ra rõ ràng rằng giá bao gồm các chỉnh sửa (alterations) cần thiết cho bộ suit.
3. Các đáp án khác không được đề cập là bao gồm trong giá trong đoạn hội thoại.
Dịch các đáp án:
A. Một số phụ kiện
B. Các chỉnh sửa
C. Thuế bán hàng
D. Giao hàng');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (41, 3, 'test1_question_41_43.mp3', NULL, 'W: Ellenville Public Library. How can I help you?
M: Hi, I''m calling from the company Grover and James. We''re interested in filming a scene for a movie in the lobby of the library. Its historic architecture is just what we''re looking for.
W: Well... we actually had a film shoot in our library last year. And the thing is...they said it would take one day and it ended up taking three. I''m concerned that will happen again.
M: I understand, but this is a very short scene.
W: Well, we have a board meeting here next week. I could give you ten minutes at the beginning to give us the details.', 'W: Thư viện công cộng Ellenville. Tôi có thể giúp gì cho bạn?
M: Xin chào, tôi gọi từ công ty Grover và James. Chúng tôi quan tâm đến việc quay một cảnh cho một bộ phim ở sảnh thư viện. Kiến trúc lịch sử của nó chính là thứ chúng tôi đang tìm kiếm.
W: À... thực ra năm ngoái chúng tôi đã có một buổi quay phim trong thư viện của mình. Và vấn đề là...họ nói sẽ mất một ngày và cuối cùng phải mất ba ngày. Tôi lo ngại điều đó sẽ xảy ra lần nữa.
M: Tôi hiểu, nhưng đây là một cảnh rất ngắn.
W: Chà, chúng ta có cuộc họp hội đồng quản trị ở đây vào tuần tới. Tôi có thể cho bạn mười phút lúc đầu để cung cấp cho chúng tôi thông tin chi tiết.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (41, 41, 41, 'What kind of a business does the man most likely work for?', 'A legal consulting firm', 'An architecture firm', 'A film production company', 'A book publishing company', 'C', 'Đáp án đúng là C (A film production company) vì:
1. Người đàn ông nói: "We''re interested in filming a scene for a movie in the lobby of the library" (Chúng tôi muốn quay một cảnh phim trong sảnh của thư viện).
2. Điều này chỉ ra rõ ràng rằng anh ta làm việc cho một công ty sản xuất phim.
3. Các đáp án khác không phù hợp với thông tin trong đoạn hội thoại.
Dịch các đáp án:
A. Một công ty tư vấn pháp lý
B. Một công ty kiến trúc
C. Một công ty sản xuất phim
D. Một công ty xuất bản sách');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (42, 3, 'test1_question_41_43.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (42, 42, 42, 'What does the woman say she is concerned about?', 'The length of a project', 'The cost of an order', 'The opinion of the public', 'The skills of some workers', 'A', 'Đáp án đúng là A (The length of a project) vì:
1. Người phụ nữ nói: "And the thing is...they said it would take one day and it ended up taking three. I''m concerned that will happen again." (Vấn đề là... họ nói sẽ mất một ngày nhưng cuối cùng lại mất ba ngày. Tôi lo lắng điều đó sẽ lặp lại.)
2. Điều này cho thấy cô ấy lo ngại về thời gian kéo dài của dự án quay phim.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Thời gian của một dự án
B. Chi phí của một đơn hàng
C. Ý kiến của công chúng
D. Kỹ năng của một số nhân viên');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (43, 3, 'test1_question_41_43.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (43, 43, 43, 'What does the woman agree to let the man do?', 'Submit an application', 'Speak at a meeting', 'Review some books', 'Measure a space', 'B', 'Đáp án đúng là B (Speak at a meeting) vì:
1. Người phụ nữ nói: "Well, we have a board meeting here next week. I could give you ten minutes at the beginning to give us the details." (Chúng tôi có một cuộc họp hội đồng vào tuần tới. Tôi có thể cho anh 10 phút ở đầu cuộc họp để cung cấp cho chúng tôi thông tin chi tiết.)
2. Điều này cho thấy cô ấy đồng ý cho người đàn ông nói chuyện tại cuộc họp.
3. Các đáp án khác không phù hợp với thông tin trong đoạn hội thoại.
Dịch các đáp án:
A. Nộp một đơn xin
B. Nói chuyện tại một cuộc họp
C. Xem xét một số sách
D. Đo đạc một không gian');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (44, 3, 'test1_question_44_46.mp3', NULL, 'M: Excuse me, I''m looking for Axel Schimidt''s painting titled the Tulips.
W: Unfortunately, his paintings aren''t on display. But it''s just temporary - We''re putting new flooring in that gallery. If you come back in a couple of weeks, the floors will be done, and you can see all of Schmidt''s artwork.
M: Oh, that''s too bad. I really wanted to see that painting.
W: I''m sorry about that. But we sell items featuring that painting in the gift shop. You could buy a souvenir so you could enjoy The Tulips every day!', 'M: Excuse me, I''m looking for Axel Schimidt''s painting titled the Tulips.
W: Unfortunately, his paintings aren''t on display. But it''s just temporary - We''re putting new flooring in that gallery. If you come back in a couple of weeks, the floors will be done, and you can see all of Schmidt''s artwork.
M: Oh, that''s too bad. I really wanted to see that painting.
W: I''m sorry about that. But we sell items featuring that painting in the gift shop. You could buy a souvenir so you could enjoy The Tulips every day!');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (44, 44, 44, 'Who most likely is Axel Schmidt?', 'A store manager', 'A construction worker', 'A journalist', 'An artist', 'D', 'Đáp án đúng là D (An artist) vì:
1. Trong đoạn hội thoại, người đàn ông đang tìm kiếm bức tranh có tên "The Tulips" của Axel Schmidt.
2. Người phụ nữ nói về "Schmidt''s artwork" (tác phẩm nghệ thuật của Schmidt).
3. Điều này ngụ ý rằng Axel Schmidt là một nghệ sĩ, người sáng tạo ra các tác phẩm nghệ thuật.
4. Các đáp án khác không phù hợp với ngữ cảnh của cuộc trò chuyện.
Dịch các đáp án:
A. Một quản lý cửa hàng
B. Một công nhân xây dựng
C. Một nhà báo
D. Một nghệ sĩ');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (45, 3, 'test1_question_44_46.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (45, 45, 45, 'What renovation does the woman mention?', 'Some walls are being painted', 'Some floors are being replaced', 'Some windows are being installed', 'Some light fixtures are being repaired', 'B', 'Đáp án đúng là B (Some floors are being replaced) vì:
1. Người phụ nữ nói: "We''re putting new flooring in that gallery" (Chúng tôi đang lắp đặt sàn mới trong phòng trưng bày đó).
2. Điều này chỉ ra rõ ràng rằng họ đang thay thế sàn nhà.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Một số bức tường đang được sơn
B. Một số sàn nhà đang được thay thế
C. Một số cửa sổ đang được lắp đặt
D. Một số đèn đang được sửa chữa');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (46, 3, 'test1_question_44_46.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (46, 46, 46, 'What does the woman encourage the man to do?', 'Visit a gift shop', 'Send a package', 'Wait for a bus', 'Take a photograph', 'A', 'Đáp án đúng là A (Visit a gift shop) vì:
1. Người phụ nữ nói: "But we sell items featuring that painting in the gift shop. You could buy a souvenir so you could enjoy The Tulips every day!" (Nhưng chúng tôi bán các món đồ có hình bức tranh đó trong cửa hàng quà tặng. Anh có thể mua một món quà lưu niệm để có thể thưởng thức The Tulips mỗi ngày!)
2. Cô ấy khuyến khích người đàn ông ghé thăm cửa hàng quà tặng để mua một món đồ lưu niệm có hình bức tranh.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Ghé thăm một cửa hàng quà tặng
B. Gửi một gói hàng
C. Đợi xe buýt
D. Chụp một bức ảnh');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (47, 3, 'test1_question_47_49.mp3', NULL, 'W: Hey, Dmitry. Are you still working onyour sales report? Collecting all the data from the car dealerships in my region is taking me such a long time. Especially because this year management wants additional information on vehiclepurchases, like model and color...
M: Are you using the sales computation software? That''s what I used for my report, and it worked really well.
W: oh - you already finished it?
M: Well - I''m done collecting andanalyzing the data, but I''m having trouble with the presentation. We didn''t get any guidelines for that.
W: Remember Julie''s presentation last year? It was very impressive. The slides are available on our company intranet.', 'W: Này, Dmitry. Bạn vẫn đang làm việc trên báo cáo bán hàng của mình chứ? Việc thu thập tất cả dữ liệu từ các đại lý xe hơi trong khu vực của tôi đang khiến tôi mất rất nhiều thời gian. Đặc biệt là vì ban quản lý năm nay muốn có thêm thông tin về việc mua xe, như mẫu xe và màu sắc...
M: Bạn có đang sử dụng phần mềm tính toán bán hàng không? Đó là những gì tôi đã sử dụng cho báo cáo của mình và nó hoạt động rất tốt.
W: ồ - bạn đã hoàn thành nó chưa? 
M: Vâng - Tôi đã thu thập và phân tích dữ liệu xong, nhưng tôi đang gặp sự cố với bài thuyết trình. Chúng tôi không nhận được bất kỳ hướng dẫn nào cho việc đó.
W: Bạn có nhớ bài thuyết trình của Julie năm ngoái không? Nó rất ấn tượng. Các trang trình bày có sẵn trên mạng nội bộ của công ty chúng tôi.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (47, 47, 47, 'What does the speakers'' company most likely sell?', 'Electronics', 'Clothing', 'Food', 'Automobiles', 'D', 'Đáp án đúng là D (Automobiles) vì:
1. Người phụ nữ nói: "Collecting all the data from the car dealerships in my region..." (Thu thập tất cả dữ liệu từ các đại lý ô tô trong khu vực của tôi...)
2. Cô ấy cũng đề cập đến "vehicle purchases" (việc mua xe) và "model and color" (kiểu dáng và màu sắc).
3. Những điều này chỉ ra rõ ràng rằng công ty của họ liên quan đến việc bán ô tô.
4. Các đáp án khác không phù hợp với thông tin trong đoạn hội thoại.
Dịch các đáp án:
A. Đồ điện tử
B. Quần áo
C. Thực phẩm
D. Ô tô');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (48, 3, 'test1_question_47_49.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (48, 48, 48, 'Why is the woman surprised?', 'Some software is expensive', 'A color is very bright', 'The man has completed a report', 'The man bought a new car', 'C', 'Đáp án đúng là C (The man has completed a report) vì:
1. Khi người đàn ông nói về việc sử dụng phần mềm tính toán doanh số, người phụ nữ hỏi: "oh - you already finished it?" (Ồ - anh đã hoàn thành nó rồi sao?)
2. Điều này cho thấy cô ấy ngạc nhiên vì người đàn ông đã hoàn thành báo cáo của mình.
3. Các đáp án khác không phù hợp với ngữ cảnh của cuộc trò chuyện.
Dịch các đáp án:
A. Một số phần mềm rất đắt
B. Một màu sắc rất sáng
C. Người đàn ông đã hoàn thành một báo cáo
D. Người đàn ông đã mua một chiếc xe mới');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (49, 3, 'test1_question_47_49.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (49, 49, 49, 'Why does the woman say, "The slides are available on our company intranet"?', 'To request assistance reviewing a document', 'To recommend using a document as a reference', 'To report that a task has been completed', 'To indicate that a file is in the wrong location', 'B', 'Đáp án đúng là B (To recommend using a document as a reference) vì:
1. Người đàn ông nói rằng anh ta đang gặp khó khăn với phần trình bày của báo cáo.
2. Người phụ nữ đề cập đến bài thuyết trình ấn tượng của Julie năm ngoái và nói rằng các slide có sẵn trên mạng nội bộ của công ty.
3. Điều này ngụ ý rằng cô ấy đang đề xuất sử dụng bài thuyết trình đó làm tài liệu tham khảo cho phần trình bày của anh ta.
4. Các đáp án khác không phù hợp với ngữ cảnh của cuộc trò chuyện.
Dịch các đáp án:
A. Để yêu cầu hỗ trợ xem xét một tài liệu
B. Để đề xuất sử dụng một tài liệu làm tham khảo
C. Để báo cáo rằng một nhiệm vụ đã hoàn thành
D. Để chỉ ra rằng một tệp tin đang ở sai vị trí');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (50, 3, 'test1_question_50_52.mp3', NULL, 'W: Thanks for coming in, Omar. You might''ve heard that Rosa Garcia is retiringat the end of November. This means her position as director of information security in Singapore will be vacant. I''d like to know if you''d be interested.
M: Oh! That would be a promotion forme.
Well, hmm. I''ll need a little time to think about it and talk it over with my family. I do have a question. When wouldI start the position?
W: The first week of December ideally. We''d pay for all your moving expenses, ofcourse. If you decide to accept the offer.', 'W: Cảm ơn vì đã đến, Omar. Bạn có thể đã nghe nói rằng Rosa Garcia sẽ nghỉ hưu vào cuối tháng Mười Một. Điều này có nghĩa là vị trí giám đốc bảo mật thông tin tại Singapore của cô ấy sẽ bị bỏ trống. Tôi muốn biết liệu bạn có hứng thú không.
M: Ồ! Đó sẽ là một hình thức thăng chức.
À, hmm. Tôi sẽ cần một chút thời gian để suy nghĩ về nó và nói chuyện với gia đình tôi. Tôi có một câu hỏi. Khi nào tôi sẽ bắt đầu vị trí này? 
W: Lý tưởng nhất là tuần đầu tiên của tháng 12. Tất nhiên, chúng tôi sẽ thanh toán tất cả các chi phí di chuyển của bạn. Nếu bạn quyết định chấp nhận lời đề nghị.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (50, 50, 50, 'According to the woman, what will happen at the end of November?', 'An executive will visit', 'An employee will retire', 'A product will be released', 'A study will be completed', 'B', 'Đáp án đúng là B (An employee will retire) vì:
1. Người phụ nữ nói: "You might''ve heard that Rosa Garcia is retiring at the end of November" (Anh có thể đã nghe rằng Rosa Garcia sẽ nghỉ hưu vào cuối tháng 11).
2. Điều này chỉ ra rõ ràng rằng một nhân viên (Rosa Garcia) sẽ nghỉ hưu vào cuối tháng 11.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Một lãnh đạo sẽ đến thăm
B. Một nhân viên sẽ nghỉ hưu
C. Một sản phẩm sẽ được ra mắt
D. Một nghiên cứu sẽ được hoàn thành');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (51, 3, 'test1_question_50_52.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (51, 51, 51, 'What does the man want to know?', 'Where he would be working', 'When he would be starting a job', 'How to get to an office building', 'Why an event time has changed', 'B', 'Đáp án đúng là B (When he would be starting a job) vì:
1. Người đàn ông hỏi: "When would I start the position?" (Khi nào tôi sẽ bắt đầu vị trí này?)
2. Điều này cho thấy rõ ràng rằng anh ta muốn biết thời điểm bắt đầu công việc mới.
3. Các đáp án khác không phù hợp với câu hỏi của người đàn ông trong đoạn hội thoại.
Dịch các đáp án:
A. Nơi anh ta sẽ làm việc
B. Khi nào anh ta sẽ bắt đầu một công việc
C. Làm thế nào để đến một tòa nhà văn phòng
D. Tạo sai thời gian sự kiện thay đổi');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (52, 3, 'test1_question_50_52.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (52, 52, 52, 'What does the woman say the company will pay for?', 'A work vehicle', 'A private office', 'Moving expenses', 'Visitors'' meals', 'C', 'Đáp án đúng là C (Moving expenses) vì:
1. Người phụ nữ nói: "We''d pay for all your moving expenses, of course. If you decide to accept the offer." (Chúng tôi sẽ trả cho tất cả chi phí chuyển nhà của anh, tất nhiên. Nếu anh quyết định chấp nhận lời đề nghị.)
2. Điều này chỉ ra rõ ràng rằng công ty sẽ trả chi phí chuyển nhà nếu Omar chấp nhận vị trí mới.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Một phương tiện làm việc
B. Một văn phòng riêng
C. Chi phí chuyển nhà
D. Bữa ăn cho khách');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (53, 3, 'test1_question_53_55.mp3', NULL, 'M: Maryam, did you hear that our construction company won the bid to buildthe river dam next to Burton City?
W: I did! This is such a major project forus... the dam''s expected to produce
enough electricity to power all of Burton. M:
Right, Say, do you know when construction will begin?
W: I don''t, but here comes the project nanager now. He may have a better idea...
Gerhard, are there any updates on the dam construction?
M2: Well, we''re going to have to wait until all the permits are approved. It''ll be awhile before anything else can happen.', 'M: Maryam, bạn có nghe nói rằng công ty xây dựng của chúng tôi đã thắng thầu xây đập sông bên cạnh thành phố Burton không? 
W: Tôi đã làm! Đây là một dự án lớn như vậy... con đập dự kiến sẽ sản xuất đủ điện để cung cấp năng lượng cho toàn bộ Burton. M:
Đúng vậy, Say, bạn có biết khi nào việc xây dựng sẽ bắt đầu không? 
W: Tôi không biết, nhưng đây là quản lý dự án bây giờ. Anh ấy có thể có một ý tưởng tốt hơn...
Gerhard, có bất kỳ cập nhật nào về việc xây dựng đập không? 
M2: Chà, chúng ta sẽ phải đợi cho đến khi tất cả các giấy phép được phê duyệt. Sẽ mất một thời gian trước khi bất cứ điều gì khác có thể xảy ra.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (53, 53, 53, 'What industry do the speakers work in?', 'Manufacturing', 'Agriculture', 'Transportation', 'Construction', 'D', 'Đáp án đúng là D (Construction) vì:
1. Người đàn ông nói: "our construction company won the bid to build the river dam" (công ty xây dựng của chúng ta đã thắng thầu để xây dựng đập nước)
2. Họ đang thảo luận về một dự án xây dựng đập.
3. Các đáp án khác không phù hợp với ngữ cảnh của cuộc trò chuyện.
Dịch các đáp án:
A. Sản xuất
B. Nông nghiệp
C. Vận tải
D. Xây dựng');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (54, 3, 'test1_question_53_55.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (54, 54, 54, 'What does the woman say a project will do for a city?', 'Increase tourism', 'Generate electricity', 'Preserve natural resources', 'Improve property values', 'B', 'Đáp án đúng là B (Generate electricity) vì:
1. Người phụ nữ nói: "the dam''s expected to produce enough electricity to power all of Burton" (đập được kỳ vọng sẽ sản xuất đủ điện để cung cấp cho toàn bộ Burton)
2. Điều này chỉ ra rõ ràng rằng dự án sẽ tạo ra điện cho thành phố.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Tăng du lịch
B. Tạo ra điện
C. Bảo tồn tài nguyên thiên nhiên
D. Cải thiện giá trị bất động sản');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (55, 3, 'test1_question_53_55.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (55, 55, 55, 'What does Gerhard say needs to be done?', 'Permits need to be approved', 'Employees need to be trained', 'Materials need to be ordered', 'Inspections need to be made', 'A', 'Đáp án đúng là A (Permits need to be approved) vì:
1. Gerhard nói: "we''re going to have to wait until all the permits are approved" (chúng ta sẽ phải đợi cho đến khi tất cả các giấy phép được phê duyệt)
2. Điều này chỉ ra rõ ràng rằng các giấy phép cần được phê duyệt trước khi tiếp tục.
3. Các đáp án khác không được đề cập trong lời nói của Gerhard.
Dịch các đáp án:
A. Giấy phép cần được phê duyệt
B. Nhân viên cần được đào tạo
C. Vật liệu cần được đặt hàng
D. Kiểm tra cần được thực hiện');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (56, 3, 'test1_question_56_58.mp3', NULL, 'M: I have a question about a customer''s prescription - He''s...oh, I''m sorry. I see you''re busy,
W: I don''t have much to do.
M: His doctor prescribed a 30-day supply of this allergy medication, but I noticed
we only have enough on the shelf for fifteen days.
W: Our weekly delivery arrives early tomorrow morning. Go ahead and give him the fifteen, and ask him to please come back for the rest.
It''s allergy season, so we''re selling a lot of that medicine.
M: Then maybe we should increase the number of bottles in our next order from the distributor.', 'M: Tôi có một câu hỏi về đơn thuốc của khách hàng - Anh ấy...ồ, tôi xin lỗi. Tôi thấy bạn đang bận,
W: Tôi không có nhiều việc phải làm.
M: Bác sĩ của anh ấy đã kê đơn thuốc dị ứng này trong 30 ngày, nhưng tôi nhận thấy
chúng tôi chỉ có đủ trên kệ trong mười lăm ngày.
W: Giao hàng hàng tuần của chúng tôi sẽ đến vào sáng sớm ngày mai. Hãy tiếp tục và đưa cho anh ta mười lăm, và yêu cầu anh ta vui lòng quay lại để lấy phần còn lại.
Đây là mùa dị ứng, vì vậy chúng tôi đang bán rất nhiều loại thuốc đó.
M: Vậy thì có lẽ chúng ta nên tăng số lượng chai trong đơn đặt hàng tiếp theo từ nhà phân phối.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (56, 56, 56, 'What does the woman imply when she says, "I don''t have much to do"?', 'She has time to help', 'She plans to leave work early', 'Her computer is not working', 'She has not received an assignment', 'A', 'Đáp án đúng là A (She has time to help) vì:
1. Khi người đàn ông xin lỗi vì nghĩ người phụ nữ đang bận, cô ấy nói "I don''t have much to do" (Tôi không có nhiều việc phải làm)
2. Điều này ngụ ý rằng cô ấy có thời gian rảnh và sẵn sàng giúp đỡ.
3. Các đáp án khác không phù hợp với ngữ cảnh của cuộc trò chuyện.
Dịch các đáp án:
A. Cô ấy có thời gian để giúp đỡ
B. Cô ấy dự định rời công việc sớm
C. Máy tính của cô ấy không hoạt động
D. Cô ấy chưa nhận được nhiệm vụ');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (57, 3, 'test1_question_56_58.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (57, 57, 57, 'What does the man notice about some medication?', 'It needs to be refrigerated', 'It has expired', 'The dosage has changed', 'The supply is limited', 'D', 'Đáp án đúng là D (The supply is limited) vì:
1. Người đàn ông nói: "His doctor prescribed a 30-day supply of this allergy medication, but I noticed we only have enough on the shelf for fifteen days" (Bác sĩ kê đơn thuốc dị ứng cho 30 ngày, nhưng tôi nhận thấy chúng ta chỉ có đủ trên kệ cho 15 ngày)
2. Điều này chỉ ra rõ ràng rằng nguồn cung thuốc bị hạn chế.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Nó cần được bảo quản lạnh
B. Nó đã hết hạn
C. Liều lượng đã thay đổi
D. Nguồn cung bị hạn chế');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (58, 3, 'test1_question_56_58.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (58, 58, 58, 'What does the man suggest doing in the future?', 'Installing some shelves', 'Confirming with a doctor', 'Increasing an order amount', 'Recommending a different medication', 'C', 'Đáp án đúng là C (Increasing an order amount) vì:
1. Người đàn ông nói: "Then maybe we should increase the number of bottles in our next order from the distributor" (Vậy thì có lẽ chúng ta nên tăng số lượng chai trong đơn hàng tiếp theo từ nhà phân phối)
2. Điều này chỉ ra rõ ràng rằng anh ta đề xuất tăng số lượng đặt hàng trong tương lai.
3. Các đáp án khác không phù hợp với gợi ý của người đàn ông.
Dịch các đáp án:
A. Lắp đặt một số kệ
B. Xác nhận với bác sĩ
C. Tăng số lượng đặt hàng
D. Đề xuất một loại thuốc khác');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (59, 3, 'test1_question_59_61.mp3', NULL, 'M: Good morning, Ms. Davis. We''ve received comments from your legal team on the terms and agreements for the travel rewards credit card that we issued.
M: Could you explain the revision we need to make to be in compliance with thelaw?
W: Sure. The problem with th agreementis this: it doesn''t disclose to users that if a card isn''t used for a year, the account will be suspended.
M: Oh, that''s an oversight on our part. We''re glad you caught that.
W: We don''t want to be fined by banking regulations, so all cardholders will need tobe notified by the end of the month.', 'M: Chào buổi sáng, cô Davis. Chúng tôi đã nhận được ý kiến từ nhóm pháp lý của bạn về các điều khoản và thỏa thuận đối với thẻ tín dụng thưởng du lịch mà chúng tôi đã phát hành.
M: Bạn có thể giải thích bản sửa đổi mà chúng tôi cần thực hiện để tuân thủ luật pháp không? 
W: Chắc chắn rồi. Vấn đề với thỏa thuận này là: nó không tiết lộ cho người dùng rằng nếu thẻ không được sử dụng trong một năm, tài khoản sẽ bị tạm ngưng.
M: Ồ, đó là sự giám sát từ phía chúng tôi. Chúng tôi rất vui vì bạn đã nắm bắt được điều đó.
W: Chúng tôi không muốn bị phạt theo quy định ngân hàng, vì vậy tất cả chủ thẻ sẽ cần được thông báo vào cuối tháng.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (59, 59, 59, 'Who most likely is the woman?', 'A travel agent', 'A bank teller', 'A lawyer', 'A mail-room worker', 'C', 'Đáp án đúng là C (A lawyer) vì:
1. Người đàn ông nói về "comments from your legal team" (nhận xét từ đội ngũ pháp lý của bạn)
2. Người phụ nữ giải thích về vấn đề pháp lý trong thỏa thuận và đề cập đến việc tuân thủ quy định ngân hàng.
3. Những điều này cho thấy cô ấy có khả năng là một luật sư.
4. Các đáp án khác không phù hợp với vai trò được thể hiện trong đoạn hội thoại.
Dịch các đáp án:
A. Một đại lý du lịch
B. Một nhân viên ngân hàng
C. Một luật sư
D. Một nhân viên phòng thư');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (60, 3, 'test1_question_59_61.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (60, 60, 60, 'What kind of document are the speakers discussing?', 'A user agreement', 'An employment contract', 'A list of travel expenses', 'An insurance certificate', 'A', 'Đáp án đúng là A (A user agreement) vì:
1. Người đàn ông nói về "terms and agreements for the travel rewards credit card" (điều khoản và thỏa thuận cho thẻ tín dụng tích điểm du lịch)
2. Người phụ nữ đề cập đến "the agreement" (thỏa thuận) khi giải thích vấn đề.
3. Đây rõ ràng là một thỏa thuận người dùng cho thẻ tín dụng.
4. Các đáp án khác không phù hợp với nội dung cuộc trò chuyện.
Dịch các đáp án:
A. Một thỏa thuận người dùng
B. Một hợp đồng lao động
C. Một danh sách chi phí du lịch
D. Một chứng chỉ bảo hiểm');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (61, 3, 'test1_question_59_61.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (61, 61, 61, 'Why must the document be revised by the end of the month?', 'To be included in a personnel file', 'To use in a merger negotiation', 'To meet a production deadline', 'To avoid paying a fine', 'D', 'Đáp án đúng là D (To avoid paying a fine) vì:
1. Người phụ nữ nói: "We don''t want to be fined by banking regulations, so all cardholders will need to be notified by the end of the month" (Chúng ta không muốn bị phạt theo quy định ngân hàng, vì vậy tất cả chủ thẻ cần được thông báo trước cuối tháng)
2. Điều này chỉ ra rõ ràng rằng việc sửa đổi và thông báo cần được thực hiện để tránh bị phạt.
3. Các đáp án khác không phù hợp với lý do được đưa ra trong đoạn hội thoại.
Dịch các đáp án:
A. Để được đưa vào hồ sơ nhân sự
B. Để sử dụng trong đàm phán sáp nhập
C. Để đáp ứng thời hạn sản xuất
D. Để tránh phải trả tiền phạt');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (62, 3, 'test1_question_62_64.mp3', 'test1-p3-image-62.jpg', 'M: Ms. Giordana, it looks like the last of the wedding guests have left. My staff''s going to start packing up our dishes and loading the van.
W: That''s fine, thank you. The food was delicious. My son and his new wife were very happy with your service.
M: I''m glad you enjoyed it. And, again, I''m sorry that some of our wait staffs were late arriving. They said they drove right past the turnoff.
W: I understand. The venue is difficult to see from the road. I really like this location, though with its view of the mountains from the gardens in the back.', 'M: Cô Giordana, có vẻ như những vị khách cuối cùng trong đám cưới đã rời đi. Nhân viên của tôi sẽ bắt đầu đóng gói các món ăn của chúng tôi và chất xe tải.
W: Được rồi, cảm ơn bạn. Thức ăn rất ngon. Con trai tôi và người vợ mới cưới của nó rất hài lòng với dịch vụ của bạn.
M: Tôi rất vui vì bạn thích nó. Và, một lần nữa, tôi xin lỗi vì một số nhân viên phục vụ của chúng tôi đã đến muộn. Họ nói rằng họ đã lái xe ngay qua ngã rẽ.
W: Tôi hiểu rồi. Địa điểm rất khó nhìn thấy từ đường. Tôi thực sự thích vị trí này, mặc dù có tầm nhìn ra những ngọn núi từ những khu vườn ở phía sau.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (62, 62, 62, 'Look at the graphic. How much did the man''s company charge for its service?', '$4,456', '$1,300', '$10,200', '$400', 'C', 'Đáp án đúng là C ($10,200) vì:
1. Trong bảng chi phí đám cưới Giordano, mục "Catering" (Ẩm thực) có giá $10,200.
2. Người đàn ông trong đoạn hội thoại đại diện cho công ty cung cấp dịch vụ ẩm thực, vì anh ta nói về việc thu dọn đĩa và nhân viên phục vụ.
3. Do đó, chi phí dịch vụ của công ty anh ta là $10,200.
Dịch các đáp án:
A. $4,456
B. $1,300
C. $10,200
D. $400');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (63, 3, 'test1_question_62_64.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (63, 63, 63, 'Why does the man apologize?', 'Business hours have changed', 'A price was wrong', 'Some staff arrived late', 'A request could not be fulfilled', 'C', 'Đáp án đúng là C (Some staff arrived late) vì:
1. Người đàn ông nói: "And, again, I''m sorry that some of our wait staffs were late arriving." (Và, một lần nữa, tôi xin lỗi vì một số nhân viên phục vụ của chúng tôi đến muộn.)
2. Điều này chỉ ra rõ ràng rằng anh ta đang xin lỗi vì một số nhân viên đến muộn.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Giờ làm việc đã thay đổi
B. Một giá tiền bị sai
C. Một số nhân viên đến muộn
D. Một yêu cầu không thể được đáp ứng');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (64, 3, 'test1_question_62_64.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (64, 64, 64, 'What does the woman like about a venue?', 'It has a nice view', 'It is conveniently located', 'It is tastefully decorated', 'It can host large events', 'A', 'Đáp án đúng là A (It has a nice view) vì:
1. Người phụ nữ nói: "I really like this location, though with its view of the mountains from the gardens in the back." (Tôi thực sự thích địa điểm này, với tầm nhìn ra núi từ khu vườn phía sau.)
2. Điều này chỉ ra rõ ràng rằng cô ấy thích địa điểm này vì có tầm nhìn đẹp.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Nó có tầm nhìn đẹp
B. Nó có vị trí thuận tiện
C. Nó được trang trí đẹp mắt
D. Nó có thể tổ chức các sự kiện lớn');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (65, 3, 'test1_question_65_67.mp3', 'test1-p3-image-65.jpg', 'W: Hey, Thomas? You like concerts. Anychance you''re interested in the local band showcase this weekend? I have two ticketsthat I don''t need.
M: You got tickets to that? That''s surprising! I heard that they sold out injust a few days.
W: They did. But I actually won these in aradio contest. That''s why I''m giving them away instead of selling them. Good seats, too. Right in the middle, close to the stage.M: Sure, Ill take them. Thanks! Why can''t you go?
W: This weekend is my parents'' anniversary.
My sisters and 1 are planning a party for them at their home in Boston.', 'W: Này, Thomas? Bạn thích các buổi hòa nhạc. Có cơ hội nào bạn quan tâm đến buổi giới thiệu ban nhạc địa phương vào cuối tuần này không? Tôi có hai vé mà tôi không cần.
M: Bạn có vé cho cái đó không? Điều đó thật đáng ngạc nhiên! Tôi nghe nói rằng họ đã bán hết chỉ trong vài ngày.
W: Họ đã làm. Nhưng tôi thực sự đã thắng những điều này trong cuộc thi phát thanh. Đó là lý do tại sao tôi cho chúng đi thay vì bán chúng. Ghế ngồi cũng tốt. Ngay giữa, gần sân khấu.M: Chắc chắn rồi, tôi sẽ lấy chúng. Cảm ơn! Tại sao bạn không thể đi? 
W: Cuối tuần này là ngày kỷ niệm của bố mẹ tôi.
Các chị em tôi và tôi đang lên kế hoạch tổ chức một bữa tiệc cho họ tại nhà của họ ở Boston.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (65, 65, 65, 'Why is the man surprised?', 'A popular band is coming to town', 'The woman plays a musical instrument', 'The woman was able to get concert tickets', 'Some musicians scheduled a second concert', 'C', 'Đáp án đúng là C (The woman was able to get concert tickets) vì:
1. Người đàn ông nói: "You got tickets to that? That''s surprising!" (Cô có vé cho buổi diễn đó sao? Thật ngạc nhiên!)
2. Anh ta tiếp tục giải thích: "I heard that they sold out in just a few days." (Tôi nghe nói vé đã bán hết chỉ trong vài ngày.)
3. Điều này cho thấy anh ta ngạc nhiên vì người phụ nữ có thể có được vé cho buổi hòa nhạc đã bán hết.
Dịch các đáp án:
A. Một ban nhạc nổi tiếng đang đến thành phố
B. Người phụ nữ chơi một nhạc cụ
C. Người phụ nữ đã có thể có được vé hòa nhạc
D. Một số nhạc sĩ đã lên lịch cho buổi hòa nhạc thứ hai');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (66, 3, 'test1_question_65_67.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (66, 66, 66, 'Look at the graphic. In which section does the woman have seats?', 'Section 1', 'Section 2', 'Section 3', 'Section 4', 'C', 'Đáp án đúng là C (Section 3) vì:
1. Người phụ nữ nói: "Good seats, too. Right in the middle, close to the stage." (Ghế ngồi cũng tốt. Ngay giữa, gần sân khấu.)
2. Trong sơ đồ chỗ ngồi, Section 3 là khu vực ở giữa và gần sân khấu nhất.
3. Các section khác không phù hợp với mô tả "giữa, gần sân khấu".
Dịch các đáp án:
A. Khu vực 1
B. Khu vực 2
C. Khu vực 3
D. Khu vực 4');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (67, 3, 'test1_question_65_67.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (67, 67, 67, 'What is the woman doing this weekend?', 'Practicing with her band', 'Entering a radio contest', 'Moving to Boston', 'Attending a party', 'D', 'Đáp án đúng là D (Attending a party) vì:
1. Người phụ nữ nói: "This weekend is my parents'' anniversary. My sisters and I are planning a party for them at their home in Boston." (Cuối tuần này là kỷ niệm ngày cưới của bố mẹ tôi. Các chị em gái tôi và tôi đang lên kế hoạch tổ chức một bữa tiệc cho họ tại nhà ở Boston.)
2. Điều này chỉ ra rõ ràng rằng cô ấy sẽ tham dự một bữa tiệc kỷ niệm cho bố mẹ của mình.
3. Các đáp án khác không phù hợp với thông tin trong đoạn hội thoại.
Dịch các đáp án:
A. Tập luyện với ban nhạc của cô ấy
B. Tham gia một cuộc thi trên radio
C. Chuyển đến Boston
D. Tham dự một bữa tiệc');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (68, 3, 'test1_question_68_70.mp3', 'test1-p3-image-68.jpg', 'M: Hello. Bellevue Apartments Management Office. Can I help you?
W: Hi. I''m Azusa Suzuki. I''m a new tenant here, and I live in 2A.
M: How''s everything in your apartment sofar?
W: Very good. One thing, though... Whencan you put my name on the building directory? It still says the previous tenant''sname.
M: No problem. I can send someone over now. Unit 2A, you said?
W: Yes. And, I''ll be stopping by youroffice tomorrow with my February rentcheck
M: OK. See you then', 'M: Xin chào. Văn phòng quản lý căn hộ Bellevue. Tôi có thể giúp gì cho bạn không? 
W: Xin chào. Tôi là Azusa Suzuki. Tôi là người thuê nhà mới ở đây, và tôi sống ở 2A.
M: Mọi thứ trong căn hộ sofar của bạn thế nào rồi? 
W: Rất tốt. Một điều, mặc dù... Khi nào bạn có thể đưa tên tôi vào danh bạ tòa nhà? Nó vẫn nói tên của người thuê trước đó.
M: Không vấn đề gì. Tôi có thể cử ai đó đến ngay bây giờ. Đơn vị 2A, bạn đã nói? 
W: Vâng. Và, tôi sẽ ghé qua văn phòng của bạn vào ngày mai với séc tiền thuê nhà tháng Hai của tôi
M: OK. Hẹn gặp lại');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (68, 68, 68, 'Who most likely is the man?', 'A maintenance worker', 'A property manager', 'A real estate agent', 'A bank employee', 'B', 'Đáp án đúng là B (A property manager) vì:
1. Người đàn ông trả lời điện thoại với "Bellevue Apartments Management Office" (Văn phòng quản lý căn hộ Bellevue).
2. Anh ta có thể xử lý các yêu cầu liên quan đến tòa nhà như thay đổi tên trong danh bạ.
3. Anh ta cũng biết về việc thanh toán tiền thuê nhà.
4. Những điều này chỉ ra rằng anh ta có khả năng là người quản lý tài sản.
Dịch các đáp án:
A. Một nhân viên bảo trì
B. Một người quản lý tài sản
C. Một môi giới bất động sản
D. Một nhân viên ngân hàng');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (69, 3, 'test1_question_68_70.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (69, 69, 69, 'Look at the graphic. Which name needs to be changed?', 'Tanaka', 'Zhao', 'Mukherjee', 'Tremblay', 'C', 'Đáp án đúng là C (Mukherjee) vì:
1. Người phụ nữ nói cô ấy sống ở căn hộ 2A.
2. Trong bảng danh sách cư dân, căn hộ 2A được ghi tên là Mukherjee.
3. Người phụ nữ yêu cầu thay đổi tên từ người thuê trước đó thành tên của cô ấy (Azusa Suzuki).
4. Do đó, tên Mukherjee cần được thay đổi thành Suzuki.
Dịch các đáp án:
A. Tanaka
B. Zhao
C. Mukherjee
D. Tremblay');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (70, 3, 'test1_question_68_70.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (70, 70, 70, 'What does the woman say she is going to do tomorrow?', 'Fill out a registration form', 'Meet with some neighbors', 'Order some furniture', 'Make a payment', 'D', 'Đáp án đúng là D (Make a payment) vì:
1. Người phụ nữ nói: "I''ll be stopping by your office tomorrow with my February rent check" (Tôi sẽ ghé qua văn phòng của anh vào ngày mai với séc tiền thuê nhà tháng Hai của tôi).
2. Điều này chỉ ra rõ ràng rằng cô ấy sẽ thanh toán tiền thuê nhà vào ngày mai.
3. Các đáp án khác không được đề cập trong đoạn hội thoại.
Dịch các đáp án:
A. Điền vào một mẫu đăng ký
B. Gặp gỡ một số hàng xóm
C. Đặt mua một số đồ nội thất
D. Thực hiện một khoản thanh toán');

-- Data for 2022 Test1 Part 4
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (71, 4, 'test1_question_71_73.mp3', NULL, 'W-Am: Hello, this is Karen Smith. I have an appointment with Dr. Miller for myannual eye exam on Tuesday. Unfortunately, I won''t be able to make it. If possible, I''d like to reschedule for later in the week. If Dr. Miller is available inthe afternoon, that would work better for me. I also wanted to ask about your warranty for eyeglasses. What exactly does the warranty cover? Thank you, and please call me back at 555-0110.', 'W-Am: Xin chào, đây là Karen Smith. Tôi có một cuộc hẹn với bác sĩ. Miller cho bài kiểm tra mắt hàng năm của tôi vào thứ Ba. Thật không may, tôi sẽ không thể làm được. Nếu có thể, tôi muốn lên lịch lại vào cuối tuần. Nếu Tiến sĩ. Miller rảnh vào buổi chiều, điều đó sẽ phù hợp hơn với tôi. Tôi cũng muốn hỏi về bảo hành kính mắt của bạn. Chính xác thì bảo hành bao gồm những gì? Cảm ơn bạn, và vui lòng gọi lại cho tôi theo số 555-0110.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (71, 71, 71, 'What kind of business is the speaker most likely calling?', 'A hair salon', 'An insurance company', 'A car dealership', 'An eye doctor''s office', 'D', 'Đáp án đúng là D (An eye doctor''s office) vì:
1. Người nói đề cập đến "annual eye exam" (kiểm tra mắt hàng năm).
2. Cô ấy nói về việc đặt lịch hẹn với "Dr. Miller".
3. Cô ấy hỏi về bảo hành cho kính mắt.
Tất cả những điều này chỉ ra rằng cô ấy đang gọi đến văn phòng bác sĩ mắt.
Dịch các đáp án:
A. Một tiệm làm tóc
B. Một công ty bảo hiểm
C. Một đại lý ô tô
D. Văn phòng bác sĩ mắt');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (72, 4, 'test1_question_71_73.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (72, 72, 72, 'What does the speaker say about her appointment?', 'It is too far away', 'It needs to be rescheduled', 'It is too expensive', 'It should be with a different person', 'B', 'Đáp án đúng là B (It needs to be rescheduled) vì:
1. Người nói nói: "Unfortunately, I won''t be able to make it. If possible, I''d like to reschedule for later in the week." (Tiếc là tôi không thể đến được. Nếu có thể, tôi muốn đổi lịch hẹn sang cuối tuần.)
2. Điều này chỉ ra rõ ràng rằng cô ấy cần đổi lịch hẹn.
Dịch các đáp án:
A. Nó quá xa
B. Nó cần được đặt lại lịch
C. Nó quá đắt
D. Nó nên với một người khác');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (73, 4, 'test1_question_71_73.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (73, 73, 73, 'What is the speaker interested in learning more about?', 'Payment methods', 'Delivery options', 'A warranty', 'A job opening', 'C', 'Đáp án đúng là C (A warranty) vì:
1. Người nói hỏi: "I also wanted to ask about your warranty for eyeglasses. What exactly does the warranty cover?" (Tôi cũng muốn hỏi về bảo hành cho kính mắt. Chính xác thì bảo hành bao gồm những gì?)
2. Điều này cho thấy cô ấy quan tâm đến việc tìm hiểu thêm về bảo hành.
Dịch các đáp án:
A. Phương thức thanh toán
B. Tùy chọn giao hàng
C. Một chính sách bảo hành
D. Một vị trí công việc đang mở');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (74, 4, 'test1_question_74_76.mp3', NULL, 'M-Cn: Curious about how chocolate is made?
Then come visit us at Bodin''s Chocolate Factory! You''ll have a great time. We offer guided tours every Saturday and Sunday at our factory, located directly across from Appleton Shopping Center. During your two-hour visit, you''ll observe the creation and packaging of Bodin''s products. And each visitor will get their picture taken with Cheery, our adorable chocolate mascot, to take home as a souvenir. Right now, with the coupon available on our Web site, you can bring in a group of twelve or more people for half the price.
Download yours today!', 'M-Cn: Tò mò về cách làm sô cô la? 
Sau đó hãy đến thăm chúng tôi tại Nhà máy Sô cô la của Bodin! Bạn sẽ có một khoảng thời gian tuyệt vời. Chúng tôi cung cấp các chuyến tham quan có hướng dẫn viên vào thứ Bảy và Chủ Nhật hàng tuần tại nhà máy của chúng tôi, nằm ngay đối diện Trung tâm mua sắm Appleton. Trong chuyến thăm kéo dài hai giờ, bạn sẽ quan sát quá trình sáng tạo và đóng gói các sản phẩm của Bodin. Và mỗi du khách sẽ được chụp ảnh với Cheery, linh vật sô cô la đáng yêu của chúng tôi, để mang về nhà làm quà lưu niệm. Ngay bây giờ, với phiếu giảm giá có sẵn trên trang web của chúng tôi, bạn có thể mang theo một nhóm từ mười hai người trở lên với giá chỉ bằng một nửa.
Tải xuống ngay hôm nay!');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (74, 74, 74, 'What is being advertised?', 'A factory tour', 'A baking competition', 'A grand opening', 'An art show', 'A', 'Đáp án đúng là A (A factory tour) vì:
1. Đoạn văn nói: "We offer guided tours every Saturday and Sunday at our factory" (Chúng tôi cung cấp các tour tham quan có hướng dẫn vào thứ Bảy và Chủ nhật tại nhà máy của chúng tôi).
2. Nó cũng mô tả chi tiết về những gì khách tham quan sẽ thấy và làm trong chuyến tham quan.
Dịch các đáp án:
A. Một tour tham quan nhà máy
B. Một cuộc thi nướng bánh
C. Một buổi khai trương
D. Một triển lãm nghệ thuật');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (75, 4, 'test1_question_74_76.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (75, 75, 75, 'What will participants receive?', 'A poster', 'A promotional mug', 'A company T-shirt', 'A photograph', 'D', 'Đáp án đúng là D (A photograph) vì:
1. Đoạn văn nói: "And each visitor will get their picture taken with Cheery, our adorable chocolate mascot, to take home as a souvenir." (Và mỗi khách tham quan sẽ được chụp ảnh với Cheery, linh vật sô-cô-la đáng yêu của chúng tôi, để mang về nhà làm kỷ niệm.)
2. Điều này chỉ ra rõ ràng rằng người tham gia sẽ nhận được một bức ảnh.
Dịch các đáp án:
A. Một tấm áp phích
B. Một cốc quảng cáo
C. Một áo phông của công ty
D. Một bức ảnh');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (76, 4, 'test1_question_74_76.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (76, 76, 76, 'What can the listeners do on a Web site?', 'Find a recipe', 'Fill out an entry form', 'View a product list', 'Download a coupon', 'D', 'Đáp án đúng là D (Download a coupon) vì:
1. Đoạn văn nói: "Right now, with the coupon available on our Web site, you can bring in a group of twelve or more people for half the price. Download yours today!" (Ngay bây giờ, với phiếu giảm giá có sẵn trên trang web của chúng tôi, bạn có thể mang theo một nhóm từ 12 người trở lên với giá chỉ bằng một nửa. Hãy tải xuống ngay hôm nay!)
2. Điều này chỉ ra rõ ràng rằng người nghe có thể tải xuống một phiếu giảm giá từ trang web.
Dịch các đáp án:
A. Tìm một công thức nấu ăn
B. Điền vào một mẫu đơn đăng ký
C. Xem danh sách sản phẩm
D. Tải xuống một phiếu giảm giá');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (77, 4, 'test1_question_77_79.mp3', NULL, 'W-Br: Attention, everyone. Unfortunately, we''ve had to stop themovie. As you''ve probably noticed, we''re having technical difficulties with the audio. I''m very sorry about this --we take our sound quality seriously and want you to know we''ll have technicians here as soon as possible to resolve this issue. As you exit, please stop by the customer service desk in the lobby to pick up two free tickets for your next movie. Again, my apologies for the inconvenience.', 'W-Br: Mọi người hãy chú ý. Thật không may, chúng tôi đã phải dừng bộ phim. Như bạn có thể nhận thấy, chúng tôi đang gặp khó khăn về kỹ thuật với âm thanh. Tôi rất xin lỗi về điều này - chúng tôi rất coi trọng chất lượng âm thanh của mình và muốn bạn biết rằng chúng tôi sẽ có kỹ thuật viên ở đây sớm nhất có thể để giải quyết vấn đề này. Khi bạn ra ngoài, vui lòng ghé qua bàn dịch vụ khách hàng ở sảnh để nhận hai vé miễn phí cho bộ phim tiếp theo của bạn. Một lần nữa, tôi xin lỗi vì sự bất tiện này.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (77, 77, 77, 'Where does the announcement take place?', 'At a sports arena', 'At a concert hall', 'At an art museum', 'At a movie theater', 'D', 'Đáp án đúng là D (At a movie theater) vì:
1. Người nói đề cập đến việc phải dừng chiếu phim: "we''ve had to stop the movie" (chúng tôi đã phải dừng bộ phim).
2. Cô ấy nói về việc phát sinh vấn đề kỹ thuật với âm thanh.
3. Cô ấy đề cập đến việc phát vé miễn phí cho lần xem phim tiếp theo.
Tất cả những điều này chỉ ra rõ ràng rằng thông báo được đưa ra tại một rạp chiếu phim.
Dịch các đáp án:
A. Tại một sân vận động thể thao
B. Tại một phòng hòa nhạc
C. Tại một bảo tàng nghệ thuật
D. Tại một rạp chiếu phim');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (78, 4, 'test1_question_77_79.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (78, 78, 78, 'Why does the speaker apologize?', 'A presenter has been delayed', 'Some lights have gone out', 'A sound system is broken', 'A construction project is noisy', 'C', 'Đáp án đúng là C (A sound system is broken) vì:
1. Người nói nói: "we''re having technical difficulties with the audio" (chúng tôi đang gặp khó khăn kỹ thuật với âm thanh).
2. Cô ấy xin lỗi vì vấn đề này và nói rằng họ sẽ có kỹ thuật viên đến để giải quyết vấn đề.
Điều này chỉ ra rõ ràng rằng hệ thống âm thanh đang gặp trục trặc.
Dịch các đáp án:
A. Một người thuyết trình bị trễ
B. Một số đèn đã tắt
C. Một hệ thống âm thanh bị hỏng
D. Một dự án xây dựng gây ồn ào');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (79, 4, 'test1_question_77_79.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (79, 79, 79, 'What does the speaker offer the listeners?', 'A promotional item', 'A parking voucher', 'Discounted snacks', 'Free tickets', 'D', 'Đáp án đúng là D (Free tickets) vì:
1. Người nói nói: "As you exit, please stop by the customer service desk in the lobby to pick up two free tickets for your next movie." (Khi bạn ra về, vui lòng ghé quầy dịch vụ khách hàng ở sảnh để nhận hai vé xem phim miễn phí cho lần tới.)
2. Điều này chỉ ra rõ ràng rằng người nói đang cung cấp vé miễn phí cho khán giả.
Dịch các đáp án:
A. Một món quà quảng cáo
B. Một phiếu đỗ xe
C. Đồ ăn nhẹ giảm giá
D. Vé miễn phí');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (80, 4, 'test1_question_80_82.mp3', NULL, 'W-Am: Welcome to Branson Tech''s second annual conference on computer security. We decided to try something different to publicize the event this year. We advertised primarily through social media rather than by e-mail newsletters or on company Web sites. And over 300 people are here! The first presentations will begin in fifteen minutes. The talks will take place in different rooms throughout the building, so please be sure to check your programs for the list of topics, speakers, and locations.', 'W-Am: Chào mừng bạn đến với hội nghị thường niên lần thứ hai của Branson Tech về bảo mật máy tính. Chúng tôi quyết định thử một cái gì đó khác biệt để công khai sự kiện trong năm nay. Chúng tôi quảng cáo chủ yếu thông qua phương tiện truyền thông xã hội thay vì bằng bản tin email hoặc trên các trang web của công ty. Và hơn 300 người đang ở đây! Các bài thuyết trình đầu tiên sẽ bắt đầu sau mười lăm phút nữa. Các buổi nói chuyện sẽ diễn ra ở các phòng khác nhau trong tòa nhà, vì vậy hãy chắc chắn kiểm tra các chương trình của bạn để biết danh sách các chủ đề, diễn giả và địa điểm.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (80, 80, 80, 'What event is taking place?', 'A technology conference', 'A product demonstration', 'A company fund-raiser', 'A training workshop', 'A', 'Đáp án đúng là A (A technology conference) vì:
1. Người nói chào mừng mọi người đến với "Branson Tech''s second annual conference on computer security" (hội nghị thường niên lần thứ hai về bảo mật máy tính của Branson Tech).
2. Điều này chỉ ra rõ ràng rằng sự kiện đang diễn ra là một hội nghị công nghệ.
Dịch các đáp án:
A. Một hội nghị công nghệ
B. Một buổi trình diễn sản phẩm
C. Một sự kiện gây quỹ của công ty
D. Một hội thảo đào tạo');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (81, 4, 'test1_question_80_82.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (81, 81, 81, 'Why does the speaker say, "And over 300 people are here"?', 'To propose moving to a larger venue', 'To indicate that some advertising was successful', 'To emphasize the importance of working quickly', 'To suggest more volunteers are needed', 'B', 'Đáp án đúng là B (To indicate that some advertising was successful) vì:
1. Người nói đề cập đến việc họ đã thử một cách tiếp cận quảng cáo mới thông qua mạng xã hội.
2. Sau đó, cô ấy nói "And over 300 people are here!" (Và hơn 300 người có mặt ở đây!)
3. Điều này ngụ ý rằng chiến lược quảng cáo mới đã thành công trong việc thu hút người tham dự.
Dịch các đáp án:
A. Để đề xuất chuyển đến một địa điểm lớn hơn
B. Để chỉ ra rằng một số quảng cáo đã thành công
C. Để nhấn mạnh tầm quan trọng của việc làm việc nhanh chóng
D. Để đề xuất cần thêm tình nguyện viên');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (82, 4, 'test1_question_80_82.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (82, 82, 82, 'What does the speaker ask the listeners to do?', 'Provide feedback', 'Silence mobile phones', 'Review an event program', 'Enjoy some refreshments', 'C', 'Đáp án đúng là C (Review an event program) vì:
1. Người nói nói: "please be sure to check your programs for the list of topics, speakers, and locations" (vui lòng đảm bảo kiểm tra chương trình của bạn để biết danh sách các chủ đề, diễn giả và địa điểm).
2. Điều này chỉ ra rõ ràng rằng người nói đang yêu cầu người nghe xem lại chương trình sự kiện.
Dịch các đáp án:
A. Cung cấp phản hồi
B. Tắt điện thoại di động
C. Xem lại chương trình sự kiện
D. Thưởng thức đồ ăn nhẹ');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (83, 4, 'test1_question_83_85.mp3', NULL, 'M-Au: Welcome, everyone. On behalf of the Department of Transportation, I''d like to announce a new experimental program to reduce traffic in Greenville. Beginning in January, there will be a ten-dollar fee for each car that enters the city. There will, however, be a lower fee for people who commute to Greenville for work. They will be asked to pay five dollars rather than ten dollars. These charges are aimed at deterring drivers from coming into this very crowded area, The program will be ineffect for three months. After that, we willdetermine if the program has decreased traffic congestion enough to continue itpermanently.', 'M-Au: Chào mừng mọi người. Thay mặt Bộ Giao thông Vận tải, tôi muốn thông báo một chương trình thử nghiệm mới để giảm giao thông ở Greenville. Bắt đầu từ tháng Giêng, sẽ có một khoản phí mười đô la cho mỗi chiếc xe vào thành phố. Tuy nhiên, sẽ có một khoản phí thấp hơn cho những người đi làm đến Greenville. Họ sẽ được yêu cầu trả năm đô la thay vì mười đô la. Những khoản phí này nhằm mục đích ngăn cản các tài xế đi vào khu vực rất đông đúc này, Chương trình sẽ không có hiệu lực trong ba tháng. Sau đó, chúng tôi sẽ xác định xem chương trình có giảm tắc nghẽn giao thông đủ để tiếp tục vĩnh viễn hay không.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (83, 83, 83, 'What is the purpose of the plan?', 'To support local businesses', 'To promote tourism', 'To decrease traffic', 'To reduce government spending', 'C', 'Đáp án đúng là C (To decrease traffic) vì:
1. Người nói nói: "I''d like to announce a new experimental program to reduce traffic in Greenville" (Tôi muốn thông báo về một chương trình thử nghiệm mới để giảm lưu lượng giao thông ở Greenville).
2. Ông ta cũng nói: "These charges are aimed at deterring drivers from coming into this very crowded area" (Những khoản phí này nhằm ngăn cản các tài xế đi vào khu vực rất đông đúc này).
Điều này chỉ ra rõ ràng rằng mục đích của kế hoạch là giảm lưu lượng giao thông.
Dịch các đáp án:
A. Để hỗ trợ doanh nghiệp địa phương
B. Để thúc đẩy du lịch
C. Để giảm lưu lượng giao thông
D. Để giảm chi tiêu của chính phủ');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (84, 4, 'test1_question_83_85.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (84, 84, 84, 'Who does the speaker say will receive a discount?', 'Commuters', 'Senior citizens', 'Students', 'City officials', 'A', 'Đáp án đúng là A (Commuters) vì:
1. Người nói nói: "There will, however, be a lower fee for people who commute to Greenville for work. They will be asked to pay five dollars rather than ten dollars." (Tuy nhiên, sẽ có mức phí thấp hơn cho những người đi làm đến Greenville. Họ sẽ được yêu cầu trả 5 đô la thay vì 10 đô la.)
2. Điều này chỉ ra rõ ràng rằng những người đi làm (commuters) sẽ nhận được giảm giá.
Dịch các đáp án:
A. Người đi làm
B. Người cao tuổi
C. Sinh viên
D. Các quan chức thành phố');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (85, 4, 'test1_question_83_85.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (85, 85, 85, 'What will happen after three months?', 'A survey will be distributed', 'A new director will take over', 'A bus line will be added', 'A program evaluation will take place', 'D', 'Đáp án đúng là D (A program evaluation will take place) vì:
1. Người nói nói: "The program will be in effect for three months. After that, we will determine if the program has decreased traffic congestion enough to continue it permanently." (Chương trình sẽ có hiệu lực trong ba tháng. Sau đó, chúng tôi sẽ xác định xem chương trình đã giảm ùn tắc giao thông đủ để tiếp tục vĩnh viễn hay không.)
2. Điều này chỉ ra rằng sau ba tháng, sẽ có một đánh giá chương trình để quyết định có tiếp tục hay không.
Dịch các đáp án:
A. Một cuộc khảo sát sẽ được phân phối
B. Một giám đốc mới sẽ tiếp quản
C. Một tuyến xe buýt sẽ được thêm vào
D. Một đánh giá chương trình sẽ diễn ra');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (86, 4, 'test1_question_86_88.mp3', NULL, 'W-Br: Thanks for tuning in to Music Today on Radio. First, a reminder that the Classical Music Festival is this weekend. Radio 49 is giving listeners a chance to win a pair of tickets by entering a contest. And tickets are almost sold out. Just go to our Web site and tell us what you enjoy most on our station, and we''ll pick a winner at random. This year is the tenth anniversary of the event, which was founded by a famous classical musician, Umesh Gupta.
On tomorrow morning''s program, Mr. Gupta will be here for an
interview about the history of the festival. Be sure to join us for that.', 'W-Br: Cảm ơn bạn đã theo dõi Music Today trên Radio. Đầu tiên, một lời nhắc nhở rằng Lễ hội Âm nhạc Cổ điển sẽ diễn ra vào cuối tuần này. Radio 49 đang mang đến cho người nghe cơ hội giành được một cặp vé bằng cách tham gia một cuộc thi. Và vé gần như đã được bán hết. Chỉ cần truy cập trang web của chúng tôi và cho chúng tôi biết bạn thích điều gì nhất trên đài của chúng tôi và chúng tôi sẽ chọn ngẫu nhiên một người chiến thắng. Năm nay là kỷ niệm mười năm sự kiện được thành lập bởi một nhạc sĩ cổ điển nổi tiếng, Umesh Gupta.
Trong chương trình sáng mai, ông Gupta sẽ có mặt ở đây để
phỏng vấn về lịch sử của lễ hội. Hãy chắc chắn tham gia cùng chúng tôi cho điều đó.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (86, 86, 86, 'What event is the speaker discussing?', 'A sports competition', 'A music festival', 'A cooking demonstration', 'A historical play', 'B', 'Đáp án đúng là B (A music festival) vì:
1. Người nói đề cập đến "the Classical Music Festival" (Liên hoan Âm nhạc Cổ điển).
2. Cô ấy nói về việc tổ chức một cuộc thi để giành vé tham dự sự kiện này.
3. Cô ấy cũng đề cập đến việc sự kiện này được thành lập bởi một nhạc sĩ cổ điển nổi tiếng.
Tất cả những điều này chỉ ra rõ ràng rằng sự kiện đang được thảo luận là một liên hoan âm nhạc.
Dịch các đáp án:
A. Một cuộc thi thể thao
B. Một liên hoan âm nhạc
C. Một buổi trình diễn nấu ăn
D. Một vở kịch lịch sử');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (87, 4, 'test1_question_86_88.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (87, 87, 87, 'Why does the speaker say, "tickets are almost sold out"?', 'To encourage the listeners to enter a contest', 'To suggest that the listeners arrive early', 'To complain that an event space is too small', 'To praise the results of a marketing plan', 'A', 'Đáp án đúng là A (To encourage the listeners to enter a contest) vì:
1. Ngay sau khi nói "tickets are almost sold out" (vé đã gần như bán hết), người nói giới thiệu về cuộc thi để giành vé.
2. Cô ấy nói: "Just go to our Web site and tell us what you enjoy most on our station, and we''ll pick a winner at random." (Chỉ cần truy cập trang web của chúng tôi và cho chúng tôi biết điều bạn thích nhất ở đài của chúng tôi, và chúng tôi sẽ chọn ngẫu nhiên một người chiến thắng.)
3. Việc đề cập đến việc vé sắp hết được sử dụng để tạo cảm giác khẩn cấp và khuyến khích người nghe tham gia cuộc thi.
Dịch các đáp án:
A. Để khuyến khích người nghe tham gia một cuộc thi
B. Để đề xuất người nghe đến sớm
C. Để phàn nàn rằng không gian sự kiện quá nhỏ
D. Để khen ngợi kết quả của một kế hoạch tiếp thị');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (88, 4, 'test1_question_86_88.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (88, 88, 88, 'What will happen tomorrow morning?', 'A new venue will open', 'A prize winner will be announced', 'An interview will take place', 'A video will be filmed', 'C', 'Đáp án đúng là C (An interview will take place) vì:
1. Người nói nói: "On tomorrow morning''s program, Mr. Gupta will be here for an interview about the history of the festival." (Trong chương trình sáng mai, ông Gupta sẽ có mặt ở đây để phỏng vấn về lịch sử của liên hoan.)
2. Điều này chỉ ra rõ ràng rằng một cuộc phỏng vấn sẽ diễn ra vào sáng mai.
Dịch các đáp án:
A. Một địa điểm mới sẽ mở cửa
B. Một người chiến thắng giải thưởng sẽ được công bố
C. Một cuộc phỏng vấn sẽ diễn ra
D. Một video sẽ được quay');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (89, 4, 'test1_question_89_91.mp3', NULL, 'W-Am: Thank you for visiting our booth here at the trade fair. We''re so excited to show you our new patio furniture. You''re probably familiar with our wooden outdoor tables and chairs, and we want you to know that we''ve expanded that line to include plastic furniture.
This furniture is very durable. It can withstand any kind of weather - and it needs no maintenance. I''m going to hand out a sample of the plastic material we use. Please pass it around after you''ve had a chance to look atit.', 'W-Am: Cảm ơn bạn đã ghé thăm gian hàng của chúng tôi tại hội chợ thương mại. Chúng tôi rất vui mừng được giới thiệu cho bạn đồ nội thất sân mới của chúng tôi. Bạn có thể quen thuộc với bàn ghế gỗ ngoài trời của chúng tôi và chúng tôi muốn bạn biết rằng chúng tôi đã mở rộng dòng sản phẩm đó để bao gồm đồ nội thất bằng nhựa.
Đồ nội thất này rất bền. Nó có thể chịu được mọi loại thời tiết - và nó không cần bảo trì. Tôi sẽ phát một mẫu vật liệu nhựa mà chúng tôi sử dụng. Vui lòng chuyển nó xung quanh sau khi bạn có cơ hội xem nó.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (89, 89, 89, 'What type of business does the speaker work for?', 'A computer company', 'A construction firm', 'A furniture manufacturer', 'An office-supply distributor', 'C', 'Đáp án đúng là C (A furniture manufacturer) vì:
1. Người nói đề cập đến "our new patio furniture" (đồ nội thất sân vườn mới của chúng tôi).
2. Cô ấy cũng nói về "our wooden outdoor tables and chairs" (bàn ghế ngoài trời bằng gỗ của chúng tôi).
3. Cô ấy đang giới thiệu về sản phẩm nội thất mới của công ty.
Tất cả những điều này chỉ ra rõ ràng rằng người nói làm việc cho một nhà sản xuất nội thất.
Dịch các đáp án:
A. Một công ty máy tính
B. Một công ty xây dựng
C. Một nhà sản xuất nội thất
D. Một nhà phân phối văn phòng phẩm');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (90, 4, 'test1_question_89_91.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (90, 90, 90, 'What does the speaker say is an advantage of the new material?', 'It is inexpensive', 'It is durable', 'It is lightweight', 'It comes in many colors', 'B', 'Đáp án đúng là B (It is durable) vì:
1. Người nói nói: "This furniture is very durable. It can withstand any kind of weather - and it needs no maintenance." (Đồ nội thất này rất bền. Nó có thể chịu được mọi loại thời tiết - và không cần bảo trì.)
2. Điều này chỉ ra rõ ràng rằng tính bền bỉ là một lợi thế của vật liệu mới.
Dịch các đáp án:
A. Nó rẻ tiền
B. Nó bền bỉ
C. Nó nhẹ
D. Nó có nhiều màu sắc');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (91, 4, 'test1_question_89_91.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (91, 91, 91, 'What will the listeners do next?', 'Sign up for a mailing list', 'Watch an instructional video', 'Enter a contest', 'Look at a sample', 'D', 'Đáp án đúng là D (Look at a sample) vì:
1. Người nói nói: "I''m going to hand out a sample of the plastic material we use. Please pass it around after you''ve had a chance to look at it." (Tôi sẽ phát một mẫu vật liệu nhựa mà chúng tôi sử dụng. Vui lòng chuyển nó xung quanh sau khi bạn đã có cơ hội xem xét nó.)
2. Điều này chỉ ra rõ ràng rằng người nghe sẽ xem xét một mẫu vật liệu tiếp theo.
Dịch các đáp án:
A. Đăng ký vào danh sách gửi thư
B. Xem một video hướng dẫn
C. Tham gia một cuộc thi
D. Xem xét một mẫu vật');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (92, 4, 'test1_question_92_94.mp3', NULL, 'W-Br: This is Noriko, the human resources supervisor here in Albany. I''m calling about your request to transfer toour branch in Havertown... I know your commute is difficult, and it takes You overan hour to drive to this office. So I''ve contacted the manager at that location, andthere is a need for a skilled software engineer. There are a few forms that you''llneed to fill out, though, to complete the request.
Now we need to talk about your work schedule to decide when you''ll start at the new location. Please call me back.', 'W-Br: Đây là Noriko, giám sát nhân sự ở Albany. Tôi đang gọi về yêu cầu chuyển khoản của bạn đến chi nhánh của chúng tôi ở Havertown... Tôi biết việc đi lại của bạn rất khó khăn, và Bạn mất hơn một giờ để lái xe đến văn phòng này. Vì vậy, tôi đã liên hệ với người quản lý tại địa điểm đó và cần một kỹ sư phần mềm lành nghề. Tuy nhiên, có một vài biểu mẫu mà bạn sẽ cần điền vào để hoàn thành yêu cầu.
Bây giờ chúng ta cần nói về lịch làm việc của bạn để quyết định khi nào bạn sẽ bắt đầu tại địa điểm mới. Vui lòng gọi lại cho tôi.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (92, 92, 92, 'Which department does the speaker work in?', 'Product Development', 'Human Resources', 'Legal', 'Accounting', 'B', 'Đáp án đúng là B (Human Resources) vì:
1. Người nói giới thiệu bản thân là "Noriko, the human resources supervisor here in Albany" (Noriko, giám sát nhân sự ở đây tại Albany).
2. Điều này chỉ ra rõ ràng rằng cô ấy làm việc trong bộ phận Nhân sự.
Dịch các đáp án:
A. Phát triển sản phẩm
B. Nhân sự
C. Pháp lý
D. Kế toán');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (93, 4, 'test1_question_92_94.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (93, 93, 93, 'Why does the speaker say, "there is a need for a skilled software engineer"?', 'To recommend an employee sign up for more training', 'To indicate that a project deadline will be extended', 'To approve a request to transfer', 'To suggest consulting with an expert', 'C', 'Đáp án đúng là C (To approve a request to transfer) vì:
1. Người nói đang nói về yêu cầu chuyển nhượng của nhân viên.
2. Cô ấy nói rằng có nhu cầu về một kỹ sư phần mềm có kỹ năng ở địa điểm mới.
3. Điều này ngụ ý rằng yêu cầu chuyển nhượng của nhân viên có thể được chấp thuận vì có vị trí phù hợp ở chi nhánh mới.
Dịch các đáp án:
A. Để đề xuất nhân viên đăng ký thêm khóa đào tạo
B. Để chỉ ra rằng thời hạn của một dự án sẽ được gia hạn
C. Để chấp thuận yêu cầu chuyển nhượng
D. Để đề xuất tham khảo ý kiến của một chuyên gia');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (94, 4, 'test1_question_92_94.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (94, 94, 94, 'What does the speaker want to discuss with the listener?', 'Some sales results', 'Some client feedback', 'An office renovation', 'A work schedule', 'D', 'Đáp án đúng là D (A work schedule) vì:
1. Người nói nói: "Now we need to talk about your work schedule to decide when you''ll start at the new location." (Bây giờ chúng ta cần nói về lịch làm việc của bạn để quyết định khi nào bạn sẽ bắt đầu tại địa điểm mới.)
2. Điều này chỉ ra rõ ràng rằng người nói muốn thảo luận về lịch làm việc với người nghe.
Dịch các đáp án:
A. Một số kết quả bán hàng
B. Một số phản hồi từ khách hàng
C. Một cuộc cải tạo văn phòng
D. Một lịch làm việc');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (95, 4, 'test1_question_95_97.mp3', 'test1-p4-image-95.jpg', 'M-Cn: You''re listening to Making My Company with Mark Sullivan. In each episode, I invite entrepreneurs from around the world to talk about how they built their successful businesses. In celebration of our radio show''s ten-year anniversary, our Web site now has all of our previously aired episodes. You can access them with the click of a button. You can even download them onto mobile devices to listen to on the go! OK, now, I welcome Haru Nakamura to the show. Ms. Nakamura is excited to be here today.', 'M-Cn: Bạn đang nghe Making My Company with Mark Sullivan. Trong mỗi tập, tôi mời các doanh nhân từ khắp nơi trên thế giới nói về cách họ xây dựng doanh nghiệp thành công của mình. Để kỷ niệm mười năm chương trình phát thanh của chúng tôi, trang web của chúng tôi hiện có tất cả các tập đã phát sóng trước đó của chúng tôi. Bạn có thể truy cập chúng chỉ bằng một cú nhấp chuột. Bạn thậm chí có thể tải chúng xuống thiết bị di động để nghe khi đang di chuyển! Được rồi, bây giờ, tôi chào đón Haru Nakamura đến với chương trình. Cô Nakamura rất vui khi có mặt ở đây hôm nay.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (95, 95, 95, 'Why are guests invited on the speaker''s radio show?', 'To discuss their businesses', 'To talk about local history', 'To teach communication skills', 'To offer travel tips', 'A', 'Đáp án đúng là A (To discuss their businesses) vì:
1. Người nói nói: "In each episode, I invite entrepreneurs from around the world to talk about how they built their successful businesses." (Trong mỗi tập, tôi mời các doanh nhân từ khắp nơi trên thế giới đến nói về cách họ xây dựng doanh nghiệp thành công của mình.)
2. Điều này chỉ ra rõ ràng rằng mục đích của việc mời khách là để thảo luận về doanh nghiệp của họ.
Dịch các đáp án:
A. Để thảo luận về doanh nghiệp của họ
B. Để nói về lịch sử địa phương
C. Để dạy kỹ năng giao tiếp
D. Để đưa ra lời khuyên du lịch');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (96, 4, 'test1_question_95_97.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (96, 96, 96, 'What can the listeners do on a Web site?', 'View photos of famous guests', 'Sign up for a special service', 'Read about upcoming programs', 'Listen to previous episodes', 'D', 'Đáp án đúng là D (Listen to previous episodes) vì:
1. Người nói nói: "our Web site now has all of our previously aired episodes. You can access them with the click of a button." (trang web của chúng tôi hiện có tất cả các tập đã phát sóng trước đây. Bạn có thể truy cập chúng chỉ bằng một cú nhấp chuột.)
2. Điều này chỉ ra rõ ràng rằng người nghe có thể nghe các tập trước đó trên trang web.
Dịch các đáp án:
A. Xem ảnh của những khách mời nổi tiếng
B. Đăng ký một dịch vụ đặc biệt
C. Đọc về các chương trình sắp tới
D. Nghe các tập trước đó');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (97, 4, 'test1_question_95_97.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (97, 97, 97, 'Look at the graphic. Which day is this episode being aired?', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'C', 'Đáp án đúng là C (Thursday) vì:
1. Trong bảng "This Week''s Guests", Haru Nakamura được liệt kê vào ngày Thứ Năm (Thursday).
2. Người nói chào đón Haru Nakamura đến với chương trình: "I welcome Haru Nakamura to the show."
3. Do đó, tập này đang được phát sóng vào ngày Thứ Năm.
Dịch các đáp án:
A. Thứ Ba
B. Thứ Tư
C. Thứ Năm
D. Thứ Sáu');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (98, 4, 'test1_question_98_100.mp3', 'test1-p4-image-98.jpg', 'M-Au: It''s Akira, calling from the district manager''s office. The visual merchandising team wants to make a slight change to the fall display standards that we sent you yesterday. They want to move the shirts with the vertical stripes-hang them instead of having them displayed on the shelf. We''ll display some colorful accessories there instead, like scarves and ties. Also, hang all the socks on grid wall panels by the cash registers. Those sell best when people can grab them when they walk up to pay. The thicker, cold-weather socks will be shipped to you soon. You''ll get an e-mail confirmation with the details when they''re sent.', 'M-Au: Đó là Akira, gọi từ văn phòng quản lý quận. Nhóm bán hàng trực quan muốn thực hiện một thay đổi nhỏ đối với các tiêu chuẩn trưng bày mùa thu mà chúng tôi đã gửi cho bạn ngày hôm qua. Họ muốn di chuyển những chiếc áo có sọc dọc - treo chúng thay vì trưng bày chúng trên kệ. Thay vào đó, chúng tôi sẽ trưng bày một số phụ kiện đầy màu sắc ở đó, như khăn quàng cổ và cà vạt. Ngoài ra, treo tất cả tất trên các tấm tường lưới bên cạnh máy tính tiền. Những thứ đó bán chạy nhất khi mọi người có thể lấy chúng khi họ bước lên để thanh toán. Những đôi tất dày hơn, thời tiết lạnh sẽ sớm được giao cho bạn. Bạn sẽ nhận được email xác nhận với các chi tiết khi chúng được gửi đi.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (98, 98, 98, 'Look at the graphic. Where will the scarves and ties be displayed?', 'On Shelf 1', 'On Shelf 2', 'On Shelf 3', 'On Shelf 4', 'A', 'Đáp án đúng là A (On Shelf 1) vì:
1. Người nói nói rằng họ muốn di chuyển áo sơ mi sọc dọc khỏi kệ và treo chúng lên.
2. Thay vào đó, họ sẽ trưng bày các phụ kiện có màu sắc như khăn quàng cổ và cà vạt ở đó.
3. Trong hình ảnh, áo sơ mi sọc dọc đang được hiển thị trên Shelf 1.
4. Do đó, khăn quàng cổ và cà vạt sẽ được trưng bày trên Shelf 1.
Dịch các đáp án:
A. Trên Kệ 1
B. Trên Kệ 2
C. Trên Kệ 3
D. Trên Kệ 4');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (99, 4, 'test1_question_98_100.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (99, 99, 99, 'What should be displayed near the cash registers?', 'Coupons', 'Hats', 'Gloves', 'Socks', 'D', 'Đáp án đúng là D (Socks) vì:
1. Người nói nói: "Also, hang all the socks on grid wall panels by the cash registers." (Ngoài ra, hãy treo tất cả các đôi tất lên các tấm lưới gần quầy thu ngân.)
2. Ông ta giải thích rằng những đôi tất này bán chạy nhất khi mọi người có thể lấy chúng khi đi đến quầy thanh toán.
Dịch các đáp án:
A. Phiếu giảm giá
B. Mũ
C. Găng tay
D. Tất');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (100, 4, 'test1_question_98_100.mp3', NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (100, 100, 100, 'What should the listener expect to receive in an e-mail?', 'A payment schedule', 'Photographs', 'Shipping information', 'Display measurements', 'C', 'Đáp án đúng là C (Shipping information) vì:
1. Người nói nói: "The thicker, cold-weather socks will be shipped to you soon. You''ll get an e-mail confirmation with the details when they''re sent." (Những đôi tất dày hơn cho thời tiết lạnh sẽ sớm được gửi đến cho bạn. Bạn sẽ nhận được một email xác nhận với các chi tiết khi chúng được gửi đi.)
2. Điều này chỉ ra rằng người nghe sẽ nhận được thông tin vận chuyển qua email.
Dịch các đáp án:
A. Một lịch thanh toán
B. Các bức ảnh
C. Thông tin vận chuyển
D. Các kích thước trưng bày');

-- Data for 2022 Test1 Part 5
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (101, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (101, 101, 101, 'Mougey Fine Gifts is known for its large range of ----- goods.', 'regional', 'regionally', 'region', 'regions', 'A', 'Đáp án đúng là (A) regional. Từ "regional" là tính từ, phù hợp để mô tả danh từ "goods" (hàng hóa). Cấu trúc "adjective + noun" là phổ biến trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa.
Dịch: Mougey Fine Gifts nổi tiếng với phạm vi rộng các mặt hàng --.
A. khu vực (tính từ)
B. theo khu vực (trạng từ)
C. khu vực (danh từ)
D. các khu vực (danh từ số nhiều)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (102, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (102, 102, 102, 'Income levels are rising in the —--- and surrounding areas.', 'family', 'world', 'company', 'city', 'D', 'Đáp án đúng là (D) city. Trong ngữ cảnh này, "city" (thành phố) là lựa chọn hợp lý nhất khi nói về mức thu nhập đang tăng lên trong một khu vực cụ thể và vùng lân cận. Các đáp án khác không phù hợp với ngữ cảnh về địa lý.
Dịch: Mức thu nhập đang tăng lên ở --- và các khu vực xung quanh.
A. gia đình (danh từ)
B. thế giới (danh từ)
C. công ty (danh từ)
D. thành phố (danh từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (103, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (103, 103, 103, 'Since we had a recent rate change, expect ----- next electricity bill to be slightly lower.', 'you', 'yours', 'yourself', 'your', 'D', 'Đáp án đúng là (D) your. "Your" là tính từ sở hữu, phù hợp để đứng trước danh từ "bill" (hóa đơn). Cấu trúc "possessive adjective + noun" là chính xác trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp trong ngữ cảnh này.
Dịch: Vì chúng tôi vừa có sự thay đổi về giá, hãy mong đợi hóa đơn tiền điện -- tiếp theo sẽ thấp hơn một chút.
A. bạn (đại từ nhân xưng)
B. của bạn (đại từ sở hữu)
C. chính bạn (đại từ phản thân)
D. của bạn (tính từ sở hữu)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (104, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (104, 104, 104, 'Hotel guests have a lovely view of the ocean ---- the south-facing windows.', 'up', 'except', 'onto', 'through', 'D', 'Đáp án đúng là (D) through. Giới từ "through" (qua) phù hợp nhất để diễn tả việc nhìn qua cửa sổ. Cấu trúc "view + of + something + through + something" là phổ biến khi mô tả tầm nhìn. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Khách của khách sạn có tầm nhìn tuyệt đẹp ra đại dương --- những cửa sổ hướng nam.
A. lên (giới từ)
B. ngoại trừ (giới từ)
C. lên trên (giới từ)
D. qua (giới từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (105, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (105, 105, 105, 'Mr. Kim would like ---- a meeting about the Jasper account as soon as possible.', 'to arrange', 'arranging', 'having arranged', 'arrangement', 'A', 'Đáp án đúng là (A) to arrange. Cấu trúc "would like + to infinitive" được sử dụng để diễn đạt mong muốn làm gì đó. Đây là cấu trúc phổ biến trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
Dịch: Ông Kim muốn ---- một cuộc họp về tài khoản Jasper càng sớm càng tốt.
A. sắp xếp (động từ nguyên mẫu)
B. đang sắp xếp (động từ -ing)
C. đã sắp xếp xong (động từ hoàn thành)
D. sự sắp xếp (danh từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (106, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (106, 106, 106, 'The factory is ----- located near the train station.', 'regularly', 'conveniently', 'brightly', 'collectively', 'B', 'Đáp án đúng là (B) conveniently. Trạng từ "conveniently" (thuận tiện) phù hợp nhất để mô tả vị trí của nhà máy gần ga tàu. Cấu trúc "be + adverb + past participle" được sử dụng để mô tả trạng thái. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Nhà máy được đặt -- gần ga tàu.
A. thường xuyên (trạng từ)
B. thuận tiện (trạng từ)
C. sáng sủa (trạng từ)
D. tập thể (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (107, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (107, 107, 107, 'Because of transportation ----- due to winter weather, some conference participants may arrive late.', 'are delayed', 'to delay', 'delays', 'had delayed', 'C', 'Đáp án đúng là (C) delays. "Delays" (sự chậm trễ) là danh từ số nhiều, phù hợp để đi sau "because of" và trước "due to". Cấu trúc "because of + noun + due to + noun phrase" là chính xác. Các đáp án khác không phù hợp về mặt ngữ pháp trong ngữ cảnh này.
Dịch: Do những sự chậm trễ về giao thông --- thời tiết mùa đông, một số người tham dự hội nghị có thể đến muộn.
A. bị trì hoãn (động từ)
B. để trì hoãn (động từ nguyên mẫu)
C. những sự chậm trễ (danh từ số nhiều)
D. đã trì hoãn (động từ quá khứ hoàn thành)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (108, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (108, 108, 108, 'Proper maintenance of your heating equipment ensures that small issues can be fixed --- they become big ones.', 'as a result', 'in addition', 'although', 'before', 'D', 'Đáp án đúng là (D) before. Liên từ "before" (trước khi) phù hợp nhất để diễn tả mối quan hệ thời gian giữa việc sửa chữa vấn đề nhỏ và trước khi chúng trở thành vấn đề lớn. Cấu trúc "verb + before + clause" là phổ biến trong tiếng Anh. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Việc bảo trì đúng cách thiết bị sưởi của bạn đảm bảo rằng các vấn đề nhỏ có thể được sửa chữa --- chúng trở thành những vấn đề lớn.
A. kết quả là (cụm từ nối)
B. thêm vào đó (cụm từ nối)
C. mặc dù (liên từ)
D. trước khi (liên từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (109, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (109, 109, 109, 'The information on the Web site of Croyell Decorators is ----- organized.', 'clear', 'clearing', 'clearest', 'clearly', 'D', 'Đáp án đúng là (D) clearly. Trạng từ "clearly" (rõ ràng) phù hợp để bổ nghĩa cho tính từ "organized". Cấu trúc "be + adverb + adjective" là chính xác trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa trong ngữ cảnh này.
Dịch: Thông tin trên trang web của Croyell Decorators được tổ chức -----.
A. rõ ràng (tính từ)
B. đang làm rõ (động từ -ing)
C. rõ ràng nhất (tính từ so sánh nhất)
D. một cách rõ ràng (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (110, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (110, 110, 110, 'The Copley Corporation is frequently ----- as a company that employs workers from all over the world.', 'recognized', 'permitted', 'prepared', 'controlled', 'A', 'Đáp án đúng là (A) recognized. Động từ "recognized" (được công nhận) phù hợp nhất với ngữ cảnh về danh tiếng của công ty. Cấu trúc "be + adverb + past participle" được sử dụng để mô tả trạng thái thụ động. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Công ty Copley thường xuyên được -- như một công ty tuyển dụng công nhân từ khắp nơi trên thế giới.
A. công nhận (động từ quá khứ phân từ)
B. cho phép (động từ quá khứ phân từ)
C. chuẩn bị (động từ quá khứ phân từ)
D. kiểm soát (động từ quá khứ phân từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (111, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (111, 111, 111, 'Payments made -------- 4:00 p.M. will be processed on the following business day.', 'later', 'after', 'than', 'often', 'B', 'Đáp án đúng là (B) after. Giới từ "after" (sau) phù hợp nhất để chỉ thời gian trong ngữ cảnh này. Cấu trúc "after + time" là phổ biến trong tiếng Anh để chỉ thời điểm. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa trong câu này.
Dịch: Các khoản thanh toán được thực hiện --- 4:00 chiều sẽ được xử lý vào ngày làm việc tiếp theo.
A. muộn hơn (trạng từ so sánh)
B. sau (giới từ)
C. hơn (liên từ so sánh)
D. thường xuyên (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (112, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (112, 112, 112, 'Greenfiddle Water Treatment hires engineers who have ------- mathematics skills.', 'adjusted', 'advanced', 'eager', 'faithful', 'B', 'Đáp án đúng là (B) advanced. Tính từ "advanced" (nâng cao) phù hợp nhất để mô tả kỹ năng toán học ở mức độ cao. Cấu trúc "have + adjective + noun" được sử dụng để mô tả phẩm chất hoặc kỹ năng. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Công ty Xử lý Nước Greenfiddle tuyển dụng các kỹ sư có kỹ năng toán học -------.
A. đã điều chỉnh (tính từ)
B. nâng cao (tính từ)
C. háo hức (tính từ)
D. trung thành (tính từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (113, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (113, 113, 113, 'After ----- the neighborhood, Mr. Park decided not to move his café to Thomasville.', 'evaluation', 'evaluate', 'evaluating', 'evaluated', 'C', 'Đáp án đúng là (C) evaluating. Động từ -ing "evaluating" phù hợp sau giới từ "after". Cấu trúc "after + verb-ing" (sau khi làm gì) là cấu trúc phổ biến trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
Dịch: Sau khi ----- khu phố, ông Park quyết định không chuyển quán cà phê của mình đến Thomasville.
A. sự đánh giá (danh từ)
B. đánh giá (động từ nguyên mẫu)
C. đánh giá (động từ -ing)
D. được đánh giá (động từ quá khứ phân từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (114, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (114, 114, 114, 'The average precipitation in Campos ------ the past three years has been 22.7 centimeters.', 'on', 'for', 'to', 'under', 'B', 'Đáp án đúng là (B) for. Giới từ "for" (trong) phù hợp nhất để chỉ khoảng thời gian trong ngữ cảnh này. Cấu trúc "for + time period" được sử dụng để chỉ thời gian kéo dài. Các đáp án khác không phù hợp về nghĩa trong câu này.
Dịch: Lượng mưa trung bình ở Campos ------ ba năm qua là 22,7 centimet.
A. vào (giới từ)
B. trong (giới từ)
C. đến (giới từ)
D. dưới (giới từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (115, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (115, 115, 115, 'Improving efficiency at Perwon Manufacturing will require a ----- revision of existing processes.', 'create', 'creativity', 'creation', 'creative', 'D', 'Đáp án đúng là (D) creative. Tính từ "creative" (sáng tạo) phù hợp để mô tả danh từ "revision" (sự xem xét lại). Cấu trúc "adjective + noun" là phổ biến trong tiếng Anh. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa trong ngữ cảnh này.
Dịch: Việc cải thiện hiệu quả tại Perwon Manufacturing sẽ đòi hỏi một sự xem xét lại -- các quy trình hiện có.
A. tạo ra (động từ)
B. sự sáng tạo (danh từ)
C. sự tạo ra (danh từ)
D. sáng tạo (tính từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (116, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (116, 116, 116, 'Conference attendees will share accommodations ---- they submit a special request for a single room.', 'even', 'unless', 'similarly', 'also', 'B', 'Đáp án đúng là (B) unless. Liên từ "unless" (trừ khi) phù hợp nhất để diễn tả một ngoại lệ hoặc điều kiện. Cấu trúc "unless + clause" được sử dụng để chỉ ra một điều kiện mà nếu không xảy ra thì hành động chính sẽ diễn ra. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Những người tham dự hội nghị sẽ chia sẻ chỗ ở ---- họ gửi yêu cầu đặc biệt cho một phòng đơn.
A. thậm chí (trạng từ)
B. trừ khi (liên từ)
C. tương tự (trạng từ)
D. cũng (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (117, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (117, 117, 117, 'To receive -----, please be sure the appropriate box is checked on the magazine order form.', 'renew', 'renewed', 'renewals', 'to renew', 'C', 'Đáp án đúng là (C) renewals. Danh từ số nhiều "renewals" (các lần gia hạn) phù hợp nhất trong ngữ cảnh này, vì nó là đối tượng trực tiếp của động từ "receive". Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
Dịch: Để nhận được —, vui lòng đảm bảo ô thích hợp được đánh dấu trên mẫu đơn đặt tạp chí.
A. gia hạn (động từ)
B. được gia hạn (tính từ)
C. các lần gia hạn (danh từ số nhiều)
D. để gia hạn (động từ nguyên mẫu)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (118, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (118, 118, 118, 'Donations to the Natusi Wildlife Reserve rise when consumers feel ------ about the economy.', 'careful', 'helpful', 'confident', 'durable', 'C', 'Đáp án đúng là (C) confident. Tính từ "confident" (tự tin) phù hợp nhất để mô tả cảm xúc của người tiêu dùng về nền kinh tế. Cấu trúc "feel + adjective" được sử dụng để diễn tả cảm xúc. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Các khoản đóng góp cho Khu Bảo tồn Động vật Hoang dã Natusi tăng lên khi người tiêu dùng cảm thấy ------ về nền kinh tế.
A. cẩn thận (tính từ)
B. hữu ích (tính từ)
C. tự tin (tính từ)
D. bền bỉ (tính từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (119, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (119, 119, 119, 'When ----- applied, Tilda''s Restorative Cream reduces the appearance of fine lines and wrinkles.', 'consistent', 'consist', 'consistently', 'consisting', 'C', 'Đáp án đúng là (C) consistently. Trạng từ "consistently" (một cách nhất quán) phù hợp nhất để mô tả cách thức áp dụng kem. Cấu trúc "when + adverb + past participle" được sử dụng để mô tả cách thức hoặc điều kiện. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
Dịch: Khi được áp dụng --, Kem Phục hồi Tilda làm giảm sự xuất hiện của các nếp nhăn và vết chân chim.
A. nhất quán (tính từ)
B. bao gồm (động từ)
C. một cách nhất quán (trạng từ)
D. đang bao gồm (động từ -ing)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (120, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (120, 120, 120, 'The marketing director confirmed that the new software program would be ready to ---- by November 1.', 'launch', 'facilitate', 'arise', 'exert', 'A', 'Đáp án đúng là (A) launch. Động từ "launch" (ra mắt) phù hợp nhất trong ngữ cảnh về việc chuẩn bị một chương trình phần mềm mới. Cấu trúc "be ready to + infinitive" được sử dụng để diễn tả sự sẵn sàng để thực hiện một hành động. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Giám đốc tiếp thị xác nhận rằng chương trình phần mềm mới sẽ sẵn sàng để ---- vào ngày 1 tháng 11.
A. ra mắt (động từ)
B. tạo điều kiện (động từ)
C. nảy sinh (động từ)
D. thực hiện (động từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (121, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (121, 121, 121, 'Satinesse Seat Covers will refund your order ----- you are not completely satisfied.', 'if', 'yet', 'until', 'neither', 'A', 'Đáp án đúng là (A) if. Liên từ "if" (nếu) phù hợp nhất để diễn tả điều kiện cho việc hoàn tiền. Cấu trúc "if + clause" được sử dụng để chỉ ra một điều kiện. Các đáp án khác không phù hợp về nghĩa hoặc ngữ pháp trong ngữ cảnh này.
Dịch: Satinesse Seat Covers sẽ hoàn tiền đơn hàng của bạn -- bạn không hoàn toàn hài lòng.
A. nếu (liên từ)
B. tuy nhiên (liên từ)
C. cho đến khi (liên từ)
D. cũng không (phó từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (122, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (122, 122, 122, 'In the last five years, production at the Harris facility has almost doubled in ----.', 'majority', 'edition', 'volume', 'economy', 'C', 'Đáp án đúng là (C) volume. Danh từ "volume" (khối lượng) phù hợp nhất để mô tả sự tăng trưởng trong sản xuất. Cấu trúc "double in + noun" được sử dụng để chỉ ra phương diện tăng gấp đôi. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Trong năm năm qua, sản lượng tại cơ sở Harris đã tăng gần gấp đôi về ----.
A. đa số (danh từ)
B. phiên bản (danh từ)
C. khối lượng (danh từ)
D. kinh tế (danh từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (123, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (123, 123, 123, 'Ms. Tsai will ---- the installation of the new workstations with the vendor.', 'coordinated', 'to coordinate', 'coordination', 'be coordinating', 'D', 'Đáp án đúng là (D) be coordinating. Cấu trúc "will be + verb-ing" (tương lai tiếp diễn) phù hợp để diễn tả một hành động sẽ đang diễn ra trong tương lai. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
Dịch: Cô Tsai sẽ ---- việc lắp đặt các trạm làm việc mới với nhà cung cấp.
A. đã phối hợp (động từ quá khứ)
B. để phối hợp (động từ nguyên mẫu)
C. sự phối hợp (danh từ)
D. đang phối hợp (động từ ở dạng tiếp diễn)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (124, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (124, 124, 124, 'An upgrade in software would increase the productivity of our administrative staff ----.', 'significantly', 'persuasively', 'proficiently', 'gladly', 'A', 'Đáp án đúng là (A) significantly. Trạng từ "significantly" (đáng kể) phù hợp nhất để mô tả mức độ tăng năng suất. Cấu trúc "verb + adverb" được sử dụng để mô tả cách thức hoặc mức độ của hành động. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Một bản nâng cấp phần mềm sẽ tăng năng suất của nhân viên hành chính của chúng tôi ----.
A. đáng kể (trạng từ)
B. thuyết phục (trạng từ)
C. thành thạo (trạng từ)
D. vui vẻ (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (125, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (125, 125, 125, 'The Rustic Diner''s chef does allow patrons to make menu ----.', 'substituted', 'substituting', 'substitutions', 'substitute', 'C', 'Đáp án đúng là (C) substitutions. Danh từ số nhiều "substitutions" (sự thay thế) phù hợp nhất trong ngữ cảnh này, vì nó là đối tượng trực tiếp của cụm "make menu". Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa trong cấu trúc này.
Dịch: Đầu bếp của Nhà hàng Rustic cho phép khách hàng thực hiện các ---- trong thực đơn.
A. được thay thế (tính từ)
B. đang thay thế (động từ -ing)
C. sự thay thế (danh từ số nhiều)
D. thay thế (động từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (126, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (126, 126, 126, 'Ms. Rodriguez noted that it is important to ---- explicit policies regarding the use of company computers.', 'inform', 'succeed', 'estimate', 'establish', 'D', 'Đáp án đúng là (D) establish. Động từ "establish" (thiết lập) phù hợp nhất trong ngữ cảnh về việc tạo ra các chính sách. Cấu trúc "it is important to + infinitive" được sử dụng để diễn tả tầm quan trọng của một hành động. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Cô Rodriguez lưu ý rằng việc ---- các chính sách rõ ràng về việc sử dụng máy tính công ty là quan trọng.
A. thông báo (động từ)
B. thành công (động từ)
C. ước tính (động từ)
D. thiết lập (động từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (127, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (127, 127, 127, '---- Peura Insurance has located a larger office space, it will begin negotiating the rental agreement.', 'Happily', 'Now that', 'Despite', 'In fact', 'B', 'Đáp án đúng là (B) Now that. Cụm từ nối "Now that" (Bây giờ khi) phù hợp nhất để diễn tả một sự kiện vừa xảy ra và dẫn đến một hành động tiếp theo. Cấu trúc "Now that + clause, main clause" được sử dụng để chỉ ra mối quan hệ nhân quả. Các đáp án khác không phù hợp về nghĩa hoặc ngữ pháp trong ngữ cảnh này.
Dịch: ---- Peura Insurance đã tìm được một không gian văn phòng lớn hơn, họ sẽ bắt đầu đàm phán hợp đồng thuê.
A. May mắn thay (trạng từ)
B. Bây giờ khi (cụm từ nối)
C. Mặc dù (giới từ)
D. Thực tế là (cụm từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (128, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (128, 128, 128, 'Mr. Tanaka''s team worked ----- for months to secure a lucrative government contract.', 'readily', 'diligently', 'curiously', 'extremely', 'B', 'Đáp án đúng là (B) diligently. Trạng từ "diligently" (cần mẫn) phù hợp nhất để mô tả cách thức làm việc của nhóm. Cấu trúc "work + adverb" được sử dụng để mô tả cách thức làm việc. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
Dịch: Nhóm của ông Tanaka đã làm việc ----- trong nhiều tháng để đảm bảo một hợp đồng chính phủ béo bở.
A. sẵn sàng (trạng từ)
B. cần mẫn (trạng từ)
C. tò mò (trạng từ)
D. cực kỳ (trạng từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (129, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (129, 129, 129, 'Though Sendark Agency''s travel insurance can be purchased over the phone, most of ----- plans are bought online.', 'whose', 'his', 'its', 'this', 'C', 'Đáp án đúng là (C) its. Tính từ sở hữu "its" (của nó) phù hợp nhất để chỉ đến các kế hoạch của Sendark Agency. Cấu trúc "possessive adjective + noun" được sử dụng để chỉ sự sở hữu. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc nghĩa trong ngữ cảnh này.
Dịch: Mặc dù bảo hiểm du lịch của Đại lý Sendark có thể được mua qua điện thoại, hầu hết các kế hoạch → được mua trực tuyến.
A. của ai (đại từ sở hữu)
B. của anh ấy (tính từ sở hữu)
C. của nó (tính từ sở hữu)
D. này (tính từ chỉ định)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (130, 5, NULL, NULL, NULL, NULL);
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (130, 130, 130, 'Garstein Furniture specializes in functional products that are inexpensive ------ beautifully crafted.', 'thus', 'as well as', 'at last', 'accordingly', 'B', 'Đáp án đúng là (B) as well as. Cụm từ nối "as well as" (cũng như) phù hợp nhất để kết nối hai đặc điểm của sản phẩm. Cấu trúc "adjective + as well as + adjective" được sử dụng để liệt kê các đặc điểm bổ sung. Các đáp án khác không phù hợp về nghĩa hoặc ngữ pháp trong ngữ cảnh này.
Dịch: Garstein Furniture chuyên về các sản phẩm chức năng vừa rẻ ------ được chế tác đẹp.
A. do đó (liên từ)
B. cũng như (cụm từ nối)
C. cuối cùng (cụm từ)
D. theo đó (trạng từ)');

-- Data for 2022 Test1 Part 6
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (131, 6, NULL, NULL, 'NOTICE
To continue providing the highest level of 131----- to our corporate tenants, we have scheduled the south lobby restrooms for maintenance this weekend, May 13 and May 14. 132---- this time, the restrooms will be out of order, so tenants and their guests should instead use the facilities in the north lobby.
We 133---- for any inconvenience this might cause. 134----
Denville Property Management Partners', 'THÔNG BÁO
Để tiếp tục cung cấp mức cao nhất là 131------ cho những người thuê công ty của chúng tôi, chúng tôi đã lên lịch bảo trì nhà vệ sinh ở sảnh phía nam vào cuối tuần này, ngày 13 tháng 5 và ngày 14 tháng 5. 132 ----- lần này, các nhà vệ sinh sẽ không hoạt động, vì vậy người thuê và khách của họ nên sử dụng các cơ sở ở sảnh phía bắc.
Chúng tôi 133---- vì bất kỳ sự bất tiện nào mà điều này có thể gây ra. 134---
Đối tác quản lý bất động sản ở Denville');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (131, 131, 131, NULL, 'serve', 'served', 'server', 'service', 'D', 'Đáp án đúng là (D) service. Danh từ "service" (dịch vụ) phù hợp nhất để hoàn thành cụm từ "highest level of service" (mức độ dịch vụ cao nhất). Cấu trúc "level of + noun" được sử dụng để chỉ mức độ của một thứ gì đó. Các đáp án khác không phù hợp về mặt ngữ pháp hoặc ngữ nghĩa trong ngữ cảnh này.
A. phục vụ (động từ)
B. đã phục vụ (động từ quá khứ)
C. máy chủ (danh từ)
D. dịch vụ (danh từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (132, 131, 132, NULL, 'Along', 'During', 'Without', 'Between', 'B', 'Đáp án đúng là (B) During. Giới từ "During" (Trong) phù hợp nhất để chỉ khoảng thời gian bảo trì. Cấu trúc "During + time period" được sử dụng để chỉ một hành động xảy ra trong một khoảng thời gian cụ thể. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
A. Dọc theo (giới từ)
B. Trong (giới từ)
C. Không có (giới từ)
D. Giữa (giới từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (133, 131, 133, NULL, 'apologize', 'organize', 'realize', 'recognize', 'A', 'Đáp án đúng là (A) apologize. Động từ "apologize" (xin lỗi) phù hợp nhất trong ngữ cảnh của thông báo về sự bất tiện. Cấu trúc "apologize for" thường được sử dụng để xin lỗi về một vấn đề hoặc sự bất tiện. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
A. xin lỗi (động từ)
B. tổ chức (động từ)
C. nhận ra (động từ)
D. công nhận (động từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (134, 131, 134, NULL, 'If you would like to join our property management team, call us today.', 'Thank you for your patience while the main lobby is being painted.', 'Please do not attempt to access the north lobby on these days.', 'Questions or comments may be directed to the Management Office.', 'D', 'Đáp án đúng là (D) Questions or comments may be directed to the Management Office. Câu này phù hợp nhất để kết thúc thông báo, cung cấp thông tin liên hệ cho những người có thắc mắc. Các đáp án khác không liên quan đến nội dung của thông báo hoặc mâu thuẫn với thông tin đã cung cấp.
A. Nếu bạn muốn tham gia đội ngũ quản lý tài sản của chúng tôi, hãy gọi cho chúng tôi ngay hôm nay. (câu)
B. Cảm ơn sự kiên nhẫn của bạn trong khi sảnh chính đang được sơn. (câu)
C. Vui lòng không cố gắng vào sảnh phía bắc trong những ngày này. (câu)
D. Các câu hỏi hoặc ý kiến có thể được gửi đến Văn phòng Quản lý. (câu)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (132, 6, NULL, NULL, 'I recently received a last-minute invitation to a formal dinner. I bought a suit and needed it tailored as 135--- as possible. A friend suggested that I use Antonio''s Tailoring Shop in downtown Auckland. When I met Antonio, he gave me his full attention 136--- his shop was busy. He took the time to listen to me and carefully noted all my measurements. He then explained all the tailoring costs up front and assured me that he could have my suit ready in three days, but he had it done in two! 137---
Antonio has run his shop for over 30 years, and his experience really shows. He is a 138---- tailor.
I highly recommend him.
Jim Kestren, Auckland', 'Gần đây tôi đã nhận được một lời mời vào phút chót cho một bữa tối trang trọng. Tôi đã mua một bộ đồ và cần nó được may như 135--- càng tốt. Một người bạn đề nghị tôi sử dụng Cửa hàng may đo của Antonio ở trung tâm thành phố Auckland. Khi tôi gặp Antonio, anh ấy đã dành cho tôi toàn bộ sự quan tâm của mình 136--- cửa hàng của anh ấy rất bận rộn. Anh ấy đã dành thời gian để lắng nghe tôi và cẩn thận ghi lại tất cả các phép đo của tôi. Sau đó, anh ấy giải thích trước tất cả các chi phí may đo và đảm bảo với tôi rằng anh ấy có thể chuẩn bị bộ đồ của tôi trong ba ngày, nhưng anh ấy đã hoàn thành nó trong hai ngày! 137---
Antonio đã điều hành cửa hàng của mình trong hơn 30 năm, và kinh nghiệm của anh ấy thực sự cho thấy. Anh ấy là một thợ may 138---.
Tôi rất muốn giới thiệu anh ấy.
Jim Kestren, Auckland');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (135, 132, 135, NULL, 'quickly', 'quicken', 'quickest', 'quickness', 'A', 'Đáp án đúng là (A) quickly. Trạng từ "quickly" (nhanh chóng) phù hợp nhất để hoàn thành cấu trúc so sánh "as ... as possible". Cấu trúc này được sử dụng để chỉ ra mức độ cao nhất có thể của một hành động. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
A. nhanh chóng (trạng từ)
B. làm nhanh lên (động từ)
C. nhanh nhất (tính từ so sánh nhất)
D. sự nhanh chóng (danh từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (136, 132, 136, NULL, 'as far as', 'even though', 'such as', 'whether', 'B', 'Đáp án đúng là (B) even though. Cụm từ nối "even though" (mặc dù) phù hợp nhất để diễn tả sự tương phản giữa việc Antonio dành sự chú ý đầy đủ cho khách hàng và việc cửa hàng đang bận rộn. Cấu trúc "even though + clause" được sử dụng để chỉ ra một sự đối lập. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
A. như là (cụm từ)
B. mặc dù (cụm từ nối)
C. chẳng hạn như (cụm từ)
D. liệu (liên từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (137, 132, 137, NULL, 'Of course, the shop is busiest on Saturdays.', 'The suit fits me perfectly too.', 'I made another purchase.', 'He used to sell shirts.', 'B', 'Đáp án đúng là (B) The suit fits me perfectly too. Câu này phù hợp nhất để kết thúc đoạn văn về trải nghiệm tại cửa hàng may đo, nhấn mạnh chất lượng công việc của Antonio. Các đáp án khác không liên quan trực tiếp đến trải nghiệm cụ thể này hoặc không phù hợp với ngữ cảnh.
A. Tất nhiên, cửa hàng bận rộn nhất vào các ngày thứ Bảy. (câu)
B. Bộ vest cũng vừa vặn hoàn hảo với tôi. (câu)
C. Tôi đã mua thêm một món hàng nữa. (câu)
D. Anh ấy từng bán áo sơ mi. (câu)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (138, 132, 138, NULL, 'former', 'temporary', 'superb', 'best', 'C', 'Đáp án đúng là (C) superb. Tính từ "superb" (tuyệt vời) phù hợp nhất để mô tả kỹ năng của Antonio như một thợ may dựa trên trải nghiệm tích cực được mô tả trong đoạn văn. Cấu trúc "a + adjective + noun" được sử dụng để mô tả đặc điểm của một người. Các đáp án khác không phù hợp về nghĩa trong ngữ cảnh này.
A. cũ (tính từ)
B. tạm thời (tính từ)
C. tuyệt vời (tính từ)
D. tốt nhất (tính từ)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (133, 6, NULL, NULL, 'Dear Director Yoshida,
Thank you for your school''s interest in visiting our farm next month. Please note that children must be at least six years old to visit and tour the farm. 139----. I have enclosed a list of the 140--- activities available for our young visitors. Two of these 141---- must be scheduled in advance. They are a cheese-making class and an introduction to beekeeping. Both are very popular with our visitors.
Please let 142 ----- know your selection by early next week. I look forward to welcoming your group soon!
Sincerely,
Annabel Romero, Coordinator
Merrytree Family Farm', 'Kính gửi Giám đốc Yoshida,
Cảm ơn trường đã quan tâm đến việc đến thăm trang trại của chúng tôi vào tháng tới. Xin lưu ý rằng trẻ em phải ít nhất sáu tuổi để tham quan và tham quan trang trại. 139----. Tôi đã đính kèm một danh sách gồm 140--- hoạt động dành cho những du khách trẻ tuổi của chúng tôi. Hai trong số 141---- này phải được lên lịch trước. Họ là một lớp học làm pho mát và giới thiệu về nghề nuôi ong. Cả hai đều rất phổ biến với khách truy cập của chúng tôi.
Vui lòng cho 142 ----- biết lựa chọn của bạn vào đầu tuần tới. Tôi mong sớm được chào đón nhóm của bạn! 
Trân trọng,
Annabel Romero, Điều phối viên
Trang trại gia đình Merrytree');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (139, 133, 139, NULL, 'In the event of bad weather, the animals will be inside.', 'There are no exceptions to this policy.', 'Ones younger than that can find much to enjoy.', 'This fee includes lunch and a small souvenir.', 'B', 'Đáp án đúng là (B) There are no exceptions to this policy. Câu này phù hợp nhất để nhấn mạnh quy định về độ tuổi đã đề cập trước đó. Nó giải thích rằng quy định này được áp dụng nghiêm ngặt mà không có ngoại lệ. Các đáp án khác không liên quan trực tiếp đến quy định về độ tuổi hoặc không phù hợp với ngữ cảnh.
A. Trong trường hợp thời tiết xấu, các con vật sẽ ở trong nhà. (câu)
B. Không có ngoại lệ nào đối với chính sách này. (câu)
C. Những người trẻ hơn có thể tìm thấy nhiều điều thú vị. (câu)
D. Phí này bao gồm bữa trưa và một món quà lưu niệm nhỏ. (câu)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (140, 133, 140, NULL, 'legal', 'artistic', 'athletic', 'educational', 'D', 'Đáp án đúng là (D) educational. Tính từ "educational" (giáo dục) phù hợp nhất để mô tả các hoạt động được tổ chức tại trang trại cho khách tham quan trẻ. Điều này phù hợp với bối cảnh của một chuyến tham quan học tập. Các đáp án khác không phù hợp với mục đích của chuyến thăm trang trại.
A. hợp pháp (tính từ)
B. nghệ thuật (tính từ)
C. thể thao (tính từ)
D. giáo dục (tính từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (141, 133, 141, NULL, 'events', 'plays', 'treatments', 'trips', 'A', 'Đáp án đúng là (A) events. Danh từ "events" (sự kiện) phù hợp nhất để mô tả các hoạt động được tổ chức tại trang trại, bao gồm lớp học làm phô mai và giới thiệu về nuôi ong. Các đáp án khác không phù hợp với bối cảnh của các hoạt động tại trang trại.
A. sự kiện (danh từ số nhiều)
B. vở kịch (danh từ số nhiều)
C. phương pháp điều trị (danh từ số nhiều)
D. chuyến đi (danh từ số nhiều)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (142, 133, 142, NULL, 'they', 'me', 'her', 'one', 'B', 'Đáp án đúng là (B) me. Đại từ tân ngữ "me" (tôi) phù hợp nhất trong ngữ cảnh này, vì người viết thư (Annabel Romero) đang yêu cầu người nhận thư (Director Yoshida) thông báo cho cô ấy về lựa chọn của họ. Các đáp án khác không phù hợp với ngữ cảnh hoặc ngữ pháp của câu.
A. họ (đại từ nhân xưng số nhiều)
B. tôi (đại từ tân ngữ)
C. cô ấy (đại từ tân ngữ)
D. một (đại từ không xác định)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (134, 6, NULL, NULL, 'To: Lakshmi Aiyar
From: info@healthonity.com
Date: February 8
Subject: Healthonity Dental
Dear Ms. Aiyar,
We, the dental health professionals of the Healthonity Dental Center, are 143--- to introduce our just-opened practice. We aim to provide access to the largest team of dental specialists in the region. On our Web site, you can see a comprehensive list of the procedures we offer. 144---- . The members of our practice share a passion for helping people maintain beautiful and healthy smiles.
Contact our center today at 305-555-0121 (145) ---- an initial evaluation. All first-time 146-----will benefit from a 50 percent discount on the cost through the end of the month.
Sincerely,
The Team at Healthonity Dental Center', 'Gửi đến: Lakshmi Aiyar
Từ: info@healthonity.com
Ngày: 8 tháng 2
Chủ đề: Nha khoa Healthonity
 Kính gửi cô Aiyar,
Chúng tôi, các chuyên gia sức khỏe răng miệng của Trung tâm Nha khoa Healthonity, là 143--- để giới thiệu phòng khám mới mở của chúng tôi. Chúng tôi mong muốn cung cấp quyền truy cập vào đội ngũ chuyên gia nha khoa lớn nhất trong khu vực. Trên trang web của chúng tôi, bạn có thể xem danh sách đầy đủ các thủ tục mà chúng tôi cung cấp. 144---- . Các thành viên trong thực hành của chúng tôi chia sẻ niềm đam mê giúp mọi người duy trì nụ cười đẹp và khỏe mạnh.
Liên hệ với trung tâm của chúng tôi ngay hôm nay theo số 305-555-0121 (145) ---- đánh giá ban đầu. Tất cả những người lần đầu 146------sẽ được hưởng lợi từ việc giảm giá 50% chi phí cho đến cuối tháng.
Trân trọng,
Đội ngũ tại Trung tâm Nha khoa Healthonity');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (143, 134, 143, NULL, 'prouder', 'proudly', 'pride', 'proud', 'D', 'Đáp án đúng là (D) proud. Tính từ "proud" (tự hào) phù hợp nhất để mô tả cảm xúc của nhóm nha sĩ khi giới thiệu về phòng khám mới của họ. Cấu trúc "are + adjective + to + verb" được sử dụng để diễn tả cảm xúc về một hành động. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
A. tự hào hơn (tính từ so sánh hơn)
B. một cách tự hào (trạng từ)
C. niềm tự hào (danh từ)
D. tự hào (tính từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (144, 134, 144, NULL, 'They include general and cosmetic procedures.', 'We have relocated from neighboring Hillsborough.', 'The Web site is a creation of A to Z Host Builders.', 'Several of them are surprisingly expensive.', 'A', 'Đáp án đúng là (A) They include general and cosmetic procedures. Câu này phù hợp nhất để cung cấp thông tin bổ sung về các thủ tục được liệt kê trên trang web của phòng khám. Nó liên quan trực tiếp đến nội dung của câu trước đó và phù hợp với ngữ cảnh của email giới thiệu. Các đáp án khác không liên quan hoặc không phù hợp với mục đích của email.
A. Chúng bao gồm các thủ tục tổng quát và thẩm mỹ. (câu)
B. Chúng tôi đã chuyển địa điểm từ Hillsborough lân cận. (câu)
C. Trang web là sản phẩm của A to Z Host Builders. (câu)
D. Một số trong số đó đắt đến bất ngờ. (câu)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (145, 134, 145, NULL, 'scheduled', 'to schedule', 'scheduling', 'being scheduled', 'B', 'Đáp án đúng là (B) to schedule. Cụm động từ nguyên mẫu "to schedule" (để đặt lịch) phù hợp nhất để hoàn thành câu, chỉ ra mục đích của việc liên hệ với trung tâm. Cấu trúc "Contact + object + to + verb" được sử dụng để chỉ ra mục đích của một hành động. Các đáp án khác không phù hợp về mặt ngữ pháp trong cấu trúc này.
A. đã lên lịch (động từ quá khứ)
B. để đặt lịch (động từ nguyên mẫu)
C. đang lên lịch (động từ hiện tại phân từ)
D. đang được lên lịch (động từ bị động hiện tại phân từ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (146, 134, 146, NULL, 'shoppers', 'residents', 'patients', 'tenants', 'C', 'Đáp án đúng là (C) patients. Danh từ "patients" (bệnh nhân) phù hợp nhất trong ngữ cảnh của một phòng khám nha khoa. Nó chỉ những người đến khám lần đầu tiên và sẽ được hưởng giảm giá. Các đáp án khác không phù hợp với bối cảnh của một cơ sở y tế.
A. người mua sắm (danh từ số nhiều)
B. cư dân (danh từ số nhiều)
C. bệnh nhân (danh từ số nhiều)
D. người thuê nhà (danh từ số nhiều)');

-- Data for 2022 Test1 Part 7
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (135, 7, NULL, NULL, 'http://www.moonglowairways.com.au
Special Announcement by Geoff Clifford, President of Moon Glow Airways As many of you are aware, there was a problem with Pelman Technology, the system that handles our airline reservations. This outage has affected several airlines. It''s been a rough week, but the good news is that it has been repaired, and we are re-setting our system. However, Moon Glow passengers may still face delays for a day or two. This most likely will include longer lines at airports. We have added more on-site customer service representatives at airports in all of our destination cities to assist customers with their flights and information. We appreciate your understanding and patience.', 'http://www.moonglowairways.com.au
Thông báo đặc biệt của Geoff Clifford, Chủ tịch của Moon Glow Airways Như nhiều người trong số các bạn đã biết, đã có vấn đề với Công nghệ Pelman, hệ thống xử lý đặt chỗ hàng không của chúng tôi. Sự cố ngừng hoạt động này đã ảnh hưởng đến một số hãng hàng không. Đó là một tuần khó khăn, nhưng tin tốt là nó đã được sửa chữa và chúng tôi đang thiết lập lại hệ thống của mình. Tuy nhiên, hành khách Moon Glow vẫn có thể phải đối mặt với sự chậm trễ trong một hoặc hai ngày. Điều này rất có thể sẽ bao gồm các hàng dài hơn tại các sân bay. Chúng tôi đã bổ sung thêm các đại diện dịch vụ khách hàng tại chỗ tại các sân bay ở tất cả các thành phố đích của chúng tôi để hỗ trợ khách hàng về các chuyến bay và thông tin của họ. Chúng tôi đánh giá cao sự thông cảm và kiên nhẫn của bạn.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (147, 135, 147, 'What is the purpose of the announcement?', 'To report on airport renovations', 'To give an update on a technical problem', 'To introduce a new reservation system', 'To advertise airline routes to some new cities', 'B', 'Đáp án đúng là B (To give an update on a technical problem - Để cập nhật về một vấn đề kỹ thuật). Giải thích:
1. Thông báo đề cập đến "a problem with Pelman Technology, the system that handles our airline reservations" (một vấn đề với Pelman Technology, hệ thống xử lý đặt vé máy bay của chúng tôi).
2. Nó cũng nói rằng vấn đề đã được sửa chữa và họ đang thiết lập lại hệ thống.
3. Mục đích chính của thông báo là để cập nhật cho hành khách về tình trạng của vấn đề này và các tác động có thể xảy ra.
Các đáp án khác không chính xác:
A. To report on airport renovations (Để báo cáo về việc cải tạo sân bay): Không có đề cập đến việc cải tạo sân bay.
C. To introduce a new reservation system (Để giới thiệu một hệ thống đặt chỗ mới): Họ đang sửa chữa hệ thống hiện tại, không phải giới thiệu hệ thống mới.
D. To advertise airline routes to some new cities (Để quảng cáo các tuyến bay đến một số thành phố mới): Không có thông tin về các tuyến bay mới.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (148, 135, 148, 'According to Mr. Clifford, what has the airline temporarily increased?', 'The number of flights available', 'Dining options on flights', 'Assistance for customers at airports', 'Prices for international flights', 'C', 'Đáp án đúng là C (Assistance for customers at airports - Hỗ trợ cho khách hàng tại sân bay). Giải thích:
Thông báo nêu rõ: "We have added more on-site customer service representatives at airports in all of our destination cities to assist customers with their flights and information" (Chúng tôi đã bổ sung thêm nhân viên dịch vụ khách hàng tại chỗ ở các sân bay tại tất cả các thành phố đích của chúng tôi để hỗ trợ khách hàng với các chuyến bay và thông tin của họ).
Các đáp án khác không chính xác:
A. The number of flights available (Số lượng chuyến bay có sẵn): Không có thông tin về việc tăng số lượng chuyến bay.
B. Dining options on flights (Các lựa chọn ăn uống trên chuyến bay): Không đề cập đến việc thay đổi dịch vụ ăn uống.
D. Prices for international flights (Giá vé cho các chuyến bay quốc tế): Không có thông tin về việc thay đổi giá vé.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (136, 7, NULL, NULL, 'Video Captioners-Work from Home
Kiesel Video is seeking detail-oriented people to use our software to add text captions to a wide variety of video material, such as television programs, movies, and university lectures.
We will provide free online training. Successful applicants must possess strong language skills and have a computer, a headset, and high-speed Internet access.
The position features:
* ﻿﻿Flexible hours— you work as much or as little as you want.
* ﻿﻿Choice of projects— we have work in many types of content.
* ﻿﻿Good pay— our captioners earn $350 to $1,100 a week, depending on the assignment.
Apply today at www.kieselvideo.com/jobs', 'Phụ đề video-Làm việc tại nhà
Kiesel Video đang tìm kiếm những người có định hướng chi tiết để sử dụng phần mềm của chúng tôi để thêm chú thích văn bản vào nhiều loại tài liệu video, chẳng hạn như chương trình truyền hình, phim ảnh và các bài giảng đại học.
Chúng tôi sẽ cung cấp khóa đào tạo trực tuyến miễn phí. Ứng viên thành công phải có kỹ năng ngôn ngữ tốt và có máy tính, tai nghe và truy cập Internet tốc độ cao.
Các tính năng của vị trí:
* Giờ làm việc linh hoạt— bạn làm việc nhiều hay ít tùy thích.
* Lựa chọn dự án— chúng tôi có công việc trong nhiều loại nội dung.
* Lương tốt— người phụ đề của chúng tôi kiếm được từ 350 đến $1,100 đô la một tuần, tùy thuộc vào nhiệm vụ.
Nộp đơn ngay hôm nay tại www.kieselvideo.com/jobs');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (149, 136, 149, 'What are applicants for this position required to have?', 'Experience in video production', 'Certain pieces of equipment', 'A university degree in language studies', 'An office with a reception area', 'B', 'Đáp án đúng là B (Certain pieces of equipment - Một số thiết bị nhất định). Giải thích:
Thông báo tuyển dụng nêu rõ: "Successful applicants must possess strong language skills and have a computer, a headset, and high-speed Internet access" (Ứng viên thành công phải có kỹ năng ngôn ngữ tốt và có máy tính, tai nghe, và kết nối Internet tốc độ cao). Đây là các thiết bị cụ thể mà ứng viên cần có.
Các đáp án khác không chính xác:
A. Experience in video production (Kinh nghiệm trong sản xuất video): Không yêu cầu kinh nghiệm sản xuất video.
C. A university degree in language studies (Bằng đại học về ngôn ngữ học): Chỉ yêu cầu kỹ năng ngôn ngữ tốt, không đề cập đến bằng cấp cụ thể.
D. An office with a reception area (Một văn phòng có khu vực tiếp tân): Công việc được mô tả là làm việc tại nhà, không yêu cầu văn phòng.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (150, 136, 150, 'What is true about the job?', 'It is a full-time position.', 'It pays a fixed salary.', 'It involves some foreign travel.', 'It offers a choice of assignments.', 'D', 'Đáp án đúng là D (It offers a choice of assignments - Nó cung cấp sự lựa chọn về các nhiệm vụ). Giải thích:
Thông báo tuyển dụng nêu rõ một trong những đặc điểm của vị trí là: "Choice of projects— we have work in many types of content" (Lựa chọn dự án - chúng tôi có công việc trong nhiều loại nội dung).
Các đáp án khác không chính xác:
A. It is a full-time position (Đó là một vị trí toàn thời gian): Thông báo nói "Flexible hours— you work as much or as little as you want" (Giờ làm việc linh hoạt - bạn làm việc nhiều hay ít tùy ý), cho thấy đây không phải là vị trí toàn thời gian bắt buộc.
B. It pays a fixed salary (Nó trả lương cố định): Thông báo nói "our captioners earn $350 to $1,100 a week, depending on the assignment" (những người ghi chú của chúng tôi kiếm được từ $350 đến $1,100 một tuần, tùy thuộc vào nhiệm vụ), cho thấy mức lương không cố định.
C. It involves some foreign travel (Nó liên quan đến một số chuyến đi nước ngoài): Không có thông tin về việc đi lại nước ngoài, công việc được mô tả là làm việc tại nhà.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (137, 7, NULL, NULL, 'February 1
SOFTWARE TESTING REPORT
Version of Software Program: Konserted 2.5
Testing Dates: January 10-12
Number of Participants: 8
Software Testing Overview: Participants were asked to complete a series of tasks testing the functionality of the revised Konserted interface. In task number 1, participants searched for a concert in a designated area. In task number 2, participants searched for new friends on the site. In task number 3, participants invited friends to a concert. In task number 4, participants posted concert reviews, photos, and videos.
Initial Findings: Task number 3 proved the most challenging, with three participants unable to complete it in under two minutes. A potential cause for this difficulty may be the choice of icons in the menu bar. Clearer, more intuitive icons could make this task easier to complete for participants.', 'Ngày 1 tháng 2
BÁO CÁO KIỂM TRA PHẦN MỀM
Phiên bản chương trình phần mềm: Konserted 2.5
Ngày thử nghiệm: 10-12 tháng 1
Số người tham gia: 8
Tổng quan về kiểm tra phần mềm: Người tham gia được yêu cầu hoàn thành một loạt tác vụ kiểm tra chức năng của giao diện Konserted đã sửa đổi. Trong nhiệm vụ số 1, những người tham gia đã tìm kiếm một buổi hòa nhạc trong một khu vực được chỉ định. Trong nhiệm vụ số 2, những người tham gia đã tìm kiếm những người bạn mới trên trang web. Trong nhiệm vụ số 3, những người tham gia đã mời bạn bè đến một buổi hòa nhạc. Trong nhiệm vụ số 4, những người tham gia đã đăng bài đánh giá, ảnh và video về buổi hòa nhạc.
Những phát hiện ban đầu: Nhiệm vụ số 3 tỏ ra là khó khăn nhất, với ba người tham gia không thể hoàn thành nó trong vòng chưa đầy hai phút. Một nguyên nhân tiềm ẩn cho khó khăn này có thể là do lựa chọn các biểu tượng trong thanh menu. Các biểu tượng rõ ràng hơn, trực quan hơn có thể giúp người tham gia hoàn thành nhiệm vụ này dễ dàng hơn.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (151, 137, 151, 'What is true about the software testing?', 'It included multiple versions of Konserted.', 'It was done over several days.', 'It required participants to complete a survey.', 'It took place at a series of concerts.', 'B', 'Đáp án đúng là B (It was done over several days - Nó được thực hiện trong vài ngày). Giải thích:
Báo cáo kiểm thử phần mềm nêu rõ "Testing Dates: January 10-12" (Ngày kiểm thử: 10-12 tháng 1), cho thấy việc kiểm thử được thực hiện trong ba ngày.
Các đáp án khác không chính xác:
A. It included multiple versions of Konserted (Nó bao gồm nhiều phiên bản của Konserted): Báo cáo chỉ đề cập đến một phiên bản: Konserted 2.5.
C. It required participants to complete a survey (Nó yêu cầu người tham gia hoàn thành một cuộc khảo sát): Không có đề cập đến việc làm khảo sát, người tham gia được yêu cầu thực hiện các nhiệm vụ cụ thể.
D. It took place at a series of concerts (Nó diễn ra tại một loạt các buổi hòa nhạc): Việc kiểm thử được thực hiện trên giao diện phần mềm, không phải tại các buổi hòa nhạc thực tế.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (152, 137, 152, 'What action was difficult for users to complete?', 'Searching for an event', 'Searching for friends', 'Inviting friends to a performance', 'Posting reviews to a Web site', 'C', 'Đáp án đúng là C (Inviting friends to a performance - Mời bạn bè đến một buổi biểu diễn). Giải thích:
Báo cáo nêu rõ: "Task number 3 proved the most challenging, with three participants unable to complete it in under two minutes" (Nhiệm vụ số 3 tỏ ra khó khăn nhất, với ba người tham gia không thể hoàn thành trong vòng hai phút). Nhiệm vụ số 3 được mô tả là "participants invited friends to a concert" (người tham gia mời bạn bè đến một buổi hòa nhạc).
Các đáp án khác không chính xác:
A. Searching for an event (Tìm kiếm một sự kiện): Đây là nhiệm vụ số 1, không được đề cập là khó khăn.
B. Searching for friends (Tìm kiếm bạn bè): Đây là nhiệm vụ số 2, không được đề cập là khó khăn.
D. Posting reviews to a Web site (Đăng đánh giá lên một trang web): Đây là một phần của nhiệm vụ số 4, không được đề cập là khó khăn.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (138, 7, NULL, NULL, '*E-mail"
To: catiyeh@mymailroom.au
From: achen@mutamark.au
Date: 1 July
Subject: Mutamark conference
Dear Ms. Atiyeh,
To follow up on our phone conversation earlier today, I would like to extend to you a formal written invitation to speak at the eighth annual Mutamark conference, scheduled to take place this year from 17 to 20 September in Zagros. Because you drew a sizeable crowd when you appeared at the conference in the past, we will be making special arrangements for your visit this time. The Blue Room at the Debeljak Hotel holds only 120, so this year we are also booking the Koros Hall, which has a capacity of 270. We can offer you a 40-to-50-minute slot on the last day of the conference, when attendance should be at its peak. Please e-mail me to confirm your acceptance and to let me know more about your audiovisual requirements. We can provide overhead projection for still images if you will be using them again.
Very best regards,
Alex Chen, Conference Planning
Mutamark Headquarters, Melbourne', '*E-mail"
Gửi: catiyeh@mymailroom.au
Từ: achen@mutamark.au
Ngày: 1 tháng 7
Chủ đề: Hội nghị Mutamark
Thưa cô Atiyeh,
Để theo dõi cuộc trò chuyện qua điện thoại của chúng ta vào đầu ngày hôm nay, tôi muốn gửi đến bạn một lời mời chính thức bằng văn bản để phát biểu tại hội nghị Mutamark thường niên lần thứ tám, dự kiến diễn ra trong năm nay từ ngày 17 đến ngày 20 tháng 9 tại Zagros. Bởi vì bạn đã thu hút một đám đông khá lớn khi bạn xuất hiện tại hội nghị trước đây, chúng tôi sẽ sắp xếp đặc biệt cho chuyến thăm của bạn lần này. Phòng Blue tại khách sạn Debeljak chỉ có sức chứa 120 người, vì vậy năm nay chúng tôi cũng sẽ đặt Phòng Koros, nơi có sức chứa 270 người. Chúng tôi có thể cung cấp cho bạn một khoảng thời gian từ 40 đến 50 phút vào ngày cuối cùng của hội nghị, khi sự tham dự nên ở mức cao nhất. Vui lòng gửi email cho tôi để xác nhận sự chấp nhận của bạn và cho tôi biết thêm về các yêu cầu nghe nhìn của bạn. Chúng tôi có thể cung cấp hình chiếu trên cao cho hình ảnh tĩnh nếu bạn sẽ sử dụng chúng một lần nữa.
Trân trọng nhất,
Alex Chen, Lập kế hoạch hội nghị
Trụ sở Mutamark, Melbourne');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (153, 138, 153, 'What is indicated about Ms. Atiyeh''s previous appearance at Mutamark?', 'It was very well attended.', 'It was moved to a larger venue.', 'It featured a musical performance.', 'It took place at the Koros Hall.', 'A', 'Đáp án đúng là A (It was very well attended - Nó được tham dự rất đông đảo). Giải thích:
Email nêu rõ: "Because you drew a sizeable crowd when you appeared at the conference in the past" (Bởi vì bạn đã thu hút được một lượng khán giả đông đảo khi bạn xuất hiện tại hội nghị trong quá khứ). Điều này cho thấy buổi xuất hiện trước đây của Ms. Atiyeh được tham dự rất đông đảo.
Các đáp án khác không chính xác:
B. It was moved to a larger venue (Nó được chuyển đến một địa điểm lớn hơn): Email không đề cập đến việc chuyển địa điểm trong lần xuất hiện trước đây.
C. It featured a musical performance (Nó có một buổi biểu diễn âm nhạc): Không có thông tin về buổi biểu diễn âm nhạc.
D. It took place at the Koros Hall (Nó diễn ra tại Koros Hall): Email chỉ đề cập đến việc đặt Koros Hall cho lần này, không phải lần trước.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (154, 138, 154, 'How many people can the Koros Hall accommodate?', '40', '50', '120', '270', 'D', 'Đáp án đúng là D (270). Giải thích:
Email nêu rõ: "The Blue Room at the Debeljak Hotel holds only 120, so this year we are also booking the Koros Hall, which has a capacity of 270" (Phòng Xanh tại Khách sạn Debeljak chỉ chứa được 120 người, vì vậy năm nay chúng tôi cũng đặt Koros Hall, có sức chứa 270 người). Điều này chỉ ra rõ ràng rằng Koros Hall có thể chứa 270 người.
Các đáp án khác không chính xác:
A. 40: Không phải là sức chứa của bất kỳ phòng nào được đề cập.
B. 50: Không phải là sức chứa của bất kỳ phòng nào được đề cập.
C. 120: Đây là sức chứa của Phòng Xanh, không phải Koros Hall.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (155, 138, 155, 'When will Ms. Atiyeh most likely appear at the Mutamark conference?', 'On September 17', 'On September 18', 'On September 19', 'On September 20', 'D', 'Đáp án đúng là D (On September 20 - Vào ngày 20 tháng 9). Giải thích:
1. Email nêu rõ rằng hội nghị diễn ra từ ngày 17 đến ngày 20 tháng 9.
2. Alex Chen viết: "We can offer you a 40-to-50-minute slot on the last day of the conference, when attendance should be at its peak" (Chúng tôi có thể cung cấp cho bạn một khoảng thời gian 40 đến 50 phút vào ngày cuối cùng của hội nghị, khi số lượng người tham dự dự kiến sẽ đạt đỉnh).
3. Ngày cuối cùng của hội nghị là ngày 20 tháng 9.
Các đáp án khác không chính xác vì chúng không phải là ngày cuối cùng của hội nghị.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (139, 7, NULL, NULL, 'Monorail Coming to Sudbury
(4 Feb.)-Ottawa-based Saenger, Inc., has been selected by the city of Sudbury to build a monorail system that will connect the city''s commercial district to the airport. — [1] —.
Funding for the system is drawn from a combination of public agencies and private investors. — [2]—. Ticket sales for the monorail will also provide a new source of revenue for the city. — [3] —. Construction is slated to begin in early June and is expected to be completed within four years. — [4] -', 'Monorail Coming to Sudbury
(4 tháng 2)-Saenger, Inc. có trụ sở tại Ottawa, đã được thành phố Sudbury lựa chọn để xây dựng một hệ thống monorail sẽ kết nối khu thương mại của thành phố với sân bay. — [1] —.
Kinh phí cho hệ thống được rút ra từ sự kết hợp của các cơ quan công và các nhà đầu tư tư nhân. — [2]—. Việc bán vé cho tàu điện một ray cũng sẽ cung cấp một nguồn doanh thu mới cho thành phố. — [3] —. Việc xây dựng dự kiến bắt đầu vào đầu tháng Sáu và dự kiến sẽ hoàn thành trong vòng bốn năm. — [4] -');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (156, 139, 156, 'What kind of business most likely is Saenger, Inc.?', 'A construction firm', 'A real estate agency', 'A cargo-handling company', 'A financial services provider', 'A', 'Đáp án đúng là A (A construction firm - Một công ty xây dựng). Giải thích:
Bài báo nêu rõ: "Saenger, Inc., has been selected by the city of Sudbury to build a monorail system" (Saenger, Inc., đã được thành phố Sudbury chọn để xây dựng hệ thống tàu điện một ray). Việc được chọn để xây dựng một hệ thống giao thông lớn như vậy cho thấy Saenger, Inc. có khả năng cao là một công ty xây dựng.
Các đáp án khác không phù hợp với thông tin trong bài:
B. A real estate agency (Một công ty bất động sản): Không liên quan đến việc xây dựng hệ thống tàu điện.
C. A cargo-handling company (Một công ty xử lý hàng hóa): Không liên quan đến việc xây dựng hệ thống tàu điện.
D. A financial services provider (Một nhà cung cấp dịch vụ tài chính): Không liên quan đến việc xây dựng hệ thống tàu điện.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (157, 139, 157, 'What is indicated about the monorail?', 'It needs more funding from investors.', 'It will take years to finish.', 'It was proposed by airport officials.', 'It offers discounted tickets to city residents.', 'B', 'Đáp án đúng là B (It will take years to finish - Nó sẽ mất nhiều năm để hoàn thành). Giải thích:
Bài báo nêu rõ: "Construction is slated to begin in early June and is expected to be completed within four years" (Việc xây dựng dự kiến sẽ bắt đầu vào đầu tháng 6 và dự kiến sẽ hoàn thành trong vòng bốn năm). Điều này chỉ ra rằng dự án sẽ mất nhiều năm để hoàn thành.
Các đáp án khác không chính xác:
A. It needs more funding from investors (Nó cần thêm tài trợ từ các nhà đầu tư): Bài báo nói rằng tài trợ đã được huy động từ các cơ quan công và nhà đầu tư tư nhân, không đề cập đến việc cần thêm tài trợ.
C. It was proposed by airport officials (Nó được đề xuất bởi các quan chức sân bay): Không có thông tin về việc ai đề xuất dự án này.
D. It offers discounted tickets to city residents (Nó cung cấp vé giảm giá cho cư dân thành phố): Không có thông tin về giá vé hoặc chính sách giảm giá.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (158, 139, 158, 'In which of the positions marked [1], [2], [3], and [4] does the following sentence best belong? "Along the way, the line will stop at nine stations."', '[1]', '[2]', '[3]', '[4]', 'A', 'Đáp án đúng là A ([1]). Giải thích:
1. Câu "Along the way, the line will stop at nine stations" (Dọc đường đi, tuyến đường sẽ dừng ở chín trạm) cung cấp thông tin chi tiết về tuyến đường của hệ thống tàu điện một ray.
2. Vị trí [1] nằm ngay sau câu giới thiệu về việc xây dựng hệ thống tàu điện một ray kết nối khu thương mại với sân bay.
3. Đặt câu này ở vị trí [1] sẽ tạo ra một luồng thông tin logic: giới thiệu về dự án, sau đó cung cấp chi tiết về tuyến đường.
Các vị trí khác không phù hợp:
B. [2]: Đoạn này nói về tài trợ, không liên quan đến thông tin về tuyến đường.
C. [3]: Đoạn này nói về doanh thu từ vé, không liên quan đến thông tin về tuyến đường.
D. [4]: Đoạn này nói về thời gian xây dựng, quá muộn để giới thiệu thông tin về tuyến đường.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (140, 7, NULL, NULL, 'Dennis Beck (2:52 P.M.)
Hi, Corinne. I just want to be sure that you saw the document I sent you. It''s the combined market analysis and advertising proposal for the Keyes Elegant Home group. We''re preparing it for tomorrow''s presentation to the client.
Corinne McCall (2:53 P.M.)
Yes. I have just downloaded it. Is this about their new line of tableware?
Dennis Beck (2:54 P.M.)
Yes. I''d like you to read it over.
Corinne McCall (3:01 P.M.)
No problem. Would you like me to revise anything, or do you want me to just check that it is all clear?
Dennis Beck (3:02 P.M.)
Feel free to add information to the section "Advertising Strategies," since that is your area of expertise.
Corinne McCall (3:03 P.M.)
Will do. I''ll get it back to you before the end of the day.', 'Dennis Beck (2:52 Chiều)
Xin Chào, Corinne. Tôi chỉ muốn chắc chắn rằng bạn đã xem tài liệu tôi đã gửi cho bạn. Đó là đề xuất quảng cáo và phân tích thị trường kết hợp cho nhóm Keyes Elegant Home. Chúng tôi đang chuẩn bị cho buổi thuyết trình ngày mai cho khách hàng.
Corinne McCall (2:53 chiều)
Có. Tôi vừa tải nó xuống. Đây có phải là về dòng bộ đồ ăn mới của họ không? 
Dennis Beck (2:54 Chiều)
Có. Tôi muốn bạn đọc lại nó.
Corinne McCall (3:01 chiều)
Không vấn đề gì. Bạn có muốn tôi sửa lại bất cứ điều gì, hay bạn chỉ muốn tôi kiểm tra xem tất cả đã rõ ràng chưa? 
Dennis Beck (3:02 chiều)
Hãy thoải mái thêm thông tin vào phần "Chiến lược quảng cáo", vì đó là lĩnh vực chuyên môn của bạn.
Corinne McCall (3:03 chiều)
Sẽ làm. Tôi sẽ trả lại nó cho bạn trước khi kết thúc ngày.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (159, 140, 159, 'At 3:01 P.M., what does Ms. McCall most likely mean when she writes, "No problem"?', 'She did not have any issues logging on to her computer.', 'She does not think a document has errors.', 'She is willing to review a document.', 'She has time to meet representatives from Keyes Elegant Home.', 'C', 'Đáp án đúng là C (She is willing to review a document - Cô ấy sẵn sàng xem xét một tài liệu). Giải thích:
1. Trước đó, Dennis Beck yêu cầu Corinne McCall đọc qua tài liệu: "I''d like you to read it over" (Tôi muốn bạn đọc qua nó).
2. Khi Corinne trả lời "No problem" (Không vấn đề gì), cô ấy đang đồng ý với yêu cầu của Dennis.
3. Câu tiếp theo của Corinne: "Would you like me to revise anything, or do you want me to just check that it is all clear?" (Bạn có muốn tôi sửa đổi gì không, hay bạn chỉ muốn tôi kiểm tra xem nó có rõ ràng không?) xác nhận thêm rằng cô ấy sẵn sàng xem xét tài liệu.
Các đáp án khác không chính xác:
A. She did not have any issues logging on to her computer (Cô ấy không gặp vấn đề gì khi đăng nhập vào máy tính): Không liên quan đến ngữ cảnh của cuộc trò chuyện.
B. She does not think a document has errors (Cô ấy không nghĩ tài liệu có lỗi): Cô ấy chưa đọc tài liệu nên không thể biết nó có lỗi hay không.
D. She has time to meet representatives from Keyes Elegant Home (Cô ấy có thời gian gặp đại diện từ Keyes Elegant Home): Không có đề cập đến việc gặp đại diện khách hàng.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (160, 140, 160, 'What type of work does Ms. McCall most likely do?', 'Marketing', 'Accounting', 'Legal consulting', 'Information technology services', 'A', 'Đáp án đúng là A (Marketing). Giải thích:
1. Dennis Beck nói với Corinne McCall: "Feel free to add information to the section ''Advertising Strategies,'' since that is your area of expertise" (Hãy thoải mái thêm thông tin vào phần "Chiến lược Quảng cáo", vì đó là lĩnh vực chuyên môn của bạn).
2. Quảng cáo là một phần quan trọng của marketing.
3. Việc Corinne được yêu cầu xem xét một tài liệu kết hợp giữa phân tích thị trường và đề xuất quảng cáo cũng cho thấy cô ấy làm việc trong lĩnh vực marketing.
Các đáp án khác không phù hợp với thông tin trong cuộc trò chuyện:
B. Accounting (Kế toán): Không có thông tin liên quan đến công việc kế toán.
C. Legal consulting (Tư vấn pháp lý): Không có thông tin liên quan đến công việc tư vấn pháp lý.
D. Information technology services (Dịch vụ công nghệ thông tin): Không có thông tin liên quan đến công việc IT.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (141, 7, NULL, NULL, 'To: Mara Renaldo <mrenaldo@viyamail.com>
From: Lisa Yang <lyang@ staffordsvillefair.org>
Date: May 28
Subject: RE: Staffordsville Craft Fair
Dear Ms. Renaldo,/nThank you for your interest in selling your handcrafted items at the annual Staffordsville Craft Fair. Please note that all applicants must submit a $25 application fee, whether or not they want to share a space with another applicant. Moreover, all applicants must submit a minimum of four photographs of their work in order to be considered as a
vendor. 一(1)—
In addition to photographs, we ask that you submit a rough sketch showing how you would display your work. Since you propose to share a space with a friend, local potter Julia Berens, it would be helpful if your sketch could indicate how you are planning to use the space jointly. — [2] —.
Also, because we hold the fair rain or shine, all vendors must supply their own tenting to protect themselves and their wares from the possibility of rain. — [3] -.
Finally, please be aware that every year we receive far more applications from jewelry makers than we can accept. We hope that you will not be too discouraged if your work is not accepted this year, as you are applying for the first time. — [4] -.
Thanks again, and best of luck with your application,
Lisa Yang', 'Gửi đến: Mara Renaldo <mrenaldo@viyamail.com>
Từ: Lisa Yang <lyang@ staffordsvillefair.org>
Ngày: 28 tháng 5
Chủ đề: RE: Hội chợ thủ công Staffordsville
Kính gửi cô Renaldo,/nCảm ơn bạn đã quan tâm đến việc bán các mặt hàng thủ công của mình tại Hội chợ thủ công Staffordsville hàng năm. Xin lưu ý rằng tất cả các ứng viên phải nộp lệ phí đăng ký 25 đô la, cho dù họ có muốn chia sẻ không gian với người nộp đơn khác hay không. Hơn nữa, tất cả các ứng viên phải nộp tối thiểu bốn bức ảnh về tác phẩm của họ để được coi là một
Nhà cung cấp. 一(1)—
Ngoài các bức ảnh, chúng tôi yêu cầu bạn gửi một bản phác thảo thô cho thấy cách bạn sẽ trưng bày tác phẩm của mình. Vì bạn đề xuất chia sẻ không gian với một người bạn, thợ gốm địa phương Julia Berens, sẽ rất hữu ích nếu bản phác thảo của bạn có thể chỉ ra cách bạn dự định sử dụng không gian chung. — [2] —.
Ngoài ra, vì chúng tôi tổ chức mưa hay nắng, tất cả các nhà cung cấp phải cung cấp lều của riêng họ để bảo vệ bản thân và đồ dùng của họ khỏi khả năng mưa. — [3] -.
Cuối cùng, xin lưu ý rằng mỗi năm chúng tôi nhận được nhiều đơn đăng ký từ các nhà sản xuất trang sức hơn mức chúng tôi có thể chấp nhận. Chúng tôi hy vọng rằng bạn sẽ không quá nản lòng nếu công việc của bạn không được chấp nhận trong năm nay, vì bạn đang nộp đơn lần đầu tiên. — [4] -.
Cảm ơn một lần nữa, và chúc may mắn với đơn đăng ký của bạn,
Lisa Yang');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (161, 141, 161, 'What is suggested about the craft fair?', 'It takes place in downtown Staffordsville.', 'It is being held for the first time.', 'It specializes in locally produced crafts.', 'It will be held outdoors.', 'D', 'Đáp án đúng là D (It will be held outdoors - Nó sẽ được tổ chức ngoài trời). Giải thích:
Email có đoạn: "Also, behense we and the fravares rom the posieny of ast supply their own tenting to" (Mặc dù đoạn này có vẻ bị lỗi, nhưng nó gợi ý về việc cung cấp lều, điều này thường chỉ cần thiết cho các sự kiện ngoài trời).
Các đáp án khác không có đủ thông tin để hỗ trợ:
A. It takes place in downtown Staffordsville (Nó diễn ra ở trung tâm Staffordsville): Không có thông tin về địa điểm cụ thể trong thành phố.
B. It is being held for the first time (Nó đang được tổ chức lần đầu tiên)
C. Nó chuyên về hàng thủ công được sản xuất tại địa phương.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (162, 141, 162, 'What is NOT mentioned as a requirement for selling at the craft fair?', 'Sharing a space with another participant', 'Paying a fee to participate', 'Submitting images of the crafts', 'Providing one''s own tenting', 'A', 'Đáp án đúng là A (Sharing a space with another participant - Chia sẻ không gian với một người tham gia khác). Giải thích:
1. Việc chia sẻ không gian không được đề cập là yêu cầu bắt buộc. Email chỉ nói "whether or not they want to share a space with another applicant" (cho dù họ có muốn chia sẻ không gian với một ứng viên khác hay không), cho thấy đây là tùy chọn.
2. Các yêu cầu khác đều được đề cập:
B. Paying a fee to participate: "all applicants must submit a $25 application fee"
C. Submitting images of the crafts: "all applicants must submit a minimum of four photographs of their work"
D. Providing one''s own tenting: "supply their own tenting" (mặc dù câu này bị lỗi, nhưng nó ngụ ý về việc cung cấp lều riêng)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (163, 141, 163, 'What does Ms. Renaldo most likely sell?', 'Sketches', 'Photographs', 'Pottery', 'Jewelry', 'D', 'Đáp án đúng là D (Jewelry - Đồ trang sức). Giải thích:
Email có đoạn: "please be aware that every year we receive far more applications from jewelry makers than we can accept" (xin lưu ý rằng mỗi năm chúng tôi nhận được nhiều đơn đăng ký từ những người làm đồ trang sức hơn số lượng chúng tôi có thể chấp nhận). Việc nhắc đến điều này cho Ms. Renaldo ngụ ý rằng cô ấy có khả năng cao là một người làm đồ trang sức.
Các đáp án khác không phù hợp:
A. Sketches (Bản phác thảo): Mặc dù có yêu cầu gửi bản phác thảo, nhưng đó là để mô tả cách trưng bày, không phải sản phẩm bán.
B. Photographs (Ảnh): Ảnh được yêu cầu như một phần của đơn đăng ký, không phải sản phẩm bán.
C. Pottery (Đồ gốm): Julia Berens được đề cập là thợ gốm địa phương, không phải Ms. Renaldo.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (164, 141, 164, 'In which of the positions marked [1], [2], [3], and [4] does the following sentence best belong? "Make sure they clearly represent the items you wish to offer for purchase at the event."', '[1]', '[2]', '[3]', '[4]', 'A', 'Đáp án đúng là A ([1]). Giải thích:
1. Câu "Make sure they clearly represent the items you wish to offer for purchase at the event" (Hãy đảm bảo chúng thể hiện rõ ràng các món đồ bạn muốn bán tại sự kiện) là hướng dẫn về các bức ảnh cần gửi.
2. Vị trí [1] nằm ngay sau yêu cầu gửi ít nhất bốn bức ảnh công việc.
3. Đặt câu này ở vị trí [1] sẽ tạo ra một luồng thông tin logic: yêu cầu gửi ảnh, sau đó hướng dẫn về nội dung của ảnh.
Các vị trí khác không phù hợp vì chúng nói về các chủ đề khác không liên quan trực tiếp đến việc gửi ảnh sản phẩm.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (142, 7, NULL, NULL, 'SLEEP SOUNDLY SOLUTIONS
Thank you for choosing Sleep Soundly Solutions!
The updated control panel is linked to an integrated system that allows you to activate and disable all security systems in your home, including your Sleep Soundly motion sensor as well as your fire, smoke, and carbon monoxide detectors.
All Sleep Soundly residential alarm systems have been tested thoroughly to ensure the highest quality and sensitivity, so you can sleep soundly in the knowledge that your home is protected. We have also developed a new smartphone application that will notify you of any disturbances wherever you are. The app is available for download now.
Sleep Soundly control equipment is carefully manufactured for use with Sleep Soundly detectors and alarms. Using products manufactured by other companies may result in an alarm system that does not meet safety requirements for residential buildings or comply with local laws.', 'GIẢI PHÁP SLEEP SOUNDLY
Cảm ơn bạn đã chọn Sleep Soundly Solutions! 
Bảng điều khiển được cập nhật được liên kết với một hệ thống tích hợp cho phép bạn kích hoạt và tắt tất cả các hệ thống an ninh trong nhà, bao gồm cảm biến chuyển động Sleep Soundly cũng như máy dò cháy, khói và carbon monoxide.
Tất cả các hệ thống báo động dân cư Sleep Soundly đã được kiểm tra kỹ lưỡng để đảm bảo chất lượng và độ nhạy cao nhất, vì vậy bạn có thể ngủ ngon khi biết rằng ngôi nhà của bạn được bảo vệ. Chúng tôi cũng đã phát triển một ứng dụng điện thoại thông minh mới sẽ thông báo cho bạn về bất kỳ sự xáo trộn nào mọi lúc mọi nơi. Ứng dụng có sẵn để tải xuống ngay bây giờ.
Thiết bị điều khiển Sleep Soundly được sản xuất cẩn thận để sử dụng với máy dò và báo thức Sleep Soundly. Sử dụng các sản phẩm do các công ty khác sản xuất có thể dẫn đến hệ thống báo động không đáp ứng các yêu cầu an toàn cho các tòa nhà dân cư hoặc tuân thủ luật pháp địa phương.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (165, 142, 165, 'In what industry does Sleep Soundly Solutions operate?', 'Real estate', 'Life insurance', 'Home security', 'Furniture moving', 'C', 'Đáp án đúng là C (Home security - An ninh nhà ở). Giải thích:
1. Thông báo đề cập đến "security systems in your home" (hệ thống an ninh trong nhà bạn).
2. Nó cũng nói về "residential alarm systems" (hệ thống báo động nhà ở) và các thiết bị như cảm biến chuyển động, báo cháy, báo khói và báo khí carbon monoxide.
3. Mục đích của sản phẩm là để "your home is protected" (nhà bạn được bảo vệ).
Tất cả những điều này chỉ ra rõ ràng rằng Sleep Soundly Solutions hoạt động trong ngành an ninh nhà ở.
Các đáp án khác không phù hợp với thông tin trong thông báo:
A. Real estate (Bất động sản): Không có thông tin về việc mua bán nhà.
B. Life insurance (Bảo hiểm nhân thọ): Không liên quan đến các sản phẩm được đề cập.
D. Furniture moving (Chuyển đồ đạc): Không liên quan đến các sản phẩm được đề cập.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (166, 142, 166, 'What new product is being offered by Sleep Soundly Solutions?', 'An outdoor motion sensor', 'A smartphone application', 'Home installation service', 'Fire detection equipment', 'B', 'Đáp án đúng là B (A smartphone application - Một ứng dụng điện thoại thông minh). Giải thích:
Thông báo nêu rõ: "We have also developed a new smartphone application that will notify you of any disturbances wherever you are. The app is available for download now." (Chúng tôi cũng đã phát triển một ứng dụng điện thoại thông minh mới sẽ thông báo cho bạn về bất kỳ sự xáo trộn nào bất cứ nơi đâu bạn ở. Ứng dụng này hiện đã có sẵn để tải xuống.)
Các đáp án khác không chính xác:
A. An outdoor motion sensor (Một cảm biến chuyển động ngoài trời): Mặc dù có đề cập đến cảm biến chuyển động, nhưng không có thông tin về loại cảm biến mới hoặc ngoài trời.
C. Home installation service (Dịch vụ lắp đặt tại nhà): Không có thông tin về dịch vụ lắp đặt mới.
D. Fire detection equipment (Thiết bị phát hiện cháy): Mặc dù có đề cập đến báo cháy, nhưng không phải là sản phẩm mới được giới thiệu.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (167, 142, 167, 'The word "meet" in paragraph 3, line 3, is closest in meaning to', 'greet', 'touch', 'satisfy', 'experience', 'C', 'Đáp án đúng là C (satisfy - đáp ứng). Giải thích:
1. Trong ngữ cảnh "Using products manufactured by other companies may result in an alarm system that does not meet safety requirements for residential buildings" (Sử dụng các sản phẩm do các công ty khác sản xuất có thể dẫn đến hệ thống báo động không đáp ứng các yêu cầu an toàn cho các tòa nhà dân cư), từ "meet" có nghĩa là đáp ứng hoặc thỏa mãn các yêu cầu.
2. "Satisfy" là từ đồng nghĩa gần nhất với "meet" trong ngữ cảnh này.
Các đáp án khác không phù hợp:
A. greet (chào đón): Không phù hợp với ngữ cảnh về đáp ứng yêu cầu.
B. touch (chạm vào): Không phù hợp với ngữ cảnh này.
D. experience (trải nghiệm): Không phù hợp với ngữ cảnh về đáp ứng yêu cầu.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (143, 7, NULL, NULL, 'March 29
Dr. Maritza Geerlings
Poseidonstraat 392
Paramaribo
Suriname
Dear Dr. Geerlings,
I am writing to thank you for your years of service on the faculty of the Jamaican Agricultural Training Academy (JATA) and to let you know about some exciting developments. As you know, JATA was originally established as a vocational school for agriculture but now offers courses in a varied array of disciplines, including cybersecurity, electrical engineering, and health information management. Our student body, which for the first ten years consisted almost exclusively of locals, is now culturally diverse, with students from across the Americas and Europe.
Today''s students work with sophisticated equipment, much of which did not exist in our early days.
To reflect these and other significant changes that JATA has undergone over time, the Board of Trustees has approved a proposal by the Faculty Senate to rename the institution the Caribbean Academy of Science and Technology. As a result, a new institutional logo will be adopted. All students and faculty members, both current and former, are invited to participate in a logo design contest. Information about the contest will be forthcoming.
There aning ce, the twent the introductio off the ney lion, i the place will be
able to join us.
Sincerely,
Audley Bartlett
Audley Bartlett
Vice President for Academic Affairs, Jamaican Agricultural Training Academy', 'Ngày 29 tháng 3
Tiến sĩ. Maritza Geerlings
Poseidonstraat 392
Paramaribo
Suriname
Tiến sĩ thân mến. Geerlings,
Tôi viết thư này để cảm ơn bạn vì những năm phục vụ trong giảng viên của Học viện Đào tạo Nông nghiệp Jamaica (JATA) và để thông báo cho bạn về một số phát triển thú vị. Như bạn đã biết, JATA ban đầu được thành lập như một trường dạy nghề về nông nghiệp nhưng hiện cung cấp các khóa học trong nhiều lĩnh vực khác nhau, bao gồm an ninh mạng, kỹ thuật điện và quản lý thông tin y tế. Sinh viên của chúng tôi, trong mười năm đầu tiên hầu như chỉ bao gồm người dân địa phương, giờ đây đa dạng về văn hóa, với sinh viên đến từ khắp châu Mỹ và châu Âu.
Sinh viên ngày nay làm việc với các thiết bị tinh vi, phần lớn trong số đó không tồn tại trong những ngày đầu của chúng tôi.
Để phản ánh những điều này và những thay đổi quan trọng khác mà JATA đã trải qua theo thời gian, Hội đồng Quản trị đã phê duyệt đề xuất của Thượng viện Khoa để đổi tên tổ chức thành Học viện Khoa học và Công nghệ Caribe. Do đó, một logo tổ chức mới sẽ được thông qua. Tất cả sinh viên và giảng viên, cả hiện tại và cũ, đều được mời tham gia cuộc thi thiết kế logo. Thông tin về cuộc thi sẽ được công bố sắp tới.
There aning ce, twet the introductio off the ney lion, i the place sẽ có thể tham gia cùng chúng tôi.
Trân trọng,
Audley Bartlett
Audley Bartlett
Phó Chủ tịch phụ trách các vấn đề Học thuật, Học viện Đào tạo Nông nghiệp Jamaica');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (168, 143, 168, 'What is one purpose of the letter?', 'To announce a name change', 'To honor distinguished alumni', 'To suggest revisions to a curriculum', 'To list an individual''s accomplishments', 'A', 'Đáp án đúng là A (To announce a name change - Để thông báo về việc thay đổi tên). Giải thích:
Lá thư nêu rõ: "To reflect these and other significant changes that JATA has undergone over time, the Board of Trustees has approved a proposal by the Faculty Senate to rename the institution the Caribbean Academy of Science and Technology" (Để phản ánh những thay đổi quan trọng này và các thay đổi khác mà JATA đã trải qua theo thời gian, Hội đồng Quản trị đã phê duyệt đề xuất của Thượng viện Khoa để đổi tên tổ chức thành Học viện Khoa học và Công nghệ Caribbean). Đây là một thông báo rõ ràng về việc thay đổi tên trường.
Các đáp án khác không chính xác:
B. To honor distinguished alumni (Để vinh danh các cựu sinh viên xuất sắc): Không có thông tin về việc vinh danh cựu sinh viên.
C. To suggest revisions to a curriculum (Để đề xuất sửa đổi chương trình giảng dạy): Mặc dù có đề cập đến các khóa học mới, nhưng đây không phải là mục đích chính của lá thư.
D. To list an individual''s accomplishments (Để liệt kê thành tích của một cá nhân): Lá thư không tập trung vào thành tích của bất kỳ cá nhân nào.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (169, 143, 169, 'The word "established" in paragraph 1, line 3, is closest in meaning to', 'affected', 'founded', 'confirmed', 'settled', 'B', 'Đáp án đúng là B (founded - thành lập). Giải thích:
1. Trong ngữ cảnh "JATA was originally established as a vocational school for agriculture" (JATA ban đầu được thành lập như một trường dạy nghề nông nghiệp), từ "established" có nghĩa là được thành lập hoặc được tạo ra.
2. "Founded" là từ đồng nghĩa gần nhất với "established" trong ngữ cảnh này.
Các đáp án khác không phù hợp:
A. affected (bị ảnh hưởng): Không phù hợp với ngữ cảnh về việc tạo ra một tổ chức.
C. confirmed (xác nhận): Không phù hợp với ngữ cảnh về việc tạo ra một tổ chức mới.
D. settled (định cư): Mặc dù có thể dùng trong một số ngữ cảnh, nhưng không phải là nghĩa phổ biến nhất cho việc thành lập một tổ chức.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (170, 143, 170, 'What is suggested about Dr. Geerlings?', 'She plans to attend JATA''s anniversary celebration.', 'She has taught courses in cybersecurity.', 'She can take part in JATA''s logo design contest.', 'She served on JATA''s Board of Trustees.', 'C', 'Đáp án đúng là C (She can take part in JATA''s logo design contest - Cô ấy có thể tham gia cuộc thi thiết kế logo của JATA). Giải thích:
Lá thư nêu rõ: "All students and faculty members, both current and former, are invited to participate in a logo design contest" (Tất cả sinh viên và giảng viên, cả hiện tại và cựu, đều được mời tham gia cuộc thi thiết kế logo). Vì Dr. Geerlings được cảm ơn vì "years of service on the faculty" (những năm phục vụ trong khoa), điều này ngụ ý rằng cô ấy là một cựu giảng viên và do đó có thể tham gia cuộc thi.
Các đáp án khác không có đủ thông tin để hỗ trợ:
A. She plans to attend JATA''s anniversary celebration (Cô ấy dự định tham dự lễ kỷ niệm của JATA): Không có thông tin về lễ kỷ niệm.
B. She has taught courses in cybersecurity (Cô ấy đã dạy các khóa học về an ninh mạng): Mặc dù có đề cập đến khóa học an ninh mạng, nhưng không có thông tin về việc Dr. Geerlings dạy nó.
D. She served on JATA''s Board of Trustees (Cô ấy từng là thành viên Hội đồng Quản trị của JATA): Không có thông tin về việc này.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (171, 143, 171, 'What is NOT indicated about JATA in the letter?', 'Its professors live on campus.', 'Its students have access to modern equipment.', 'It will be twenty years old on June 1.', 'It is attended by international students.', 'A', 'Đáp án đúng là A (Its professors live on campus - Các giáo sư của nó sống trong khuôn viên trường). Giải thích:
Không có thông tin nào trong lá thư đề cập đến việc các giáo sư sống trong khuôn viên trường.
Các đáp án khác đều được đề cập hoặc ngụ ý trong lá thư:
B. Its students have access to modern equipment (Sinh viên của nó có quyền tiếp cận thiết bị hiện đại): Lá thư nói "Today''s students work with sophisticated equipment" (Sinh viên ngày nay làm việc với thiết bị tinh vi).
C. It will be twenty years old on June 1 (Nó sẽ tròn 20 tuổi vào ngày 1 tháng 6): Mặc dù câu này bị lỗi, nhưng có đề cập đến "the twent" có thể là ám chỉ đến kỷ niệm 20 năm.
D. It is attended by international students (Nó có sinh viên quốc tế theo học): Lá thư nói "Our student body... is now culturally diverse, with students from across the Americas and Europe" (Sinh viên của chúng tôi... giờ đây đa dạng về văn hóa, với sinh viên từ khắp châu Mỹ và châu Âu).');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (144, 7, NULL, NULL, 'Ashley Montaine 8:54 A.M.: How did the interview with Mr. Erickson go?
Dan Campbell 8:55 A.M.: I really enjoyed meeting him. I think he''d be a great reporter here. He seems smart and organized, and his samples show that he''s a great writer.
Ashley Montaine 8:57 A.M.: Brooke, can you contact Mr. Erickson to set up the next interview? Is that a problem?
Dan Campbell 8:58 A.M.: I''d really like to work with him. It is very important that he impress Mr. Peters.
Brooke Randolph 8:59 A.M.: Not at all.
Ashley Montaine 9:00 A.M.: Thanks. I also see that he has a varied work history. That will make him a well-rounded reporter.
Brooke Randolph 9:02 A.M.: When would you like to meet with him again?
Dan Campbell 9:03 A.M.: Ashley, I believe you will participate in the next interview.
Note that Mr. Peters is probably going to ask why Mr. Erickson wants to transition from freelance writing to in-house news reporting. Also, Mr. Peters will want assurances that he''s committed and will stick around for several years.
Ashley Montaine 9:04 A.M.: Brooke, Mr. Peters and I are both free Friday morning.
Brooke Randolph 9:06 A.M.: Great. I''ll write an e-mail shortly.', 'Ashley Montaine 8:54 sáng: Cuộc phỏng vấn với ông Erickson diễn ra như thế nào? 
Dan Campbell 8:55 sáng: Tôi thực sự rất vui khi được gặp anh ấy. Tôi nghĩ anh ấy sẽ là một phóng viên tuyệt vời ở đây. Anh ấy có vẻ thông minh và có tổ chức, và các mẫu của anh ấy cho thấy anh ấy là một nhà văn tuyệt vời.
Ashley Montaine 8:57 sáng: Brooke, bạn có thể liên hệ với ông Erickson để sắp xếp cuộc phỏng vấn tiếp theo không? Đó có phải là một vấn đề không? 
Dan Campbell 8:58 sáng: Tôi thực sự muốn làm việc với anh ấy. Điều rất quan trọng là anh ấy phải gây ấn tượng với ông Peters.
Brooke Randolph 8:59 sáng: Không hề.
Ashley Montaine 9:00 sáng: Cảm ơn. Tôi cũng thấy rằng anh ấy có một lịch sử công việc đa dạng. Điều đó sẽ khiến anh ấy trở thành một phóng viên toàn diện.
Brooke Randolph 9:02 sáng: Khi nào bạn muốn gặp lại anh ấy? 
Dan Campbell 9:03 sáng: Ashley, tôi tin rằng bạn sẽ tham gia vào cuộc phỏng vấn tiếp theo.
Lưu ý rằng ông Peters có thể sẽ hỏi tại sao ông Erickson muốn chuyển từ viết tự do sang báo cáo tin tức nội bộ. Ngoài ra, ông Peters sẽ muốn được đảm bảo rằng ông ấy cam kết và sẽ gắn bó trong vài năm.
Ashley Montaine 9:04 sáng: Brooke, ông Peters và tôi đều rảnh vào sáng thứ Sáu.
Brooke Randolph 9:06 sáng: Tuyệt vời. Tôi sẽ viết một e-mail trong thời gian ngắn.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (172, 144, 172, 'For what type of company do the writers work?', 'A book publisher', 'A newspaper', 'A film production company', 'A job-placement firm', 'B', 'Đáp án đúng là B (A newspaper - Một tờ báo). Giải thích:
1. Cuộc trò chuyện đề cập đến việc tuyển dụng một "reporter" (phóng viên).
2. Họ nói về việc chuyển từ "freelance writing to in-house news reporting" (viết tự do sang báo cáo tin tức nội bộ).
3. Các thuật ngữ này thường được sử dụng trong ngành báo chí.
Các đáp án khác không phù hợp với thông tin trong cuộc trò chuyện:
A. A book publisher (Một nhà xuất bản sách): Không có đề cập đến việc xuất bản sách.
C. A film production company (Một công ty sản xuất phim): Không có thông tin liên quan đến sản xuất phim.
D. A job-placement firm (Một công ty tuyển dụng): Mặc dù họ đang tuyển dụng, nhưng đây là cho công ty của họ, không phải là một công ty tuyển dụng chuyên nghiệp.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (173, 144, 173, 'At 8:59 A.M., what does Ms. Randolph most likely mean when she writes, "Not at all"?', 'She would like to participate in an interview.', 'She does not think Mr. Erickson should be hired.', 'She feels comfortable fulfilling a request.', 'She has not read Mr. Erickson''s writing.', 'C', 'Đáp án đúng là C (She feels comfortable fulfilling a request - Cô ấy cảm thấy thoải mái thực hiện một yêu cầu). Giải thích:
1. Ashley Montaine hỏi Brooke: "can you contact Mr. Erickson to set up the next interview? Is that a problem?" (bạn có thể liên hệ với ông Erickson để sắp xếp cuộc phỏng vấn tiếp theo không? Điều đó có vấn đề gì không?)
2. Brooke trả lời "Not at all" (Hoàn toàn không), ngụ ý rằng cô ấy không có vấn đề gì với việc thực hiện yêu cầu này.
Các đáp án khác không chính xác:
A. She would like to participate in an interview (Cô ấy muốn tham gia một cuộc phỏng vấn): Không có thông tin về việc Brooke muốn tham gia phỏng vấn.
B. She does not think Mr. Erickson should be hired (Cô ấy không nghĩ ông Erickson nên được thuê): Không có thông tin về ý kiến của Brooke về việc thuê Mr. Erickson.
D. She has not read Mr. Erickson''s writing (Cô ấy chưa đọc bài viết của ông Erickson): Không liên quan đến câu hỏi của Ashley.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (174, 144, 174, 'What is indicated about Mr. Erickson?', 'He has never been on a job interview before.', 'He has held many different types of jobs.', 'He is taking over Mr. Peters'' position.', 'He is a former colleague of Ms. Montaine.', 'B', 'Đáp án đúng là B (He has held many different types of jobs - Ông ấy đã từng làm nhiều loại công việc khác nhau). Giải thích:
Ashley Montaine nói: "I also see that he has a varied work history. That will make him a well-rounded reporter." (Tôi cũng thấy rằng anh ấy có lịch sử làm việc đa dạng. Điều đó sẽ giúp anh ấy trở thành một phóng viên toàn diện.) Điều này ngụ ý rằng Mr. Erickson đã từng làm nhiều loại công việc khác nhau.
Các đáp án khác không chính xác:
A. He has never been on a job interview before (Ông ấy chưa từng tham gia phỏng vấn việc làm trước đây): Ngược lại, ông ấy đã tham gia một cuộc phỏng vấn và sắp có cuộc phỏng vấn thứ hai.
C. He is taking over Mr. Peters'' position (Ông ấy đang tiếp quản vị trí của ông Peters): Không có thông tin về việc này. Mr. Peters có vẻ là người có thẩm quyền trong công ty.
D. He is a former colleague of Ms. Montaine (Ông ấy là cựu đồng nghiệp của bà Montaine): Không có thông tin về mối quan hệ trước đây giữa Mr. Erickson và Ms. Montaine.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (175, 144, 175, 'According to the discussion, what is important to Mr. Peters about a new hire?', 'Prior news reporting experience', 'Ability to begin working immediately', 'Communicating well with colleagues', 'Staying with the company over the long term', 'D', 'Đáp án đúng là D (Staying with the company over the long term - Gắn bó với công ty trong thời gian dài). Giải thích:
Dan Campbell nói: "Mr. Peters will want assurances that he''s committed and will stick around for several years" (Ông Peters sẽ muốn đảm bảo rằng anh ấy cam kết và sẽ gắn bó trong vài năm). Điều này chỉ ra rõ ràng rằng Mr. Peters coi trọng việc nhân viên mới sẽ ở lại với công ty trong thời gian dài.
Các đáp án khác không được đề cập là quan trọng đối với Mr. Peters:
A. Prior news reporting experience (Kinh nghiệm báo cáo tin tức trước đây): Mặc dù có đề cập đến việc chuyển từ viết tự do sang báo cáo tin tức nội bộ, nhưng không nói đây là điều quan trọng đối với Mr. Peters.
B. Ability to begin working immediately (Khả năng bắt đầu làm việc ngay lập tức): Không có thông tin về thời gian bắt đầu làm việc.
C. Communicating well with colleagues (Giao tiếp tốt với đồng nghiệp): Không có thông tin về kỹ năng giao tiếp.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (145, 7, NULL, NULL, 'Alberta Business Matters
April issue
Improve Your Office
Environment Now!
Today''s office environment, featuring
windowless cubicles, might not inspire comfort, beauty, and energy. However, there are some easy, inexpensive ways to make your office space more inviting.
Air quality
* ﻿﻿Add some green plants to the décor. Plants offer a natural filtration system, increasing oxygen levels. Nonflowering plants should be preferred, as they will not scatter pollen.
* ﻿﻿A small, tabletop air purifier helps improve stale air and removes dust.
Light quality
• Take breaks and go outdoors. Even just five minutes before or after lunch break will provide your eyes with a respite from artificial light sources.
* ﻿﻿Use desktop lamps with full-spectrum lightbulbs.
* ﻿﻿Install double-glazed windows instead of blinds to reduce glare while maintaining natural light.
Stress relief
* ﻿﻿Earplugs or noise-cancelling headphones can block distracting noise in an open office floor plan.
* ﻿﻿Photographs of loved ones and places we have visited for vacation are reminders of our life away from the office. Select a few favorite pictures as important decorative elements.
Dear readers, if you have tips to add to this list, send them in and they will be published in next month''s issue.
=====
Alberta Business Matters
Letters to the Editor
It may interest your readers to know about the company I work for, called Moveable, Inc.
We aspire to make dull offices more comfortable and convenient for workers, especially for today''s on-the-move employees.
For example, say you work two days a week at your headquarters in Edmonton, and the rest of the week you are in a satellite office. Our "Can-Do Case" ensures that your favorite office supplies always travel with you. Our "Modular Décor Kit," weighing just 1.75 kg, contains a portable reading lamp, a miniature silk plant, and a folding photo frame with space for four pictures. Look us up online and follow us on social media, as we offer new items frequently!
Best,
Maria Testa', 'Alberta Business Matters
Vấn đề tháng 4
Cải thiện văn phòng của bạn
Môi trường ngay! 
Môi trường văn phòng ngày nay, với
các ngăn không cửa sổ, có thể không truyền cảm hứng cho sự thoải mái, vẻ đẹp và năng lượng. Tuy nhiên, có một số cách dễ dàng, không tốn kém để làm cho không gian văn phòng của bạn trở nên hấp dẫn hơn.
Chất lượng không khí
* Thêm một số cây xanh vào trang trí. Thực vật cung cấp một hệ thống lọc tự nhiên, tăng nồng độ oxy. Nên ưu tiên cây không ra hoa, vì chúng sẽ không phân tán phấn hoa.
* Máy lọc không khí nhỏ để bàn giúp cải thiện không khí cũ và loại bỏ bụi.
Chất lượng ánh sáng
• Nghỉ ngơi và ra ngoài trời. Chỉ cần chỉ năm phút trước hoặc sau giờ nghỉ trưa sẽ giúp mắt bạn nghỉ ngơi khỏi các nguồn ánh sáng nhân tạo.
* Sử dụng đèn bàn có bóng đèn quang phổ đầy đủ.
* Lắp đặt cửa sổ kính hai lớp thay vì rèm để giảm ánh sáng chói trong khi vẫn duy trì ánh sáng tự nhiên.
Giảm căng thẳng
* Nút tai hoặc tai nghe khử tiếng ồn có thể ngăn tiếng ồn gây mất tập trung trong sơ đồ sàn văn phòng mở.
* Những bức ảnh của những người thân và những nơi chúng ta đã ghé thăm trong kỳ nghỉ là những lời nhắc nhở về cuộc sống của chúng ta khi xa văn phòng. Chọn một vài bức ảnh yêu thích làm yếu tố trang trí quan trọng.
Bạn đọc thân mến, nếu bạn có mẹo để thêm vào danh sách này, hãy gửi chúng và chúng sẽ được xuất bản trong số tháng tới.
=====
Alberta Business Matters
Thư gửi Biên tập viên
Độc giả của bạn có thể quan tâm khi biết về công ty tôi làm việc, được gọi là Moveable, Inc.
Chúng tôi mong muốn làm cho các văn phòng buồn tẻ thoải mái và thuận tiện hơn cho người lao động, đặc biệt là đối với những nhân viên đang di chuyển ngày nay.
Ví dụ: bạn làm việc hai ngày một tuần tại trụ sở chính ở Edmonton và phần còn lại của tuần bạn đang ở văn phòng vệ tinh. "Can-Do Case" của chúng tôi đảm bảo rằng đồ dùng văn phòng yêu thích của bạn luôn đi cùng bạn. "Bộ trang trí mô-đun" của chúng tôi, chỉ nặng 1,75 kg, chứa một chiếc đèn đọc sách di động, một cây lụa thu nhỏ và một khung ảnh gấp với không gian cho bốn bức ảnh. Tìm kiếm chúng tôi trực tuyến và theo dõi chúng tôi trên phương tiện truyền thông xã hội, vì chúng tôi thường xuyên cung cấp các mặt hàng mới! 
Tốt nhất,
Maria Testa');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (176, 145, 176, 'What is NOT recommended in the article?', 'Using plants to decorate cubicles', 'Walking outdoors during breaks', 'Using a calming noise machine', 'Decorating with personal photographs', 'C', 'Đáp án đúng là C (Using a calming noise machine - Sử dụng một máy tạo tiếng ồn êm dịu). Giải thích:
1. Bài báo không đề cập đến việc sử dụng máy tạo tiếng ồn êm dịu.
2. Các đề xuất khác đều được đề cập trong bài:
A. Using plants to decorate cubicles (Sử dụng cây để trang trí ô làm việc): "Add some green plants to the décor"
B. Walking outdoors during breaks (Đi bộ ngoài trời trong giờ nghỉ): "Take breaks and go outdoors"
D. Decorating with personal photographs (Trang trí bằng ảnh cá nhân): "Photographs of loved ones and places we have visited for vacation are reminders of our life away from the office"
Vì vậy, C là lựa chọn duy nhất không được đề cập trong bài báo.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (177, 145, 177, 'Why are blinds mentioned?', 'Because they are relatively expensive', 'Because they block natural light', 'Because they are hard to match to furniture', 'Because they attract dust', 'B', 'Đáp án đúng là B (Because they block natural light - Vì chúng chặn ánh sáng tự nhiên). Giải thích:
Bài báo nêu: "Install double-glazed windows instead of blinds to reduce glare while maintaining natural light" (Lắp đặt cửa sổ kính hai lớp thay vì rèm để giảm chói trong khi vẫn duy trì ánh sáng tự nhiên). Điều này ngụ ý rằng rèm (blinds) được đề cập vì chúng chặn ánh sáng tự nhiên, trong khi cửa sổ kính hai lớp có thể giảm chói mà vẫn cho phép ánh sáng tự nhiên vào.
Các đáp án khác không được đề cập trong bài:
A. Because they are relatively expensive (Vì chúng tương đối đắt)
C. Because they are hard to match to furniture (Vì chúng khó phù hợp với nội thất)
D. Because they attract dust (Vì chúng hút bụi)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (178, 145, 178, 'What is indicated about the magazine?', 'It is the only business publication in Alberta.', 'Its publisher is hiring additional staff.', 'Its editors would like to hear from readers.', 'It is sponsored by a furniture company.', 'C', 'Đáp án đúng là C (Its editors would like to hear from readers - Các biên tập viên của nó muốn nghe từ độc giả). Giải thích:
Cuối bài báo có đoạn: "Dear readers, if you have tips to add to this list, send them in and they will be published in next month''s issue" (Các độc giả thân mến, nếu bạn có mẹo để thêm vào danh sách này, hãy gửi cho chúng tôi và chúng sẽ được đăng trong số tháng sau). Điều này rõ ràng cho thấy các biên tập viên muốn nhận phản hồi từ độc giả.
Các đáp án khác không có thông tin hỗ trợ trong bài:
A. It is the only business publication in Alberta (Đó là ấn phẩm kinh doanh duy nhất ở Alberta)
B. Its publisher is hiring additional staff (Nhà xuất bản của nó đang tuyển thêm nhân viên)
D. It is sponsored by a furniture company (Nó được tài trợ bởi một công ty nội thất)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (179, 145, 179, 'What is suggested about Ms. Testa?', 'She is a professional writer.', 'She is starting a new company.', 'She travels frequently in her work.', 'She read the previous issue of Alberta Business Matters.', 'D', 'Đáp án đúng là D (She read the previous issue of Alberta Business Matters - Cô ấy đã đọc số trước của Alberta Business Matters). Giải thích:
Ms. Testa bắt đầu thư của mình bằng câu: "It may interest your readers to know about the company I work for" (Độc giả của bạn có thể quan tâm đến công ty mà tôi làm việc). Điều này gợi ý rằng cô ấy đã đọc số trước của tạp chí, nơi có bài viết về cải thiện môi trường văn phòng, và cô ấy đang phản hồi với thông tin liên quan.
Các đáp án khác không có đủ thông tin hỗ trợ:
A. She is a professional writer (Cô ấy là một nhà văn chuyên nghiệp)
B. She is starting a new company (Cô ấy đang bắt đầu một công ty mới)
C. She travels frequently in her work (Cô ấy thường xuyên đi công tác trong công việc)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (180, 145, 180, 'What is suggested about Moveable, Inc.''s products?', 'They are packable.', 'They are affordable.', 'They are available for a short time.', 'They are made from recycled materials.', 'A', 'Đáp án đúng là A (They are packable - Chúng có thể đóng gói được). Giải thích:
1. Ms. Testa mô tả "Can-Do Case" như một sản phẩm đảm bảo "your favorite office supplies always travel with you" (các vật dụng văn phòng yêu thích của bạn luôn đi cùng bạn).
2. "Modular Décor Kit" được mô tả là chỉ nặng 1.75 kg và chứa các vật dụng như đèn đọc sách di động, cây lụa thu nhỏ và khung ảnh gập.
Những mô tả này gợi ý rằng sản phẩm của Moveable, Inc. được thiết kế để dễ dàng đóng gói và mang theo.
Các đáp án khác không có đủ thông tin hỗ trợ:
B. They are affordable (Chúng có giá phải chăng)
C. They are available for a short time (Chúng chỉ có sẵn trong thời gian ngắn)
D. They are made from recycled materials (Chúng được làm từ vật liệu tái chế)');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (146, 7, NULL, NULL, 'http://www.Lloydtouringcompany.co.uk
Choose one of Lloyd Touring Company''s (LTC) most popular outings to see the best that London has to offer!
Tour 1: Full-day tour of the most popular tourist sites on one of our famous red double-decker buses. See the Changing of the Guard and conclude the day with a river cruise.
Tour 2: Full-day walking tour of London''s best shopping areas. Explore London''s famous department stores and wander along fashionable Bond and Oxford Streets.
Tour 3: Half-day tour on a red double-decker bus, including private tour of the Tower of London and lunch at a nearby café.
Tour 4: Half-day tour of Buckingham Palace, including the Changing of the Guard. Tour ends with a traditional fish-and-chips lunch.
Tour 5: Full-day walking tour featuring London''s top highlights. Complete the day with a medieval banquet.
LTC''s knowledgeable local staff members personally guide each one of our tours. Meals are not covered, except when noted in the tour description. Participants are responsible for meeting at chosen departure destination. LTC does not provide pickup from hotels. All tours can be upgraded for an additional fee to include an open-date ticket to the London Eye, London''s famous observation wheel.
=====
5 Stars
-Ella Bouton
Lloyd Touring Company Review
This was my first trip to London. I decided to see all the major tourist sites on my own, but I wanted someone to help me discover the most interesting places to shop in London.
My LTC tour guide, Larissa, was wonderful. She is an avid shopper herself, and at the beginning of the tour, she tried to get to know the participants. She was able to guide everyone to the shops that they were most interested in. It was such a personalized tour!
And it was a bonus that Larissa also speaks French. My daughter and I were visiting from Paris, and we appreciated being able to communicate in two languages. The tour was very reasonably priced, too. I would highly recommend it. The only unpleasant part of the tour was that Oxford Street was extremely crowded when we visited, and it was difficult to walk around easily.', 'http://www.Lloydtouringcompany.co.uk
Chọn một trong những chuyến đi chơi phổ biến nhất của Công ty Lloyd Touring (LTC) để xem những điều tốt nhất mà London mang lại! 
Tour 1: Tham quan cả ngày đến các địa điểm du lịch nổi tiếng nhất trên một trong những chiếc xe buýt hai tầng màu đỏ nổi tiếng của chúng tôi. Xem The Changing of the Guard và kết thúc một ngày với một chuyến du ngoạn trên sông.
Tour 2: Tour đi bộ cả ngày đến các khu vực mua sắm tốt nhất của London. Khám phá các cửa hàng bách hóa nổi tiếng của London và đi lang thang dọc theo các đường Bond và Oxford thời thượng.
Tour 3: Tour nửa ngày trên xe buýt hai tầng màu đỏ, bao gồm tour riêng của Tháp Luân Đôn và ăn trưa tại một quán cà phê gần đó.
Tour 4: Tour nửa ngày của Cung điện Buckingham, bao gồm cả việc thay đổi bảo vệ. Chuyến tham quan kết thúc với bữa trưa cá và khoai tây chiên truyền thống.
Tour 5: Tour đi bộ cả ngày với những điểm nổi bật hàng đầu của London. Hoàn thành một ngày với một bữa tiệc thời trung cổ.
Các nhân viên địa phương am hiểu của LTC sẽ đích thân hướng dẫn từng chuyến tham quan của chúng tôi. Các bữa ăn không được bao gồm, trừ khi được ghi chú trong mô tả tour. Những người tham gia chịu trách nhiệm gặp gỡ tại điểm đến khởi hành đã chọn. LTC không cung cấp dịch vụ đón khách từ khách sạn. Tất cả các tour du lịch có thể được nâng cấp với một khoản phí bổ sung để bao gồm một vé ngày mở cho London Eye, bánh xe quan sát nổi tiếng của London.
=====
5 Stars
-Ella Bouton
Đánh giá của Lloyd Touring Company
Đây là chuyến đi đầu tiên của tôi đến London. Tôi quyết định tự mình tham quan tất cả các điểm du lịch lớn, nhưng tôi muốn ai đó giúp tôi khám phá những địa điểm thú vị nhất để mua sắm ở London.
Hướng dẫn viên du lịch LTC của tôi, Larissa, thật tuyệt vời. Bản thân cô ấy là một người đam mê mua sắm, và khi bắt đầu chuyến tham quan, cô ấy đã cố gắng làm quen với những người tham gia. Cô ấy có thể hướng dẫn mọi người đến các cửa hàng mà họ quan tâm nhất. Đó là một chuyến tham quan được cá nhân hóa! 
Và đó là một phần thưởng khi Larissa cũng nói tiếng Pháp. Con gái tôi và tôi đến thăm từ Paris, và chúng tôi đánh giá cao việc có thể giao tiếp bằng hai ngôn ngữ. Chuyến tham quan cũng có giá rất hợp lý. Tôi rất muốn giới thiệu nó. Phần khó chịu duy nhất của chuyến tham quan là Phố Oxford cực kỳ đông đúc khi chúng tôi đến thăm, và rất khó để đi bộ xung quanh một cách dễ dàng.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (181, 146, 181, 'How does Tour 1 differ from all the other tours?', 'It uses a double-decker bus.', 'It includes multiple meals at famous restaurants.', 'It allows participants to see London from the water.', 'It takes the entire day.', 'C', 'Đáp án đúng là C (It allows participants to see London from the water - Nó cho phép người tham gia xem London từ trên mặt nước). Giải thích:
1. Tour 1 là tour duy nhất đề cập đến "river cruise" (du thuyền trên sông), cho phép người tham gia xem London từ trên mặt nước.
2. Các tour khác không có hoạt động này.
Các đáp án khác không chính xác vì:
A. It uses a double-decker bus (Nó sử dụng xe buýt hai tầng): Tour 3 cũng sử dụng xe buýt hai tầng.
B. It includes multiple meals at famous restaurants (Nó bao gồm nhiều bữa ăn tại các nhà hàng nổi tiếng): Không có tour nào đề cập đến nhiều bữa ăn tại nhà hàng nổi tiếng.
D. It takes the entire day (Nó kéo dài cả ngày): Tour 2 và Tour 5 cũng là các tour cả ngày.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (182, 146, 182, 'What is included in the cost of the tours?', 'Transportation from hotels', 'A tour guide', 'Breakfast at a restaurant', 'A ticket to the London Eye', 'B', 'Đáp án đúng là B (A tour guide - Một hướng dẫn viên du lịch). Giải thích:
1. Thông tin nêu rõ: "LTC''s knowledgeable local staff members personally guide each one of our tours" (Nhân viên địa phương am hiểu của LTC trực tiếp hướng dẫn mỗi chuyến tour của chúng tôi).
2. Điều này ngụ ý rằng hướng dẫn viên du lịch được bao gồm trong chi phí của tour.
Các đáp án khác không chính xác:
A. Transportation from hotels (Đưa đón từ khách sạn): Thông tin nêu rõ "LTC does not provide pickup from hotels" (LTC không cung cấp dịch vụ đón từ khách sạn).
C. Breakfast at a restaurant (Bữa sáng tại nhà hàng): "Meals are not covered, except when noted in the tour description" (Các bữa ăn không được bao gồm, trừ khi được ghi chú trong mô tả tour).
D. A ticket to the London Eye (Vé đến London Eye): "All tours can be upgraded for an additional fee to include an open-date ticket to the London Eye" (Tất cả các tour có thể được nâng cấp với một khoản phí bổ sung để bao gồm vé mở ngày đến London Eye).');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (183, 146, 183, 'What tour did Ms. Bouton most likely take?', 'Tour 2', 'Tour 3', 'Tour 4', 'Tour 5', 'A', 'Đáp án đúng là A (Tour 2). Giải thích:
1. Ms. Bouton nói: "I wanted someone to help me discover the most interesting places to shop in London" (Tôi muốn ai đó giúp tôi khám phá những nơi mua sắm thú vị nhất ở London).
2. Tour 2 được mô tả là "Full-day walking tour of London''s best shopping areas" (Tour đi bộ cả ngày đến các khu mua sắm tốt nhất của London).
3. Ms. Bouton cũng đề cập đến Oxford Street, một trong những địa điểm được nêu trong Tour 2.
Các tour khác không phù hợp với mô tả của Ms. Bouton về trải nghiệm của cô ấy, vì chúng tập trung vào các địa điểm du lịch khác không liên quan đến mua sắm.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (184, 146, 184, 'What does the review suggest about Ms. Bouton?', 'She prefers bus tours.', 'She speaks French.', 'She was on a business trip.', 'She used LTC before.', 'B', 'Đáp án đúng là B (She speaks French - Cô ấy nói tiếng Pháp). Giải thích:
1. Ms. Bouton nói: "My daughter and I were visiting from Paris, and we appreciated being able to communicate in two languages" (Con gái tôi và tôi đang đến thăm từ Paris, và chúng tôi đánh giá cao việc có thể giao tiếp bằng hai ngôn ngữ).
2. Cô ấy cũng đề cập rằng hướng dẫn viên Larissa nói tiếng Pháp, và điều này được coi là một "bonus" (điểm cộng).
Những điều này gợi ý rằng Ms. Bouton nói tiếng Pháp.
Các đáp án khác không có thông tin hỗ trợ trong bài đánh giá:
A. She prefers bus tours (Cô ấy thích các tour bằng xe buýt): Không có thông tin về sở thích này.
C. She was on a business trip (Cô ấy đi công tác): Bài đánh giá gợi ý đây là chuyến du lịch cá nhân.
D. She used LTC before (Cô ấy đã sử dụng LTC trước đây): Ms. Bouton nói đây là chuyến đi đầu tiên của cô ấy đến London.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (185, 146, 185, 'Why was Ms. Bouton disappointed with the tour?', 'It was expensive.', 'It was disorganized.', 'It was in a very crowded area.', 'It was in an uninteresting part of the City.', 'C', 'Đáp án đúng là C (It was in a very crowded area - Nó diễn ra ở một khu vực rất đông đúc). Giải thích:
Ms. Bouton nói: "The only unpleasant part of the tour was that Oxford Street was extremely crowded when we visited, and it was difficult to walk around easily" (Phần duy nhất không dễ chịu của chuyến tham quan là Oxford Street cực kỳ đông đúc khi chúng tôi đến thăm, và rất khó để đi lại dễ dàng).
Các đáp án khác không chính xác:
A. It was expensive (Nó đắt đỏ): Ngược lại, Ms. Bouton nói rằng "The tour was very reasonably priced" (Chuyến tham quan có giá rất hợp lý).
B. It was disorganized (Nó không được tổ chức tốt): Không có thông tin về việc tour không được tổ chức tốt. Thực tế, Ms. Bouton có vẻ hài lòng với cách tổ chức tour.
D. It was in an uninteresting part of the City (Nó diễn ra ở một phần không thú vị của thành phố): Ms. Bouton không đề cập đến việc khu vực này không thú vị, chỉ là quá đông đúc.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (147, 7, NULL, NULL, 'To: Joseph Morgan <joseph.morgan@peltergraphics.com>
From: administrator@costaseminars.org
Date: May 31
Subject: Book order
Dear Mr. Morgan,
Thank you for registering for Emilio Costa''s seminar on June 11 at the Rothford Business Center. We are glad you took advantage of the opportunity for conference participants to purchase some of Emilio Costa''s graphic-design books at a discounted price. The information below is a confirmation of your order. The books will be waiting for you at the check-in desk on the day of the seminar. Please note that we will accept any major credit card for payment. We are looking forward to seeing you on June 11.
Quantity/ Title/ Price/ Discounted Price/ Total Price
1/ Perfected Figures: Making Data Visually Appealing/ $22.00/ $17.60/ $17.60
1/ Logos in the Information Age/ $18.00/ $14.40/ $14.40
1/ Branding Strategies in Graphic Design/ $20.00/ $16.00/ $16.00
2/ Best Practices in Web Design: A European Perspective/ $28.00/ $22.40/ $44.80
TOTAL DUE: $92.80
=====
Attention, Seminar Participants:
Unfortunately, we do not have copies of Emilio Costa''s book Branding Strategies in Graphic Design with us today. For those of you who have ordered it, please give your mailing address to the volunteer at the check-in desk, and the book will be mailed to your home at no cost to you. We will charge your credit card upon shipment. We are sorry for the inconvenience.
=====
*E-mail*
To: roberta.tsu@peltergraphics.com
From: joseph.morgan@peltergraphics.com
Date: June 22
Sent: Costa book
Dear Roberta,
I''m looking forward to finishing up our brochure design for Entchen Financial Consultants. Before we submit our final draft, I would like to rethink how we are presenting our data. Have you had a chance to look through the Costa book I showed you? He gives great advice on improving the clarity of financial information in marketing materials. Anyway, let''s talk about it at lunch tomorrow.
Best,
Joseph', 'Gửi đến: Joseph Morgan <joseph.morgan@peltergraphics.com>
Từ: administrator@costaseminars.org
Ngày: 31 tháng 5
Chủ đề: Đặt hàng sách
Kính gửi ông Morgan,
Cảm ơn bạn đã đăng ký tham gia hội thảo của Emilio Costa vào ngày 11 tháng 6 tại Trung tâm Kinh doanh Rothford. Chúng tôi rất vui vì bạn đã tận dụng cơ hội cho những người tham gia hội nghị mua một số cuốn sách thiết kế đồ họa của Emilio Costa với giá chiết khấu. Thông tin dưới đây là xác nhận đơn đặt hàng của bạn. Những cuốn sách sẽ đợi bạn tại quầy làm thủ tục vào ngày diễn ra hội thảo. Xin lưu ý rằng chúng tôi sẽ chấp nhận bất kỳ thẻ tín dụng chính nào để thanh toán. Chúng tôi mong được gặp bạn vào ngày 11 tháng 6.
Số lượng/ Tiêu đề/ Giá/ Giá chiết khấu/ Tổng giá
1/ Số liệu hoàn thiện: Làm cho dữ liệu hấp dẫn trực quan/ $22.00/ $17.60/ $17.60
1/ Logos in the Information Age/ $18.00/ $14.40/ $14.40
1/ Chiến lược xây dựng thương hiệu trong thiết kế đồ họa/ $20.00/ $16.00/ $16.00
2/ Thực tiễn tốt nhất trong thiết kế web: Quan điểm châu Âu/ $28.00/ $22.40/ $44.80
TOTAL DO: $92.80
====
Chú ý, Người tham gia hội thảo:
Thật không may, chúng tôi không có bản sao của cuốn sách Chiến lược xây dựng thương hiệu trong thiết kế đồ họa của Emilio Costa với chúng tôi hôm nay. Đối với những người đã đặt hàng, vui lòng cung cấp địa chỉ gửi thư của bạn cho tình nguyện viên tại quầy làm thủ tục và cuốn sách sẽ được gửi đến nhà bạn miễn phí. Chúng tôi sẽ tính phí thẻ tín dụng của bạn khi giao hàng. Chúng tôi xin lỗi vì sự bất tiện này.
=====
*E-mail*
Gửi: roberta.tsu@peltergraphics.com
Từ: joseph.morgan@peltergraphics.com
Ngày: 22 tháng 6
Gửi: Costa book
Kính gửi Roberta,
Tôi rất mong được hoàn thành thiết kế tài liệu quảng cáo của chúng tôi cho Entchen Financial Consultants. Trước khi chúng tôi gửi bản nháp cuối cùng, tôi muốn suy nghĩ lại về cách chúng tôi trình bày dữ liệu của mình. Bạn đã có cơ hội xem qua cuốn sách Costa mà tôi đã cho bạn xem chưa? Anh ấy đưa ra lời khuyên tuyệt vời về việc cải thiện sự rõ ràng của thông tin tài chính trong các tài liệu tiếp thị. Dù sao, hãy nói về nó vào bữa trưa ngày mai.
Tốt nhất,
Joseph');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (186, 147, 186, 'What most likely is the topic of the seminar on June 11?', 'Financial consulting', 'Graphic design', 'Marketing strategies', 'Business writing', 'B', 'Đáp án đúng là B (Graphic design - Thiết kế đồ họa). Giải thích:
1. Email đề cập đến "Emilio Costa''s graphic-design books" (sách thiết kế đồ họa của Emilio Costa).
2. Các cuốn sách được liệt kê đều liên quan đến thiết kế đồ họa, ví dụ: "Making Data Visually Appealing" (Làm cho dữ liệu hấp dẫn trực quan), "Logos in the Information Age" (Logo trong thời đại thông tin), "Branding Strategies in Graphic Design" (Chiến lược xây dựng thương hiệu trong thiết kế đồ họa).
3. Emilio Costa là người tổ chức hội thảo và là tác giả của các cuốn sách về thiết kế đồ họa.
Các đáp án khác không phù hợp với thông tin được cung cấp:
A. Financial consulting (Tư vấn tài chính): Mặc dù có đề cập đến "financial information" trong email cuối cùng, nhưng đó là trong ngữ cảnh của thiết kế đồ họa.
C. Marketing strategies (Chiến lược marketing): Mặc dù có liên quan đến thiết kế đồ họa, nhưng không phải là chủ đề chính của hội thảo.
D. Business writing (Viết kinh doanh): Không có thông tin liên quan đến chủ đề này.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (187, 147, 187, 'What is suggested about Mr. Morgan?', 'He attended the seminar with a coworker.', 'He gave a presentation at the seminar.', 'He received free shipping on a book purchase.', 'He paid for some books in advance.', 'C', 'Đáp án đúng là C (He received free shipping on a book purchase - Anh ấy nhận được giao hàng miễn phí cho một cuốn sách đã mua). Giải thích:
1. Thông báo nêu rõ: "For those of you who have ordered it, please give your mailing address to the volunteer at the check-in desk, and the book will be mailed to your home at no cost to you" (Đối với những người đã đặt sách, vui lòng cung cấp địa chỉ gửi thư cho tình nguyện viên tại quầy đăng ký, và sách sẽ được gửi đến nhà bạn mà không tính phí).
2. Mr. Morgan đã đặt mua cuốn "Branding Strategies in Graphic Design", cuốn sách được đề cập trong thông báo.
Các đáp án khác không có đủ thông tin hỗ trợ:
A. He attended the seminar with a coworker (Anh ấy tham dự hội thảo với một đồng nghiệp): Không có thông tin về việc tham dự với đồng nghiệp.
B. He gave a presentation at the seminar (Anh ấy thuyết trình tại hội thảo): Không có thông tin về việc Mr. Morgan thuyết trình.
D. He paid for some books in advance (Anh ấy trả tiền trước cho một số cuốn sách): Email nói rằng sẽ chấp nhận thẻ tín dụng vào ngày hội thảo, không đề cập đến việc trả tiền trước.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (188, 147, 188, 'What is the purpose of the notice?', 'To explain a problem', 'To ask for volunteers', 'To request payment', 'To promote a book', 'A', 'Đáp án đúng là A (To explain a problem - Để giải thích một vấn đề). Giải thích:
1. Thông báo bắt đầu bằng: "Unfortunately, we do not have copies of Emilio Costa''s book Branding Strategies in Graphic Design with us today" (Rất tiếc, chúng tôi không có bản sao của cuốn sách Branding Strategies in Graphic Design của Emilio Costa với chúng tôi hôm nay).
2. Thông báo này giải thích vấn đề thiếu sách và cách họ sẽ giải quyết nó.
Các đáp án khác không chính xác:
B. To ask for volunteers (Để yêu cầu tình nguyện viên): Không có yêu cầu tình nguyện viên nào trong thông báo.
C. To request payment (Để yêu cầu thanh toán): Thông báo nói rằng họ sẽ tính phí thẻ tín dụng khi gửi hàng, không yêu cầu thanh toán ngay.
D. To promote a book (Để quảng bá một cuốn sách): Thông báo không quảng bá cuốn sách, mà giải thích việc thiếu sách.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (189, 147, 189, 'According to the second e-mail, what does Mr. Morgan suggest changing?', 'The deadline for submitting a project', 'The content of a book review', 'The time of a scheduled meeting', 'The display of some information', 'D', 'Đáp án đúng là D (The display of some information - Cách hiển thị một số thông tin). Giải thích:
Mr. Morgan viết: "Before we submit our final draft, I would like to rethink how we are presenting our data" (Trước khi chúng ta nộp bản thảo cuối cùng, tôi muốn suy nghĩ lại về cách chúng ta đang trình bày dữ liệu của mình). Điều này cho thấy anh ấy muốn thay đổi cách hiển thị thông tin trong tài liệu.
Các đáp án khác không chính xác:
A. The deadline for submitting a project (Thời hạn nộp một dự án): Không có đề cập đến việc thay đổi thời hạn.
B. The content of a book review (Nội dung của một bài đánh giá sách): Không có đề cập đến việc đánh giá sách.
C. The time of a scheduled meeting (Thời gian của một cuộc họp đã lên lịch): Mặc dù có đề cập đến bữa trưa ngày mai, nhưng không có gợi ý về việc thay đổi thời gian.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (190, 147, 190, 'How much did Mr. Morgan spend on the book he showed to Ms. Tsu?', '$17.60', '$14.40', '$16.00', '$22.40', 'A', 'Đáp án đúng là A ($17.60). Giải thích:
1. Trong email cuối cùng, Mr. Morgan đề cập đến một cuốn sách của Costa mà anh ấy đã cho Ms. Tsu xem: "Have you had a chance to look through the Costa book I showed you? He gives great advice on improving the clarity of financial information in marketing materials" (Bạn đã có cơ hội xem qua cuốn sách của Costa mà tôi đã cho bạn xem chưa? Ông ấy đưa ra lời khuyên tuyệt vời về việc cải thiện sự rõ ràng của thông tin tài chính trong tài liệu tiếp thị).
2. Dựa vào mô tả này, cuốn sách có khả năng nhất là "Perfected Figures: Making Data Visually Appealing" (Hình ảnh hoàn hảo: Làm cho dữ liệu hấp dẫn trực quan), vì nó liên quan đến việc trình bày thông tin tài chính.
3. Giá được chiết khấu cho cuốn sách này là $17.60.
Các đáp án khác không phù hợp với cuốn sách được mô tả trong email cuối cùng.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (148, 7, NULL, NULL, 'Anton Building
Clanton (12 October)-The planned renovation of the historic Anton Building by Jantum Property Developers (JPD) is facing new delays. A JPD spokesperson says their negotiations with the city regarding a package of subsidies and tax incentives are ongoing and are proving somewhat contentious.
According to the renovation plan, JPD must protect the historical integrity of the Anton Building while it creates a mixed-use interior, offering both office space and lower-level retail space. However, JPD''s city permit to do the project is on hold pending the current negotiations.
This is making city revitalization advocates increasingly anxious. Aditi Yadav comments, "This plan to create useful space out of an empty decaying building will go a long way to restoring vibrancy to that area of the city. I sincerely hope that JPD does not back out. In creating their offer the City Council should consider JPD''s excellent record of beautifully restoring and maintaining several other historic buildings in Clanton."
=====
From: anabautista@lenoiva-health.com
To: t.rowell @jantunipropertydevelopers.com
Date:20 February
Subject: Lease inquiry
Dear Mr. Rowell,
I am the owner of Lenoiva, a health-care technology company. We plan to expand our operations and we need new office space. The Anton Building is one of the locations in Clanton that we are considering. We have been informed that your restoration project of this building will be finished sometime this spring, which is good timing for us. We are particularly attracted by the easy access to public transportation services that your building offers. Do you still have spaces available for rent? We anticipate needing a space at least 300 square metres in size. Would there be any reserved parking for our employees if we rented there? We would appreciate any information you can provide.
Thank you in advance,
Ana Bautista
=====
One Anton Place-2nd Floor Plan (office space)
Unit 2A/350 m2/T&M Accountancy
Unit 2B/150 m2/Available
Unit 2C/100 m2/Available
Unit 2D/250 m2/Available
Unit 2E/375 m2/Available', 'Tòa nhà Anton
Clanton (ngày 12 tháng 10) - Kế hoạch cải tạo Tòa nhà Anton lịch sử của Jantum Property Developers (JPD) đang phải đối mặt với sự chậm trễ mới. Người phát ngôn của JPD cho biết các cuộc đàm phán của họ với thành phố về gói trợ cấp và ưu đãi thuế đang diễn ra và đang tỏ ra có phần gây tranh cãi.
Theo kế hoạch cải tạo, JPD phải bảo vệ tính toàn vẹn lịch sử của Tòa nhà Anton trong khi tạo ra nội thất sử dụng hỗn hợp, cung cấp cả không gian văn phòng và không gian bán lẻ cấp thấp hơn. Tuy nhiên, giấy phép thành phố của JPD để thực hiện dự án đang bị tạm dừng trong khi chờ các cuộc đàm phán hiện tại.
Điều này đang khiến những người ủng hộ sự hồi sinh của thành phố ngày càng lo lắng. Aditi Yadav nhận xét, "Kế hoạch tạo ra không gian hữu ích từ một tòa nhà trống đổ nát này sẽ đi một chặng đường dài để khôi phục lại sự sống động cho khu vực đó của thành phố. Tôi chân thành hy vọng rằng JPD sẽ không rút ra. Khi đưa ra đề nghị của họ, Hội đồng Thành phố nên xem xét hồ sơ xuất sắc của JPD về việc khôi phục và duy trì một số tòa nhà lịch sử khác ở Clanton."
=====
Từ: anabautista@lenoiva-health.com
Gửi: t.rowell @jantunipropertydevelopers.com
Ngày: 20 tháng 2
Chủ đề: Yêu cầu cho thuê
Thưa ông Rowell,
Tôi là chủ sở hữu của Lenoiva, một công ty công nghệ chăm sóc sức khỏe. Chúng tôi dự định mở rộng hoạt động của mình và chúng tôi cần không gian văn phòng mới. Tòa nhà Anton là một trong những địa điểm ở Clanton mà chúng tôi đang cân nhắc. Chúng tôi đã được thông báo rằng dự án khôi phục tòa nhà này của bạn sẽ hoàn thành vào mùa xuân này, đây là thời điểm tốt cho chúng tôi. Chúng tôi đặc biệt bị thu hút bởi việc dễ dàng tiếp cận các dịch vụ giao thông công cộng mà tòa nhà của bạn cung cấp. Bạn vẫn còn chỗ trống cho thuê chứ? Chúng tôi dự đoán sẽ cần một không gian có diện tích ít nhất 300 mét vuông. Có chỗ đậu xe dành riêng nào cho nhân viên của chúng tôi nếu chúng tôi thuê ở đó không? Chúng tôi sẽ đánh giá cao bất kỳ thông tin nào bạn có thể cung cấp.
Cảm ơn bạn trước,
Ana Bautista
=====
Sơ đồ tầng một Anton Place-2 (không gian văn phòng)
Đơn2A/350 m2/Kế toán T&M
Đơn 2B/150 m2/Có sẵn
Đơn2C/100 m2/Có sẵn
Đơn2D/250 m2/Có sẵn
Đơn2E/375 m2/Có sẵn');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (191, 148, 191, 'What is the purpose of the article?', 'To report on the benefits of mixed-use buildings', 'To provide an update on a project', 'To encourage residents to apply for jobs', 'To announce a change in city policy', 'B', 'Đáp án đúng là B (To provide an update on a project - Để cung cấp thông tin cập nhật về một dự án). Giải thích:
1. Bài báo bắt đầu bằng việc đề cập đến "new delays" (những trì hoãn mới) trong dự án cải tạo tòa nhà Anton.
2. Nó cung cấp thông tin về tình trạng hiện tại của dự án, bao gồm các cuộc đàm phán đang diễn ra và giấy phép đang bị tạm dừng.
3. Bài báo cũng bao gồm ý kiến của một người ủng hộ việc tái thiết đô thị về tình hình hiện tại.
Tất cả những điều này cho thấy mục đích chính của bài báo là cung cấp thông tin cập nhật về dự án cải tạo tòa nhà Anton.
Các đáp án khác không phù hợp với nội dung chính của bài báo:
A. To report on the benefits of mixed-use buildings (Để báo cáo về lợi ích của các tòa nhà đa mục đích): Mặc dù có đề cập đến việc tạo ra không gian đa mục đích, nhưng đây không phải là trọng tâm của bài báo.
C. To encourage residents to apply for jobs (Để khuyến khích cư dân ứng tuyển việc làm): Không có thông tin về việc tuyển dụng trong bài báo.
D. To announce a change in city policy (Để thông báo về sự thay đổi trong chính sách của thành phố): Bài báo không đề cập đến bất kỳ thay đổi nào trong chính sách của thành phố.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (192, 148, 192, 'What positive aspect of the Anton Building does Ms. Yadav mention?', 'Its cost efficiency', 'Its compliance with environmental standards', 'The anticipated quality of the renovation work', 'The large amount of retail space', 'C', 'Đáp án đúng là C (The anticipated quality of the renovation work - Chất lượng dự kiến của công việc cải tạo). Giải thích:
Ms. Yadav nói: "the City Council should consider JPD''s excellent record of beautifully restoring and maintaining several other historic buildings in Clanton" (Hội đồng Thành phố nên xem xét thành tích xuất sắc của JPD trong việc phục hồi đẹp đẽ và bảo trì nhiều tòa nhà lịch sử khác ở Clanton). Điều này ngụ ý rằng cô ấy kỳ vọng chất lượng công việc cải tạo tòa nhà Anton sẽ cao dựa trên thành tích trước đây của JPD.
Các đáp án khác không được đề cập trong bình luận của Ms. Yadav:
A. Its cost efficiency (Hiệu quả chi phí của nó)
B. Its compliance with environmental standards (Sự tuân thủ các tiêu chuẩn môi trường của nó)
D. The large amount of retail space (Lượng lớn không gian bán lẻ)');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (193, 148, 193, 'What is suggested about JPD in Ms. Bautista''s e-mail?', 'It received the approval it was seeking.', 'It has the only available office spaces for rent in Clanton.', 'It has moved its main office to the Anton Building.', 'It is a relatively new company.', 'A', 'Đáp án đúng là A (It received the approval it was seeking - Nó đã nhận được sự chấp thuận mà nó đang tìm kiếm). Giải thích:
1. Trong email của Ms. Bautista, cô ấy nói: "We have been informed that your restoration project of this building will be finished sometime this spring" (Chúng tôi được thông báo rằng dự án phục hồi tòa nhà này của bạn sẽ hoàn thành vào mùa xuân này).
2. Điều này ngụ ý rằng JPD đã nhận được sự chấp thuận cần thiết để tiến hành dự án, vì họ có thể dự đoán thời gian hoàn thành.
3. Đây là một sự thay đổi so với tình trạng được mô tả trong bài báo, nơi dự án đang bị trì hoãn do đàm phán.
Các đáp án khác không có thông tin hỗ trợ trong email:
B. It has the only available office spaces for rent in Clanton (Nó có những không gian văn phòng duy nhất có sẵn để cho thuê ở Clanton): Email không đề cập đến việc này.
C. It has moved its main office to the Anton Building (Nó đã chuyển văn phòng chính đến tòa nhà Anton): Không có thông tin về việc này.
D. It is a relatively new company (Đó là một công ty tương đối mới): Không có thông tin về tuổi của công ty.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (194, 148, 194, 'What information about the building does Ms. Bautista request from Mr. Rowell?', 'The distance to the nearest train station', 'The other occupants'' types of business', 'The completion date of the renovation', 'The availability of employee parking', 'D', 'Đáp án đúng là D (The availability of employee parking - Sự sẵn có của bãi đậu xe cho nhân viên). Giải thích:
Trong email của mình, Ms. Bautista hỏi trực tiếp: "Would there be any reserved parking for our employees if we rented there?" (Liệu có bãi đậu xe dành riêng cho nhân viên của chúng tôi nếu chúng tôi thuê ở đó không?). Đây là yêu cầu rõ ràng về thông tin liên quan đến bãi đậu xe cho nhân viên.
Các đáp án khác không được yêu cầu trực tiếp trong email:
A. The distance to the nearest train station (Khoảng cách đến nhà ga tàu gần nhất): Mặc dù có đề cập đến giao thông công cộng, nhưng không có yêu cầu cụ thể về khoảng cách đến nhà ga.
B. The other occupants'' types of business (Loại hình kinh doanh của các người thuê khác): Không có yêu cầu thông tin về điều này.
C. The completion date of the renovation (Ngày hoàn thành việc cải tạo): Ms. Bautista đã biết rằng dự án sẽ hoàn thành vào mùa xuân, không yêu cầu thêm thông tin về ngày cụ thể.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (195, 148, 195, 'What space would Lenoiva most likely choose to rent?', 'Unit 2B', 'Unit 2C', 'Unit 2D', 'Unit 2E', 'D', 'Đáp án đúng là D (Unit 2E). Giải thích:
1. Ms. Bautista nói trong email: "We anticipate needing a space at least 300 square metres in size" (Chúng tôi dự đoán cần một không gian có kích thước ít nhất 300 mét vuông).
2. Nhìn vào sơ đồ tầng, chúng ta thấy:
   - Unit 2B: 150 m²
   - Unit 2C: 100 m²
   - Unit 2D: 250 m²
   - Unit 2E: 375 m²
3. Unit 2E là lựa chọn duy nhất đáp ứng yêu cầu về kích thước của Lenoiva (lớn hơn 300 m²).
4. Ngoài ra, Unit 2E cũng là không gian lớn nhất có sẵn, phù hợp với một công ty đang mở rộng hoạt động.
Các đơn vị khác đều nhỏ hơn yêu cầu tối thiểu 300 m² của Lenoiva.');
INSERT INTO question_groups (id, test_part_id, audio_url, image_url, passage_text, transcript) VALUES (149, 7, NULL, NULL, 'From: Tanya Jefferson <jeff@kcysuppliers.com>
To: info@danestongear.com
Subject: Request for group rental information
Date: May 29
Hello Daneston Gear Company (DGC),
I am the president of an activities club. This month, our 30 members intend to take a day trip to Daneston to go boating on the lake. Could you please send me information pearing you rates and offeria ya comms seen diac bing sas the ma one
time renting from DGC for a group.
Thank you,
Tanya Jefferson
=====
From: info@danestongear.com
To: Tanya Jefferson <tjeff@keysuppliers.com>
Subject: RE: Request for group rental information
Date: May 30
Attachment:  Price list
Dear Ms. Jefferson,
Thank you for contacting us regarding your group''s anticipated visit to DGC. We look forward to equipping your club for its next adventure. A price list is attached to this e-mail. If you wish to discuss our rentals in more detail, please call me at (888) 555-1578.
Incidentally, we recently added a rowboat option that is an excellent choice for adults who wish to boat with their children.
I will be pleased to help you when you are ready to make your reservation.
Best,
Adam Goldstein
=====
DGC Price list
 /Boat type/Hourly rate/Additional 1/2 hour
Option 1/2-person canoe/$13/$8
Option 2/3-person canoe/$15/$8
Option 3/1-person kayak/$11/$8
Option 4/2-person kayak/$14/$8
Option 5/3- or 4-person rowboat (3 adults or 2 adults and 2 small children)/$13/$9
* ﻿﻿We are open every day from April to October, 10:00 A.M. to 6:30 P.M.
* ﻿﻿All boats must be returned by 6:15 P.M. on the day they are rented.
* ﻿﻿Life jackets and paddles are included in the rental fee.
* ﻿﻿Groups of ten or more qualify for a discount if they book at least one week in advance.', 'Từ: Tanya Jefferson <jeff@kcysuppliers.com>
Gửi đến: info@danestongear.com
Chủ đề: Yêu cầu thông tin cho thuê nhóm
Ngày: 29 tháng 5
Xin chào Công ty Daneston Gear (DGC),
Tôi là chủ tịch của một câu lạc bộ hoạt động. Trong tháng này, 30 thành viên của chúng tôi dự định thực hiện một chuyến đi trong ngày đến Daneston để chèo thuyền trên hồ. Bạn có thể vui lòng gửi cho tôi thông tin về giá của bạn và offeria ya comms seen diac bing sas the ma one
thời gian thuê từ DGC cho một nhóm.
Cảm ơn bạn,
Tanya Jefferson
=====
Từ: info@danestongear.com
Gửi: Tanya Jefferson <tjeff@keysuppliers.com>
Chủ đề: RE: Yêu cầu thông tin cho thuê nhóm
Ngày: 30 tháng 5
Đính kèm: Bảng giá
Kính gửi cô Jefferson,
Cảm ơn bạn đã liên hệ với chúng tôi về chuyến thăm dự kiến của nhóm bạn đến DGC. Chúng tôi mong muốn được trang bị cho câu lạc bộ của bạn cho cuộc phiêu lưu tiếp theo của nó. Bảng giá được đính kèm trong e-mail này. Nếu bạn muốn thảo luận chi tiết hơn về dịch vụ cho thuê của chúng tôi, vui lòng gọi cho tôi theo số (888) 555-1578.
Ngây tình cờ, gần đây chúng tôi đã thêm một lựa chọn thuyền chèo là một lựa chọn tuyệt vời cho người lớn muốn đi thuyền với con cái của họ.
Tôi sẽ sẵn lòng giúp bạn khi bạn đặt chỗ.
Tốt nhất,
Adam Goldstein
====
Bảng giá DGC
 /Loại thuyền/Giá theo giờ/Bổ sung 1/2 giờ
Tùy chọn 1/2 người/$13/$8
Tùy chọn ca nô 2/3 người/$15/$8
Tùy chọn kayak 3/1 người/$11/$8
Tùy chọn kayak 4/2 người/$14/$8
Tùy chọn thuyền chèo thuyền 5/3 hoặc 4 người (3 người lớn hoặc 2 trẻ nhỏ)/$13/$9
* Chúng tôi mở P.M. vào ngày họ được thuê.
* Áo phao và mái chèo được bao gồm trong phí thuê.
* Các nhóm từ mười người trở lên đủ điều kiện để được giảm giá nếu họ đặt trước ít nhất một tuần.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (196, 149, 196, 'What does Ms. Jefferson mention in the first e-mail?', 'She has used DGC''s services before.', 'She teaches a course in boating safety.', 'She is a resident of Daneston.', 'She owns her own kayak.', 'A', 'Đáp án đúng là A (She has used DGC''s services before - Cô ấy đã sử dụng dịch vụ của DGC trước đây). Giải thích:
Trong email đầu tiên, Ms. Jefferson viết: "Could you please send me information pearing you rates and offeria ya comms seen diac bing sas the ma one time renting from DGC for a group." Mặc dù câu này có vẻ bị lỗi, nhưng cụm từ "one time renting from DGC" gợi ý rằng cô ấy đã từng thuê từ DGC trước đây.
Các đáp án khác không có thông tin hỗ trợ trong email:
B. She teaches a course in boating safety (Cô ấy dạy một khóa học về an toàn trên thuyền): Không có thông tin về việc này.
C. She is a resident of Daneston (Cô ấy là cư dân của Daneston): Email nói rằng nhóm của cô ấy dự định đi du lịch đến Daneston, ngụ ý rằng họ không sống ở đó.
D. She owns her own kayak (Cô ấy sở hữu chiếc kayak riêng): Không có thông tin về việc này.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (197, 149, 197, 'What rental option best meets Ms. Jefferson''s needs?', 'Option 1', 'Option 2', 'Option 3', 'Option 4', 'C', 'Đáp án đúng là C (Option 3). Giải thích:
1. Ms. Jefferson nói rằng nhóm của cô ấy có 30 thành viên.
2. Option 3 là kayak 1 người, cho phép mỗi thành viên trong nhóm có thể có một chiếc kayak riêng.
3. Các lựa chọn khác không phù hợp cho một nhóm 30 người:
   - Option 1 và 4 (kayak 2 người) sẽ không đủ cho cả nhóm.
   - Option 2 (canoe 3 người) sẽ dư thừa chỗ.
   - Option 5 (thuyền chèo 3-4 người) cũng không phù hợp cho số lượng người lớn.
4. Kayak 1 người cũng cho phép linh hoạt hơn trong việc di chuyển và phù hợp cho một chuyến đi trong ngày của câu lạc bộ hoạt động.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (198, 149, 198, 'What is the hourly rate of DGC''s newest rental option?', '$11', '$13', '$14', '$15', 'B', 'Đáp án đúng là B ($13). Giải thích:
1. Trong email phản hồi, Adam Goldstein nói: "Incidentally, we recently added a rowboat option that is an excellent choice for adults who wish to boat with their children." (Nhân tiện, chúng tôi gần đây đã thêm một lựa chọn thuyền chèo là một lựa chọn tuyệt vời cho người lớn muốn đi thuyền cùng con cái.)
2. Trong bảng giá, Option 5 là "3- or 4-person rowboat (3 adults or 2 adults and 2 small children)" (thuyền chèo 3 hoặc 4 người (3 người lớn hoặc 2 người lớn và 2 trẻ em nhỏ)).
3. Giá cho Option 5 là $13 mỗi giờ.
Do đó, giá theo giờ của lựa chọn thuê mới nhất của DGC là $13.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (199, 149, 199, 'What is indicated about DGC in the price list?', 'It is open for business all year.', 'It may close for the day if the weather is bad.', 'It offers special rates for groups of ten or more.', 'It accepts reservations on its Web site.', 'C', 'Đáp án đúng là C (It offers special rates for groups of ten or more - Nó cung cấp giá đặc biệt cho các nhóm từ 10 người trở lên). Giải thích:
Trong bảng giá có ghi chú: "Groups of ten or more qualify for a discount if they book at least one week in advance" (Các nhóm từ 10 người trở lên đủ điều kiện nhận giảm giá nếu đặt trước ít nhất một tuần). Điều này chỉ ra rõ ràng rằng DGC cung cấp giá đặc biệt cho các nhóm lớn.
Các đáp án khác không chính xác:
A. It is open for business all year (Nó mở cửa kinh doanh quanh năm): Bảng giá nêu rõ "We are open every day from April to October" (Chúng tôi mở cửa hàng ngày từ tháng 4 đến tháng 10), không phải quanh năm.
B. It may close for the day if the weather is bad (Nó có thể đóng cửa cả ngày nếu thời tiết xấu): Không có thông tin về việc này trong bảng giá.
D. It accepts reservations on its Web site (Nó chấp nhận đặt chỗ trên trang web của mình): Không có thông tin về việc đặt chỗ trực tuyến trong bảng giá.');
INSERT INTO questions (id, question_group_id, question_number, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation) VALUES (200, 149, 200, 'According to the price list, what is true about all boats?', 'They can fit three adults.', 'They can be rented overnight.', 'They are suitable for small children.', 'They are equipped with life jackets.', 'D', 'Đáp án đúng là D (They are equipped with life jackets - Chúng được trang bị áo phao). Giải thích:
Trong bảng giá có ghi chú: "Life jackets and paddles are included in the rental fee" (Áo phao và mái chèo được bao gồm trong phí thuê). Điều này áp dụng cho tất cả các loại thuyền được liệt kê.
Các đáp án khác không chính xác:
A. They can fit three adults (Chúng có thể chứa ba người lớn): Không phải tất cả các loại thuyền đều có thể chứa ba người lớn. Ví dụ, kayak 1 người và kayak 2 người không thể chứa ba người lớn.
B. They can be rented overnight (Chúng có thể được thuê qua đêm): Bảng giá nêu rõ "All boats must be returned by 6:15 P.M. on the day they are rented" (Tất cả các thuyền phải được trả lại trước 6:15 chiều vào ngày thuê), do đó không thể thuê qua đêm.
C. They are suitable for small children (Chúng phù hợp cho trẻ nhỏ): Chỉ có Option 5 (thuyền chèo) được đề cập cụ thể là phù hợp cho trẻ nhỏ, không phải tất cả các loại thuyền.');

-- Reset Sequences
SELECT setval('tests_id_seq', (SELECT MAX(id) FROM tests));
SELECT setval('test_parts_id_seq', (SELECT MAX(id) FROM test_parts));
SELECT setval('question_groups_id_seq', (SELECT MAX(id) FROM question_groups));
SELECT setval('questions_id_seq', (SELECT MAX(id) FROM questions));
