# Pokemon Center Bot - Build Instructions

## Hướng dẫn build thành file .exe (Windows)

### Yêu cầu
- Python 3.7 trở lên
- pip (Python package manager)

### Các bước thực hiện

#### Cách 1: Sử dụng script tự động (Khuyến nghị)

1. Mở Command Prompt hoặc PowerShell
2. Di chuyển đến thư mục chứa code:
   ```cmd
   cd path\to\pokemon-tool
   ```

3. Chạy script build:
   ```cmd
   build_exe.bat
   ```

4. File .exe sẽ được tạo trong thư mục `dist\PokemonCenterBot.exe`

#### Cách 2: Build thủ công

1. Cài đặt dependencies:
   ```cmd
   pip install -r requirements.txt
   ```

2. Build bằng PyInstaller:
   ```cmd
   pyinstaller --onefile --name=PokemonCenterBot --console pokemon_center_bot.py
   ```

3. File .exe sẽ nằm trong thư mục `dist\`

### Chạy file .exe

1. Copy file `dist\PokemonCenterBot.exe` ra ngoài
2. Double-click để chạy, hoặc chạy từ Command Prompt:
   ```cmd
   PokemonCenterBot.exe
   ```

3. Với các tùy chọn:
   ```cmd
   PokemonCenterBot.exe --url https://www.pokemoncenter-online.com
   PokemonCenterBot.exe --headless
   ```

---

## Build trên macOS/Linux

### Yêu cầu
- Python 3.7+
- pip3

### Các bước

1. Cấp quyền thực thi cho script:
   ```bash
   chmod +x build_exe.sh
   ```

2. Chạy script:
   ```bash
   ./build_exe.sh
   ```

3. File executable sẽ nằm trong `dist/PokemonCenterBot`

4. Chạy:
   ```bash
   ./dist/PokemonCenterBot
   ```

---

## Lưu ý quan trọng

### ChromeDriver
- File .exe vẫn cần ChromeDriver để hoạt động
- ChromeDriver phải tương thích với phiên bản Chrome/Brave đang cài
- Selenium sẽ tự động tải ChromeDriver nếu chưa có

### Brave Browser
- Phải cài đặt Brave Browser trên máy
- Script sẽ tự động tìm Brave ở các vị trí mặc định:
  - Windows: `C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe`
  - macOS: `/Applications/Brave Browser.app/Contents/MacOS/Brave Browser`
  - Linux: `/usr/bin/brave-browser`

### Antivirus
- Một số antivirus có thể chặn file .exe do PyInstaller tạo ra
- Nếu bị chặn, thêm file vào whitelist của antivirus

### Kích thước file
- File .exe sẽ có kích thước khoảng 10-20MB
- Đây là kích thước bình thường do PyInstaller đóng gói Python runtime

---

## Troubleshooting

### Lỗi "Python not found"
- Cài đặt Python từ https://www.python.org/
- Đảm bảo chọn "Add Python to PATH" khi cài đặt

### Lỗi "pip not found"
```cmd
python -m ensurepip --upgrade
```

### Lỗi "PyInstaller failed"
```cmd
pip install --upgrade pyinstaller
```

### File .exe không chạy
- Chạy từ Command Prompt để xem lỗi chi tiết
- Kiểm tra log file nếu có
- Đảm bảo Brave Browser đã được cài đặt

### Lỗi "Brave Browser not found"
- Cài đặt Brave từ https://brave.com/
- Hoặc cập nhật đường dẫn trong code (hàm `detect_browser_binary()`)

---

## Phân phối

Khi phân phối file .exe cho người khác:

1. **Cần có:**
   - File `PokemonCenterBot.exe`
   - Brave Browser đã cài đặt trên máy đích

2. **Không cần:**
   - Python
   - Source code
   - Dependencies khác

3. **Hướng dẫn sử dụng:**
   - Double-click file .exe
   - Hoặc chạy từ Command Prompt với các tùy chọn
