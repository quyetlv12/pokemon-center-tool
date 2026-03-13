#!/usr/bin/env python3
from __future__ import annotations

import argparse
import logging
import sys
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
TARGET_SLIDE_SELECTOR = '.swiper-slide[data-swiper-slide-index="0"] a'
LOTTERY_BUTTON_SELECTOR = ".comBtn.fixBtn a.goLotteryBtn"
LOTTERY_ITEM_SELECTOR = "ul.comOrderList > li"
LOTTERY_TITLE_SELECTOR = ".lBox p"
DETAIL_TOGGLE_SELECTOR = "dl.subDl > dt"
CANCEL_LINK_SELECTOR = "ul.linkList01 a.popup-modal"
MODAL_CANCEL_BUTTON_SELECTOR = "#cancelBtn"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Open Pokemon Center Online in Chrome."
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


def detect_chrome_binary() -> Optional[str]:
    candidates = (
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/usr/bin/google-chrome",
        "/usr/bin/google-chrome-stable",
        "/usr/bin/chromium",
        "/usr/bin/chromium-browser",
    )
    for candidate in candidates:
        if Path(candidate).exists():
            return candidate
    return None


def build_driver(headless: bool) -> webdriver.Chrome:
    options = ChromeOptions()
    binary = detect_chrome_binary()
    if binary:
        options.binary_location = binary
    options.add_argument("--start-maximized")
    options.add_argument("--disable-dev-shm-usage")
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


def cancel_lottery_entries(driver: webdriver.Chrome) -> None:
    processed_titles: set[str] = set()

    while True:
        items = driver.find_elements(By.CSS_SELECTOR, LOTTERY_ITEM_SELECTOR)
        current_item: Optional[WebElement] = None
        current_title = ""

        for item in items:
            title_elements = item.find_elements(By.CSS_SELECTOR, LOTTERY_TITLE_SELECTOR)
            title = title_elements[0].text.strip() if title_elements else ""
            if not title or title in processed_titles:
                continue
            if item.find_elements(By.CSS_SELECTOR, CANCEL_LINK_SELECTOR):
                current_item = item
                current_title = title
                break

        if not current_item:
            LOGGER.info("No more lottery entries to cancel.")
            return

        LOGGER.info("Processing lottery entry: %s", current_title)

        detail_toggle = current_item.find_element(By.CSS_SELECTOR, DETAIL_TOGGLE_SELECTOR)
        click_element(driver, detail_toggle)

        cancel_link = WebDriverWait(driver, 10).until(
            lambda current_driver: next(
                (
                    element
                    for element in current_item.find_elements(By.CSS_SELECTOR, CANCEL_LINK_SELECTOR)
                    if element.is_displayed()
                ),
                None,
            )
        )
        click_element(driver, cancel_link)

        modal_cancel_button = find_visible_element(driver, MODAL_CANCEL_BUTTON_SELECTOR)
        click_element(driver, modal_cancel_button)

        WebDriverWait(driver, 10).until(
            lambda current_driver: not any(
                element.is_displayed()
                for element in current_driver.find_elements(
                    By.CSS_SELECTOR, MODAL_CANCEL_BUTTON_SELECTOR
                )
            )
        )
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
        cancel_lottery_entries(driver)
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
