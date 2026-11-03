# Điều khiển nấu ăn bằng giọng nói ("Bếp ơi, bước tiếp theo")

Kế hoạch + tiến trình prompt cho Claude Code. Ngày lập: 2026-10-31.
Phạm vi: chỉ màn nấu (`app/lib/features/cooking/`). Không đụng Google login, face login, thực đơn theo ngân sách.

## 1. Mục tiêu

Người nấu nói "Bếp ơi" rồi nói lệnh, app tự chuyển bước, không cần chạm màn hình (tay đang dính dầu mỡ).

| Lệnh nói | Hành động (đã có sẵn trong `CookingController`) |
|---|---|
| bước tiếp theo | `next()` |
| bước trước | `previous()` |
| hẹn giờ | `startTimer()` |
| dừng hẹn giờ | `pauseTimer()` |

Chỉ nghe khi màn nấu đang mở (màn đã bật `WakelockPlus`, nên màn hình luôn sáng và app luôn ở foreground). Không làm nghe nền.

## 2. Quyết định kỹ thuật

- Nhận dạng offline bằng **Vosk model tiếng Việt nhỏ** + plugin `vosk_flutter_service` (bản 0.1.3 lúc lập kế hoạch, kiểm tra lại trên pub.dev).
- **Grammar** (danh sách từ được phép): `["bếp ơi", "bước tiếp theo", "bước trước", "hẹn giờ", "dừng hẹn giờ", "[unk]"]`. `[unk]` để câu khác (tivi, nói chuyện) rơi vào "không rõ", không bị ép thành lệnh. Cần xác nhận `[unk]` chạy được trong plugin Flutter.
- **Cổng 2 bước** (logic Dart, không nằm trong Vosk):
  1. `idle`: nghe thấy "bếp ơi" thì sang `armed`, rung nhẹ, mở cửa sổ 5 giây.
  2. `armed`: nghe thấy lệnh hợp lệ thì thực thi, sang `cooldown` 1,5 giây rồi về `idle`. Hết 5 giây không có lệnh thì về `idle`.
  3. Nếu một câu có cả "bếp ơi" lẫn lệnh ("bếp ơi bước tiếp theo") thì thực thi luôn.
  4. Chống chạy lặp: nhớ câu vừa xử lý + thời điểm, bỏ qua câu trùng trong cooldown.
- So khớp lệnh sau khi bỏ dấu tiếng Việt, chữ thường (tự viết bảng bỏ dấu, không thêm thư viện).
- Phương án dự phòng nếu không đạt go/no-go: Porcupine (wake word tiếng Anh) + `speech_to_text` (xem phần 6).

## 3. Tiêu chí go / no-go (đo ở giai đoạn V2)

- Nhận đúng "bếp ơi": ít nhất 8/10 lần.
- Nhận đúng "bước tiếp theo": ít nhất 8/10 lần.
- Kích hoạt nhầm: tối đa 1 lần trong 2 phút có tivi hoặc người nói chuyện.
- Đạt cả ba: làm tiếp V3. Không đạt: ghi kết quả vào bảng theo dõi, chuyển phần 6.
- Ghi rõ đo trên máy nào (emulator dùng micro máy tính nên kết quả có thể kém hơn điện thoại thật).

## 4. Bảng theo dõi tiến trình

| Giai đoạn | Việc | Ai làm | Ước tính | Trạng thái |
|---|---|---|---|---|
| V0 | Tải model Vosk Việt, đặt vào assets, kiểm tra tên và dung lượng | Mày | 15 phút | [ ] |
| V1 | Màn thử `voice_lab_screen.dart` in chữ nhận được | Claude Code | 1 giờ | [ ] |
| V2 | Đo theo tiêu chí go/no-go | Mày | 20 phút | [ ] |
| V3 | Bộ phân tích lệnh + máy trạng thái 2 bước + unit test | Claude Code | 1,5 giờ | [ ] |
| V4 | Gắn vào `cooking_screen` (bật/tắt, biểu tượng mic, rung) | Claude Code | 1,5 giờ | [ ] |
| V5 | Test trên máy thật/emulator, chỉnh grammar, viết `docs/` | Mày + Claude Code | 1 giờ | [ ] |
| V6 | Chỉ khi no-go: Porcupine + speech_to_text | Claude Code | 3 giờ | [ ] |

