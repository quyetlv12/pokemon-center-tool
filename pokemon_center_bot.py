#!/usr/bin/env python3
from __future__ import annotations

import argparse
import logging
import socket
import sys
import platform
from pathlib import Path
from typing import Optional

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver import ChromeOptions
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support.ui import WebDriverWait


LOGGER = logging.getLogger("pokemon_center_bot")
DEFAULT_BASE_URL = "https://www.pokemoncenter-online.com"

# Detect OS and set appropriate paths
SYSTEM = platform.system()

if SYSTEM == "Darwin":  # macOS
    BRAVE_USER_DATA_DIR = (
        Path.home() / "Library/Application Support/BraveSoftware/Brave-Browser"
    )
elif SYSTEM == "Windows":
    BRAVE_USER_DATA_DIR = (
        Path.home() / "AppData/Local/BraveSoftware/Brave-Browser/User Data"
    )
else:  # Linux
    BRAVE_USER_DATA_DIR = (
        Path.home() / ".config/BraveSoftware/Brave-Browser"
    )

BRAVE_PROFILE_DIRECTORY = "Default"
BRAVE_DEBUG_HOST = "127.0.0.1"
BRAVE_DEBUG_PORT = 9222
TARGET_SLIDE_SELECTOR = '.swiper-slide[data-swiper-slide-index="0"] a'
LOTTERY_BUTTON_SELECTOR = ".comBtn.fixBtn a.goLotteryBtn"
LOTTERY_ITEM_SELECTOR = "ul.comOrderList > li"
LOTTERY_TITLE_SELECTOR = "div.lBox > p"
DETAIL_TOGGLE_SELECTOR = "dl.subDl > dt"
ACCEPT_BOX_SELECTOR = "div.acceptBox.accepting"
# New selectors for application
RADIO_BUTTON_SELECTOR = "input[type='radio']"
CHECKBOX_SELECTOR = "input[type='checkbox']"
APPLY_LINK_SELECTOR = "a.popup-modal"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Open Pokemon Center Online in Brave."
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_BASE_URL,
        help=f"URL to open. Default: {DEFAULT_BASE_URL}",
    )
    parser.add_argument(
        "--headless",
        action="store_true",
        help="Run Chrome in headless mode.",
    )
    return parser.parse_args()


def detect_browser_binary() -> Optional[str]:
    system = platform.system()
    
    if system == "Darwin":  # macOS
        candidates = (
            "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
        )
    elif system == "Windows":
        candidates = (
            str(Path.home() / "AppData/Local/BraveSoftware/Brave-Browser/Application/brave.exe"),
            "C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe",
            "C:/Program Files (x86)/BraveSoftware/Brave-Browser/Application/brave.exe",
        )
    else:  # Linux
        candidates = (
            "/usr/bin/brave-browser",
            "/usr/bin/brave-browser-stable",
            "/usr/bin/brave",
        )
    
    for candidate in candidates:
        if Path(candidate).exists():
            LOGGER.info("Found Brave browser at: %s", candidate)
            return candidate
    
    LOGGER.error("Brave browser not found. Tried: %s", candidates)
    return None


