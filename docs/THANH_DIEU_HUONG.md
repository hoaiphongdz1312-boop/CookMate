# Thanh điều hướng dưới đáy — kế hoạch và tiến trình

> **Cập nhật 31/10:** đã bỏ tab Cứu hộ (gỡ toàn bộ Bếp cứu hộ khỏi app và server). Thanh dưới còn 3 tab: Công thức, Cộng đồng, Hồ sơ. Các mục nhắc Cứu hộ bên dưới đã sửa theo.

Ngày lập: 2026-10-31. Phạm vi: điều hướng của app Flutter (`app/lib/router.dart`, `app/lib/features/home/`). Không đụng server, auth, face, màn nấu.

## 1. Mục tiêu

Người dùng chuyển giữa các giao diện chính bằng 1 thanh ở đáy màn hình, không phải bấm icon nhỏ trên AppBar.

| Tab | Nhãn | Màn | Route |
|---|---|---|---|
| 1 | Công thức | `RecipeListScreen` | `/` |
| 2 | Cộng đồng | `CommunityFeedScreen` | `/community` |
| 3 | Hồ sơ | `ProfileScreen` | `/profile` |

## 2. Quyết định kỹ thuật

- Dùng `NavigationBar` (Material 3) + `StatefulShellRoute.indexedStack` của go_router (đã có sẵn trong project, không thêm thư viện). Mỗi tab giữ trạng thái riêng: đang tìm kiếm/lọc ở tab Công thức, qua tab khác quay lại vẫn còn.
- Bấm lại tab đang mở thì về màn đầu của tab đó (`goBranch(..., initialLocation: true)`).
- Màn con mở trên navigator gốc (`parentNavigatorKey`) nên **che thanh tab**: chi tiết món `/recipes/:id`, màn nấu `/recipes/:id/cook`. Lý do: màn nấu cần toàn màn hình, tay đang dính dầu mỡ.
- Các màn ngoài thanh tab (không đổi): `/login`, `/register`, `/verify-email`, `/forgot-password`, `/reset-password`, `/face-login`, `/face-enroll`, `/splash`, `/voice-lab` (debug).
- Bỏ 3 nút trên AppBar của `RecipeListScreen` (Cứu hộ, Hồ sơ, Đăng xuất) vì đã có thanh tab. **Nút Đăng xuất chuyển sang AppBar của Hồ sơ**, hộp thoại xác nhận giữ nguyên.

## 3. Bảng theo dõi tiến trình

| Mã | Việc | Ai làm | Trạng thái |
|---|---|---|---|
| N1 | Tạo `features/home/main_shell.dart` (NavigationBar 3 tab) | Claude | [x] |
| N2 | `router.dart`: `StatefulShellRoute` + `navigatorKey` gốc, chuyển `/`, `/community`, `/profile` vào 3 nhánh (ban đầu có `/rescue`, đã bỏ 31/10) | Claude | [x] |
| N3 | `recipe_list_screen.dart`: bỏ 3 nút AppBar và `_confirmLogout` | Claude | [x] |
| N4 | `profile_screen.dart`: thêm nút Đăng xuất + `_confirmLogout` | Claude | [x] |
| N5 | `flutter analyze` + `flutter test` (đặc biệt `recipe_list_screen_test.dart`) | Mày | [ ] |
| N6 | Chạy tay trên máy ảo/điện thoại, theo checklist mục 4 | Mày | [ ] |
| N7 | Cập nhật ảnh chụp màn hình trong báo cáo/slide (có thanh tab mới) | Mày | [ ] |

## 4. Checklist test tay (N6)

- [ ] Đăng nhập xong thấy thanh 3 tab ở đáy, tab Công thức sáng.
- [ ] Gõ tìm "canh", sang tab Cộng đồng rồi về lại: ô tìm kiếm và kết quả còn nguyên.
- [ ] Bấm lại tab Công thức khi đang ở màn con của tab đó: về danh sách.
- [ ] Vào chi tiết món rồi bấm Nấu: thanh tab ẩn; thoát nấu về chi tiết, thoát tiếp về danh sách, thanh tab hiện lại.
- [ ] Tab Hồ sơ: "Đang nấu dở" bấm vào mở màn nấu đúng bước; thoát về Hồ sơ vẫn đúng tab.
- [ ] Hồ sơ → Đăng xuất → hộp thoại → về màn đăng nhập; đăng nhập lại về tab Công thức.
- [ ] Nút Back của Android ở tab 2 hoặc 3 không thoát app ngay mà về tab 1 (nếu app thoát luôn thì ghi lại, xử lý ở bước sau).
- [ ] Chế độ tối: thanh tab đọc rõ.

## 5. Rủi ro đã biết

- Chưa chạy `flutter analyze` ở bước viết code (không có Flutter SDK trong môi trường soạn), nên N5 là bắt buộc trước khi tin kết quả.
- Nút "Cần trợ giúp" ở màn nấu từng mở `/rescue` (một nhánh của thanh tab) chồng lên navigator gốc, gây lỗi `keyReservation` của go_router. Đã xử lý bằng cách bỏ hẳn Bếp cứu hộ.

## 6. Kết quả test (điền ở N5, N6)

| Lần | Máy | analyze | test | Checklist mục 4 | Ghi chú |
|---|---|---|---|---|---|
| 1 | | | | | |