Tổng ước tính nếu đạt go/no-go: 5–6 giờ.

Kết quả đo (điền ở V2):

| Lần đo | Thiết bị | "bếp ơi" đúng/10 | "bước tiếp theo" đúng/10 | Nhầm/2 phút ồn | Kết luận |
|---|---|---|---|---|---|
| 1 | | | | | |

## 5. Các prompt (dán lần lượt vào Claude Code, mở trong `D:\DoAnLTDD\CookMate`)

Dán xong mỗi prompt, chờ Claude Code báo kết quả rồi mới sang bước sau.

### V0 — Mày tự làm (không cần prompt)

1. Mở trang danh sách model của Vosk, tìm model tiếng Việt loại **small** (ký hiệu `vn`). Ghi lại tên chính xác và dung lượng (tao chưa xác nhận được).
2. Tải file zip, đặt vào `app/assets/models/` (cùng chỗ với `mobilefacenet.tflite`).
3. Báo lại tên file zip để điền vào prompt V1.

### V1 — Màn thử nghiệm (spike)

```
Làm thử nghiệm nhận dạng giọng nói offline cho app Flutter trong app/. Trả lời tiếng Việt. CHỈ làm thử, chưa gắn vào màn nấu.

Mục tiêu: một màn debug cho tôi nói vào máy và xem Vosk nhận ra chữ gì.

Việc cần làm:
1. pubspec.yaml: thêm vosk_flutter_service (bản mới nhất trên pub.dev) và khai báo asset model Vosk tiếng Việt: assets/models/<TÊN_FILE_ZIP>.zip (tôi đã đặt file này vào app/assets/models/). Giữ nguyên asset mobilefacenet.tflite.
2. AndroidManifest.xml (app/android/app/src/main/): thêm <uses-permission android:name="android.permission.RECORD_AUDIO"/>. Không xóa gì có sẵn.
3. Đọc README đúng bản plugin vừa cài để dùng đúng API (tạo model từ asset zip, tạo recognizer sampleRate 16000 có tham số grammar, khởi tạo speech service nghe micro, nghe onPartial và onResult). Không đoán API.
4. Tạo app/lib/features/cooking/voice_lab_screen.dart:
   - Xin quyền micro bằng permission_handler (project đã có).
   - Nút Bắt đầu/Dừng nghe.
   - Grammar: ["bếp ơi", "bước tiếp theo", "bước trước", "hẹn giờ", "dừng hẹn giờ", "[unk]"].
   - Hiển thị danh sách các kết quả nhận được (partial và final), kèm giờ, dòng mới nhất ở trên. Có nút xóa danh sách.
   - Có công tắc "Dùng grammar" để so sánh nhận dạng tự do và nhận dạng theo grammar.
5. router.dart: thêm route /voice-lab, chỉ hoạt động ở chế độ debug (kDebugMode). Không thêm nút vào giao diện người dùng.

Ràng buộc: không sửa CookingController, cooking_screen, auth, face. minSdk của project là 26: nếu plugin yêu cầu cao hơn thì báo tôi, đừng tự đổi.
Chạy flutter analyze và flutter build apk --debug để chắc không lỗi. Báo cho tôi: tên model đã dùng, kích thước APK tăng bao nhiêu, và có chỗ nào API plugin khác với dự kiến (đặc biệt "[unk]" trong grammar có dùng được không).
```

### V2 — Mày đo (không cần prompt)

Mở `/voice-lab` trên máy test, làm đúng phần 3, ghi vào bảng kết quả đo. Gửi bảng cho Claude để quyết định go/no-go.

### V3 — Bộ phân tích lệnh và máy trạng thái (không phụ thuộc Vosk, test được)

