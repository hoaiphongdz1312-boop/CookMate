# CookMate: kế hoạch tính năng mới và tiến trình prompt

Cập nhật lần đầu: 01/11/2026. Cách dùng: làm lần lượt từng bước, gửi đúng prompt của bước đó cho Claude, kiểm tra theo cột "Kiểm tra", rồi đổi `[ ]` thành `[x]`.

## 1. Mục tiêu

Thêm 3 tính năng vào CookMate, ưu tiên cái ít rủi ro làm trước:

| # | Tính năng | Đụng server (phải publish lại myasp.net)? | Test được trên máy ảo? |
|---|---|---|---|
| A | Hỏi khẩu vị lần đầu mở app, mục "Dành cho bạn" | Có (thêm nhãn khẩu vị cho món, lưu khẩu vị người dùng) | Có |
| B | Lucky Meal "Hôm nay ăn gì?" (quay món ngẫu nhiên) | Có (thêm 1 API) | Có |
| C | Nghe "bếp ơi" xuyên suốt app, hiện bảng "Bạn cần gì?" | Không | **Không chắc** (mic máy ảo không nhận) |

Thứ tự: A, rồi B, rồi C. A và B dùng chung bộ nhãn khẩu vị. C làm cuối vì không test chắc được khi chưa có máy thật.

## 2. Ràng buộc cần nhớ

- Hạn nộp đồ án: ghi chú cũ ghi "tuần sau" tính từ 28/10/2026. Phải chốt phạm vi nhỏ, không làm dàn trải.
- DB thật: `Recipe` có `Status` (0 chờ, 1 duyệt, 2 từ chối), `IsDeleted`, `PrepMinutes`, `CookMinutes`, `Difficulty` (số 1 đến 3), `CategoryId`, `AuthorId` (null là món hệ thống). Chưa có nhãn khẩu vị, chưa có bảng yêu thích.
- App chỉ có 3 tab: Công thức, Cộng đồng, Hồ sơ. Chưa có "trang chủ".
- Chỉ 15 món seed (`server/Data/Seed/recipes.json`): cần gắn nhãn thủ công.
- Mỗi lần sửa server hoặc DB phải publish lại lên myasp.net. Sửa riêng app Flutter thì không cần.
- Mic máy ảo không nhận. Bật thử: Extended controls, Microphone, bật "Virtual microphone uses host audio input", rồi cold boot máy ảo. Chưa verify.

## 3. Quyết định đã chốt (sửa nếu đổi ý)

- Khẩu vị cố định 6 nhãn: cay, chua, ngọt, đậm đà, thanh nhẹ, béo. Chọn nhiều, có nút "Bỏ qua".
- Mỗi món seed gắn 1 đến 3 nhãn.
- Khẩu vị người dùng lưu trên server (theo tài khoản).
- Gợi ý theo số nhãn trùng, không dùng AI.
- Lucky Meal chỉ quay món hệ thống (`AuthorId` null), bộ lọc: danh mục, độ khó, thời gian tối đa. Bỏ lọc chay/mặn, bỏ yêu thích, bỏ lịch sử quay.
- Nút "Hôm nay ăn gì?" đặt ở đầu tab Công thức.
- Wake word toàn app: chỉ khi app đang mở. Không làm chạy nền khi khóa màn hình.

## 4. Chuẩn bị (làm trước khi gửi prompt nào)

- [x] Sao lưu DB (lệnh trong `docs/DEMO.md`, mục 3).
- [ ] Commit git bản hiện tại, tạo nhánh mới cho từng tính năng.
- [x] Chạy test hiện có của app và server, ghi lại cái nào đang đỏ để khỏi nhầm lỗi mới.

## 5. Chuỗi prompt

### Bước A1: nhãn khẩu vị cho món (server)

- Prompt: "Trong server CookMate, thêm bộ 6 nhãn khẩu vị (cay, chua, ngọt, đậm đà, thanh nhẹ, béo) gắn với Recipe, nhiều nhãn cho mỗi món. Cập nhật recipes.json seed cho 15 món, tạo migration EF, và trả nhãn trong RecipeSummaryDto và RecipeDetailDto. Chưa đụng app Flutter. Đề xuất nhãn cho từng món rồi chờ tôi duyệt trước khi ghi vào file seed."
- Kết quả mong đợi: migration mới, seed có nhãn, API công thức trả nhãn.
- Kiểm tra: gọi API danh sách món thấy nhãn; chạy test server vẫn xanh.
- Trạng thái: [x]

