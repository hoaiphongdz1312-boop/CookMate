# Đăng nhập bằng Google

Luồng: app dùng `google_sign_in` lấy **idToken** → `POST /api/auth/google { idToken }` → server verify
bằng `Google.Apis.Auth` (audience = `Google:ClientId`) → tìm/tạo user → trả JWT của CookMate như đăng nhập thường.

Cần **2 OAuth client** trong cùng một project Google Cloud:

| Client | Dùng để | Điền vào đâu |
|---|---|---|
| **Web application** | idToken có audience = client này; server kiểm tra | `Google:ClientId` (server) và `GOOGLE_SERVER_CLIENT_ID` (app) |
| **Android** (package `com.cookmate.cookmate` + SHA-1) | Cho phép app Android gọi Google Sign-In | Không điền vào code, chỉ cần tồn tại |

> Điền nhầm Android client ID vào `GOOGLE_SERVER_CLIENT_ID` là lỗi hay gặp nhất, xem phần "Lỗi thường gặp".

## 1. Lấy SHA-1 của khóa debug

```bash
cd app/android
./gradlew signingReport
```

Trên Windows PowerShell dùng `.\gradlew signingReport`. Lấy dòng `SHA1` của variant `debug`
(khóa nằm ở `~/.android/debug.keystore`). Mỗi máy dev có SHA-1 khác nhau: mỗi người thêm một Android client
(hoặc thêm cùng package với SHA-1 khác). Bản release có SHA-1 riêng.

## 2. Tạo trên Google Cloud Console

1. Tạo project (hoặc dùng project có sẵn) tại <https://console.cloud.google.com>.
2. **APIs & Services → OAuth consent screen**: chọn *External*, điền tên app, email hỗ trợ. Để trạng thái **Testing**.
3. Trong **Test users**, thêm các Gmail sẽ dùng để thử (chỉ các tài khoản này đăng nhập được khi app còn ở Testing).
4. **Credentials → Create credentials → OAuth client ID**:
   - Loại **Android**: package name `com.cookmate.cookmate`, dán SHA-1 ở bước 1.
   - Loại **Web application**: đặt tên bất kỳ (không cần redirect URI). Copy **Client ID** của client này.

## 3. Cấu hình server

Đặt Web client ID, không commit vào Git:

```bash
cd server/CookMate.Api
dotnet user-secrets set "Google:ClientId" "<web-client-id>.apps.googleusercontent.com"
```

(hoặc điền vào `appsettings.Development.json`, file này đã nằm ngoài Git). Thiếu `Google:ClientId`:
ở Development server chỉ log cảnh báo và `/api/auth/google` trả **503**; môi trường khác server không khởi động.

Áp migration thêm cột `GoogleId`:

```bash
dotnet ef database update
```

## 4. Chạy app

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

Hoặc gom vào file (khỏi gõ dài): copy `app/env.example.json` thành `app/env.json`, điền Web client ID, rồi `flutter run --dart-define-from-file=env.json` (file `env.json` đã được .gitignore).

Nếu đã dùng `--dart-define=API_BASE_URL=...` thì thêm cả hai cờ. Không truyền cờ này thì bấm nút Google sẽ báo thiếu cấu hình.

## Hành vi tài khoản

- Email Google chưa có trong hệ thống: tạo tài khoản mới (đã xác thực, không có mật khẩu).
- Email đã có tài khoản đã xác thực: gắn Google vào tài khoản đó, giữ nguyên mật khẩu.
- Email đã đăng ký nhưng **chưa xác thực**: gắn Google, **xóa mật khẩu cũ** và đánh dấu đã xác thực. Việc xóa mật khẩu
  chặn kẻ đăng ký trước bằng email của người khác rồi chiếm tài khoản (vì `Register` cho đăng ký lại email chưa xác thực).
- Tài khoản không có mật khẩu muốn đăng nhập bằng email/mật khẩu: dùng "Quên mật khẩu" để đặt mật khẩu.
- Google trả `email_verified = false`: server từ chối (403).

## Lỗi thường gặp

| Triệu chứng | Nguyên nhân / cách xử lý |
|---|---|
| `ApiException: 10` hoặc `DEVELOPER_ERROR` | Sai SHA-1 hoặc package name của Android client. Chạy lại `gradlew signingReport`, so với client trên Console; package phải là `com.cookmate.cookmate`. Sau khi sửa có thể mất vài phút mới có hiệu lực. |
| `idToken` null / báo "Google không trả idToken" | `GOOGLE_SERVER_CLIENT_ID` đang dùng Android client ID. Phải là **Web client ID**. |
| Server trả 401 "Đăng nhập Google thất bại" | Web client ID ở server khác với ở app, hoặc token hết hạn. Hai nơi phải dùng cùng một Web client ID. |
| Server trả 503 | Server chưa có `Google:ClientId`. |
| Server trả 403 "Email Google chưa được xác thực" | Tài khoản Google có email chưa xác thực. |
| Màn chọn tài khoản không hiện / "Access blocked" | Consent screen đang Testing mà Gmail chưa nằm trong Test users. |
| Emulator không có tài khoản để chọn | Dùng emulator có **Google Play** (icon Play Store trong AVD), và đăng nhập một tài khoản Google trong Settings. |
| Báo lỗi cấu hình khi bấm nút | Chưa truyền `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`. |
