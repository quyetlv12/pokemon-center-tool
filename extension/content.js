// Content script - runs on Pokemon Center Online pages
let isRunning = false;
let processedTitles = new Set();

// Check if bot should auto-resume after page navigation
chrome.storage.local.get(['botRunning', 'botStep'], (result) => {
  if (result.botRunning) {
    isRunning = true;
    log('═══════════════════════════════════════', 'info');
    log('🔄 AUTO-RESUME: Tiếp tục bot sau khi chuyển trang', 'info');
    log(`   Step: ${result.botStep}`, 'info');
    log(`   URL: ${window.location.href}`, 'info');
    log('═══════════════════════════════════════', 'info');
    
    // Wait a bit for page to load
    setTimeout(() => {
      if (result.botStep === 'navigate') {
        log('→ Tiếp tục điều hướng...', 'info');
        updateStatus('Đang điều hướng...', 'info');
        continueNavigation();
      } else if (result.botStep === 'apply') {
        log('→ Bắt đầu đăng ký...', 'info');
        updateStatus('Đang đăng ký...', 'info');
        applyLotteryEntries();
      }
    }, 2000); // Tăng thời gian chờ lên 2s
  }
});

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message) => {
  if (message.action === 'start') {
    isRunning = true;
    chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
    log('Bắt đầu xử lý...', 'info');
    startBot();
  } else if (message.action === 'stop') {
    isRunning = false;
    chrome.storage.local.set({ botRunning: false, botStep: null });
    log('Đã dừng', 'warning');
  }
});

function log(message, level = 'info') {
  console.log(`[Pokemon Bot] ${message}`);
  chrome.runtime.sendMessage({ type: 'log', message, level });
}