### Bước A2: lưu khẩu vị người dùng (server)

- Prompt: "Thêm khả năng lưu và đọc khẩu vị yêu thích của người dùng (danh sách nhãn) trên server CookMate: migration, API đọc và ghi cho người dùng đang đăng nhập, và thêm endpoint gợi ý món theo khẩu vị (món nào trùng nhiều nhãn hơn thì xếp trước, chỉ món hệ thống đã duyệt). Có test cho phần gợi ý."
- Kiểm tra: người dùng chọn "cay" thì món có nhãn cay đứng đầu; người dùng chưa chọn gì thì trả danh sách thường.
- Trạng thái: [x]

### Bước A3: màn hỏi khẩu vị và mục "Dành cho bạn" (app)

- Prompt: "Trong app Flutter CookMate, thêm màn chọn khẩu vị (6 nhãn, chọn nhiều, có nút Bỏ qua) hiện một lần sau khi người dùng mới đăng ký hoặc đăng nhập lần đầu mà chưa có khẩu vị. Thêm mục 'Dành cho bạn' ở đầu tab Công thức dùng API gợi ý, và cho sửa khẩu vị trong tab Hồ sơ. Theo cấu trúc router.dart và go_router đang có."
- Kiểm tra trên máy ảo: tài khoản mới thấy màn hỏi; chọn xong thấy "Dành cho bạn"; bỏ qua thì không bị hỏi lại.
- Trạng thái: [x]

### Bước B1: API quay món (server)

- Prompt: "Thêm GET api/recipes/random vào RecipesController của CookMate. Chỉ chọn món hệ thống đã duyệt, chưa xóa. Bộ lọc tùy chọn: categoryId, difficulty (1 đến 3), maxMinutes (chuẩn bị + nấu), excludeIds. Không có món phù hợp thì trả lỗi nghiệp vụ theo ErrorResponse hiện có. Có test."
- Kiểm tra: gọi nhiều lần ra món khác nhau; excludeIds được loại; bộ lọc ra rỗng thì báo đúng.
- Trạng thái: [x]

### Bước B2: màn Lucky Meal (app)

- Prompt: "Thêm màn 'Hôm nay ăn gì?' vào app CookMate: nút ở đầu tab Công thức, màn thiết lập bộ lọc (danh mục, độ khó, thời gian tối đa), nút QUAY NGAY, hiệu ứng quay ngắn dừng đúng món server trả về, thẻ kết quả có Xem công thức, Nấu món này, Thử món khác (loại các món đã trúng trong phiên). Tùy chọn: chỉ quay trong món hợp khẩu vị."
- Kiểm tra: dừng đúng món; hết món thì báo, không lỗi; Nấu món này mở được màn nấu.
- Trạng thái: [x]

### Bước C1: đưa giọng nói lên cấp toàn app

- Prompt: "Trong app CookMate, chuyển VoiceService và VoiceGate ra khỏi cooking_screen.dart thành một bộ điều khiển dùng chung khởi tạo ở cấp app. Thêm công tắc bật nghe 'bếp ơi' trong Hồ sơ. Giữ nguyên hành vi hiện tại ở màn nấu, tạm dừng nghe ở các màn dùng camera (quét mặt, chọn ảnh), tự dừng khi app xuống nền. Giữ test voice_gate hiện có xanh."
- Kiểm tra: màn nấu vẫn điều khiển bằng giọng như cũ; vào màn quét mặt thì mic không tranh chấp.
- Trạng thái: [x]

### Bước C2: bảng "Bạn cần gì?"

