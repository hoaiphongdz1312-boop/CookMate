# Mở app bằng Android Studio

1. Android Studio → **Open** → chọn thư mục `D:\DoAnLTDD\CookMate\app` (thư mục có `pubspec.yaml`, KHÔNG chọn thư mục gốc `CookMate`).
2. Đợi Gradle sync xong, bấm **Pub get** nếu có thanh nhắc.
3. Chọn thiết bị `Pixel_7` (máy ảo) ở thanh trên, bấm Run.

## Chạy server trước
Bấm đúp `server\chay-server.bat` (hoặc chạy `dotnet run --launch-profile http` trong `server\CookMate.Api`).
Kiểm tra: `http://localhost:5255/api/health` phải trả `{"status":"ok"}`.

## Kết nối
Máy ảo gọi server qua `http://10.0.2.2:5255/api` (đã là mặc định). Điện thoại thật: xem `KET_NOI_SERVER.md`.
Đổi địa chỉ trong Android Studio: Run → Edit Configurations → Additional run args →
`--dart-define=API_BASE_URL=http://<ip>:5255/api`.
