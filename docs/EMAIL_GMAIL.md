# Gửi mã xác thực qua Gmail

Server gửi mã 6 số về email trong 2 trường hợp: **xác thực email khi đăng ký** và **quên mật khẩu**.
Mã có hiệu lực 10 phút, nhập sai quá 5 lần thì mã bị hủy, gửi lại cách nhau 60 giây.

## Cấu hình Gmail (làm một lần, trên máy chạy server)

1. Bật xác minh 2 bước cho tài khoản Gmail dùng để gửi: <https://myaccount.google.com/security>.
2. Tạo **Mật khẩu ứng dụng** (App Password) tại <https://myaccount.google.com/apppasswords>, đặt tên "CookMate". Google trả về chuỗi 16 ký tự.
3. Lưu vào user-secrets của server, KHÔNG ghi vào file trong Git:

```bash
cd server/CookMate.Api
dotnet user-secrets set "Email:User" "ten-ban@gmail.com"
dotnet user-secrets set "Email:Password" "xxxxxxxxxxxxxxxx"
```

4. Chạy lại server. Đăng ký một tài khoản bằng email thật của bạn và kiểm tra hộp thư (kể cả mục Spam).

Dùng App Password chứ không dùng mật khẩu Gmail thật. Nếu lộ, vào trang trên và thu hồi.

## Khi chưa cấu hình

Ở môi trường Development, nếu chưa có `Email:User`/`Email:Password` thì server không gửi email thật mà
in nội dung email (kèm mã) ra console, dòng bắt đầu bằng `[CHƯA CẤU HÌNH SMTP]`. Chỉ dùng để test.
Môi trường khác (Production) không có cấu hình thì server từ chối khởi động.

## Lưu ý

- Gmail giới hạn khoảng 500 email/ngày, đủ cho demo.
- Tài khoản tạo trước khi có tính năng này được coi là đã xác thực.
- Giới hạn 10 request/phút/IP áp dụng chung cho đăng nhập, đăng ký, xác thực, gửi lại mã, quên/đặt lại mật khẩu.
