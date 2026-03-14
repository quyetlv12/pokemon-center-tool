# Hướng dẫn cài đặt Extension - Pokemon Center Bot

## Bước 1: Tải extension

Nếu bạn đang xem file này, bạn đã có thư mục `extension` rồi. Nếu chưa, tải về từ repository.

## Bước 2: Mở Chrome Extensions

1. Mở Google Chrome
2. Vào địa chỉ: `chrome://extensions/`
3. Hoặc: Menu (⋮) → Extensions → Manage Extensions

## Bước 3: Bật Developer Mode

Ở góc trên bên phải, bật công tắc "Developer mode"

![Developer Mode](https://i.imgur.com/example.png)

## Bước 4: Load Extension

1. Click nút "Load unpacked" (Tải tiện ích đã giải nén)
2. Chọn thư mục `extension` (thư mục chứa file này)
3. Click "Select Folder"

## Bước 5: Kiểm tra

Extension sẽ xuất hiện trong danh sách với:
- Tên: "Pokemon Center Bot"
- Icon: 🎮
- Trạng thái: Enabled (màu xanh)

## Bước 6: Ghim Extension (Khuyến nghị)

1. Click icon puzzle (🧩) trên thanh toolbar
2. Tìm "Pokemon Center Bot"
3. Click icon ghim (📌) để giữ extension luôn hiển thị

## Sử dụng

1. Đăng nhập vào Pokemon Center Online
2. Mở bất kỳ trang nào trên website
3. Click icon extension (🎮)
4. Click "🚀 Bắt đầu đăng ký"
5. Extension sẽ tự động:
   - Điều hướng đến trang lottery list
   - Đăng ký tất cả items đang nhận đơn
   - Hiển thị kết quả

## Troubleshooting

### Extension không xuất hiện

- Kiểm tra đã chọn đúng thư mục `extension`
- Thư mục phải chứa file `manifest.json`
- Thử reload extension: click icon reload (🔄)

### Extension không hoạt động

- Refresh trang Pokemon Center Online (F5)
- Mở Console (F12) để xem lỗi
- Kiểm tra đã đăng nhập chưa

### Lỗi "Manifest file is missing or unreadable"

- Kiểm tra file `manifest.json` có trong thư mục
- Kiểm tra file không bị lỗi cú pháp

### Extension bị vô hiệu hóa

- Vào `chrome://extensions/`
- Tìm "Pokemon Center Bot"
- Bật công tắc Enable

## Gỡ cài đặt

1. Vào `chrome://extensions/`
2. Tìm "Pokemon Center Bot"
3. Click "Remove"

## Cập nhật Extension

1. Tải phiên bản mới
2. Vào `chrome://extensions/`
3. Tìm "Pokemon Center Bot"
4. Click icon reload (🔄)

Hoặc gỡ và cài lại theo hướng dẫn trên.

## Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
- Console log (F12 → Console)
- Extension log (click "Xem log" trong popup)
- README.md để biết thêm chi tiết
