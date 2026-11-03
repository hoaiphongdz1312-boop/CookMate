# Kế hoạch & tiến trình: Duyệt công thức nấu ăn do thành viên đăng

Cập nhật lần cuối: 2026-11-02

## 1. Mục tiêu

Thành viên đăng công thức thì hệ thống tự quyết định bài phải chờ admin duyệt hay đăng thẳng, và có cơ chế báo cáo vi phạm.

## 2. Quy tắc nghiệp vụ (đã chốt)

| # | Quy tắc |
|---|---------|
| 1 | User mới (dưới 3 bài đã được duyệt) thì bài đăng vào hàng chờ `Pending`. |
| 2 | User đã có từ 3 bài `Approved` trở lên thì bài đăng thẳng `Approved`. |
| 3 | Mọi bài đang hiển thị đều có nút "Báo cáo vi phạm". |
| 4 | Admin có thể gỡ bài đã duyệt (chuyển về `Rejected`) khi có báo cáo hợp lệ. |
| 5 | User chặn được user khác (yêu cầu UGC của Google Play). |
| 6 | Chủ bài luôn thấy bài của mình ở mọi trạng thái, kèm lý do nếu bị từ chối. |
| 7 | User nhận thông báo khi bài được duyệt hoặc bị từ chối. |

Trạng thái bài: `0 = Pending`, `1 = Approved`, `2 = Rejected`.

Ngưỡng 3 bài là giá trị khởi đầu, cấu hình ở `Community:AutoApproveAfter` trong `appsettings.json` (lớp `CommunityOptions`).

## 3. Các giai đoạn

### Giai đoạn 1: Database
- [x] Bảng `Recipes`: `Status`, `RejectReason`, `ReviewedById`, `ReviewedAt` đã có từ migration `AddCommunityRecipes`. Cột `Status` cố ý **không** có default ở DB (xem `DropRecipeStatusDefault`).
- [x] Bảng mới `RecipeReports`: `Id`, `RecipeId`, `ReporterId`, `Reason`, `Detail`, `CreatedAt`, `Status` (0 chờ xử lý / 1 đã xử lý), `Resolution`, `ResolvedById`, `ResolvedAt`. Index duy nhất `(RecipeId, ReporterId)`.
- [x] Bảng mới `UserBlocks`: khóa chính `(BlockerId, BlockedId)`, `CreatedAt`, CHECK không tự chặn.
- [x] Số bài đã duyệt: **đếm từ `Recipes`**, không thêm cột `ApprovedCount`.
- [x] Migration `AddReportsBlocksNotifications` (thêm cả bảng `Notifications`). Dữ liệu cũ đã ở `Status = 1` từ `AddCommunityRecipes`. Đã chạy thử trên một DB trống của SQL Server.

### Giai đoạn 2: API (server)
- [x] `POST /api/community/recipes`: dưới ngưỡng thì `Pending`, đạt ngưỡng thì `Approved` (`ReviewedAt` = lúc đăng, `ReviewedById` = null).
- [x] `GET /api/community/recipes` (feed): chỉ `Status = 1`, bỏ bài của người mà người xem đã chặn.
- [x] `GET /api/community/recipes/mine`: đã có sẵn.
- [x] `POST /api/community/recipes/{id}/report`: mỗi user một lần (409 lần 2), không báo cáo bài của mình, lý do `other` bắt buộc mô tả.
- [x] `POST /api/users/{id}/block`, `DELETE /api/users/{id}/block`, thêm `GET /api/users/me/blocks`.
- [x] `GET /api/admin/recipes/pending`: đã có sẵn.
- [x] Duyệt: `POST /api/admin/recipes/{id}/approve` (giữ POST như code cũ, không đổi sang PUT).
- [x] Từ chối: `POST /api/admin/recipes/{id}/reject`, bắt buộc lý do.
- [x] `GET /api/admin/reports` (gộp theo bài), `GET /api/admin/reports/count`, `POST /api/admin/reports/recipes/{id}/takedown`, `POST /api/admin/reports/recipes/{id}/dismiss`.
- [x] Phân quyền: `/api/admin/*` chỉ cho role Admin.
- [~] Thông báo: **thông báo trong app** (`GET /api/notifications`, `/unread-count`, `POST /read-all`), tạo khi duyệt, từ chối, gỡ bài. **Push FCM chưa làm**: cần tạo project Firebase và `google-services.json`.

### Giai đoạn 3: App Android (người dùng)
- [x] Màn đăng bài: SnackBar "Bài đang chờ duyệt..." hoặc "Đã đăng...".
- [x] Màn "Bài của tôi": nhãn trạng thái và lý do từ chối (đã có sẵn).
- [x] Menu "Báo cáo vi phạm" trên chi tiết công thức (cả công thức hệ thống), lý do: sai thông tin, spam, nội dung xấu, vi phạm bản quyền, khác.
- [x] "Chặn người dùng" trên chi tiết bài cộng đồng; Hồ sơ > "Người dùng đã chặn" để bỏ chặn.
- [x] Chuông thông báo (có số chưa đọc) ở tab Cộng đồng, màn Thông báo.

