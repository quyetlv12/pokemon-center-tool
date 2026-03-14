// Background service worker
chrome.runtime.onInstalled.addListener(() => {
  console.log('Pokemon Center Bot extension installed');
});

// Open side panel when extension icon is clicked
chrome.action.onClicked.addListener(async (tab) => {
  // Open the side panel
  await chrome.sidePanel.open({ tabId: tab.id });
});

// Handle messages from content script and popup
chrome.runtime.onMessage.addListener((message) => {
  // Forward messages between content script and popup
  if (message.type === 'log' || message.type === 'status' || message.type === 'complete') {
    // Broadcast to all extension pages (popup)
    chrome.runtime.sendMessage(message).catch(() => {
      // Popup might be closed, ignore error
    });
  }
});
