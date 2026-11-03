# CookMate: kế hoạch và tiến trình phát hành APK (tải về điện thoại và chạy)

Cập nhật lần đầu: 03/11/2026. Mục tiêu: người dùng tải APK từ GitHub Releases, cài lên điện thoại Android và dùng được (đăng nhập, quét mặt, gọi API trên hosting).

Cách dùng: làm lần lượt từng bước, xong thì đổi `[ ]` thành `[x]` và ghi ngày vào bảng ở mục 3.

## 1. Hiện trạng đã kiểm tra (03/11/2026)

| Hạng mục | Tình trạng | Căn cứ |
|---|---|---|
| Quyền INTERNET, CAMERA, RECORD_AUDIO | Đã khai báo | `app/android/app/src/main/AndroidManifest.xml` |
| Server trên hosting myasp.net | Đã publish ngày 01/11 (ghi trong `KE_HOACH_VA_PROMPT.md`) | Chưa gọi lại `/api/health` hôm nay |
| URL API mặc định của app | `https://cookmate2026-001-site1.dtempurl.com/api` | `docs/DEMO.md` mục 3 |
| Ký APK release | **Đang ký bằng khóa debug** | `app/android/app/build.gradle.kts` (`signingConfigs.getByName("debug")`) |
| `usesCleartextTraffic="true"` | **Đang bật** (cho phép HTTP) | `AndroidManifest.xml` |
| `app-release.apk` hiện có | Build ngày 01/11, **cũ hơn** các tính năng duyệt bài, báo cáo, chặn (02/11); dung lượng 175 MB | `app/build/app/outputs/flutter-apk/` |

## 2. Các bước phát hành

### Bước 1: kiểm tra server còn sống
- [ ] Mở `https://cookmate2026-001-site1.dtempurl.com/api/health` trên trình duyệt điện thoại (dùng 4G, không dùng wifi nhà). Phải ra OK.
- [ ] Gói hosting miễn phí 60 ngày: ghi ngày hết hạn vào mục 4. Hết hạn thì API chết, APK mở được nhưng không đăng nhập được.

### Bước 2: tạo khóa ký release
- [ ] Chạy trong PowerShell:
  ```
  keytool -genkey -v -keystore D:\DoAnLTDD\cookmate-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cookmate
  ```
  Lưu file `.jks` ngoài thư mục dự án (đúng như đường dẫn trên).
- [ ] Backup `.jks` và mật khẩu ra USB hoặc ổ khác. Mất file này thì bản sau không cài đè được lên bản cũ.
- [ ] Tạo `app/android/key.properties`:
  ```
  storePassword=MAT_KHAU_CUA_MAY
  keyPassword=MAT_KHAU_CUA_MAY
  keyAlias=cookmate
  storeFile=D:/DoAnLTDD/cookmate-release.jks
  ```
- [ ] Sửa `app/android/app/build.gradle.kts`:
  - Thêm 2 dòng import ở **đầu file**: `import java.util.Properties` và `import java.io.FileInputStream`
  - Thêm ngay sau khối `plugins { ... }`:
    ```kotlin
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }
    ```
  - Trong khối `android { ... }`, thêm trước `buildTypes`:
    ```kotlin
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    ```
  - Trong `buildTypes { release { ... } }`, đổi dòng `signingConfig` thành: `signingConfig = signingConfigs.getByName("release")`

### Bước 3: đăng nhập Google với khóa release
- [ ] Lấy SHA-1: `keytool -list -v -keystore D:\DoAnLTDD\cookmate-release.jks -alias cookmate` (dòng `SHA1:`).
- [ ] Vào Google Cloud Console → APIs & Services → Credentials → OAuth client loại **Android** của CookMate → thêm SHA-1 này (package name `com.cookmate.cookmate`).
- [ ] Không làm bước này thì APK release báo lỗi khi bấm đăng nhập Google, dù bản debug trên máy ảo chạy bình thường. Chi tiết cấu hình ở `docs/GOOGLE_LOGIN.md`.

