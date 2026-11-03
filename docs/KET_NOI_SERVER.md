# Kết nối app CookMate với server

Địa chỉ server chỉ đặt ở **một nơi**: `app/lib/core/app_config.dart` (`AppConfig.apiBaseUrl`).
Mặc định là `http://10.0.2.2:5255/api`, dùng cho máy ảo Android. Đổi địa chỉ lúc chạy bằng
`--dart-define`, không cần sửa code.

Server lắng nghe `http://0.0.0.0:5255` (xem `server/CookMate.Api/appsettings.json`, khóa `Urls`).
Kiểm tra nhanh trên laptop: mở `http://localhost:5255/api/health`, phải thấy `{"status":"ok"}`.

## 1. Máy ảo Android (Android Studio)

`10.0.2.2` là địa chỉ của laptop khi nhìn từ máy ảo. Không cần cấu hình gì thêm:

```bash
flutter run
```

Kiểm tra: mở Chrome trong máy ảo, vào `http://10.0.2.2:5255/api/health`.

## 2. Điện thoại thật cắm USB (khuyên dùng khi demo)

Chuyển cổng 5255 của điện thoại về laptop qua cáp, rồi để app gọi `localhost`:

```bash
adb reverse tcp:5255 tcp:5255
```

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5255/api
```

`adb reverse` mất khi rút cáp hoặc khởi động lại adb, phải chạy lại.

## 3. Điện thoại thật qua Wi-Fi / hotspot

1. Điện thoại và laptop cùng một mạng (hoặc điện thoại bắt hotspot của laptop).
2. Lấy IP của laptop: chạy `ipconfig`, xem `IPv4 Address` của card Wi-Fi (hotspot của Windows thường là `192.168.137.1`).
3. Mở cổng 5255 trên Windows Firewall (PowerShell chạy quyền Admin):

   ```powershell
   New-NetFirewallRule -DisplayName "CookMate API 5255" -Direction Inbound -Protocol TCP -LocalPort 5255 -Action Allow -Profile Private
   ```

4. Chạy app với IP đó:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.137.1:5255/api
   ```

Kiểm tra: mở trình duyệt trên điện thoại, vào `http://<IP laptop>:5255/api/health`.

## HTTP (cleartext)

Android chặn HTTP mặc định. App chỉ cho phép HTTP ở bản **debug**
(`app/android/app/src/debug/AndroidManifest.xml`, `android:usesCleartextTraffic="true"`).
Nếu build bản release/profile để demo thì phải bật thêm cho bản đó (làm ở bước R2).

## Build APK với địa chỉ cố định

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.137.1:5255/api
```
