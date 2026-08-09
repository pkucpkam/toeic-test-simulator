# TOEIC Web App - Deployment Walkthrough

Tôi đã hoàn tất cấu hình source code để chuẩn bị deploy lên production. Các thay đổi đã được thực hiện:
- Cập nhật `application.yml` hỗ trợ cấu hình dynamic port và migration mode.
- Cập nhật `SecurityConfig.java` cho phép CORS động qua environment variables.
- Tạo `MediaController.java` để xử lý logic redirect audio/images qua Google Drive.
- Cập nhật `.gitignore` để tránh rò rỉ secret.

Bây giờ bạn cần thực hiện các bước sau để deploy:

---

## 1. Import Database vào Aiven PostgreSQL

Aiven của bạn hiện đang trống. File script tạo database và insert câu hỏi mẫu nằm ở: `backend/practice/src/main/resources/db/migration/V2__init_schema.sql` (16MB).

Bạn cần chạy lệnh này trong Terminal để import data:
```bash
psql "ĐƯỜNG_DẪN_KẾT_NỐI_AIVEN_CỦA_BẠN" -f backend/practice/src/main/resources/db/migration/V2__init_schema.sql
```
> [!NOTE]
> Thay `"ĐƯỜNG_DẪN_KẾT_NỐI_AIVEN_CỦA_BẠN"` bằng Service URI lấy từ trang dashboard của Aiven (ví dụ: `postgres://avnadmin:pass@host:port/defaultdb?sslmode=require`).

---

## 2. Chuẩn bị file mapping cho Google Drive (Tuỳ chọn)

Hiện tại, nếu bạn truy cập `/api/media/audio/test1.mp3`, API sẽ chuyển hướng (redirect) tới một ID Google Drive giả định. Để API này hoạt động thật sự với file bạn upload lên Drive, bạn cần chỉnh sửa logic trong method `getDriveFileIdByPath` ở file `MediaController.java` (backend) để trả về đúng ID của file tương ứng trên Google Drive.

> [!TIP]
> Bạn có thể tự viết một hàm đọc file JSON mapping `{"audio/test1.mp3": "1A2B3C...", ...}` trong tương lai nếu cần.

---

## 3. Deploy Backend lên Koyeb

1. Đăng nhập Koyeb, tạo Service mới.
2. Chọn **GitHub**, chọn repository `toeic-test-simulator`.
3. **Builder**: Chọn **Buildpack** hoặc **Dockerfile** (Nếu dùng Buildpack, Koyeb sẽ tự động nhận diện Gradle).
4. Cấu hình các mục sau:
   - **Root directory**: `backend/practice`
   - **Build command**: `./gradlew build -x test`
   - **Run command**: `java -jar build/libs/practice-0.0.1-SNAPSHOT.jar`
   - **Port**: `8080` (như cũ)

5. **Environment Variables**:
   - `DATABASE_URL` = `jdbc:postgresql://<aiven-host>:<port>/<db>?sslmode=require` (nhớ đổi `postgres://` thành `jdbc:postgresql://`)
   - `DB_USERNAME` = username Aiven (vd: `avnadmin`)
   - `DB_PASSWORD` = mật khẩu Aiven
   - `JWT_SECRET` = `243073985814ea0d626091196c8ab5abc1e6bd3916b6e9be56151f14684f8c42`
   - `SQL_INIT_MODE` = `never`
   - `media.strategy` = `drive`
   - `CORS_ALLOWED_ORIGINS` = `https://<ten-mien-vercel-cua-ban>.vercel.app` (cập nhật sau khi deploy Vercel)

---

## 4. Deploy Frontend lên Vercel

1. Đăng nhập Vercel, tạo Project mới từ GitHub.
2. Chọn thư mục root là `frontend`.
3. Cài đặt các **Environment Variables**:
   - `NEXT_PUBLIC_API_URL` = `https://<ten-mien-koyeb-cua-ban>.koyeb.app/api`
4. Bấm **Deploy**.

> [!IMPORTANT]
> Sau khi Vercel deploy xong, bạn sẽ có domain (ví dụ `toeic-test.vercel.app`). Đừng quên **quay lại Koyeb** để cập nhật biến môi trường `CORS_ALLOWED_ORIGINS` thành domain này và restart backend!

---

## 5. Đẩy code lên GitHub

Bạn cần commit và push các thay đổi này lên nhánh `main`:
```bash
git add .
git commit -m "chore: prepare for production deployment with Google Drive media and env vars"
git push origin main
```
Sau khi code được đẩy lên, bạn có thể kết nối GitHub với Koyeb và Vercel để hoàn thành deploy!