function updateStatus(message, level = 'info') {
  chrome.runtime.sendMessage({ type: 'status', message, level });
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitForElement(selector, timeout = 10000) {
  log(`⏳ Đợi element: ${selector} (timeout: ${timeout}ms)`, 'info');
  const startTime = Date.now();
  while (Date.now() - startTime < timeout) {
    const element = document.querySelector(selector);
    if (element && element.offsetParent !== null) {
      log(`✓ Tìm thấy element: ${selector}`, 'success');
      return element;
    }
    await sleep(100);
  }
  log(`✗ Timeout: Không tìm thấy ${selector} sau ${timeout}ms`, 'error');
  throw new Error(`Element not found: ${selector}`);
}

async function waitForVueRender(timeout = 15000) {
  log('Đợi Vue.js render...', 'info');
  const startTime = Date.now();
  
  // First check if container exists
  const container = document.querySelector('ul.comOrderList');
  if (!container) {
    log('⚠ Không tìm thấy container ul.comOrderList', 'warning');
    log('→ Có thể trang bị lỗi hoặc không có quyền truy cập', 'warning');
    return false;
  }
  
  while (Date.now() - startTime < timeout) {
    const innerHTML = container.innerHTML;
    
    // Check if Vue has rendered (no template variables)
    if (!innerHTML.includes('{{')) {
      log('Vue.js đã render xong', 'success');
      await sleep(2000); // Extra wait for stability
      return true;
    }
    
    await sleep(500);
  }
  
  log('⚠ Vue.js render timeout, nhưng tiếp tục thử...', 'warning');
  await sleep(2000);
  return true; // Continue anyway
}

async function clickElement(element) {
  element.scrollIntoView({ block: 'center', behavior: 'smooth' });
  await sleep(300);
  
  try {
    element.click();
  } catch (e) {
    // Fallback to JS click
    element.dispatchEvent(new MouseEvent('click', {
      view: window,
      bubbles: true,
      cancelable: true
    }));
  }
}

async function navigateToLotteryList() {
  const url = window.location.href;
  log(`📍 URL hiện tại: ${url}`, 'info');
  
  // Already on lottery apply page (the actual list page)
  if (url.includes('lottery/apply')) {
    log('✓ Đã ở trang lottery apply', 'success');
    updateStatus('Đã ở trang lottery apply', 'success');
    chrome.storage.local.set({ botStep: 'apply' });
    return true;
  }
  
  // Check if on login page
  if (url.includes('lottery/login')) {
    log('⚠ Đang ở trang login', 'warning');
    updateStatus('Vui lòng đăng nhập rồi chạy lại', 'error');
    chrome.storage.local.set({ botRunning: false, botStep: null });
    throw new Error('Cần đăng nhập trước');
  }
  
  // If on lottery landing page, click the blue button "抽選へ進む"
  if (url.includes('lottery/landing-page')) {
    log('Đang ở trang lottery landing, tìm nút "抽選へ進む"...', 'info');
    updateStatus('Đang tìm nút lottery...', 'info');
    
    try {
      // Look for the blue button
      const lotteryButton = await waitForElement('a.btn-lottery, .btn[href*="lottery"], a[href*="lottery/apply"]', 5000);
      log('✓ Tìm thấy nút, đang click...', 'info');
      
      // Save state before navigation
      chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
      
      await clickElement(lotteryButton);
      await sleep(2000);
      
      if (window.location.href.includes('lottery/apply')) {
        log('✓ Đã đến trang lottery apply', 'success');
        chrome.storage.local.set({ botStep: 'apply' });
        return true;
      }
    } catch (e) {
      log(`⚠ Không tìm thấy nút (${e.message})`, 'warning');
    }
    
    // Fallback: direct navigation
    log('→ Điều hướng trực tiếp đến lottery apply...', 'info');
    chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
    window.location.href = 'https://www.pokemoncenter-online.com/lottery/apply.html';
    // Will resume after page load
    return false;
  }
  
  // If on any other lottery page, try direct navigation
  if (url.includes('lottery/')) {
    log('Đang ở trang lottery, điều hướng trực tiếp đến apply...', 'info');
    updateStatus('Điều hướng đến lottery apply...', 'info');
    chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
    window.location.href = 'https://www.pokemoncenter-online.com/lottery/apply.html';
    // Will resume after page load
    return false;
  }
  
  // On homepage - try to find slide
  log('Đang ở trang chủ, tìm slide lottery...', 'info');
  updateStatus('Đang tìm slide lottery...', 'info');
  
  try {
    const slideLink = await waitForElement('.swiper-slide[data-swiper-slide-index="0"] a', 5000);
    log('✓ Tìm thấy slide, đang click...', 'info');
    
    // Save state before navigation
    chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
    
    await clickElement(slideLink);
    await sleep(2000);
    
    // Check if redirected to login
    if (window.location.href.includes('lottery/login')) {
      log('⚠ Chuyển đến trang login', 'warning');
      updateStatus('Vui lòng đăng nhập rồi chạy lại', 'error');
      chrome.storage.local.set({ botRunning: false, botStep: null });
      throw new Error('Cần đăng nhập');
    }
    
    // If already on apply page, done
    if (window.location.href.includes('lottery/apply')) {
      log('✓ Đã đến trang lottery apply', 'success');
      chrome.storage.local.set({ botStep: 'apply' });
      return true;
    }
    
    // If on landing page, need to click button
    if (window.location.href.includes('lottery/landing-page')) {
      log('Đã đến landing page, tìm nút...', 'info');
      try {
        const lotteryButton = await waitForElement('a.btn-lottery, .btn[href*="lottery"], a[href*="lottery/apply"]', 5000);
        log('✓ Tìm thấy nút, đang click...', 'info');
        chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
        await clickElement(lotteryButton);
        await sleep(2000);
      } catch (e) {
        log('→ Điều hướng trực tiếp...', 'info');
        chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
        window.location.href = 'https://www.pokemoncenter-online.com/lottery/apply.html';
        return false;
      }
      return true;
    }
    
  } catch (e) {
    log(`⚠ Không tìm thấy slide (${e.message})`, 'warning');
  }
  
  // Fallback: direct navigation
  log('→ Điều hướng trực tiếp đến lottery apply...', 'info');
  updateStatus('Điều hướng trực tiếp...', 'info');
  chrome.storage.local.set({ botRunning: true, botStep: 'navigate' });
  window.location.href = 'https://www.pokemoncenter-online.com/lottery/apply.html';
  // Will resume after page load
  return false;
}

async function continueNavigation() {
  const url = window.location.href;
  
  if (url.includes('lottery/apply')) {
    log('✓ Đã đến trang lottery apply, bắt đầu đăng ký', 'success');
    chrome.storage.local.set({ botStep: 'apply' });
    await applyLotteryEntries();
  } else if (url.includes('lottery/landing-page')) {
    log('Đang ở landing page, tiếp tục điều hướng...', 'info');
    await navigateToLotteryList();
  } else {
    log('Trang không đúng, thử điều hướng lại...', 'warning');
    await navigateToLotteryList();
  }
}

async function applyLotteryEntries() {
  try {
    // Mark that we're in apply phase
    chrome.storage.local.set({ botStep: 'apply' });
    
    // Check for access denied error
    const errorElement = document.querySelector('Error, Message');
    if (errorElement) {
      const errorText = document.body.textContent;
      if (errorText.includes('Access Denied') || errorText.includes('AccessDenied')) {
        log('❌ Lỗi: Access Denied - Không có quyền truy cập', 'error');
        updateStatus('Lỗi: Không có quyền truy cập trang này', 'error');
        log('→ Vui lòng đăng nhập và vào trang lottery list thủ công trước', 'warning');
        chrome.storage.local.set({ botRunning: false, botStep: null });
        chrome.runtime.sendMessage({ type: 'complete' });
        return;
      }
    }
    
    // Wait for Vue to render
    log('⏳ Đợi Vue.js render...', 'info');
    const rendered = await waitForVueRender();
    
    if (!rendered) {
      log('❌ Không thể render trang', 'error');
      updateStatus('Lỗi: Trang không load được', 'error');
      chrome.storage.local.set({ botRunning: false, botStep: null });
      chrome.runtime.sendMessage({ type: 'complete' });
      return;
    }
    
    // Find all lottery items
    const items = document.querySelectorAll('ul.comOrderList > li');
    
    if (items.length === 0) {
      log('❌ Không tìm thấy item nào', 'error');
      updateStatus('Không tìm thấy lottery items', 'error');
      log('→ Có thể bạn chưa có quyền truy cập hoặc không có lottery nào', 'warning');
      chrome.storage.local.set({ botRunning: false, botStep: null });
      chrome.runtime.sendMessage({ type: 'complete' });
      return;
    }
    
    log(`✓ Tìm thấy ${items.length} items`, 'success');
    updateStatus(`Đang xử lý ${items.length} items...`, 'info');
    
    let successCount = 0;
    let skipCount = 0;
    let errorCount = 0;
    
    for (let i = 0; i < items.length && isRunning; i++) {
      const item = items[i];
      
      // Get title - try multiple selectors like Python script
      let title = '';
      
      // Method 1: div.lBox > p
      let titleElem = item.querySelector('div.lBox > p');
      if (titleElem && titleElem.textContent.trim()) {
        title = titleElem.textContent.trim();
      }
      
      // Method 2: .lBox p
      if (!title) {
        titleElem = item.querySelector('.lBox p');
        if (titleElem && titleElem.textContent.trim()) {
          title = titleElem.textContent.trim();
        }
      }
      
      // Method 3: ul.waresUl p.name
      if (!title) {
        titleElem = item.querySelector('ul.waresUl p.name');
        if (titleElem && titleElem.textContent.trim()) {
          title = titleElem.textContent.trim();
        }
      }
      
      // Method 4: Any p tag with substantial text
      if (!title) {
        const allPs = item.querySelectorAll('p');
        for (const p of allPs) {
          const text = p.textContent.trim();
          if (text && text.length > 10) {
            title = text;
            break;
          }
        }
      }
      
      // Fallback
      if (!title) {
        title = `Item ${i + 1}`;
      }
      
      log(`─────────────────────────────`, 'info');
      log(`📦 [${i + 1}/${items.length}] ${title}`, 'info');
      
      // Check if accepting - like Python script
      const statusElem = item.querySelector('div.acceptBox');
      if (!statusElem) {
        log('⚠ Không tìm thấy status box, bỏ qua', 'warning');
        skipCount++;
        continue;
      }
      
      const statusClass = statusElem.className;
      const statusText = statusElem.textContent;
      
      // Check both class and text like Python
      const isAccepting = statusClass.includes('accepting') || statusText.includes('受付中');
      
      if (!isAccepting) {
        log('⏸ Không đang nhận đơn, bỏ qua', 'warning');
        skipCount++;
        continue;
      }
      
      if (processedTitles.has(title)) {
        log('✓ Đã xử lý rồi, bỏ qua', 'warning');
        skipCount++;
        continue;
      }
      
      try {
        // 1. Click "詳しく見る" (Detail Toggle) - dl.subDl > dt
        const detailToggle = item.querySelector('dl.subDl > dt');
        if (!detailToggle) {
          log('❌ Không tìm thấy nút chi tiết', 'error');
          errorCount++;
          continue;
        }
        
        log('  → Click "詳しく見る"...', 'info');
        
        // Scroll into view
        detailToggle.scrollIntoView({ block: 'center', behavior: 'smooth' });
        await sleep(300);
        
        // Check if dd is already visible
        const dd = item.querySelector('dl.subDl > dd');
        const isVisible = dd && dd.offsetParent !== null;
        
        if (!isVisible) {
          // Try multiple click methods like Python
          try {
            detailToggle.click();
            await sleep(500);
          } catch (e) {
            log('  → Regular click failed, trying JS click', 'warning');
            detailToggle.dispatchEvent(new MouseEvent('click', {
              view: window,
              bubbles: true,
              cancelable: true
            }));
            await sleep(500);
          }
          
          // Force display if still not visible
          if (dd && dd.offsetParent === null) {
            log('  → Force mở chi tiết...', 'warning');
            dd.style.display = 'block';
            await sleep(300);
          }
        }
        
        // Wait for detail to be visible
        const startTime = Date.now();
        while (Date.now() - startTime < 10000) {
          if (dd && dd.offsetParent !== null) {
            break;
          }
          await sleep(100);
        }
        
        if (!dd || dd.offsetParent === null) {
          log('❌ Không thể mở chi tiết', 'error');
          errorCount++;
          continue;
        }
        
        log('  → Chi tiết đã mở', 'success');
        await sleep(500);
        
        // 2. Find mailForm
        const mailForm = item.querySelector('div.mailForm');
        if (!mailForm) {
          log('❌ Không tìm thấy form', 'error');
          errorCount++;
          continue;
        }
        
        // 3. Click radio button
        const radio = mailForm.querySelector('input[type="radio"]');
        if (!radio) {
          log('❌ Không tìm thấy radio button', 'error');
          errorCount++;
          continue;
        }
        
        log('  → Chọn sản phẩm...', 'info');
        await clickElement(radio);
        await sleep(500);
        
        // 4. Check checkbox
        const checkbox = mailForm.querySelector('input[type="checkbox"]');
        if (!checkbox) {
          log('❌ Không tìm thấy checkbox', 'error');
          errorCount++;
          continue;
        }
        
        if (!checkbox.checked) {
          log('  → Đồng ý điều khoản...', 'info');
          await clickElement(checkbox);
          await sleep(500);
        }
        
        // 5. Click apply button (a.popup-modal in mailForm)
        const applyBtn = mailForm.querySelector('a.popup-modal');
        if (!applyBtn) {
          log('❌ Không tìm thấy nút đăng ký', 'error');
          errorCount++;
          continue;
        }
        
        log('  → Click "応募する"...', 'info');
        await clickElement(applyBtn);
        await sleep(1500);
        
        // 6. Click confirmation button (a#applyBtn) - like Python script
        try {
          log('  → Đợi popup xác nhận...', 'info');
          const confirmBtn = await waitForElement('a#applyBtn', 2000);
          if (confirmBtn) {
            log('  → Tìm thấy nút xác nhận, đang click...', 'info');
            
            // Scroll to button
            confirmBtn.scrollIntoView({ block: 'center' });
            await sleep(300);
            
            // Click
            try {
              confirmBtn.click();
            } catch (e) {
              log('  → Regular click failed, using JS', 'warning');
              confirmBtn.dispatchEvent(new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true
              }));
            }
            
            log('  → Đã click xác nhận', 'success');
            await sleep(1000);
          }
        } catch (e) {
          // Confirmation popup might not appear
          log('  → Không có popup xác nhận (có thể đã submit)', 'info');
        }
        
        log(`✅ Đã đăng ký: ${title}`, 'success');
        processedTitles.add(title);
        successCount++;
        
      } catch (error) {
        log(`❌ Lỗi: ${error.message}`, 'error');
        errorCount++;
      }
      
      await sleep(500);
    }
    
    log('═══════════════════════════════════════', 'success');
    log(`🎉 Hoàn thành!`, 'success');
    log(`  ✅ Thành công: ${successCount}`, 'success');
    log(`  ⏸ Bỏ qua: ${skipCount}`, 'warning');
    log(`  ❌ Lỗi: ${errorCount}`, errorCount > 0 ? 'error' : 'info');
    log('═══════════════════════════════════════', 'success');
    
    updateStatus(`Hoàn thành! Đã đăng ký ${successCount}/${items.length} items`, 'success');
    
    // Clear bot state
    chrome.storage.local.set({ botRunning: false, botStep: null });
    chrome.runtime.sendMessage({ type: 'complete' });
    
  } catch (error) {
    log(`❌ Lỗi nghiêm trọng: ${error.message}`, 'error');
    updateStatus(`Lỗi: ${error.message}`, 'error');
    chrome.storage.local.set({ botRunning: false, botStep: null });
    chrome.runtime.sendMessage({ type: 'complete' });
  }
}