### Giai đoạn 4: Màn hình admin (trong app Android)
- [x] Danh sách bài chờ duyệt, xem đủ nội dung: đã có sẵn.
- [x] Duyệt / Từ chối (nhập lý do): đã có sẵn.
- [x] Hồ sơ > "Báo cáo vi phạm (n)": xem các báo cáo theo bài, Xem bài, Gỡ bài (nhập lý do), Bỏ qua.

### Giai đoạn 5: Kiểm thử
Tự động: `server/CookMate.Api.Tests/ModerationTests.cs` (8 test) và `app/test/moderation_test.dart`.

- [x] User mới đăng bài: bài vào `Pending`, không hiện ở feed.
- [x] Admin duyệt: bài hiện ở feed, user nhận thông báo.
- [x] Admin từ chối: bài không hiện ở feed, chủ bài thấy lý do.
- [x] User có đủ 3 bài đã duyệt đăng bài: lên feed ngay.
- [x] Báo cáo cùng một bài hai lần bởi một user: lần 2 bị chặn (409).
- [x] User bị chặn: bài của họ không hiện trong feed của người chặn.
- [x] User thường gọi endpoint `/admin/*`: nhận lỗi 403.
- [x] Dữ liệu cũ vẫn hiển thị bình thường sau migration (test `Seeded_recipes_stay_approved_and_listed`).
- [x] Chạy tay trên máy thật (Samsung SM-G781N, Android 13) với 3 tài khoản test (tác giả, người xem, admin), server trỏ vào DB thật. Dữ liệu test đã xóa sau khi chạy.

## 4. Bảng tiến trình

| Giai đoạn | Trạng thái | Ngày bắt đầu | Ngày xong | Ghi chú |
|-----------|-----------|--------------|-----------|---------|
| 1. Database | Xong | 2026-11-02 | 2026-11-02 | Đã migrate DB thật (backup `CookMate_truoc_duyet_bai.bak`) |
| 2. API | Xong (trừ push FCM) | 2026-11-02 | 2026-11-02 | Thông báo trong app thay cho push |
| 3. App Android | Xong | 2026-11-02 | 2026-11-02 | |
| 4. Admin | Xong | 2026-11-02 | 2026-11-02 | Làm trong app Android |
| 5. Kiểm thử | Xong | 2026-11-02 | 2026-11-02 | Test tự động + chạy tay trên máy thật |

## 5. Nhật ký

- 2026-11-02: Chốt hướng kết hợp (user mới chờ duyệt, user đã có 3 bài duyệt thì đăng thẳng, kèm báo cáo và chặn). Tạo file kế hoạch.
- 2026-11-02: Làm giai đoạn 1–4. Phần lớn luồng duyệt đã có từ tính năng Cộng đồng (`CONG_DONG.md`); bổ sung ngưỡng tự duyệt, báo cáo, chặn, thông báo trong app, màn admin xử lý báo cáo. Server 68/69 test qua (test lỗi là `GoogleLoginTests.Missing_client_id_returns_503`, lỗi cũ do cấu hình máy), app 116 test qua.

- 2026-11-02: Backup và migrate DB thật. Test trên máy thật: API 57/58 (lần duy nhất trượt là giới hạn sẵn có 5 bài/giờ chặn bài thứ 6), giao diện qua hết. Phát hiện và sửa: màn "Báo cáo vi phạm" của admin trắng trơn vì theme cho `FilledButton`/`OutlinedButton` rộng vô hạn (`Size.fromHeight`) nên đặt trong `Row` là vỡ layout; hai nhãn bị cắt chữ.

## 6. Quyết định

- Admin duyệt ở đâu: **trong app Android** (màn duyệt đã có sẵn).
- Tự ẩn bài khi đủ số báo cáo: **chưa làm**, mọi báo cáo do admin xử lý tay.
- Sửa bài đã duyệt: giữ quy tắc cũ, **không cho sửa** (xóa và đăng lại). Bài bị từ chối hoặc bị gỡ sửa xong luôn quay về `Pending`, kể cả tác giả đủ ngưỡng, để admin xem lại.
- Bài bị gỡ chuyển sang `Rejected` nên không còn tính vào ngưỡng 3 bài.
- Bài đăng thẳng vẫn nằm trong hàng chờ báo cáo như mọi bài khác.

## 7. Triển khai

1. Backup DB (file `.bak` trong `backup/`).
2. Dừng server, chạy `dotnet ef database update` trong `server/CookMate.Api`.
3. Chạy lại server, build lại app.
