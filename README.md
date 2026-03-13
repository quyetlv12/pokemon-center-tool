# Pokemon Center Bot

Tự động đăng ký xổ số Pokemon Center Online cho cả Windows và macOS.

## Yêu cầu

- Python 3.7+
- Google Chrome
- pip (Python package manager)

## Cài đặt

### Windows

```cmd
# Cài đặt dependencies
pip install -r requirements.txt

# Cài đặt ChromeDriver
install_chromedriver.bat
```

### macOS/Linux

```bash
# Cấp quyền thực thi cho scripts
chmod +x *.sh

# Cài đặt dependencies
pip3 install -r requirements.txt

# Cài đặt ChromeDriver
./install_chromedriver.sh
```

## Sử dụng

### Cách đơn giản nhất (Khuyến nghị)

#### Windows
```cmd
START_HERE.bat
```

#### macOS/Linux
```bash
./START_HERE.sh
```

Script sẽ tự động:
1. Đóng Chrome cũ
2. Mở Chrome với profile Default + debug mode
3. Chạy bot tự động

### Chạy từ source code

#### Windows
```cmd
python pokemon_center_bot.py
```

#### macOS/Linux
```bash
python3 pokemon_center_bot.py
```

### Các tùy chọn

```bash
# Sử dụng profile khác
python3 pokemon_center_bot.py --profile "Profile 1"

# Chỉ định User Data Directory
python3 pokemon_center_bot.py --user-data-dir "/path/to/chrome/data"

# Liệt kê profiles có sẵn
python3 pokemon_center_bot.py --list-profiles

# Chạy headless (không hiển thị UI)
python3 pokemon_center_bot.py --headless
```

## Troubleshooting

### Lỗi: Chrome không khởi động hoặc bị treo

#### Windows
```cmd
# 1. Fix Chrome locks
fix_chrome_lock.bat

# 2. Test Chrome connection
quick_test.bat

# 3. Chạy lại
START_HERE.bat
```

#### macOS/Linux
```bash
# 1. Fix Chrome locks
./fix_chrome_lock.sh

# 2. Test Chrome connection
./quick_test.sh

# 3. Chạy lại
./START_HERE.sh
```

### Lỗi: ChromeDriver version mismatch

```bash
# Windows
install_chromedriver.bat

# macOS/Linux
./install_chromedriver.sh
```

### Lỗi: Chrome đang chạy

Đóng tất cả Chrome windows và chạy lại, hoặc:

#### Windows
```cmd
taskkill /F /IM chrome.exe
```

#### macOS
```bash
killall "Google Chrome"
```

#### Linux
```bash
killall chrome
```

## Build thành executable

### Windows

```cmd
# Build
build_exe.bat

# File .exe sẽ nằm trong dist/
dist\PokemonCenterBot.exe
```

### macOS/Linux

```bash
# Build
./build_exe.sh

# File executable sẽ nằm trong dist/
./dist/PokemonCenterBot
```

## Cấu trúc thư mục

```
pokemon-center-tool/
├── pokemon_center_bot.py      # Main script
├── requirements.txt            # Python dependencies
├── README.md                   # This file
│
├── Windows Scripts:
├── START_HERE.bat             # All-in-one launcher (Windows)
├── fix_chrome_lock.bat        # Fix Chrome profile locks
├── install_chromedriver.bat   # Install ChromeDriver
├── quick_test.bat             # Test Chrome connection
├── build_exe.bat              # Build to .exe
│
├── macOS/Linux Scripts:
├── START_HERE.sh              # All-in-one launcher (Unix)
├── fix_chrome_lock.sh         # Fix Chrome profile locks
├── install_chromedriver.sh    # Install ChromeDriver
├── quick_test.sh              # Test Chrome connection
├── build_exe.sh               # Build to executable
│
└── Test Scripts:
    ├── quick_test.py          # Python test script
    └── test_chrome_connection.py
```

## Tính năng

- ✅ Tự động mở Chrome với profile đã đăng nhập
- ✅ Tự động điền form đăng ký xổ số
- ✅ Hỗ trợ đăng ký nhiều sản phẩm
- ✅ Đợi user đăng nhập nếu chưa đăng nhập
- ✅ Xử lý Vue.js rendering
- ✅ Hỗ trợ cả Windows và macOS
- ✅ Tự động tải đúng version ChromeDriver
- ✅ Logging chi tiết
- ✅ Error handling tốt

## Lưu ý

- Tool sẽ sử dụng profile "Default" của Chrome (nơi có session đăng nhập)
- Nếu bị redirect về trang login, tool sẽ đợi bạn đăng nhập
- Đảm bảo Chrome đã được cài đặt và chạy ít nhất 1 lần
- Port 9222 phải available (không bị chiếm bởi app khác)

## License

MIT License
