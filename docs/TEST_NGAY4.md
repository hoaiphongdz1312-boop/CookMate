# Danh sách cần kiểm thử – Ngày 4 (B7 + F9)

Chuẩn bị: server chạy (`dotnet run` trong `server/CookMate.Api`), máy ảo gọi `http://10.0.2.2:<port>`, có 2 tài khoản A và B đã xác thực email.

## 1. API phiên nấu (Swagger, bấm Authorize bằng token của A)
| # | Thao tác | Mong đợi |
|---|---|---|
| 1 | POST /api/cooking-sessions `{recipeId:1, servings:2}` | 201, `currentStep:1`, `status:"InProgress"` |
| 2 | Gọi lại y hệt | 200, **cùng id** (không tạo phiên mới) |
| 3 | POST với `servings:0` hoặc `21` | 400 |
| 4 | POST với `recipeId:9999` | 404 |
| 5 | PATCH `{currentStep:2}` | 200, currentStep=2 |
| 6 | PATCH `{currentStep:0}` và `{currentStep:<số bước + 1>}` | 400 cả hai |
| 7 | Token của B: PATCH / complete phiên của A | 404 |
| 8 | Không token: gọi bất kỳ API nào ở trên | 401 |
| 9 | POST complete, rồi gọi complete lần 2 | 200 cả hai, `completedAt` không đổi |
| 10 | PATCH phiên đã hoàn thành | 400 |
| 11 | GET /api/users/me/progress (A) | đúng `completedCount`, `inProgress`, `history` |
| 12 | GET /api/users/me/progress (B) | rỗng, không thấy dữ liệu của A |

## 2. App (máy ảo)
| # | Kịch bản | Mong đợi |
|---|---|---|
| 1 | Chọn món, bấm Bắt đầu nấu, sang bước 3, thoát ra | Hồ sơ hiện món ở "Đang nấu dở" với "Bước 3/n" |
| 2 | Mở lại món đó | Hộp thoại "Tiếp tục bước 3" / "Nấu lại" |
| 3 | Chọn "Nấu lại" | Về bước 1; hồ sơ sau đó hiện Bước 1 |
| 4 | Nấu dở, **đăng xuất**, đăng nhập lại bằng mật khẩu | Món dở vẫn còn, tiếp tục đúng bước |
| 5 | Như 4 nhưng đăng nhập bằng khuôn mặt | Như trên |
| 6 | Đi hết các bước, bấm Hoàn thành | Hộp thoại chúc mừng; "Món đã nấu" tăng 1; món chuyển sang Lịch sử |
| 7 | Hồ sơ: bấm một món ở Lịch sử | Mở chi tiết món |
| 8 | Tắt server giữa chừng, bấm Tiếp vài lần, bật lại server, bấm Tiếp tiếp | App không treo; sau khi có mạng, bước được lưu lại (kiểm tra ở Hồ sơ) |
| 9 | Tắt server, ở bước cuối bấm Hoàn thành | Báo lỗi, vẫn ở màn nấu; bật server bấm lại thì hoàn thành được |
| 10 | Tắt server rồi vào Bắt đầu nấu | Vẫn nấu được, có thông báo "Chưa lưu được tiến độ" |
| 11 | Mở Hồ sơ | Chỉ có ô "Món đã nấu", không còn "Sự cố đã cứu" (Bếp cứu hộ đã bỏ) |
| 12 | Hồ sơ khi server tắt | Hiện lỗi và nút Thử lại, bấm được |
| 13 | Hẹn giờ 1 phút, đổi sang bước khác rồi quay lại | Thời gian còn lại vẫn đúng (không bị ảnh hưởng bởi F9) |

## 3. Ghi lại để gửi tôi
- Mục nào lỗi: số mục + thông báo/ảnh chụp màn hình.
- **F10** (chưa làm được vì cần dữ liệu thật): bảng test đăng nhập mặt gồm bạn và ít nhất 2 người khác thử vào tài khoản của bạn (người, số lần thử, số lần thành công, ánh sáng, kính, ghi chú).
