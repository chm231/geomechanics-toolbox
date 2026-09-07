"""Open the launcher and the Hydrofracturing panel, run the default case,
save screenshots and exit. Used to check the GUI renders without a human.

    python tools/screenshot_gui.py out_dir
"""
from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QTimer
from PySide6.QtWidgets import QApplication

from geomech.gui.app import Launcher
from geomech.gui.hydrofrac_panel import HydrofracPanel


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    out.mkdir(parents=True, exist_ok=True)
    app = QApplication(sys.argv)
    launcher = Launcher()
    launcher.resize(520, 360)
    launcher.show()
    panel = HydrofracPanel()
    panel.resize(1200, 720)
    panel.show()

    def step1():
        panel.run()
        QTimer.singleShot(300, step2)

    def step2():
        launcher.grab().save(str(out / "launcher.png"))
        panel.grab().save(str(out / "hydrofrac_history.png"))
        panel.plot_profile()
        QTimer.singleShot(300, step3)

    def step3():
        panel.grab().save(str(out / "hydrofrac_profile.png"))
        panel.plot_3d()
        QTimer.singleShot(600, step4)

    def step4():
        panel.grab().save(str(out / "hydrofrac_3d.png"))
        print("screenshots written to", out)
        app.quit()

    QTimer.singleShot(500, step1)
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