```
Viết logic cổng 2 bước cho điều khiển giọng nói, thuần Dart, không phụ thuộc Vosk hay Flutter UI để unit test được. Trả lời tiếng Việt. Giữ phong cách code và comment tiếng Việt như các file trong app/lib/features/cooking/.

Tạo 2 file:
1. app/lib/features/cooking/voice_command_parser.dart
   - enum VoiceCommand { next, previous, startTimer, pauseTimer }
   - hàm bỏ dấu tiếng Việt (tự viết bảng ký tự, nhớ xử lý đ/Đ), chữ thường, gộp khoảng trắng.
   - hàm tìm cụm gọi "bep oi" trong câu (đã bỏ dấu) và hàm tìm lệnh: "buoc tiep theo"/"tiep theo" -> next; "buoc truoc"/"quay lai" -> previous; "dung hen gio"/"tam dung" -> pauseTimer; "hen gio"/"bat dau hen gio" -> startTimer. Kiểm tra "dung hen gio" trước "hen gio" để không nhận nhầm.
2. app/lib/features/cooking/voice_gate.dart
   - Lớp VoiceGate nhận callback onCommand(VoiceCommand), onArmed(), onDisarmed(); nhận thời gian qua hàm now() truyền vào constructor để test.
   - Hàm feed(String text, {required bool isFinal}).
   - Trạng thái: idle -> armed (cửa sổ 5 giây) -> cooldown (1,5 giây) -> idle.
   - Một câu chứa cả "bếp ơi" lẫn lệnh thì thực thi luôn.
   - Chống lặp: cùng một câu (đã chuẩn hóa) trong cooldown thì bỏ qua; kết quả partial chỉ dùng để mở cổng "bếp ơi", lệnh chỉ thực thi từ kết quả final, trừ khi câu partial đã khớp đủ lệnh và chưa xử lý.
   - Hàm pause()/resume() để tạm bỏ qua mọi kết quả (khi app xuống nền).

Viết unit test trong app/test/ cho: câu có dấu và không dấu; "bếp ơi" rồi lệnh trong 5 giây; "bếp ơi" rồi im 5 giây (hết hạn, lệnh sau đó bị bỏ); lệnh khi chưa gọi "bếp ơi" (bị bỏ); một câu có cả hai; lặp lệnh trong cooldown; "[unk]" và câu rỗng bị bỏ; "dừng hẹn giờ" không bị nhận thành "hẹn giờ"; pause()/resume().
Chạy flutter test và flutter analyze, báo kết quả. Không sửa file nào khác.
```

### V4 — Gắn vào màn nấu

```
Gắn điều khiển giọng nói vào màn nấu của app Flutter. Trả lời tiếng Việt. Chỉ sửa trong app/lib/features/cooking/ và AndroidManifest/pubspec nếu thiếu. Không sửa CookingController (đã có next/previous/startTimer/pauseTimer), không đụng auth/face/recipes.

Đã có: voice_command_parser.dart, voice_gate.dart (đã test), voice_lab_screen.dart (ví dụ cách dùng Vosk, API đã được kiểm chứng ở đó).

Việc cần làm:
1. Tạo features/cooking/voice_service.dart: bọc Vosk (khởi tạo model và recognizer một lần, grammar như voice_lab), phát stream kết quả partial/final cho VoiceGate, có start()/stop()/dispose(). Lỗi khởi tạo (không xin được quyền micro, load model lỗi) thì không làm app crash: báo trạng thái "không dùng được" để UI hiện thông báo gọn.
2. cooking_screen.dart:
   - Thêm công tắc/nút nhỏ trên thanh tiêu đề để bật/tắt giọng nói, mặc định TẮT lần đầu. Lưu lựa chọn lần sau bằng cách đơn giản có sẵn trong project (xem token_storage/flutter_secure_storage), nếu phức tạp thì không lưu.
   - Khi bật: xin quyền micro, start VoiceService, nối VoiceGate -> controller.next()/previous()/startTimer()/pauseTimer(). Nhớ giữ nguyên hành vi lưu tiến độ onStepChanged đã có.
   - Biểu tượng mic có 3 trạng thái: đang nghe (idle), đã nghe "bếp ơi" (armed, sáng hơn), không dùng được. Khi armed gọi HapticFeedback.mediumImpact(). Khi thực thi lệnh hiện SnackBar ngắn kiểu "Đã chuyển sang bước 3".
   - Bật/tắt trong initState/dispose giống cách WakelockPlus đang làm. Thêm WidgetsBindingObserver: app xuống nền thì pause()+stop, quay lại thì resume nếu công tắc đang bật.
   - Ở bước cuối, lệnh "bước tiếp theo" không làm gì (đúng với controller.next() hiện tại), không tự bấm Hoàn thành.
3. Khi hết giờ hẹn giờ (hàm báo "Hết giờ ở bước…") không để Vosk nghe nhầm âm báo của chính app: nếu app phát âm thanh thì pause nghe trong lúc đó.

Chạy flutter analyze, flutter test, flutter build apk --debug. Liệt kê file đã sửa/tạo và những gì tôi cần thử tay trên máy.
```