def is_port_open(host: str, port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(0.5)
        return sock.connect_ex((host, port)) == 0


def is_brave_running() -> bool:
    system = platform.system()
    
    if system == "Darwin":  # macOS
        lock_file = BRAVE_USER_DATA_DIR / "SingletonLock"
        return lock_file.exists()
    elif system == "Windows":
        # On Windows, check for lockfile in the profile directory
        lock_file = BRAVE_USER_DATA_DIR / "lockfile"
        singleton_lock = BRAVE_USER_DATA_DIR / "SingletonLock"
        return lock_file.exists() or singleton_lock.exists()
    else:  # Linux
        lock_file = BRAVE_USER_DATA_DIR / "SingletonLock"
        return lock_file.exists()


def build_driver(headless: bool) -> webdriver.Chrome:
    options = ChromeOptions()
    binary = detect_browser_binary()
    if not binary:
        raise FileNotFoundError(
            f"Brave Browser binary not found on this machine ({platform.system()}). "
            "Please install Brave Browser or update the path in detect_browser_binary()."
        )
    options.binary_location = binary
    LOGGER.info("Using Brave browser at: %s", binary)

    if is_port_open(BRAVE_DEBUG_HOST, BRAVE_DEBUG_PORT):
        options.debugger_address = f"{BRAVE_DEBUG_HOST}:{BRAVE_DEBUG_PORT}"
        LOGGER.info(
            "Attaching to existing Brave at %s:%s",
            BRAVE_DEBUG_HOST,
            BRAVE_DEBUG_PORT,
        )
    else:
        if is_brave_running():
            raise RuntimeError(
                "Brave main profile is already running and locked. "
                "Either quit Brave completely, or start it with "
                "--remote-debugging-port=9222 so Selenium can attach to it."
            )
        LOGGER.info("Starting new Brave instance with user data dir: %s", BRAVE_USER_DATA_DIR)
        options.add_argument(f"--user-data-dir={BRAVE_USER_DATA_DIR}")
        options.add_argument(f"--profile-directory={BRAVE_PROFILE_DIRECTORY}")

    options.add_argument("--start-maximized")
    options.add_argument("--disable-dev-shm-usage")
    
    # Windows-specific options
    if platform.system() == "Windows":
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
    
    if headless:
        options.add_argument("--headless=new")
        options.add_argument("--window-size=1400,1400")

    service = Service()
    return webdriver.Chrome(service=service, options=options)


def configure_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
    )


def find_target_slide_link(driver: webdriver.Chrome) -> WebElement:
    return find_visible_element(driver, TARGET_SLIDE_SELECTOR)


def find_visible_element(driver: webdriver.Chrome, selector: str) -> WebElement:
    def locate(current_driver: webdriver.Chrome) -> Optional[WebElement]:
        elements = current_driver.find_elements(By.CSS_SELECTOR, selector)
        for element in elements:
            if element.is_displayed():
                return element
        return elements[0] if elements else None

    return WebDriverWait(driver, 20).until(locate)


def click_element(driver: webdriver.Chrome, element: WebElement) -> None:
    driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", element)
    driver.execute_script("arguments[0].click();", element)