- Prompt: "Thêm lớp phủ (overlay) ở cấp MaterialApp.router của CookMate: khi nghe 'bếp ơi' ở bất kỳ màn nào thì hiện bảng 'Bạn cần gì?' có icon mic, tự đóng sau 5 giây không có lệnh. Thêm lệnh 'mở món đang nấu', 'về trang chủ' (tab Công thức) và 'hôm nay ăn gì' (mở Lucky Meal). Lệnh nấu ăn khi không ở màn nấu thì bảng báo 'Hãy mở một món để dùng lệnh này'. Thêm test cho phần phân tích lệnh."
- Kiểm tra: test đơn vị xanh. Test bằng giọng chỉ chắc khi có máy thật; trên máy ảo thử bật mic host, nếu không nhận thì ghi rõ "chưa test bằng giọng" trong báo cáo.
- Trạng thái: [x]

### Bước D: hoàn thiện

- Prompt: "Rà soát CookMate sau khi thêm khẩu vị, Lucky Meal và nghe toàn app: chạy toàn bộ test app và server, cập nhật docs/DEMO.md và docs/BAO_CAO.md cho 3 tính năng mới, liệt kê những gì chưa test được (giọng nói trên máy ảo). Kèm danh sách file server đã đổi và bước publish lên myasp.net, gồm cả cập nhật DB."
- Kiểm tra: test xanh; tài liệu khớp code.
- Trạng thái: [x]

## 6. Publish lên myasp.net (làm sau B1 và A2, và sau bước D)

- [x] Publish lại server (profile `cookmate2026-001-site1`).
- [x] Áp migration lên DB của hosting (không chỉ upload code).
- [x] Kiểm tra chuỗi kết nối DB và khóa JWT trên host không bị ghi đè.
- [x] Gọi `/api/health` và API mới trên địa chỉ thật.
- [x] Build lại APK với `API_BASE_URL` của host.

## 7. Bảng tiến trình

| Bước | Nội dung | Trạng thái | Ngày xong | Ghi chú |
|---|---|---|---|---|
| 0 | Chuẩn bị, sao lưu | [x] | 01/11/2026 | Backup `CookMate_truoc_khau_vi.bak`. Chưa có git nên chưa commit/nhánh. Test nền: server 1 đỏ sẵn (GoogleLogin 503) |
| A1 | Nhãn khẩu vị (server) | [x] | 01/11/2026 | Cột chuỗi `Recipes.Tastes`, migration `AddRecipeTastes` |
| A2 | Lưu khẩu vị, API gợi ý | [x] | 01/11/2026 | `Users.Tastes` (null = chưa hỏi), `PUT users/me/tastes`, `GET recipes/recommended` |
| A3 | Màn hỏi khẩu vị, Dành cho bạn | [x] | 01/11/2026 | Máy ảo: "Dành cho bạn" đúng; lưu khẩu vị trên app chưa thấy thành công |
| B1 | API quay món | [x] | 01/11/2026 | Đếm + Skip ngẫu nhiên, không phụ thuộc hàm random của provider; đã gọi trên SQL Server máy này |
| B2 | Màn Lucky Meal | [x] | 01/11/2026 | Máy ảo: quay, loại món, hết món đúng. Bỏ tùy chọn "chỉ món hợp khẩu vị" |
| C1 | Giọng nói cấp app | [x] | 01/11/2026 | `VoiceController`; công tắc không lưu giữa các lần mở app. Chưa test bằng giọng |
| C2 | Bảng "Bạn cần gì?" | [x] | 01/11/2026 | Test tự động xanh; **chưa test bằng giọng** |
| D | Hoàn thiện, tài liệu | [x] | 01/11/2026 | Server 60/61, app 109/109; DEMO.md mục 5-6, BAO_CAO.md, `docs/sql_AddTastes.sql` |
| P | Publish myasp.net | [x] | 01/11/2026 | Chạy SQL + FTP (app_offline), API thật đã kiểm; APK release build lại trỏ hosting |

## 8. Cắt giảm nếu thiếu thời gian

1. Bỏ C1 và C2 (giọng nói toàn app), giữ nguyên giọng nói ở màn nấu.
2. Bỏ B2 phần lọc, chỉ để nút quay không điều kiện.
3. Giữ A1 đến A3 và B1 đến B2 cơ bản, vì test đầy đủ trên máy ảo.

## 9. Chưa kiểm chứng

- Giọng nói trên máy ảo (mic không nhận).
- App gọi server thật: `docs/DEMO.md` ghi "chưa thử".
- Cách EF Core dịch hàm random với bản SQL Server provider đang dùng.
