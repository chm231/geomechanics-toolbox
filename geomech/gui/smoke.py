"""Open every module window, run its default computation and close it again.

    geomech --smoke-test                          exit code 0 when every module ran
    python tools/screenshot_gui.py out_dir [...]  same steps, saving a screenshot per view

Used to check a build (the frozen exe included) without a human clicking through it.
"""
from __future__ import annotations

import sys
import traceback
from pathlib import Path

import numpy as np
from PySide6.QtCore import QTimer
from PySide6.QtWidgets import QApplication

from geomech.gui import worker


def _grab(widget, out: Path | None, name: str):
    if out is not None:
        widget.grab().save(str(out / f"{name}.png"))


def hydrofrac_steps(out):
    from geomech.gui.hydrofrac_panel import HydrofracPanel
    panel = HydrofracPanel()
    panel.resize(1200, 720)
    panel.show()

    def s1():
        panel.run()
        _grab(panel, out, "hydrofrac_history")
        panel.plot_profile()
        _grab(panel, out, "hydrofrac_profile")
        panel.plot_3d()
        _grab(panel, out, "hydrofrac_3d")
        panel.close()

    return panel, [s1]


def thermal_steps(out):
    from geomech.gui.thermal_panel import ThermalPanel
    panel = ThermalPanel()
    panel.resize(1200, 720)
    panel.show()

    def s1():
        panel.rb_model["gringarten"].setChecked(True)
        panel.calculate()
        _grab(panel, out, "thermal_field")
        panel.plot_profile()
        panel.ov_box["Q_m"].setChecked(True)
        panel.ov_edit["Q_m"].setText("80")
        panel.plot_profile()
        _grab(panel, out, "thermal_profile")
        panel.close()

    return panel, [s1]


def mohr_steps(out):
    from geomech.gui.mohr_panel import MohrPanel
    panel = MohrPanel()
    panel.resize(1100, 700)
    panel.show()

    def s1():
        panel.add_plot()
        _grab(panel, out, "mohr_2d")
        panel.view_3d()
        _grab(panel, out, "mohr_3d")
        panel.close()

    return panel, [s1]


def anisotropy_steps(out):
    from geomech.gui.anisotropy_panel import AnisotropyPanel
    panel = AnisotropyPanel()
    panel.resize(1000, 600)
    panel.show()

    def s1():
        panel.add_plot()
        panel.fields["sigma_3"].setText("15")
        panel.add_plot()
        _grab(panel, out, "anisotropy")
        panel.close()

    return panel, [s1]


def borehole_steps(out):
    from geomech.gui.borehole_panel import BoreholePanel
    panel = BoreholePanel()
    panel.resize(1300, 800)
    panel.show()

    def s1():
        panel.cb_fluid.setChecked(True); panel.in_Pmud.setText("15")
        panel.cb_fail.setChecked(True)
        panel.run()
        _grab(panel, out, "borehole_contour")
        panel.in_loc_r.setText("0.1"); panel.in_loc_th.setText("90")
        panel.local_analysis()
        _grab(panel, out, "borehole_local")
        panel.rb_all.setChecked(True)
        panel.run()
        _grab(panel, out, "borehole_ucs")
        panel.tabs.setCurrentWidget(panel.plot_obb)
        _grab(panel, out, "borehole_obb")
        panel.rb_one.setChecked(True); panel.rb_fem.setChecked(True)
        panel.run()
        _grab(panel, out, "borehole_fem")
        panel.close()

    return panel, [s1]


def hydroshear_steps(out):
    from geomech.gui.hydroshear_panel import HydroshearPanel
    panel = HydroshearPanel()
    panel.resize(1300, 820)
    panel.show()

    def s1():
        panel.add_joint()
        panel.in_dip.setText("75.29"); panel.in_dd.setText("151.94"); panel.add_joint()
        panel.quick_run()
        panel.advanced_run()
        for key in ("pcm", "pc", "pco", "grad"):
            panel.tabs.setCurrentWidget(panel.plots[key]); _grab(panel, out, f"hydroshear_{key}")
        panel.close()

    return panel, [s1]


