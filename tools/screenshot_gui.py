"""Open the launcher and each ported panel, run its default case, save
screenshots and exit. Used to check the GUI renders without a human.

    python tools/screenshot_gui.py out_dir [panel ...]     (panels: hydrofrac thermal)
"""
from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QTimer
from PySide6.QtWidgets import QApplication

from geomech.gui.app import Launcher
from geomech.gui.hydrofrac_panel import HydrofracPanel
from geomech.gui.thermal_panel import ThermalPanel


def hydrofrac_steps(out: Path):
    panel = HydrofracPanel()
    panel.resize(1200, 720)
    panel.show()

    def s1():
        panel.run()
        panel.grab().save(str(out / "hydrofrac_history.png"))
        panel.plot_profile()
        panel.grab().save(str(out / "hydrofrac_profile.png"))
        panel.plot_3d()
        panel.grab().save(str(out / "hydrofrac_3d.png"))
        panel.close()

    return panel, [s1]


def thermal_steps(out: Path):
    panel = ThermalPanel()
    panel.resize(1200, 720)
    panel.show()

    def s1():
        panel.rb_model["gringarten"].setChecked(True)
        panel.calculate()
        panel.grab().save(str(out / "thermal_field.png"))
        panel.plot_profile()
        panel.ov_box["Q_m"].setChecked(True)
        panel.ov_edit["Q_m"].setText("80")
        panel.plot_profile()
        panel.grab().save(str(out / "thermal_profile.png"))
        panel.close()

    return panel, [s1]


def mohr_steps(out: Path):
    from geomech.gui.mohr_panel import MohrPanel
    panel = MohrPanel()
    panel.resize(1100, 700)
    panel.show()

    def s1():
        panel.add_plot()
        panel.grab().save(str(out / "mohr_2d.png"))
        panel.view_3d()
        panel.grab().save(str(out / "mohr_3d.png"))
        panel.close()

    return panel, [s1]


def anisotropy_steps(out: Path):
    from geomech.gui.anisotropy_panel import AnisotropyPanel
    panel = AnisotropyPanel()
    panel.resize(1000, 600)
    panel.show()

    def s1():
        panel.add_plot()
        panel.fields["sigma_3"].setText("15")
        panel.add_plot()
        panel.grab().save(str(out / "anisotropy.png"))
        panel.close()

    return panel, [s1]


SCENARIOS = {"hydrofrac": hydrofrac_steps, "thermal": thermal_steps,
             "mohr": mohr_steps, "anisotropy": anisotropy_steps}


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    names = sys.argv[2:] or list(SCENARIOS)
    out.mkdir(parents=True, exist_ok=True)
    app = QApplication(sys.argv)
    launcher = Launcher()
    launcher.resize(520, 360)
    launcher.show()
    queue = [(name, SCENARIOS[name]) for name in names]
    keep = []

    def run_next():
        if not queue:
            launcher.grab().save(str(out / "launcher.png"))
            print("screenshots written to", out)
            app.quit()
            return
        name, factory = queue.pop(0)
        panel, steps = factory(out)
        keep.append(panel)

        def run_steps(i=0):
            if i < len(steps):
                steps[i]()
                QTimer.singleShot(300, lambda: run_steps(i + 1))
            else:
                QTimer.singleShot(200, run_next)

        QTimer.singleShot(400, run_steps)

    QTimer.singleShot(400, run_next)
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
