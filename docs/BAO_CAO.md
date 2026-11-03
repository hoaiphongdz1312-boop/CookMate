# CookMate: khung báo cáo và dàn slide (R1)

Quy ước: `[ĐIỀN: ...]` là chỗ cần số liệu/kết quả thật, chưa có thì để trống, không tự bịa.

## Phần A. Khung báo cáo

### 1. Giới thiệu và mục tiêu
- Bài toán: người mới nấu ăn cần công thức, định lượng theo số người, hẹn giờ và hướng dẫn từng bước đủ chi tiết.
- Mục tiêu: ứng dụng Android hướng dẫn nấu từng bước, có đăng nhập bằng khuôn mặt.
- Nhóm/thành viên, giảng viên: [ĐIỀN].

### 2. Phạm vi chức năng
**Đã làm** (đối chiếu code ngày 29/10; mục nào chưa test tay thì ghi rõ):
- Đăng ký, đăng nhập mật khẩu, JWT 7 ngày; xác thực email bằng mã 6 số; quên/đặt lại mật khẩu.
- Đăng ký và đăng nhập bằng khuôn mặt (kèm chớp mắt); xóa dữ liệu khuôn mặt.
- Danh sách công thức: tìm, lọc danh mục/độ khó/thời gian; chi tiết; quy đổi khẩu phần 1-20.
- Chế độ nấu từng bước, hẹn giờ, giữ sáng màn hình; phiên nấu và tiến độ lưu trên server.
- Mỗi bước nấu có câu chính và các ý chi tiết (cách làm, dấu hiệu nhận biết, lưu ý); công thức hệ thống có ảnh minh họa.
- Khẩu vị (thêm 01/11): hỏi một lần sau khi đăng nhập (6 nhãn: cay, chua, ngọt, đậm đà, thanh nhẹ, béo; chọn nhiều hoặc Bỏ qua), lưu theo tài khoản trên server, sửa ở Hồ sơ. Mục "Dành cho bạn" đầu tab Công thức xếp món hệ thống theo số nhãn trùng, không dùng AI.
- "Hôm nay ăn gì?" (thêm 01/11): quay ngẫu nhiên một món hệ thống đã duyệt theo danh mục, độ khó, thời gian tối đa; "Thử món khác" loại các món đã trúng trong phiên; từ kết quả mở công thức hoặc nấu ngay.
- Điều khiển giọng nói (Vosk, chạy offline trên máy): nói "Bếp ơi" rồi ra lệnh. Ở màn nấu: bước tiếp theo, bước trước, hẹn giờ, dừng hẹn giờ. Từ 01/11 nghe được ở mọi màn khi bật công tắc trong Hồ sơ: hiện bảng "Bạn cần gì?" (tự đóng sau 5 giây), lệnh "hôm nay ăn gì", "mở món đang nấu", "về trang chủ". Chỉ nghe khi app đang mở; tự dừng khi app xuống nền và khi màn quét mặt/chọn ảnh đang dùng camera. **Chưa test bằng giọng trên máy ảo** (mic máy ảo không nhận), mới kiểm bằng test tự động.

**Chưa làm / ngoài phạm vi** (nói thẳng): lọc chay/mặn, yêu thích và lịch sử quay ở "Hôm nay ăn gì?"; nghe "Bếp ơi" khi khóa màn hình; đăng nhập Google, thông báo đẩy, trang admin, thực đơn tuần, tủ lạnh, cộng đồng, nhận diện ảnh món, offline, landmark 133 điểm, refresh token; Yêu thích, Quiz, checklist mua sắm: [ĐIỀN: làm hay không].
**Nội dung hiện có**: [ĐIỀN: số công thức thực tế trong DB. File seed có 15 món, 13 món có ảnh minh họa].
**Đã bỏ**: Bếp cứu hộ (cây câu hỏi xử lý sự cố khi nấu) đã được gỡ khỏi app và server ngày 31/10; migration `DropRescue` xóa các bảng liên quan.

### 3. Kiến trúc
- App: Flutter (Android, minSdk 26), dio, go_router, flutter_secure_storage, camera, ML Kit Face Detection, TFLite (MobileFaceNet).
- Server: ASP.NET Core Web API (net10.0), EF Core, SQL Server, JWT, rate limiting.
- Luồng: App ⇄ HTTP/JSON ⇄ API ⇄ SQL Server. Vẽ sơ đồ khối: [ĐIỀN: hình].
- Nhận diện mặt chạy tạo embedding trên app; server so khớp cosine.

### 4. Thiết kế CSDL
Các bảng chính: Users, Categories, Recipes, RecipeIngredients, RecipeSteps, CookingSessions,
cộng EmailCodes (xác thực email) theo bổ sung ở KE_HOACH mục 5. Nhãn khẩu vị lưu thành cột chuỗi `Tastes` (các nhãn cách nhau dấu phẩy) trên `Recipes` và `Users`, không thêm bảng; `Users.Tastes` null = chưa được hỏi, rỗng = đã bỏ qua (migration `AddRecipeTastes`, `AddUserTastes`). Chèn sơ đồ ERD: [ĐIỀN: hình xuất từ SSMS/EF]. Ghi chú: gộp Ingredients vào RecipeIngredients; embedding mặt lưu `varbinary(max)` float32.

