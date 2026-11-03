# Chạy demo CookMate (R2)

Mục đánh dấu **[đã chạy thử]** là lệnh đã chạy thật trên máy này (29/10). Mục **[chưa thử]** cần máy ảo/điện thoại thật,
phải tự thử trước ngày nộp.

## 1. Chạy server từ máy này

SQL Server là instance mặc định `localhost`, database `CookMate`. Chuỗi kết nối nằm ở
`server/CookMate.Api/appsettings.Development.json` (không commit; mẫu ở `appsettings.Development.example.json`).

```bash
server\chay-server.bat
```

Hoặc: `dotnet run --launch-profile http` trong `server/CookMate.Api`. Server nghe `http://0.0.0.0:5255`.
Kiểm tra: `http://localhost:5255/api/health` phải trả `{"status":"ok"}`; Swagger ở `/swagger`.

Server tự seed khi DB còn trống, từ `server/Data/Seed/recipes.json` (15 món, 13 món có ảnh, mỗi món 1-3 nhãn khẩu vị). DB đã có dữ liệu thì mỗi lần khởi động server cập nhật ảnh, nhãn khẩu vị và các bước của món hệ thống theo file này.

Server **không** tự áp migration. DB cũ (trước 01/11) phải chạy `dotnet ef database update` trong `server/` (máy này) hoặc `docs/sql_AddTastes.sql` (hosting), xem mục 6.

Mã xác thực email: chưa cấu hình Gmail thì mã in ra console server, dòng `[CHƯA CẤU HÌNH SMTP]`
(xem `EMAIL_GMAIL.md`). Khi demo, tạo sẵn tài khoản đã xác thực.

Firewall (chỉ cần khi điện thoại gọi qua Wi-Fi/hotspot), PowerShell quyền Admin:

```powershell
New-NetFirewallRule -DisplayName "CookMate API 5255" -Direction Inbound -Protocol TCP -LocalPort 5255 -Action Allow -Profile Private
```

## 2. App gọi được server **[chưa thử]**

| Môi trường | Địa chỉ | Cách |
|---|---|---|
| Máy ảo Android | `http://10.0.2.2:5255/api` | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5255/api` **[đã chạy thử 01/11]** |
| Điện thoại cắm USB | `http://localhost:5255/api` | `adb reverse tcp:5255 tcp:5255` rồi `flutter run --dart-define=API_BASE_URL=http://localhost:5255/api` |
| Điện thoại qua hotspot/Wi-Fi | `http://<IP laptop>:5255/api` | `ipconfig` lấy IPv4 (hotspot Windows thường `192.168.137.1`), mở firewall như trên |

Không truyền `API_BASE_URL` thì app gọi server hosting `https://cookmate2026-001-site1.dtempurl.com/api` (mặc định trong `app_config.dart`). Server hosting chưa publish bản có khẩu vị/Lucky Meal thì màn chọn khẩu vị báo "Không tìm thấy dữ liệu" (404).

`adb reverse` mất khi rút cáp hoặc restart adb. Chi tiết: `KET_NOI_SERVER.md`.

Camera trước của máy ảo = webcam laptop: Android Studio → Device Manager → sửa AVD → Show Advanced Settings →
Camera → Front: `Webcam0`; khởi động lại máy ảo (Cold Boot).

## 3. Sao lưu và khôi phục DB **[đã chạy thử]**

Sao lưu (sau khi đã tạo tài khoản demo và đăng ký mặt):

```bash
sqlcmd -S localhost -E -C -Q "BACKUP DATABASE CookMate TO DISK = N'D:\DoAnLTDD\CookMate\backup\CookMate.bak' WITH INIT, FORMAT"
```

Khôi phục (đè DB cũ):

```bash
sqlcmd -S localhost -E -C -Q "ALTER DATABASE CookMate SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE CookMate FROM DISK = N'D:\DoAnLTDD\CookMate\backup\CookMate.bak' WITH REPLACE; ALTER DATABASE CookMate SET MULTI_USER"
```

Máy khác chưa có DB: `RESTORE ... WITH MOVE 'CookMate' TO '<đường dẫn>.mdf', MOVE 'CookMate_log' TO '<đường dẫn>.ldf'`
(đã thử restore sang DB tạm `CookMate_verify` thành công, số món đọc lại là 3, khớp DB gốc, rồi đã xóa DB tạm).
Thư mục `backup/` nằm trong `.gitignore` vì chứa dữ liệu người dùng; nộp file `.bak` riêng.

Quan trọng: embedding khuôn mặt nằm trong DB. Đăng ký mặt trên đúng DB sẽ dùng để demo (xem KE_HOACH mục 12.6).

