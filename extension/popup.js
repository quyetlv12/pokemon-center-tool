// Popup script
let isRunning = false;

const statusDiv = document.getElementById('status');
const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const clearLogBtn = document.getElementById('clearLogBtn');
const logDiv = document.getElementById('log');

// Load logs from storage
chrome.storage.local.get(['logs'], (result) => {
  if (result.logs) {
    result.logs.forEach(log => addLog(log.message, log.type));
  }
});

// Start button
startBtn.addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  if (!tab.url.includes('pokemoncenter-online.com')) {
    updateStatus('Vui lòng mở trang Pokemon Center Online', 'error');
    return;
  }
  
  isRunning = true;
  startBtn.style.display = 'none';
  stopBtn.style.display = 'block';
  updateStatus('Đang chạy...', 'info');
  
  // Send message to content script
  chrome.tabs.sendMessage(tab.id, { action: 'start' });
});

// Stop button
stopBtn.addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  isRunning = false;
  stopBtn.style.display = 'none';
  startBtn.style.display = 'block';
  updateStatus('Đã dừng', 'warning');
  
  chrome.tabs.sendMessage(tab.id, { action: 'stop' }).catch(() => {
    // Tab might not have content script
  });
});

// Clear log button
clearLogBtn.addEventListener('click', () => {
  logDiv.innerHTML = '';
  chrome.storage.local.set({ logs: [] });
});

// Listen for messages from content script
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'log') {
    addLog(message.message, message.level);
  } else if (message.type === 'status') {
    updateStatus(message.message, message.level);
  } else if (message.type === 'complete') {
    isRunning = false;
    stopBtn.style.display = 'none';
    startBtn.style.display = 'block';
    updateStatus('Hoàn thành!', 'success');
  }
});

function updateStatus(message, type = 'info') {
  statusDiv.textContent = message;
  statusDiv.className = `status ${type}`;
}

function addLog(message, type = 'info') {
  const entry = document.createElement('div');
  entry.className = `log-entry ${type}`;
  const time = new Date().toLocaleTimeString();
  entry.textContent = `[${time}] ${message}`;
  logDiv.appendChild(entry);
  logDiv.scrollTop = logDiv.scrollHeight;
  
  // Save to storage
  chrome.storage.local.get(['logs'], (result) => {
    const logs = result.logs || [];
    logs.push({ message, type, time });
    // Keep only last 100 logs
    if (logs.length > 100) logs.shift();
    chrome.storage.local.set({ logs });
  });
}
