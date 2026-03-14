## Pokemon Center Bot - Chrome Extension

Extension tự động đăng ký xổ số Pokemon Center Online.

## Cài đặt

### Cách 1: Load Unpacked (Development)

1. Mở Chrome và vào `chrome://extensions/`
2. Bật "Developer mode" (góc trên bên phải)
3. Click "Load unpacked"
4. Chọn thư mục `extension`
5. Extension sẽ xuất hiện trong toolbar

### Cách 2: Từ file .crx (nếu có)

1. Kéo file `.crx` vào `chrome://extensions/`
2. Click "Add extension"

## Sử dụng

1. **Đăng nhập** vào Pokemon Center Online
2. **Mở bất kỳ trang nào** trên Pokemon Center Online
3. **Click vào icon extension** trên toolbar
4. **Click "🚀 Bắt đầu đăng ký"**
5. Extension sẽ tự động:
   - **Bước 1:** Click vào slide lottery (data-swiper-slide-index="0")
   - **Bước 2:** Click nút "抽選へ進む" (goLotteryBtn)
   - **Bước 3:** Đợi Vue.js render trang lottery list
   - **Bước 4:** Tìm tất cả items đang nhận đơn (受付中)
   - **Bước 5:** Cho mỗi item:
     - Click "詳しく見る" để mở chi tiết
     - Chọn radio button (sản phẩm)
     - Check checkbox (đồng ý điều khoản)
     - Click "応募する" (apply button)
     - Click nút xác nhận trong popup (nếu có)

## Luồng hoạt động (giống Python script)

```
Trang chủ
  ↓ Click slide[data-swiper-slide-index="0"]
Trang lottery
  ↓ Click .goLotteryBtn
Trang lottery/list
  ↓ Đợi Vue.js render
  ↓ Tìm items có class "accepting" hoặc text "受付中"
  ↓ Cho mỗi item:
    - Click dt (詳しく見る)
    - Đợi dd hiển thị
    - Click radio button
    - Click checkbox
    - Click a.popup-modal (応募する)
    - Click a#applyBtn (xác nhận)
  ↓
Hoàn thành
```

## Tính năng

- ✅ Tự động điều hướng từ trang chủ đến lottery list
- ✅ Tự động xử lý tất cả lottery items
- ✅ Đợi Vue.js render
- ✅ Bỏ qua items đã xử lý
- ✅ Bỏ qua items không nhận đơn
- ✅ Logging chi tiết
- ✅ Có thể dừng giữa chừng
- ✅ Không cần Python hay Selenium
- ✅ Chạy trực tiếp trong browser
- ✅ Sử dụng session đã đăng nhập

## Cấu trúc

```
extension/
├── manifest.json       # Extension config
├── popup.html          # UI popup
├── popup.js            # Popup logic
├── content.js          # Main bot logic
├── background.js       # Background service worker
├── icons/              # Extension icons
└── README.md           # This file
```

## Troubleshooting

### Extension không hoạt động

1. Kiểm tra đã bật extension chưa
2. Refresh trang Pokemon Center
3. Kiểm tra console (F12) xem có lỗi không

### Không tìm thấy items

1. Đảm bảo đang ở trang lottery list
2. Đợi trang load xong
3. Kiểm tra có items "受付中" không

### Lỗi khi click

1. Thử click thủ công xem có hoạt động không
2. Có thể trang web đã thay đổi cấu trúc
3. Kiểm tra console để xem lỗi cụ thể

## Ưu điểm so với Python version

- ✅ Không cần cài Python
- ✅ Không cần Selenium/ChromeDriver
- ✅ Không có vấn đề version mismatch
- ✅ Chạy trực tiếp trong browser
- ✅ Dễ cài đặt và sử dụng
- ✅ Không cần mở Chrome với debug mode
- ✅ Tự động dùng session đã đăng nhập

## Lưu ý

- Extension chỉ hoạt động trên trang Pokemon Center Online
- Cần đăng nhập trước khi sử dụng
- Nếu bị redirect về login, đăng nhập rồi chạy lại
- Extension sẽ tự động bỏ qua items đã xử lý