def _example_dips() -> np.ndarray:
    """The stereonet example data set when the source tree is around, else a synthetic
    three-set sample (the frozen exe carries no data files)."""
    from geomech.core import stereonet as st
    src = Path(__file__).resolve().parents[2] / "src" / "stereo_exmapledata" / "exampleData.txt"
    if src.exists():
        return st.load_dip_file(src)
    rng = np.random.default_rng(0)
    sets = [(60, 120, 100), (30, 300, 90), (80, 30, 96)]
    return np.vstack([np.column_stack([np.clip(rng.normal(d, 6, n), 0, 90), (rng.normal(dd, 8, n)) % 360]) for d, dd, n in sets])


def stereonet_steps(out):
    from geomech.gui.stereonet_panel import StereonetPanel
    panel = StereonetPanel()
    panel.resize(1300, 820)
    panel.show()

    def s1():
        panel.set_data(_example_dips())
        panel.pole_plot()
        panel.cb_net.setChecked(True)
        panel._circles.append((np.deg2rad(60), np.deg2rad(120))); panel._refresh_list(); panel.redraw()
        _grab(panel, out, "stereonet_poles")
        panel.cb_net.setChecked(False)
        panel.mean_direction()
        panel.cluster()
        _grab(panel, out, "stereonet_sets")
        panel.cb_contour.setChecked(True)
        _grab(panel, out, "stereonet_contour")
        panel.rose()
        _grab(panel, out, "stereonet_rose")
        panel.close()

    return panel, [s1]


def dfn_steps(out):
    from geomech.gui.dfn_panel import DFNPanel
    win = DFNPanel()
    win.resize(1400, 860)
    win.show()
    panel = win.toolbox

    def s1():
        win.setCurrentWidget(panel)
        panel.generate()
        _grab(win, out, "dfn_3d")
        panel.verification()
        _grab(win, out, "dfn_verification")
        panel.window_plot()
        _grab(win, out, "dfn_window")
        panel.drill_classify()
        _grab(win, out, "dfn_drill")
        rmp = win.rockmass
        win.setCurrentWidget(rmp)
        rmp.in_size.setText("40"); rmp.in_crop.setText("15")
        rmp.generate()
        _grab(win, out, "dfn_rockmass_3d")
        rmp.plot_traces()
        _grab(win, out, "dfn_rockmass_traces")
        rmp.plot_validation()
        _grab(win, out, "dfn_rockmass_validation")
        win.close()

    return win, [s1]


SCENARIOS = {"hydrofrac": hydrofrac_steps, "thermal": thermal_steps,
             "mohr": mohr_steps, "anisotropy": anisotropy_steps, "borehole": borehole_steps,
             "hydroshear": hydroshear_steps, "stereonet": stereonet_steps, "dfn": dfn_steps}


def run(out: Path | None = None, names: list[str] | None = None, log: Path | None = None) -> int:
    """Run the scenarios inside a Qt event loop. Returns 0 when all of them completed."""
    from geomech.gui.app import Launcher
    worker.SYNC = True                      # background jobs run inline so each step sees its result
    if out is not None:
        out.mkdir(parents=True, exist_ok=True)
    app = QApplication.instance() or QApplication(sys.argv)
    launcher = Launcher()
    launcher.resize(520, 360)
    launcher.show()
    queue = [(name, SCENARIOS[name]) for name in (names or list(SCENARIOS))]
    keep, failures, done = [], [], []

    def report(text: str):
        if sys.stderr is not None:
            print(text, file=sys.stderr)
        if log is not None:
            with open(log, "a", encoding="utf-8") as fh:
                fh.write(text + "\n")

    def run_next():
        if not queue:
            _grab(launcher, out, "launcher")
            report(f"smoke test: {len(done)} scenario(s) ran, {len(failures)} failed" + (f" ({', '.join(failures)})" if failures else ""))
            app.exit(1 if failures else 0)
            return
        name, factory = queue.pop(0)
        try:
            panel, steps = factory(out)
        except Exception:  # noqa: BLE001
            failures.append(name); report(f"[{name}] {traceback.format_exc()}")
            QTimer.singleShot(100, run_next)
            return
        keep.append(panel)

        def run_steps(i=0):
            if i < len(steps):
                try:
                    steps[i]()
                except Exception:  # noqa: BLE001
                    failures.append(name); report(f"[{name}] {traceback.format_exc()}")
                    QTimer.singleShot(100, run_next)
                    return
                QTimer.singleShot(300, lambda: run_steps(i + 1))
            else:
                done.append(name)
                QTimer.singleShot(200, run_next)

        QTimer.singleShot(400, run_steps)

    QTimer.singleShot(400, run_next)
    return app.exec()
