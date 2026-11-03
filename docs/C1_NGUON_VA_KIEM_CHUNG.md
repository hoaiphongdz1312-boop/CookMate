# C1: ghi chú nguồn và mục cần kiểm chứng

File này không nạp vào app. Nội dung công thức do AI soạn bằng lời mới, chưa được người thật duyệt.
Mục **[CẦN KIỂM CHỨNG]** phải có người đối chiếu nguồn trước khi nộp; tôi chưa tra nguồn trực tuyến nên không ghi đường dẫn cụ thể.

## 1. Công thức (15 món)
- Định lượng và thời gian là ước lượng thông thường của món Việt, **[CẦN KIỂM CHỨNG]** bằng cách nấu thử hoặc đối chiếu 1-2 sách/trang nấu ăn đáng tin (ví dụ sách nấu ăn của các tác giả Việt, trang ẩm thực lớn) cho từng món.
- Đã soát: baseServings khớp lượng nguyên liệu; bước có hẹn giờ có `timerSeconds` > 0.
- Món độ khó 3 (cá kho tộ, canh chua cá, phở gà) nhiều khả năng cần chỉnh định lượng nhất. Thời gian ninh phở gà ghi 50 + 30 phút là ước lượng.
- Đơn vị "bìa" (đậu hũ), "trái" (đậu bắp), "nắm nhỏ", "phần" là đơn vị đếm nên quy đổi khẩu phần sẽ ra số thập phân; xem lại cách hiển thị ở app (F7).

## 2. Bếp cứu hộ (đã bỏ)
Tính năng Bếp cứu hộ đã gỡ khỏi app và server ngày 31/10 (xóa `rescue.json`, migration `DropRescue`). Bảng nguồn và các câu cảnh báo an toàn của phần này không còn dùng.

## 3. Bước nấu chi tiết và ảnh
- Ngày 31/10 mỗi bước được viết lại thành câu chính + 1-3 ý chi tiết (mỗi ý một dòng trong `instruction`). Các ý chi tiết cũng do AI soạn, **[CẦN KIỂM CHỨNG]** như phần định lượng.
- Ảnh minh họa: nguồn và giấy phép ở `docs/ANH_MINH_HOA.md`.

## 4. Cách nạp vào DB
Seeder chỉ nạp công thức khi bảng còn trống. Khi đã có dữ liệu, mỗi lần khởi động server sẽ cập nhật ảnh và các bước của những món hệ thống trùng tên với file seed (món không có trong file thì giữ nguyên). Muốn nạp đủ 15 món vào DB đang có 3 món mẫu thì vẫn phải xóa dữ liệu nội dung rồi chạy lại server. Dữ liệu người dùng và phiên nấu cũ không còn khớp món, nên làm trước khi tạo tài khoản demo, và sao lưu `.bak` sau khi nạp.
