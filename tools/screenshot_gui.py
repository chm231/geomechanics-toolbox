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


def borehole_steps(out: Path):
    from geomech.gui.borehole_panel import BoreholePanel
    panel = BoreholePanel()
    panel.resize(1300, 800)
    panel.show()

    def s1():
        panel.cb_fluid.setChecked(True); panel.in_Pmud.setText("15")
        panel.cb_fail.setChecked(True)
        panel.run()
        panel.grab().save(str(out / "borehole_contour.png"))
        panel.in_loc_r.setText("0.1"); panel.in_loc_th.setText("90")
        panel.local_analysis()
        panel.grab().save(str(out / "borehole_local.png"))
        panel.rb_all.setChecked(True)
        panel.run()
        panel.grab().save(str(out / "borehole_ucs.png"))
        panel.tabs.setCurrentWidget(panel.plot_obb)
        panel.grab().save(str(out / "borehole_obb.png"))
        panel.rb_one.setChecked(True); panel.rb_fem.setChecked(True)
        panel.run()
        panel.grab().save(str(out / "borehole_fem.png"))
        panel.close()

    return panel, [s1]


def hydroshear_steps(out: Path):
    from geomech.gui.hydroshear_panel import HydroshearPanel
    panel = HydroshearPanel()
    panel.resize(1300, 820)
    panel.show()

    def s1():
        panel.add_joint()
        panel.in_dip.setText("75.29"); panel.in_dd.setText("151.94"); panel.add_joint()
        panel.quick_run()
        panel.advanced_run()
        panel.tabs.setCurrentWidget(panel.plots["pcm"]); panel.grab().save(str(out / "hydroshear_pcm.png"))
        panel.tabs.setCurrentWidget(panel.plots["pc"]); panel.grab().save(str(out / "hydroshear_pc.png"))
        panel.tabs.setCurrentWidget(panel.plots["pco"]); panel.grab().save(str(out / "hydroshear_pco.png"))
        panel.tabs.setCurrentWidget(panel.plots["grad"]); panel.grab().save(str(out / "hydroshear_grad.png"))
        panel.close()

    return panel, [s1]


def stereonet_steps(out: Path):
    import numpy as np
    from geomech.core import stereonet as st
    from geomech.gui.stereonet_panel import StereonetPanel
    panel = StereonetPanel()
    panel.resize(1300, 820)
    panel.show()
    src = Path(__file__).resolve().parents[1] / "src" / "stereo_exmapledata" / "exampleData.txt"

    def s1():
        panel.set_data(st.load_dip_file(src))
        panel.pole_plot()
        panel.cb_net.setChecked(True)
        panel._circles.append((np.deg2rad(60), np.deg2rad(120))); panel._refresh_list(); panel.redraw()
        panel.grab().save(str(out / "stereonet_poles.png"))
        panel.cb_net.setChecked(False)
        panel.mean_direction()
        panel.cluster()
        panel.grab().save(str(out / "stereonet_sets.png"))
        panel.cb_contour.setChecked(True)
        panel.grab().save(str(out / "stereonet_contour.png"))
        panel.rose()
        panel.grab().save(str(out / "stereonet_rose.png"))
        panel.close()

    return panel, [s1]


def dfn_steps(out: Path):
    from geomech.gui.dfn_panel import DFNPanel
    win = DFNPanel()
    win.resize(1400, 860)
    win.show()
    panel = win.toolbox

    def s1():
        win.setCurrentWidget(panel)
        panel.generate()
        win.grab().save(str(out / "dfn_3d.png"))
        panel.verification()
        win.grab().save(str(out / "dfn_verification.png"))
        panel.window_plot()
        win.grab().save(str(out / "dfn_window.png"))
        panel.drill_classify()
        win.grab().save(str(out / "dfn_drill.png"))
        rmp = win.rockmass
        win.setCurrentWidget(rmp)
        rmp.in_size.setText("40"); rmp.in_crop.setText("15")
        rmp.generate()
        win.grab().save(str(out / "dfn_rockmass_3d.png"))
        rmp.plot_traces()
        win.grab().save(str(out / "dfn_rockmass_traces.png"))
        rmp.plot_validation()
        win.grab().save(str(out / "dfn_rockmass_validation.png"))
        win.close()

    return win, [s1]


SCENARIOS = {"hydrofrac": hydrofrac_steps, "thermal": thermal_steps,
             "mohr": mohr_steps, "anisotropy": anisotropy_steps, "borehole": borehole_steps,
             "hydroshear": hydroshear_steps, "stereonet": stereonet_steps, "dfn": dfn_steps}


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
