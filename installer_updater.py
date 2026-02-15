#!/usr/bin/env python3
import sys
import os
import requests
from pathlib import Path
from threading import Thread
from PySide6 import QtCore, QtWidgets, QtGui

# ---------------- CONFIG ------------------

DOWNLOAD_DIR = Path.cwd() / "WinDownloads"
DOWNLOAD_DIR.mkdir(exist_ok=True)

LAUNCHER_EXE = DOWNLOAD_DIR / "win_launcher.exe"
VERSION_FILE = DOWNLOAD_DIR / "version_win_launcher.txt"

URL_LAUNCHER = "https://github.com/acierto-incomodo/ScamLine/releases/latest/download/launcher_win.exe"
URL_VERSION  = "https://github.com/acierto-incomodo/ScamLine/releases/latest/download/version_win_launcher.txt"

# ---------------- Utils -------------------

def download(url: str, dest: Path, progress_callback=None):
    resp = requests.get(url, stream=True, timeout=60)
    resp.raise_for_status()

    total = resp.headers.get("content-length")
    total = int(total) if total and total.isdigit() else None

    with open(dest, "wb") as f:
        downloaded = 0
        for chunk in resp.iter_content(chunk_size=8192):
            if not chunk:
                continue
            f.write(chunk)
            downloaded += len(chunk)
            if progress_callback and total:
                progress_callback(int(downloaded * 100 / total))

# ---------------- GUI ----------------------

class UpdaterWindow(QtWidgets.QWidget):

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Launcher Updater")
        self.setMinimumSize(500, 125)
        self.setMaximumSize(500, 125)

        self.setup_ui()
        self.start_check()

    def setup_ui(self):
        layout = QtWidgets.QVBoxLayout(self)

        title = QtWidgets.QLabel("Actualizando Launcher…")
        title.setAlignment(QtCore.Qt.AlignCenter)
        title.setStyleSheet("font-size:22px; font-weight:bold;")
        layout.addWidget(title)

        self.status = QtWidgets.QLabel("Comprobando versión…")
        self.status.setAlignment(QtCore.Qt.AlignCenter)
        layout.addWidget(self.status)

        self.progress = QtWidgets.QProgressBar()
        self.progress.setRange(0, 100)
        layout.addWidget(self.progress)

        self.version_display = QtWidgets.QLabel("", alignment=QtCore.Qt.AlignCenter)
        self.version_display.setStyleSheet("font-weight:bold; font-size:14px; margin-top:8px;")
        layout.addWidget(self.version_display)

        layout.addStretch()

    def set_status(self, text):
        self.status.setText(text)

    # ---------------- VERSION CHECK ----------------

    def start_check(self):
        Thread(target=self._check_thread, daemon=True).start()

    def _check_thread(self):
        try:
            resp = requests.get(URL_VERSION, timeout=30)
            resp.raise_for_status()
            remote_version = resp.text.strip()
        except Exception as e:
            self.error(f"Error obteniendo versión: {e}")
            return

        QtCore.QMetaObject.invokeMethod(
            self, "check_local_version",
            QtCore.Qt.QueuedConnection,
            QtCore.Q_ARG(str, remote_version)
        )

    @QtCore.Slot(str)
    def check_local_version(self, remote_version):
        self.version_display.setText(f"Versión disponible: {remote_version}")

        local_version = None
        if VERSION_FILE.exists():
            local_version = VERSION_FILE.read_text().strip()

        # Si ya está la última versión → ejecutar
        if local_version == remote_version and LAUNCHER_EXE.exists():
            self.set_status("Launcher actualizado. Iniciando…")
            self.progress.setValue(100)
            QtCore.QTimer.singleShot(1000, self.run_launcher)
            return

        # Si no → descargar
        self.set_status("Descargando actualización…")
        Thread(target=self.download_update, args=(remote_version,), daemon=True).start()

    # ---------------- DOWNLOAD ----------------

    def download_update(self, remote_version):
        try:
            # descargar version
            download(URL_VERSION, VERSION_FILE)

            # descargar exe
            download(URL_LAUNCHER, LAUNCHER_EXE,
                     lambda p: QtCore.QMetaObject.invokeMethod(
                         self.progress, "setValue",
                         QtCore.Qt.QueuedConnection,
                         QtCore.Q_ARG(int, p)
                     ))

            QtCore.QMetaObject.invokeMethod(
                self, "download_done",
                QtCore.Qt.QueuedConnection
            )

        except Exception as e:
            self.error(f"Error de descarga: {e}")

    @QtCore.Slot()
    def download_done(self):
        self.set_status("Actualización instalada. Iniciando…")
        self.progress.setValue(100)
        QtCore.QTimer.singleShot(1000, self.run_launcher)

    # ---------------- RUN ----------------

    @QtCore.Slot()
    def run_launcher(self):
        try:
            os.startfile(str(LAUNCHER_EXE))
        except Exception as e:
            self.error(f"No se pudo iniciar el launcher: {e}")
            return
        self.close()

    # ---------------- ERROR ----------------

    def error(self, msg):
        self.set_status(msg)

# ---------------- MAIN ----------------------

def main():
    app = QtWidgets.QApplication(sys.argv)
    w = UpdaterWindow()
    w.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
