# Bảng kiểm thử tay (Q1)

Cách dùng: chạy server, cài app lên ít nhất 2 môi trường (máy 1, máy 2: 2 máy ảo khác nhau hoặc máy ảo + điện thoại thật). Điền cột kết quả bằng **Đạt / Lỗi / Bỏ qua**. Mức độ: **N** = nghiêm trọng (chặn demo), **T** = trung bình, **Nh** = nhẹ.

Test tự động của server: `dotnet test` trong `server/CookMate.Api.Tests` (25 test, gồm email trùng, sai mật khẩu, không token, tách dữ liệu 2 người, lọc difficulty, PATCH ngoài khoảng, answer nút lá, rate limit 429).

| # | Kịch bản | Kết quả mong đợi | Máy 1 | Máy 2 | Người test | Kết quả | Ghi chú | Mức độ |
|---|---|---|---|---|---|---|---|---|
| **Đăng nhập mật khẩu** | | | | | | | | |
| 1 | Đăng ký email mới, nhập mã gửi về email | Vào được app sau khi xác thực | | | | | | N |
| 2 | Đăng ký email đã có | Báo "Email đã được đăng ký" | | | | | | T |
| 3 | Đăng nhập sai mật khẩu | Báo "Email hoặc mật khẩu không đúng" | | | | | | T |
| 4 | Đăng nhập khi chưa xác thực email | Báo chưa xác thực, có đường nhập mã | | | | | | T |
| 5 | Quên mật khẩu, nhập mã, đặt mật khẩu mới, đăng nhập lại | Đăng nhập được bằng mật khẩu mới | | | | | | T |
| 6 | Tắt hẳn app rồi mở lại | Vẫn còn đăng nhập | | | | | | N |
| 7 | Đăng xuất | Về màn đăng nhập, mở lại không tự vào | | | | | | N |
| **Khuôn mặt** | | | | | | | | |
| 8 | Đăng ký mặt (3-5 mẫu) | Thành công, hồ sơ báo đã đăng ký mặt | | | | | | N |
| 9 | Đăng nhập mặt, ánh sáng bình thường (thử 5 lần) | ≥ 4/5 lần vào được | | | | | | N |
| 10 | Đăng nhập mặt, phòng tối | Ghi lại tỉ lệ; không nhận thì chuyển mật khẩu được | | | | | | T |
| 11 | Đăng nhập mặt, ngược sáng | Như trên | | | | | | T |
| 12 | Đăng nhập mặt, đeo kính | Ghi lại tỉ lệ | | | | | | Nh |
| 13 | Người khác thử vào tài khoản của mình bằng mặt họ | Bị từ chối ("Chưa nhận ra bạn") | | | | | | N |
| 14 | Giơ ảnh in / ảnh trên màn hình khác trước camera | Không qua được bước chớp mắt | | | | | | N |
| 15 | Đăng ký cùng mặt cho tài khoản thứ hai | Báo 409 mặt đã thuộc tài khoản khác | | | | | | T |
| 16 | Xóa dữ liệu khuôn mặt ở hồ sơ | hasFace = false, đăng nhập mặt không còn vào được | | | | | | T |
| 17 | Thử sai mặt 3 lần | Hiện "Chưa nhận ra bạn" + nút "Dùng mật khẩu" | | | | | | T |
| **Công thức** | | | | | | | | |
| 18 | Tìm "thịt kho" | Ra đúng món, chờ ~400ms mới gọi | | | | | | N |
| 19 | Lọc danh mục, độ khó, thời gian | Danh sách đúng điều kiện | | | | | | T |
| 20 | Kéo xuống để tải lại | Tải lại được | | | | | | Nh |
| 21 | Khẩu phần 2 → 4 | Định lượng nhân đôi, làm tròn đúng (g tròn 5, thìa/chén 1/4) | | | | | | N |
| 22 | Khẩu phần lẻ (3, 7) | Số hợp lý, không lỗi hiển thị | | | | | | T |
| **Chế độ nấu** | | | | | | | | |
| 23 | Hẹn giờ 1 phút, sang màn khác rồi quay lại | Thời gian còn lại vẫn đúng | | | | | | N |
| 24 | Hết giờ | Rung/phát âm | | | | | | T |
| 25 | Nấu trọn một món, bấm Hoàn thành | Hộp thoại chúc mừng, "Món đã nấu" tăng 1 | | | | | | N |
| 26 | Nấu dở, thoát, mở lại món đó | Hỏi tiếp tục từ bước đã lưu | | | | | | N |
| **Ảnh và bước chi tiết** | | | | | | | | |
| 27 | Mở danh sách công thức | 13 món có ảnh; Trứng chiên hành, Canh cải thịt bằm hiện biểu tượng mặc định | | | | | | N |
| 28 | Mở chi tiết một món có ảnh | Ảnh lớn đầu trang; các bước có ý chi tiết dạng gạch đầu dòng | | | | | | Nh |
| 29 | Vào màn nấu, xem một bước dài | Câu chính chữ to, ý chi tiết bên dưới, cuộn được; không còn nút "Cần trợ giúp" | | | | | | N |
| **Tiến độ** | | | | | | | | |
| 30 | Nấu dở, đăng xuất, đăng nhập lại (mật khẩu) | Món dở còn, tiếp tục đúng bước | | | | | | N |
| 31 | Như trên nhưng đăng nhập bằng mặt | Như trên | | | | | | N |
| 32 | Hai tài khoản trên cùng máy | Mỗi bên chỉ thấy tiến độ của mình | | | | | | N |
| **Điều kiện xấu** | | | | | | | | |
| 33 | Mất mạng giữa lúc đang nấu, bấm Tiếp vài lần, bật lại | Không treo; tiến độ lưu lại khi có mạng | | | | | | N |
| 34 | Tắt server rồi mở danh sách công thức | Báo lỗi + nút Thử lại, không treo | | | | | | N |
| 35 | Tắt server rồi đăng nhập | Báo lỗi dễ hiểu | | | | | | T |
| 36 | Xoay màn hình khi đang nấu / đang quét mặt | Không mất trạng thái, không crash | | | | | | T |
| 37 | App ra nền rồi vào lại khi đang nấu | Giữ bước và hẹn giờ; camera được giải phóng khi ra nền | | | | | | T |
| 38 | Đăng nhập sai 11 lần trong 1 phút | Lần 11 báo "Thử quá nhiều lần" (429) | | | | | | Nh |

## Danh sách lỗi cần sửa (điền sau khi test, gửi cho bước H1)

| # | Mục test | Mô tả lỗi / thông báo | Mức độ | Trạng thái |
|---|---|---|---|---|
| | | | | |