### Bước 4: tắt HTTP cho bản phát hành
- [ ] API hosting đã dùng `https://`, nên xóa `android:usesCleartextTraffic="true"` trong `AndroidManifest.xml`.
- [ ] Chỉ giữ lại nếu còn demo bằng server máy cá nhân qua HTTP (`DEMO.md` mục 4). Khi đó phải build 2 bản khác nhau.

### Bước 5: build APK
- [ ] Chạy trong `D:\DoAnLTDD\CookMate\app`:
  ```
  flutter clean
  flutter pub get
  flutter build apk --release --split-per-abi
  ```
  Không truyền `API_BASE_URL` thì app dùng URL hosting (đúng ý).
- [ ] Máy thật gần như luôn là `arm64-v8a`. File cần phát: `app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Bản split nhỏ hơn bản 175 MB hiện tại (mức giảm chưa verify, so sánh sau khi build).
- [ ] Nếu không rõ máy người dùng, dùng `flutter build apk --release` (một file chạy mọi máy, nặng hơn).

### Bước 6: test trước khi phát
- [ ] **Gỡ app cũ trên điện thoại trước.** App cũ ký bằng khóa debug, bản mới ký khóa release, Android từ chối cài đè (báo "xung đột" hoặc "chưa cài được").
- [ ] Cài: chép APK sang điện thoại hoặc `adb install app-arm64-v8a-release.apk`.
- [ ] Checklist chạy tay trên điện thoại, dùng 4G:
  - [ ] Đăng ký và đăng nhập email
  - [ ] Đăng nhập Google
  - [ ] Đăng ký và đăng nhập bằng khuôn mặt
  - [ ] Xem danh sách công thức, ảnh hiện đủ
  - [ ] "Dành cho bạn" và "Hôm nay ăn gì?"
  - [ ] Nấu ăn bằng giọng nói ("bếp ơi", "bước tiếp")
  - [ ] Đăng bài cộng đồng, báo cáo, chặn
- [ ] Mục giọng nói chưa từng test bằng giọng thật trên máy ảo (xem `KE_HOACH_VA_PROMPT.md` mục 9). Điện thoại thật là lần test đầu tiên.

### Bước 7: phát APK
- [ ] Upload `app-arm64-v8a-release.apk` lên GitHub Releases, ghi mô tả: yêu cầu Android 8.0 trở lên (`minSdk = 26`), bản thử nghiệm.
- [ ] Hướng dẫn người dùng: mở link trên điện thoại → tải `.apk` → bật "Cho phép cài từ nguồn này" → Cài. Play Protect cảnh báo thì bấm "Vẫn cài đặt".
- [ ] Bản sau: tăng `version` trong `app/pubspec.yaml` (ví dụ `0.1.1+2`, số sau `+` phải tăng), build lại, upload bản mới.

## 3. Bảng tiến trình

| Bước | Nội dung | Trạng thái | Ngày xong | Ghi chú |
|---|---|---|---|---|
| 1 | Kiểm tra server hosting | [ ] | | |
| 2 | Tạo khóa ký release, sửa `build.gradle.kts` | [ ] | | Backup `.jks` |
| 3 | Thêm SHA-1 vào OAuth client Android | [ ] | | |
| 4 | Tắt cleartext HTTP | [ ] | | |
| 5 | Build APK release | [ ] | | APK 01/11 cũ, phải build lại |
| 6 | Test trên điện thoại thật | [ ] | | Gỡ app cũ trước |
| 7 | Phát APK cho người dùng | [ ] | | |

## 4. Mốc thời gian cần điền

- Ngày hết hạn hosting miễn phí 60 ngày: ______ (điền từ trang quản trị myasp.net)
- Hạn nộp đồ án: ______

## 5. Chưa kiểm chứng

- Server hosting đang sống và đã có bản mới nhất (duyệt bài, báo cáo, chặn, thông báo): `KE_HOACH_DUYET_BAI.md` ghi test trên server máy cá nhân, chưa thấy ghi đã publish lại lên hosting sau 02/11.
- Giọng nói bằng mic thật.
- Mức giảm dung lượng của `--split-per-abi`.
- Đăng nhập Google với khóa release (phụ thuộc bước 3).