### V5 — Test và hoàn thiện

Mày tự thử (kịch bản):
- [ ] Bật giọng nói, nói "bếp ơi bước tiếp theo": chuyển đúng bước.
- [ ] Nói "bếp ơi" rồi im 6 giây rồi nói "bước tiếp theo": không chuyển.
- [ ] Nói "bước tiếp theo" khi chưa gọi "bếp ơi": không chuyển.
- [ ] "bếp ơi hẹn giờ" rồi "bếp ơi dừng hẹn giờ": bộ đếm chạy rồi dừng đúng.
- [ ] Bật tivi 2 phút: không tự chuyển bước.
- [ ] Thoát ra màn hình chính rồi quay lại: không bị nghe hai lần.
- [ ] Từ chối quyền micro: app không crash, có thông báo.

Sau đó dán prompt này:

```
Dựa vào kết quả test này (dán bảng/ghi chú của tôi: lệnh nào hay bị trượt, câu nào bị nhận nhầm, thiết bị nào), điều chỉnh: grammar trong voice_service.dart, bảng từ khóa trong voice_command_parser.dart (thêm biến thể phát âm hay gặp), thời gian cửa sổ armed/cooldown trong voice_gate.dart. Mỗi chỗ đổi phải thêm hoặc sửa unit test. Sau đó tạo docs/GIONG_NOI.md: cách hoạt động, cách đặt model, lệnh hỗ trợ, các lỗi thường gặp (quyền micro, model chưa tải, emulator không có micro), và dung lượng APK tăng thêm. Chạy flutter analyze và flutter test.
```

## 6. Phương án dự phòng (chỉ khi no-go ở V2)

Porcupine: wake word tiếng Anh (ví dụ "Hey Cook") huấn luyện trên Picovoice Console, cần AccessKey, phát hiện chạy offline. Tiếng Việt chưa được trang chính thức liệt kê hỗ trợ. Điều khoản miễn phí chưa verify. Sau khi bắt được wake word thì dừng Porcupine, dùng `speech_to_text` (ngôn ngữ Việt) nghe một lệnh, xong thì bật lại Porcupine. Hai thư viện không dùng micro cùng lúc được. Nhược điểm: có tiếng bíp mỗi lần nghe lệnh, cần mạng.

Prompt V6 sẽ viết khi cần, dựa trên kết quả đo thực tế.

## 7. Rủi ro đã biết

- Model tiếng Việt: tên và dung lượng chưa xác nhận, APK sẽ nặng thêm khoảng vài chục MB, RAM khi chạy khoảng 300MB theo ghi chú chung của Vosk cho model nhỏ.
- `vosk_flutter_service` ít người dùng (khoảng 1,5 nghìn lượt tải), có thể lỗi trên một số máy.
- `[unk]` trong grammar chưa verify trong plugin Flutter.
- Emulator dùng micro máy tính, kết quả không đại diện cho điện thoại thật.
- Tốn pin khi nghe liên tục, nhưng chỉ nghe lúc màn nấu đang mở.

## 8. Thứ tự đề xuất với các việc khác

Google login (khoảng 1 ngày) -> V0–V2 (khoảng 1,5 giờ, để biết có làm tiếp hay không) -> phần còn lại của giọng nói hoặc thực đơn theo ngân sách tùy deadline. Deadline cụ thể chưa rõ.
