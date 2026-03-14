# Pokemon Center Bot

Tự động đăng ký xổ số Pokemon Center Online.

## 🎯 Có 2 phiên bản

### 1. Chrome Extension (Khuyến nghị) ⭐

**Ưu điểm:**
- ✅ Dễ cài đặt và sử dụng nhất
- ✅ Không cần Python, Selenium
- ✅ Chạy trực tiếp trong browser
- ✅ Không có vấn đề ChromeDriver
- ✅ Tự động dùng session đã đăng nhập

**Cài đặt:**
```
1. Mở Chrome: chrome://extensions/
2. Bật "Developer mode"
3. Click "Load unpacked"
4. Chọn thư mục "extension"
```

**Sử dụng:**
```
1. Đăng nhập Pokemon Center Online
2. Vào trang lottery list
3. Click icon extension
4. Click "Bắt đầu đăng ký"
```

👉 [Xem hướng dẫn chi tiết](extension/README.md)

---

### 2. Python Script (Advanced)

**Ưu điểm:**
- ✅ Có thể chạy headless
- ✅ Có thể schedule tự động
- ✅ Có thể build thành .exe

**Yêu cầu:**
- Python 3.7+
- Google Chrome
- pip

**Cài đặt:**

Windows:
```cmd
pip install -r requirements.txt
fix_chromedriver_windows.bat
```

macOS:
```bash
chmod +x *.sh
pip3 install -r requirements.txt
./fix_chromedriver_mac.sh
```

**Sử dụng:**

Windows:
```cmd
START_HERE.bat
```

macOS:
```bash
./START_HERE.sh
```

👉 [Hướng dẫn Windows](README_WINDOWS.md) | [Hướng dẫn macOS](README_MAC.md)

---

## 📋 So sánh

| Tính năng | Extension | Python Script |
|-----------|-----------|---------------|
| Dễ cài đặt | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Dễ sử dụng | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Không cần Python | ✅ | ❌ |
| Không cần ChromeDriver | ✅ | ❌ |
| Chạy headless | ❌ | ✅ |
| Build thành .exe | ❌ | ✅ |
| Schedule tự động | ❌ | ✅ |

## 🚀 Khuyến nghị

**Người dùng thông thường:** Dùng Chrome Extension

**Developer/Advanced user:** Dùng Python Script nếu cần automation nâng cao

## 📝 Tính năng chung

- Tự động đăng ký tất cả lottery items
- Đợi Vue.js render
- Bỏ qua items đã xử lý
- Bỏ qua items không nhận đơn
- Logging chi tiết
- Xử lý login redirect

## ⚠️ Lưu ý

- Tool chỉ hoạt động trên Pokemon Center Online
- Cần đăng nhập trước khi sử dụng
- Tuân thủ terms of service của website

## 📄 License

MIT License