### 5. Danh sách API
Lấy từ KE_HOACH_v2.md mục 5 (Auth, Công thức, Phiên nấu và tiến độ; bỏ nhóm Bếp cứu hộ vì đã gỡ). Trình bày thành bảng: phương thức, đường dẫn, yêu cầu đăng nhập, mô tả. Đối chiếu lại với Swagger trước khi nộp. API thêm 01/11: `GET /api/recipes/recommended?limit=` (gợi ý theo khẩu vị người đăng nhập; khách hoặc chưa chọn thì trả danh sách thường), `GET /api/recipes/random?categoryId=&difficulty=&maxMinutes=&excludeIds=` (404 kèm thông báo khi không còn món phù hợp), `PUT /api/users/me/tastes` (cần đăng nhập; nhãn lạ trả 400). `GET /api/users/me` và các API công thức trả thêm `tastes`.

### 6. Đăng nhập bằng khuôn mặt
- Quy trình đăng ký (3-5 mẫu, kiểm tra đồng nhất ≥ 0.75, chống trùng ≥ 0.75) và đăng nhập (3 embedding, cosine ≥ 0.80, hơn người thứ hai ≥ 0.08, giới hạn 10 lần/phút/IP). Ngưỡng ở `appsettings.json` mục `Face`.
- Nguyên tắc: không lưu ảnh, chỉ gửi vector chuẩn hóa L2.
- **Hạn chế (viết thẳng, theo KE_HOACH 3.4)**:
  - Chống ảnh giả chỉ ở mức kiểm tra chớp mắt trên app; ai gọi thẳng API với vector bị lộ vẫn vào được.
  - Embedding lưu trên server, như một "mật khẩu không đổi được": lộ thì chỉ có xóa và đăng ký lại.
  - Demo chạy HTTP, embedding đi qua mạng không mã hóa; không dùng ngoài Internet.
  - Ánh sáng yếu, kính, khẩu trang làm giảm độ chính xác.
- Kết quả hiệu chỉnh ngưỡng (F10): [ĐIỀN: bảng người/số lần thử/thành công/ánh sáng/kính]. Chưa có số liệu thì không nêu tỉ lệ.

### 7. Nội dung công thức
Nội dung công thức do nhóm soạn (xem `docs/C1_NGUON_VA_KIEM_CHUNG.md`). Mỗi bước gồm câu chính và 1-3 ý chi tiết, lưu cùng một trường `Instruction` (mỗi ý một dòng) nên không phải đổi CSDL. Ảnh minh họa lấy từ Wikimedia Commons, giấy phép mở; bảng tác giả và giấy phép ở `docs/ANH_MINH_HOA.md`. Người duyệt nội dung: [ĐIỀN].

### 8. Kiểm thử
- Test tự động server: `dotnet test` = 61 test, đạt 60/61 (chạy 01/11). Test lỗi `GoogleLoginTests.Missing_client_id_returns_503` (nhận 401 thay vì 503) đã lỗi từ trước khi thêm 3 tính năng mới, chưa xử lý.
- Test Flutter: `flutter test` = 109 test, đạt 109/109 (chạy 01/11).
- Đã chạy thử trên máy ảo với server máy này (01/11): "Dành cho bạn", "Hôm nay ăn gì?" (lọc, quay, loại món đã trúng, báo hết món). Chưa thử: lưu khẩu vị trên app, sửa khẩu vị ở Hồ sơ, mọi lệnh giọng nói.
- Test tay: chép bảng kết quả từ `docs/TEST.md` ([ĐIỀN: số mục đạt/lỗi, số máy, người test]); danh sách lỗi và cách xử lý: [ĐIỀN].

### 9. Phần việc đã thực hiện
[ĐIỀN: phân việc từng người; bản một người làm thì ghi rõ việc đã làm và công cụ AI hỗ trợ nếu giảng viên yêu cầu khai báo].

### 10. Hướng phát triển
Refresh token và HTTPS; giọng nói khi khóa màn hình, kiểm thử giọng nói trên máy thật; gợi ý theo lịch sử nấu; chống giả mạo tốt hơn (liveness phía server, lưu embedding mã hóa); thêm nội dung công thức; Yêu thích/Quiz; chạy timer nền; landmark; offline.

### 11. Tài liệu tham khảo
[ĐIỀN: tài liệu ASP.NET, Flutter, ML Kit, MobileFaceNet (BSD-3-Clause, `LICENSE-mobilefacenet.txt`), nguồn ảnh minh họa theo `docs/ANH_MINH_HOA.md`].

## Phần B. Dàn slide (11 trang, bám kịch bản demo)

| # | Slide | Nội dung chính |
|---|---|---|
| 1 | Tiêu đề | Tên đề tài, thành viên, giảng viên |
| 2 | Vấn đề và mục tiêu | Khó khăn khi nấu; mục tiêu app |
| 3 | Phạm vi | Đã làm / chưa làm |
| 4 | Kiến trúc | Sơ đồ Flutter - ASP.NET - SQL Server |
| 5 | CSDL | ERD |
| 6 | Đăng nhập mặt | Quy trình + ngưỡng + hạn chế |
| 7 | **Demo 1** | Đăng ký, đăng ký mặt, đăng xuất, đăng nhập mặt (có chớp mắt) |
| 8 | **Demo 2** | Tìm "thịt kho trứng", khẩu phần 2→4, nấu từng bước, hẹn giờ |
| 9 | **Demo 3** | Hoàn thành món, xem tiến độ ở Hồ sơ; chia sẻ công thức ở tab Cộng đồng; chọn khẩu vị → "Dành cho bạn"; "Hôm nay ăn gì?" quay món |
| 10 | Kiểm thử | Số liệu thật từ TEST.md và F10 |
| 11 | Hạn chế và hướng phát triển | Như mục 6 và 10 |

Tổng thời gian demo ≤ 8 phút (KE_HOACH mục 11). Phương án dự phòng: video quay sẵn, chuyển đăng nhập bằng mật khẩu nếu mặt không nhận.