## 4. Build APK

```bash
cd app
flutter build apk --release --dart-define=API_BASE_URL=http://localhost:5255/api
```

APK ra ở `app/build/app/outputs/flutter-apk/app-release.apk`. Ghi chú:
- Bản release hiện **ký bằng khóa debug** (`android/app/build.gradle.kts`), đủ để cài demo, không dùng để phát hành.
- Release mặc định chặn HTTP, nên đã thêm `usesCleartextTraffic="true"` vào `AndroidManifest.xml` chính. Chỉ dùng cho demo.
- `localhost` trong APK chỉ chạy khi có `adb reverse`. Dùng hotspot thì build với `--dart-define=API_BASE_URL=http://192.168.137.1:5255/api`.
- Cài: `adb install -r app\build\app\outputs\flutter-apk\app-release.apk`.

## 5. Khẩu vị, "Hôm nay ăn gì?", nghe "Bếp ơi" toàn app (thêm 01/11)

| Tính năng | Cách demo | Trạng thái |
|---|---|---|
| Hỏi khẩu vị lần đầu | Tài khoản chưa có khẩu vị đăng nhập → màn "Khẩu vị của bạn" (6 nhãn, chọn nhiều, Bỏ qua). Sửa lại ở Hồ sơ → "Khẩu vị của bạn" | Màn hỏi hiện đúng trên máy ảo; **lưu thành công trên app chưa thấy** (lần thử đó app còn gọi hosting). API lưu đã thử bằng curl |
| Không hỏi lại | Đăng nhập tài khoản đã có khẩu vị → vào thẳng tab Công thức | [đã chạy thử] |
| "Dành cho bạn" | Đầu tab Công thức, món trùng nhiều nhãn xếp trước; ẩn khi đang tìm/lọc | [đã chạy thử] khẩu vị "cay" ra Cá kho tộ, Gà kho gừng, Gà rang sả ớt |
| Hôm nay ăn gì? | Nút đầu tab Công thức → chọn lọc → QUAY NGAY → Thử món khác | [đã chạy thử] lọc "Canh": dừng đúng món, hết 3 món thì báo "Bạn đã xem hết các món phù hợp." |
| Xem công thức / Nấu món này từ thẻ kết quả | Bấm trên thẻ kết quả | [chưa thử] |
| Công tắc "Nghe Bếp ơi" | Hồ sơ → bật công tắc (xin quyền micro) | [chưa thử trên máy ảo] |
| Bảng "Bạn cần gì?" | Nói "Bếp ơi" ở màn bất kỳ → bảng hiện, tự đóng sau 5 giây; "hôm nay ăn gì", "mở món đang nấu", "về trang chủ" | **Chưa test bằng giọng** (mic máy ảo không nhận); chỉ có test tự động |

Tài khoản thử ở DB máy này: `khauvi.demo@test.vn` (tạo 01/11, đã xác thực, khẩu vị "cay"). Mật khẩu trùng `ApiFactory.Password` trong test server.

Thử mic máy ảo (chưa verify): Extended controls → Microphone → bật "Virtual microphone uses host audio input" → Cold Boot.

## 6. Cập nhật DB và publish lên myasp.net

DB máy này đã áp 2 migration ngày 01/11, bản sao lưu ngay trước đó: `backup/CookMate_truoc_khau_vi.bak`.

Hosting **đã publish 01/11/2026** và đã kiểm tra trên địa chỉ thật: `/api/health` ok; `/api/recipes` trả `tastes`; `/api/recipes/recommended`, `/api/recipes/random` chạy (lọc rỗng trả 404 kèm thông báo); `PUT /api/users/me/tastes` không token trả 401.

Bài học lần publish 01/11:
- Upload bằng FTP khi site đang chạy không thay được `CookMate.Api.dll` (bị khóa). Phải đặt `app_offline.htm` trước, chép file, rồi xóa nó.
- Mật khẩu FTP có thể khác mật khẩu đăng nhập trang quản trị (đăng nhập bằng Google). Đặt lại trong Control Panel → FTP → bút chì ở dòng `cookmate2026-001`.
- DB `db_ad0915_cookmate` không nằm trong mục MSSQL của plan này; chạy SQL bằng `sqlcmd`/SSMS.
- Lên code mới trước khi DB có cột thì app lỗi 500.30 lúc khởi động, và vẫn lỗi cho tới khi site khởi động lại (lưu lại `web.config` hoặc Recycle trong Dashboard, chọn đúng pool trước khi bấm).

Thứ tự khi publish:

1. Sao lưu DB hosting (trang quản trị myasp/site4now).
2. Chạy `docs/sql_AddTastes.sql` trên DB hosting (SSMS hoặc trang SQL của host). Script idempotent: chạy lại không lỗi, migration đã có thì bỏ qua. Thêm cột `Recipes.Tastes`, `Users.Tastes`.
3. Publish `server/CookMate.Api` bằng profile `cookmate2026-001-site1` (Visual Studio → Publish, hoặc `dotnet publish -c Release` rồi FTP). Bản publish phải có `Seed/recipes.json` mới (csproj tự chép).
4. Kiểm tra `appsettings.Production.json` trên host: chuỗi kết nối và `Jwt:Key` không bị bản publish ghi đè sai.
5. Khởi động lại site. Lần khởi động đầu, server tự ghi nhãn khẩu vị cho 15 món hệ thống theo `Seed/recipes.json` (khớp theo tên món).
6. Kiểm tra: `/api/health`, `/api/recipes/recommended`, `/api/recipes/random` trên địa chỉ thật; món trả về phải có `tastes` khác rỗng.
7. Build lại APK (mục 4). Không truyền `API_BASE_URL` thì APK dùng địa chỉ hosting.

File server đã đổi cho 3 tính năng:

| File | Thay đổi |
|---|---|
| `Entities/TasteTags.cs` (mới) | 6 nhãn, đọc/chuẩn hóa chuỗi nhãn |
| `Entities/Recipe.cs`, `Entities/User.cs` | Cột `Tastes` |
| `Data/AppDbContext.cs` | Cấu hình 2 cột |
| `Data/DbSeeder.cs` | Seed và đồng bộ nhãn món hệ thống |
| `Data/Migrations/*_AddRecipeTastes.*`, `*_AddUserTastes.*` (mới) | Migration |
| `Dtos/RecipeDtos.cs`, `Dtos/AuthDtos.cs` | `tastes` trong món và `UserDto`; `TastesRequest` |
| `Services/TasteRanking.cs` (mới), `Services/UserMapping.cs` | Xếp hạng gợi ý; trả `tastes` của user |
| `Controllers/RecipesController.cs` | `GET recommended`, `GET random`, trả nhãn |
| `Controllers/UsersController.cs` | `PUT me/tastes` |
| `../Data/Seed/recipes.json` | Trường `tastes` cho 15 món |

Nghe "Bếp ơi" toàn app (C1, C2) chỉ đổi app Flutter, không cần publish server.

## 7. Checklist trước giờ demo

1. [ ] Pin laptop và điện thoại/máy ảo đầy, cắm sạc.
2. [ ] SQL Server đang chạy; `CookMate` đã restore từ `.bak` sạch.
3. [ ] Server chạy, `/api/health` ok.
4. [ ] Firewall mở cổng 5255 (nếu dùng hotspot).
5. [ ] Đã thử đúng cách kết nối sẽ dùng khi demo (10.0.2.2 / `adb reverse` / hotspot).
6. [ ] App đã cài, đã cấp quyền camera.
7. [ ] Tài khoản demo đã xác thực email, đã đăng nhập thử được bằng mật khẩu.
8. [ ] Mặt đã đăng ký trên đúng DB demo; đăng nhập mặt thử 3 lần liên tiếp thành công.
9. [ ] Ánh sáng phòng demo đủ; thử luôn trường hợp "không nhận mặt" để chuyển sang mật khẩu.
10. [ ] Tìm "thịt kho" ra món; đổi khẩu phần 2 → 4 đúng.
11. [ ] Hẹn giờ 1 phút chạy và báo khi hết.
12. [ ] Danh sách món hiện ảnh; màn nấu hiện câu chính và các ý chi tiết của từng bước.
13. [ ] Hồ sơ hiện tiến độ đúng sau khi hoàn thành một món.
14. [ ] Video quay sẵn bản dự phòng, `.bak`, APK, slide đã copy ra USB.
15. [ ] Tắt thông báo/chế độ không làm phiền; tắt tự khóa màn hình.
16. [ ] Server đang dùng đã có 2 migration khẩu vị (máy này: đã có; hosting: xem mục 6).
17. [ ] Tài khoản demo chọn khẩu vị xong thấy "Dành cho bạn"; tài khoản mới thấy màn hỏi khẩu vị.
18. [ ] "Hôm nay ăn gì?" quay ra món, Thử món khác không lặp món.
19. [ ] Nếu demo giọng nói: thử "Bếp ơi, hôm nay ăn gì" trên đúng máy demo; không nhận thì bỏ phần này khỏi kịch bản.
