const { app, BrowserWindow, ipcMain, session, Menu } = require('electron');
const path = require('path');
let mainWindow;

function createWindow() {
    // Remove the application menu bar entirely (File, Edit, View, etc.)
    Menu.setApplicationMenu(null);

    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        fullscreen: true,
        autoHideMenuBar: true,
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

    mainWindow.webContents.send('discovery-status', { state: 'found', message: `Connecting to Cloud Server...` });
    console.log(`[Connection] Connecting to https://sameerbanchhor-work-kalyan-pg-system.hf.space/`);

    // Redirect after a short delay for visual feedback
    setTimeout(() => {
        mainWindow.loadURL('https://sameerbanchhor-work-kalyan-pg-system.hf.space/').catch(err => {
            console.error('[Connection] Failed to load server URL:', err);
            mainWindow.webContents.send('discovery-status', { state: 'error', message: 'Failed to connect to cloud server.' });
        });
    }, 2000);
}

app.whenReady().then(() => {
    console.log('Kalyan Smart Student System Starting...');

    // INJECT THE SECRET HEADER FOR ALL REQUESTS
    session.defaultSession.webRequest.onBeforeSendHeaders((details, callback) => {
        details.requestHeaders['X-Kalyan-App-Auth'] = 'KalyanSecureAccess2026';
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
