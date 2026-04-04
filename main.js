const { app, BrowserWindow, ipcMain, session } = require('electron');
const path = require('path');
const Bonjour = require('bonjour-service').default;

const bonjour = new Bonjour();
let mainWindow;
let discoveryTimeout;
const DISCOVERY_TIMEOUT_MS = 15000;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        fullscreen: true,
        title: "Kalyan Smart Student System",
        icon: path.join(__dirname, 'media', 'kalyan_college_logo.png'),
        show: false,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            contextIsolation: true,
            nodeIntegration: false,
        },
    });

    mainWindow.loadFile('loading.html');

    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
        startDiscovery();
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

function startDiscovery() {
    if (!mainWindow) return;

    mainWindow.webContents.send('discovery-status', { state: 'searching', message: 'Scanning local campus network...' });

    // Reset timeout
    if (discoveryTimeout) clearTimeout(discoveryTimeout);
    discoveryTimeout = setTimeout(() => {
        mainWindow.webContents.send('discovery-status', { state: 'timeout', message: 'Server not found on local network.' });
        console.log('[Discovery] Timeout reached. Server not found.');
    }, DISCOVERY_TIMEOUT_MS);

    // Start mDNS browsing
    const browser = bonjour.find({ type: 'http' });

    browser.on('up', (service) => {
        console.log('[Discovery] Service found:', service.name, service.host, service.port);

        // Filter for KalyanScanner
        if (service.name.includes('KalyanScanner')) {
            clearTimeout(discoveryTimeout);
            const ip = service.addresses[0];
            const port = service.port;
            const serverUrl = `http://${ip}:${port}`;

            mainWindow.webContents.send('discovery-status', { state: 'found', message: `Server identified. Connecting...` });
            console.log(`[Discovery] Success! Connecting to ${serverUrl}`);

            // Redirect after a short delay for visual feedback
            setTimeout(() => {
                mainWindow.loadURL(serverUrl).catch(err => {
                    console.error('[Discovery] Failed to load server URL:', err);
                    mainWindow.webContents.send('discovery-status', { state: 'error', message: 'Failed to connect to identified server.' });
                });
            }, 3000);
            
            browser.stop();
        }
    });
}

app.whenReady().then(() => {
    console.log('Kalyan Smart Student System Starting...');

    // INJECT THE SECRET HEADER FOR ALL REQUESTS
    session.defaultSession.webRequest.onBeforeSendHeaders((details, callback) => {
        details.requestHeaders['X-Kalyan-App-Auth'] = 'Kalyan_Secure_Access_2026_##';
        callback({ requestHeaders: details.requestHeaders });
    });

    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });

    // Handle retry from UI
    ipcMain.on('retry-discovery', () => {
        console.log('[Discovery] Manual retry triggered by user.');
        startDiscovery();
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// IPC Listeners
ipcMain.on('update-status', (event, status) => {
    console.log(`[Status Update] ${status}`);
});
