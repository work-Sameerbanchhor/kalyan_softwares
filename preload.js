const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    // Discovery communication
    onDiscoveryStatus: (callback) => ipcRenderer.on('discovery-status', (_event, value) => callback(value)),
    
    // Status updates
    updateStatus: (status) => ipcRenderer.send('update-status', status),
    
    // Retry discovery
    retryDiscovery: () => ipcRenderer.send('retry-discovery'),
    
    // Server connection
    connectToServer: (serverUrl) => ipcRenderer.send('connect-server', serverUrl),
    
    // Basic system info (safe)
    getAppVersion: () => process.env.npm_package_version || '1.0.0',
});

console.log('Kalyan Secure Bridge Initialized');
