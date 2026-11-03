# Tab Cộng đồng: chia sẻ công thức có admin duyệt

Kế hoạch gốc: `KE_HOACH_CHIA_SE_CONG_THUC.md`. Tài liệu này chỉ ghi cách chạy và những gì khác kế hoạch.

## Triển khai lần đầu (làm theo thứ tự)

1. **Backup DB** trước khi migrate (file `.bak` trong thư mục `backup/`).
2. Dừng server đang chạy, rồi cập nhật DB (migration `AddCommunityRecipes` đặt mọi công thức cũ thành Đã duyệt):

   ```bash
   cd server/CookMate.Api
   dotnet ef database update
   ```

3. Tạo admin bằng user-secrets. Email đã có tài khoản thì được nâng thành Admin; chưa có thì tạo tài khoản mới (cần cả mật khẩu, tối thiểu 8 ký tự):

   ```bash
   dotnet user-secrets set "Admin:Email" "admin@example.com"
   dotnet user-secrets set "Admin:Password" "mat-khau-manh-cua-ban"
   ```

   Hoặc chạy SQL: `UPDATE Users SET Role='Admin' WHERE Email='...'`.
4. Chạy lại server. **Admin phải đăng nhập lại** để token mới có claim vai trò.
5. App: `flutter pub get` (thêm `image_picker`), chạy lại app.

## Tự duyệt, báo cáo, chặn, thông báo

Xem `KE_HOACH_DUYET_BAI.md`. Cần chạy migration `AddReportsBlocksNotifications` (backup DB trước).

## Khác với kế hoạch

- Bài xóa là **xóa mềm** (cột `IsDeleted`) vì `CookingSession.RecipeId` dùng `DeleteBehavior.Restrict`.
- Chống hai admin xử lý chồng: `Status` là concurrency token (không dùng `ExecuteUpdate` vì test dùng EF InMemory). Kết quả vẫn là 409.
- Bộ giới hạn 5 bài/giờ tính cả yêu cầu bị từ chối vì validate; chỉnh bằng `RateLimit:SharePerHour`.
- Màn duyệt gộp list + chi tiết trong `features/admin/admin_review_screens.dart`. Chi tiết dùng `GET /api/recipes/{id}` (admin xem được bài chờ duyệt).
- Sửa bài ở app đổi `timerSeconds` sang phút làm tròn lên (90 giây thành 2 phút).
- Token admin còn hiệu lực tới khi hết hạn (7 ngày) dù bị hạ quyền trong DB; chưa có API hạ quyền.
- Ảnh lưu ở `server/CookMate.Api/wwwroot/uploads` (đổi bằng `Uploads:Directory`), phục vụ ở `/uploads/...`. Chưa dọn ảnh mồ côi khi xóa bài.

## Kiểm thử

- Server: `CommunityTests.cs` (rò rỉ, quyền admin, duyệt/từ chối, sửa/xóa, validate, upload, rate limit).
- App: `test/community_test.dart`.
- `GoogleLoginTests.Missing_client_id_returns_503` fail trên máy có `Google:ClientId` trong `appsettings.Development.json`; không liên quan tính năng này.
- Checklist chạy tay với 2 tài khoản (User + Admin): mục 7.3 của kế hoạch.