def apply_lottery_entries(driver: webdriver.Chrome) -> None:
    import time
    processed_titles: set[str] = set()

    while True:
        # Wait for the container to at least exist
        try:
            WebDriverWait(driver, 10).until(
                lambda d: d.find_elements(By.CSS_SELECTOR, "ul.comOrderList")
            )
        except:
            LOGGER.info("Could not find lottery list container (ul.comOrderList) after 10s.")
            return

        # Wait for Vue.js to render - check if template variables are gone
        LOGGER.info("Waiting for Vue.js to render the lottery list...")
        try:
            WebDriverWait(driver, 15).until(
                lambda d: "{{" not in d.find_element(By.CSS_SELECTOR, "ul.comOrderList").get_attribute("innerHTML")
            )
            LOGGER.info("Vue.js rendering complete")
        except:
            LOGGER.warning("Vue.js may not have finished rendering, but continuing anyway...")
        
        # Additional wait to ensure everything is loaded
        time.sleep(2)

        items = driver.find_elements(By.CSS_SELECTOR, LOTTERY_ITEM_SELECTOR)
        if not items:
            LOGGER.info("Lottery list container found, but no <li> items inside.")
            return
            
        LOGGER.info("Found %d items in the lottery list.", len(items))
        
        # Debug: Print first item's HTML structure
        if items:
            first_item_html = driver.execute_script("return arguments[0].outerHTML;", items[0])
            LOGGER.info("First item HTML (first 500 chars): %s", first_item_html[:500])
        
        current_item: Optional[WebElement] = None
        current_title = ""

        for i, item in enumerate(items):
            # Debug: Print the HTML structure
            LOGGER.info("=" * 60)
            LOGGER.info("Analyzing item %d", i + 1)
            
            # Try to get title from multiple potential locations
            title = ""
            
            # Method 1: div.lBox > p
            title_elements = item.find_elements(By.CSS_SELECTOR, "div.lBox > p")
            if title_elements:
                title = title_elements[0].text.strip()
                LOGGER.info("Found title via 'div.lBox > p': '%s'", title)
            
            # Method 2: .lBox p
            if not title:
                lbox_ps = item.find_elements(By.CSS_SELECTOR, ".lBox p")
                if lbox_ps:
                    title = lbox_ps[0].text.strip()
                    LOGGER.info("Found title via '.lBox p': '%s'", title)
            
            # Method 3: ul.waresUl p.name
            if not title:
                name_ps = item.find_elements(By.CSS_SELECTOR, "ul.waresUl p.name")
                if name_ps:
                    title = name_ps[0].text.strip()
                    LOGGER.info("Found title via 'ul.waresUl p.name': '%s'", title)
            
            # Method 4: Any p tag with substantial text
            if not title:
                all_ps = item.find_elements(By.CSS_SELECTOR, "p")
                for p in all_ps:
                    text = p.text.strip()
                    if text and len(text) > 10:
                        title = text
                        LOGGER.info("Found title via any p tag: '%s'", title)
                        break

            # Debug: Log the status box
            status_elements = item.find_elements(By.CSS_SELECTOR, "div.acceptBox")
            if status_elements:
                status_elem = status_elements[0]
                status_text = status_elem.text.strip()
                status_class = status_elem.get_attribute("class")
                status_html = driver.execute_script("return arguments[0].outerHTML;", status_elem)
                
                LOGGER.info("Status element found:")
                LOGGER.info("  Text: '%s'", status_text.replace('\n', ' '))
                LOGGER.info("  Class: '%s'", status_class)
                LOGGER.info("  HTML: %s", status_html[:200])
            else:
                status_text = "No status box"
                status_class = ""
                LOGGER.info("No status element found")

            # Check if this item is accepting applications
            is_accepting = "accepting" in status_class or "受付中" in status_text
            LOGGER.info("Is accepting: %s", is_accepting)
            
            if not is_accepting:
                continue
            
            if title and title in processed_titles:
                continue
            
            current_item = item
            current_title = title if title else f"Unknown Item {i+1}"
            break

        if not current_item:
            LOGGER.info("No more eligible lottery entries to process.")
            return

        LOGGER.info("Processing application for: %s", current_title)

        try:
            import time
            
            # 1. Click '詳しく見る' (Detail Toggle)
            detail_toggles = current_item.find_elements(By.CSS_SELECTOR, DETAIL_TOGGLE_SELECTOR)
            if not detail_toggles:
                LOGGER.warning("No detail toggle found for '%s', skipping", current_title)
                continue
            
            detail_toggle = detail_toggles[0]
            LOGGER.info("Clicking detail toggle ('詳しく見る')")
            
            # Scroll into view first
            driver.execute_script("arguments[0].scrollIntoView({block: 'center', behavior: 'smooth'});", detail_toggle)
            time.sleep(0.3)
            
            # Check if dd is already visible
            dd_element = current_item.find_element(By.CSS_SELECTOR, "dl.subDl > dd")
            is_visible = dd_element.is_displayed()
            LOGGER.info("DD element display status before click: %s", is_visible)
            
            if not is_visible:
                # Try multiple click methods
                LOGGER.info("Attempting to click detail toggle...")
                
                # Method 1: Regular click
                try:
                    detail_toggle.click()
                    time.sleep(0.5)
                except Exception as e:
                    LOGGER.info("Regular click failed: %s", e)
                
                # Method 2: JavaScript click
                if not dd_element.is_displayed():
                    LOGGER.info("Trying JavaScript click")
                    driver.execute_script("arguments[0].click();", detail_toggle)
                    time.sleep(0.5)
                
                # Method 3: Dispatch click event
                if not dd_element.is_displayed():
                    LOGGER.info("Trying to dispatch click event")
                    driver.execute_script("""
                        var event = new MouseEvent('click', {
                            view: window,
                            bubbles: true,
                            cancelable: true
                        });
                        arguments[0].dispatchEvent(event);
                    """, detail_toggle)
                    time.sleep(0.5)
                
                # Method 4: Toggle display directly via JavaScript
                if not dd_element.is_displayed():
                    LOGGER.info("Forcing display via JavaScript")
                    driver.execute_script("""
                        var dd = arguments[0].querySelector('dl.subDl > dd');
                        if (dd) {
                            dd.style.display = 'block';
                        }
                    """, current_item)
                    time.sleep(0.3)
            
            # Wait for the dd (detail content) to become visible
            LOGGER.info("Waiting for detail content to expand...")
            WebDriverWait(current_item, 10).until(
                lambda item: item.find_element(By.CSS_SELECTOR, "dl.subDl > dd").is_displayed()
            )
            LOGGER.info("Detail content expanded successfully")
            time.sleep(0.5)

            # 2. Find the mailForm container
            mail_form = WebDriverWait(current_item, 10).until(
                lambda item: item.find_element(By.CSS_SELECTOR, "div.mailForm")
            )
            LOGGER.info("Found mailForm container")

            # 3. Select the radio button for the product
            radio_buttons = mail_form.find_elements(By.CSS_SELECTOR, RADIO_BUTTON_SELECTOR)
            if not radio_buttons:
                LOGGER.warning("No radio button found, skipping this item")
                continue
            
            radio_button = radio_buttons[0]
            LOGGER.info("Clicking radio button")
            click_element(driver, radio_button)
            
            # Wait a bit for UI to update
            import time
            time.sleep(0.5)

            # 4. Check the agreement checkbox
            checkboxes = mail_form.find_elements(By.CSS_SELECTOR, CHECKBOX_SELECTOR)
            if not checkboxes:
                LOGGER.warning("No checkbox found, skipping this item")
                continue
                
            checkbox = checkboxes[0]
            if not checkbox.is_selected():
                LOGGER.info("Checking agreement checkbox")
                click_element(driver, checkbox)
                time.sleep(0.5)

            # 5. Click '応募する' (Apply) - First button in mailForm
            apply_links = mail_form.find_elements(By.CSS_SELECTOR, APPLY_LINK_SELECTOR)
            if not apply_links:
                LOGGER.warning("No apply link found, skipping this item")
                continue
                
            apply_link = apply_links[0]
            LOGGER.info("Clicking apply button ('応募する') in mailForm")
            click_element(driver, apply_link)
            
            # Wait for modal/popup to appear
            time.sleep(1)
            
            # 6. Click confirmation button in the popup
            try:
                LOGGER.info("Waiting for confirmation popup...")
                confirm_button = WebDriverWait(driver, 10).until(
                    lambda d: d.find_element(By.CSS_SELECTOR, "a#applyBtn")
                )
                LOGGER.info("Found confirmation button, clicking...")
                
                # Scroll to button
                driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", confirm_button)
                time.sleep(0.3)
                
                # Click confirmation button
                try:
                    confirm_button.click()
                except:
                    LOGGER.info("Regular click failed, using JavaScript")
                    driver.execute_script("arguments[0].click();", confirm_button)
                
                LOGGER.info("Clicked confirmation button")
                time.sleep(1)
                
            except Exception as e:
                LOGGER.warning("Could not find or click confirmation button: %s", e)
            
            # Wait for modal or confirmation
            time.sleep(1)
            
        except Exception as e:
            LOGGER.error("Error processing item '%s': %s", current_title, e)
            continue

        
        LOGGER.info("Application submitted for: %s", current_title)
        processed_titles.add(current_title)


def main() -> int:
    configure_logging()
    args = parse_args()
    driver: Optional[webdriver.Chrome] = None

    try:
        driver = build_driver(args.headless)
        LOGGER.info("Opening %s", args.url)
        driver.get(args.url)
        target_link = find_target_slide_link(driver)
        LOGGER.info("Clicking slide link with data-swiper-slide-index=0")
        click_element(driver, target_link)
        lottery_button = find_visible_element(driver, LOTTERY_BUTTON_SELECTOR)
        LOGGER.info("Clicking lottery button")
        click_element(driver, lottery_button)
        apply_lottery_entries(driver)
        input("Chrome đã mở trang. Nhấn Enter để đóng browser...")
        return 0
    except KeyboardInterrupt:
        LOGGER.warning("Interrupted by user.")
        return 130
    except Exception as exc:
        LOGGER.exception("Failed to open browser: %s", exc)
        return 1
    finally:
        if driver:
            driver.quit()


if __name__ == "__main__":
    sys.exit(main())
