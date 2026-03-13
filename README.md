# Pokemon Center Online Auto Buyer

Tool Python chạy với Chrome để theo dõi hàng về, thêm vào giỏ, và đi tiếp tới bước xác nhận đơn cuối cùng trên `pokemoncenter-online.com`.

## Cách làm việc

- Dùng Selenium + Chrome profile riêng để giữ session đăng nhập.
- Tự refresh trang sản phẩm cho đến khi hết trạng thái `品切れ`.
- Tự thêm vào cart và đi qua các bước checkout phổ biến.
- Mặc định dừng ở nút đặt hàng cuối để bạn tự kiểm tra trước khi mua.

## Yêu cầu

- macOS có cài Google Chrome
- Python 3.9+

## Cài đặt

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Project đã có sẵn `config.json`. Sửa file này trước khi chạy:

- `product_url`: link sản phẩm cần mua
- `quantity`: số lượng
- `poll_interval_seconds`: chu kỳ refresh
- `max_wait_minutes`: `0` là chờ vô hạn
- `profile_dir`: thư mục Chrome profile local cho bot
- `checkout`: `true` để đi tiếp qua checkout
- `auto_submit_final_order`: `false` để dừng ở trang xác nhận cuối

## Chạy

```bash
python3 pokemon_center_bot.py
```

Override nhanh bằng CLI:

```bash
python3 pokemon_center_bot.py \
  --product-url "https://www.pokemoncenter-online.com/4521329462172.html" \
  --quantity 1
```

## Luồng đăng nhập

Site này có `reCAPTCHA Enterprise` và trang `login-mfa`, nên script không cố fake đăng nhập bằng HTTP request.

Luồng thực tế:

1. Bot mở Chrome bằng profile riêng ở `profile_dir`
2. Nếu bị chuyển sang trang login/MFA, bạn đăng nhập trực tiếp trên Chrome
3. Quay lại terminal và nhấn `Enter`
4. Bot tiếp tục dùng session vừa có

Sau lần đầu, profile đã giữ cookie/session nên các lần sau thường không cần login lại cho tới khi session hết hạn.

## Lưu ý thực tế

- Không nên chạy `headless` khi login hoặc checkout.
- Site có thể đổi selector hoặc thêm anti-bot/captcha, lúc đó cần cập nhật script.
- `auto_submit_final_order=true` sẽ click nút đặt hàng cuối nếu tìm thấy. Chỉ bật khi bạn chấp nhận rủi ro mua tự động hoàn toàn.

## File chính

- `pokemon_center_bot.py`: CLI + flow automation
- `config.example.json`: mẫu config

open -na "Brave Browser" --args \
 --remote-debugging-port=9222 \
 --user-data-dir="$HOME/Library/Application Support/BraveSoftware/Brave-Browser" \
 --profile-directory="Default"

python3 pokemon_center_bot.py
