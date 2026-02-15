./Clear.ps1
cp main.py launcher_win.py
python -m PyInstaller --onefile --windowed --noconsole --icon=ScamLine.ico launcher_win.py
python -m PyInstaller --onefile --windowed --noconsole --icon=ScamLine.ico installer_updater.py
echo 1.0.0 > version_win_launcher.txt