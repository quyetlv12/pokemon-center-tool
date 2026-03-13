# Hướng dẫn sử dụng Profile thật trên Windows

## Vấn đề: Script mở Brave ở chế độ testing/guest

Khi chạy script, Brave mở với profile mới (testing) thay vì profile thật có đăng nhập sẵn.

## Giải pháp

### Cách 1: Attach vào Brave đang chạy (Khuyến nghị)

1. **Đóng Brave hoàn toàn** (nếu đang mở)

2. **Mở Brave với remote debugging:**
   - Nhấn `Win + R`
   - Paste lệnh sau và nhấn Enter:
   
   ```
   "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222
   ```
   
   Hoặc nếu Brave ở vị trí khác:
   ```
   "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222
   ```

3. **Đăng nhập vào Pokemon Center** trong Brave vừa mở

4. **Chạy script:**
   ```cmd
   PokemonCenterBot.exe
   ```
   
   Script sẽ tự động attach vào Brave đang chạy và sử dụng session đã đăng nhập!

### Cách 2: Tạo shortcut để mở Brave với debugging

1. **Tạo shortcut:**
   - Chuột phải trên Desktop → New → Shortcut
   - Target: 
     ```
     "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222
     ```
   - Name: `Brave (Debug Mode)`

2. **Sử dụng:**
   - Double-click shortcut để mở Brave
   - Chạy script

### Cách 3: Chỉ định profile cụ thể

Nếu bạn có nhiều profile trong Brave:

```cmd
# Liệt kê các profile
dir "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data"

# Chạy với profile cụ thể
PokemonCenterBot.exe --profile "Profile 1"
PokemonCenterBot.exe --profile "Default"
```

### Cách 4: Chỉ định User Data Directory tùy chỉnh

```cmd
PokemonCenterBot.exe --user-data-dir "C:\Path\To\Your\BraveData"
```

## Kiểm tra đường dẫn Profile

Để tìm đường dẫn profile thật của bạn:

1. Mở Brave
2. Vào `brave://version`
3. Tìm dòng "Profile Path", ví dụ:
   ```
   C:\Users\YourName\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default
   ```

4. Sử dụng:
   ```cmd
   PokemonCenterBot.exe --user-data-dir "C:\Users\YourName\AppData\Local\BraveSoftware\Brave-Browser\User Data" --profile "Default"
   ```

## Tất cả các tùy chọn

```cmd
PokemonCenterBot.exe [options]

Options:
  --url URL                 URL to open (default: https://www.pokemoncenter-online.com)
  --headless               Run in headless mode (no GUI)
  --profile PROFILE        Profile directory name (default: Default)
  --user-data-dir PATH     Custom user data directory path
  --debug-port PORT        Remote debugging port (default: 9222)

Examples:
  # Attach to running Brave
  PokemonCenterBot.exe
  
  # Use specific profile
  PokemonCenterBot.exe --profile "Profile 1"
  
  # Use custom user data directory
  PokemonCenterBot.exe --user-data-dir "D:\MyBraveData"
  
  # Use different debug port
  PokemonCenterBot.exe --debug-port 9223
```

## Troubleshooting

### Lỗi: "Brave is already running and locked"

**Giải pháp:**
1. Đóng Brave hoàn toàn
2. Mở Task Manager (Ctrl+Shift+Esc)
3. Tìm và kết thúc tất cả process "Brave"
4. Chạy lại script

### Script vẫn mở profile mới

**Nguyên nhân:** Brave đang chạy ở background

**Giải pháp:**
1. Đóng Brave hoàn toàn
2. Mở Brave với `--remote-debugging-port=9222`
3. Chạy script

### Không thể attach vào Brave

**Kiểm tra:**
1. Brave có đang chạy với `--remote-debugging-port=9222` không?
2. Port 9222 có bị chiếm bởi app khác không?
   ```cmd
   netstat -ano | findstr :9222
   ```
3. Thử port khác:
   ```cmd
   PokemonCenterBot.exe --debug-port 9223
   ```

## Tạo Batch File để chạy nhanh

Tạo file `run_with_brave.bat`:

```batch
@echo off
echo Starting Brave with debugging...
start "" "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222

echo Waiting for Brave to start...
timeout /t 3 /nobreak

echo Running Pokemon Center Bot...
PokemonCenterBot.exe

pause
```

Double-click file này để tự động mở Brave và chạy bot!