async function startBot() {
  try {
    log('═══════════════════════════════════════', 'info');
    log('🚀 Bắt đầu Pokemon Center Bot', 'info');
    log('═══════════════════════════════════════', 'info');
    
    const currentUrl = window.location.href;
    log(`📍 URL hiện tại: ${currentUrl}`, 'info');
    
    // If already on lottery apply page, skip navigation
    if (currentUrl.includes('lottery/apply')) {
      log('✓ Đã ở trang lottery apply, bỏ qua điều hướng', 'success');
      chrome.storage.local.set({ botStep: 'apply' });
    } else {
      // Navigate to lottery apply page
      log('📍 Bắt đầu điều hướng đến lottery apply', 'info');
      updateStatus('Đang điều hướng...', 'info');
      
      const navigated = await navigateToLotteryList();
      
      // If navigation caused page reload, stop here (will resume after reload)
      if (!navigated) {
        log('⏳ Đang chuyển trang, sẽ tiếp tục sau khi load...', 'info');
        return;
      }
      
      // Wait for page to load completely
      log('⏳ Đợi trang load...', 'info');
      await sleep(2000);
      
      // Verify we're on the right page
      if (!window.location.href.includes('lottery/apply')) {
        throw new Error('Không thể đến trang lottery apply');
      }
      
      log('✓ Đã đến trang lottery apply', 'success');
    }
    
    // Apply for lottery entries
    log('📝 Bắt đầu đăng ký lottery', 'info');
    updateStatus('Đang đăng ký...', 'info');
    
    await applyLotteryEntries();
    
  } catch (error) {
    log('═══════════════════════════════════════', 'error');
    log(`❌ Lỗi: ${error.message}`, 'error');
    log('═══════════════════════════════════════', 'error');
    updateStatus(`Lỗi: ${error.message}`, 'error');
    chrome.storage.local.set({ botRunning: false, botStep: null });
    chrome.runtime.sendMessage({ type: 'complete' });
  }
}

// Auto-detect if on lottery page
if (window.location.href.includes('pokemoncenter-online.com')) {
  log('Extension đã load', 'info');
}
