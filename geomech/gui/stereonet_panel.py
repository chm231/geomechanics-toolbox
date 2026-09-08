"""Stereographic Projection window (port of stereoProjection.fig / stereoProjection.m
plus the 'untitled' list window)."""
from __future__ import annotations

import numpy as np
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QCheckBox, QFileDialog, QGridLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit, QListWidget,
    QMessageBox, QPushButton, QRadioButton, QSlider, QTableWidget, QTableWidgetItem, QTabWidget,
    QVBoxLayout, QWidget,
)

from geomech.core import hydroshear as hs
from geomech.core import stereonet as st
from geomech.gui.mplcanvas import MplWidget

COLORS = [(1, 0, 0), (0.1, 0.7, 0.1), (0, 0, 1), (1, 0.4, 0.1), (0, 0.5, 0.7), (0.7, 0, 0.5)]


def _edit(text: str = "", width: int = 60) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class StereonetPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Stereographic Projection")
        self._circles: list[tuple[float, float]] = []      # (dip, dipdir) rad of drawn great circles
        self._windows: list[st.SetWindow] = []
        self._clusters: list[st.Cluster] = []
        self._density = None
        self._plotted = False
        self._build()

    # ------------------------------------------------------------------ UI
    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)

        g = QGroupBox("Joint data (dip, dip direction)")
        v = QVBoxLayout(g)
        self.table = QTableWidget(0, 2)
        self.table.setHorizontalHeaderLabels(["Dip (°)", "Dip direction (°)"])
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.setMinimumHeight(220)
        v.addWidget(self.table)
        row = QHBoxLayout()
        self.in_dip, self.in_dd = _edit(), _edit()
        row.addWidget(QLabel("Dip:")); row.addWidget(self.in_dip); row.addWidget(QLabel("Dip dir.:")); row.addWidget(self.in_dd)
        b = QPushButton("Add joint"); b.clicked.connect(self.add_joint); row.addWidget(b)
        v.addLayout(row)
        row = QHBoxLayout()
        b1 = QPushButton("Import dip/dipDirec…"); b1.clicked.connect(self.import_dip)
        b2 = QPushButton("Import DFN…"); b2.clicked.connect(self.import_dfn)
        b3 = QPushButton("Clear data"); b3.clicked.connect(lambda: self.table.setRowCount(0))
        row.addWidget(b1); row.addWidget(b2); row.addWidget(b3)
        v.addLayout(row)
        left.addWidget(g)

        g = QGroupBox("Projection")
        grid = QGridLayout(g)
        self.rb_lower, self.rb_upper = QRadioButton("Lower"), QRadioButton("Upper")
        self.rb_area, self.rb_angle = QRadioButton("Equal-area"), QRadioButton("Equal-angle")
        self.rb_lower.setChecked(True); self.rb_area.setChecked(True)
        grid.addWidget(self.rb_lower, 0, 0); grid.addWidget(self.rb_upper, 0, 1)
        grid.addWidget(self.rb_area, 1, 0); grid.addWidget(self.rb_angle, 1, 1)
        self.btn_pole = QPushButton("Pole plot"); self.btn_pole.clicked.connect(self.pole_plot)
        self.btn_pole.setStyleSheet("font-weight: bold;")
        self.btn_rose = QPushButton("Rose diagram"); self.btn_rose.clicked.connect(self.rose)
        self.btn_clear = QPushButton("Clear plot"); self.btn_clear.clicked.connect(self.clear_plot)
        grid.addWidget(self.btn_pole, 2, 0); grid.addWidget(self.btn_rose, 2, 1); grid.addWidget(self.btn_clear, 3, 0, 1, 2)
        left.addWidget(g)

        g = QGroupBox("Overlays")
        grid = QGridLayout(g)
        self.cb_net = QCheckBox("Show Wulff / Schmidt net"); self.cb_net.toggled.connect(self.redraw)
        self.sl_net = QSlider(Qt.Orientation.Horizontal); self.sl_net.setRange(-90, 90); self.sl_net.setValue(0)
        self.sl_net.valueChanged.connect(self.redraw)
        self.lbl_rot = QLabel("Rotation angle: 0°")
        grid.addWidget(self.cb_net, 0, 0, 1, 2); grid.addWidget(self.sl_net, 1, 0); grid.addWidget(self.lbl_rot, 1, 1)
        self.cb_circle = QCheckBox("Draw great circle (click on the plot)"); self.cb_circle.toggled.connect(self.redraw)
        grid.addWidget(self.cb_circle, 2, 0, 1, 2)
        self.cb_contour = QCheckBox("Contour image"); self.cb_contour.toggled.connect(self.redraw)
        self.cb_cbar = QCheckBox("Colorbar"); self.cb_cbar.setChecked(True); self.cb_cbar.toggled.connect(self.redraw)
        grid.addWidget(self.cb_contour, 3, 0); grid.addWidget(self.cb_cbar, 3, 1)
        left.addWidget(g)

        g = QGroupBox("Designate joint set (pole window)")
        grid = QGridLayout(g)
        self.in_tf, self.in_tt, self.in_pf, self.in_pt = _edit("150"), _edit("220"), _edit("10"), _edit("40")
        grid.addWidget(QLabel("Trend of pole:"), 0, 0); grid.addWidget(self.in_tf, 0, 1); grid.addWidget(QLabel("° ~"), 0, 2); grid.addWidget(self.in_tt, 0, 3); grid.addWidget(QLabel("°"), 0, 4)
        grid.addWidget(QLabel("Plunge of pole:"), 1, 0); grid.addWidget(self.in_pf, 1, 1); grid.addWidget(QLabel("° ~"), 1, 2); grid.addWidget(self.in_pt, 1, 3); grid.addWidget(QLabel("°"), 1, 4)
        b = QPushButton("Mean direc."); b.clicked.connect(self.mean_direction)
        grid.addWidget(b, 2, 0, 1, 2)
        b = QPushButton("Remove sets"); b.clicked.connect(self.clear_sets)
        grid.addWidget(b, 2, 3, 1, 2)
        left.addWidget(g)

        g = QGroupBox("Clustering (fuzzy c-means)")
        row = QHBoxLayout(g)
        row.addWidget(QLabel("No. of sets:")); self.in_n = _edit("3", 40); row.addWidget(self.in_n)
        b = QPushButton("Clustering"); b.clicked.connect(self.cluster); row.addWidget(b)
        b = QPushButton("Remove"); b.clicked.connect(self.clear_clusters); row.addWidget(b)
        self.lbl_cluster = QLabel(""); row.addWidget(self.lbl_cluster, 1)
        left.addWidget(g)

        g = QGroupBox("Labels (dip, dip direction)")
        v = QVBoxLayout(g)
        self.list = QListWidget(); self.list.setMaximumHeight(110)
        v.addWidget(self.list)
        b = QPushButton("Delete selected"); b.clicked.connect(self.delete_selected)
        v.addWidget(b)
        left.addWidget(g)
        left.addStretch(1)

        self.tabs = QTabWidget()
        self.plot = MplWidget()
        self.plot.canvas.mpl_connect("button_press_event", self._on_click)
        self.plot_rose = MplWidget(projection="polar")
        self.tabs.addTab(self.plot, "Stereonet")
        self.tabs.addTab(self.plot_rose, "Rose diagram")
        root.addWidget(self.tabs, 1)

    # ------------------------------------------------------------ data
    def data(self) -> np.ndarray:
        rows = []
        for i in range(self.table.rowCount()):
            a, b = self.table.item(i, 0), self.table.item(i, 1)
            if a and b and a.text().strip():
                rows.append([float(a.text()), float(b.text())])
        return np.array(rows, float).reshape(-1, 2)

    def set_data(self, arr: np.ndarray):
        self.table.setRowCount(len(arr))
        for i, (d, dd) in enumerate(arr):
            self.table.setItem(i, 0, QTableWidgetItem(f"{d:g}")); self.table.setItem(i, 1, QTableWidgetItem(f"{dd:g}"))

    def add_joint(self):
        try:
            self.set_data(np.vstack([self.data(), [float(self.in_dip.text()), float(self.in_dd.text())]]))
            self.in_dip.clear(); self.in_dd.clear()
        except ValueError:
            QMessageBox.critical(self, "Stereographic Projection", "Enter numeric dip and dip direction.")

    def import_dip(self):
        path, _ = QFileDialog.getOpenFileName(self, "File open", "", "Text files (*.txt)")
        if path:
            try:
                self.set_data(st.load_dip_file(path))
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Stereographic Projection", f"Could not read file:\n{e}")

    def import_dfn(self):
        path, _ = QFileDialog.getOpenFileName(self, "File open", "", "Text files (*.txt)")
        if path:
            try:
                self.set_data(hs.load_dfn(path))
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Stereographic Projection", f"Could not read DFN file:\n{e}")

    # ------------------------------------------------------------ state
    def upper(self) -> bool:
        return self.rb_upper.isChecked()

    def equal_angle(self) -> bool:
        return self.rb_angle.isChecked()

    def pole_plot(self):
        self._plotted = True
        self._density = None
        self.redraw()
        self.tabs.setCurrentWidget(self.plot)

    def clear_plot(self):
        self._plotted = False
        self._circles.clear(); self._windows.clear(); self._clusters.clear(); self._density = None
        self.cb_net.setChecked(False); self.cb_circle.setChecked(False); self.cb_contour.setChecked(False)
        self.list.clear()
        self.plot.clear(); self.plot.draw()

    def clear_sets(self):
        self._windows.clear(); self._refresh_list(); self.redraw()

    def clear_clusters(self):
        self._clusters.clear(); self.lbl_cluster.setText(""); self._refresh_list(); self.redraw()

    def delete_selected(self):
        row = self.list.currentRow()
        if row < 0:
            return
        kind, idx = self.list.item(row).data(Qt.ItemDataRole.UserRole)
        {"circle": self._circles, "set": self._windows, "cluster": self._clusters}[kind].pop(idx)
        self._refresh_list(); self.redraw()

    def _refresh_list(self):
        self.list.clear()
        for i, (di, did) in enumerate(self._circles):
            it = self._add_list(f"circle  {np.rad2deg(di):.1f}, {np.rad2deg(did):.1f}"); it.setData(Qt.ItemDataRole.UserRole, ("circle", i))
        for i, w in enumerate(self._windows):
            txt = "NaN, NaN" if w.mean_vec is None else f"{w.mean_dip_deg:.1f}, {w.mean_dipdir_deg:.1f}"
            it = self._add_list(f"set  → {txt}  (n = {w.n_members})"); it.setData(Qt.ItemDataRole.UserRole, ("set", i))
        for i, c in enumerate(self._clusters):
            it = self._add_list(f"cluster  {c.dip_deg:.1f}, {c.dipdir_deg:.1f}  (n = {len(c.members)})"); it.setData(Qt.ItemDataRole.UserRole, ("cluster", i))

    def _add_list(self, text):
        self.list.addItem(text)
        return self.list.item(self.list.count() - 1)

    # ------------------------------------------------------------ actions
    def _on_click(self, event):
        if not (self._plotted and self.cb_circle.isChecked()) or event.inaxes is None:
            return
        x, y = float(event.xdata), float(event.ydata)
        if np.hypot(x, y) > 1.0:
            return
        self._circles.append(st.unproject(x, y, self.upper(), self.equal_angle()))
        self._refresh_list(); self.redraw()

    def mean_direction(self):
        try:
            d = self.data()
            w = [np.deg2rad(float(e.text())) for e in (self.in_tf, self.in_tt, self.in_pf, self.in_pt)]
            self._windows.append(st.designate_set(d[:, 0], d[:, 1], *w, upper=self.upper(), equal_angle=self.equal_angle()))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Stereographic Projection", f"Mean direction failed:\n{e}")
            return
        self._refresh_list(); self.redraw()

    def cluster(self):
        try:
            n = int(self.in_n.text())
            if n <= 0:
                raise ValueError("number of sets must be positive")
            d = self.data()
            self._clusters = st.cluster_poles(d[:, 0], d[:, 1], n)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Stereographic Projection", f"Clustering failed:\n{e}")
            return
        self.lbl_cluster.setText("" if len(self._clusters) == n else f"There are only {len(self._clusters)} sets found")
        self._refresh_list(); self.redraw()

    def rose(self):
        d = self.data()
        if not len(d):
            return
        counts, edges = st.rose_histogram(d[:, 1])
        ax = self.plot_rose.clear()
        ax.bar((edges[:-1] + edges[1:]) / 2, counts, width=edges[1] - edges[0], bottom=0, edgecolor="k", facecolor="none")
        ax.set_theta_zero_location("E"); ax.set_theta_direction(1)
        ax.set_xticks(np.deg2rad([0, 90, 180, 270])); ax.set_xticklabels(["E", "N", "W", "S"], fontweight="bold")
        ax.set_title("Direction of Strikes", fontweight="bold")
        self.plot_rose.draw()
        self.tabs.setCurrentWidget(self.plot_rose)

    # ------------------------------------------------------------ drawing
    def redraw(self, *_):
        self.lbl_rot.setText(f"Rotation angle: {self.sl_net.value()}°")
        if not self._plotted:
            return
        d = self.data()
        upper, ea = self.upper(), self.equal_angle()
        ax = self.plot.clear()
        fig = self.plot.figure
        if self.cb_contour.isChecked() and len(d):
            if self._density is None or self._density[0] != (upper, ea, len(d)):
                self._density = ((upper, ea, len(d)), st.pole_density(d[:, 0], d[:, 1], upper, ea))
            cx, cy, res = self._density[1]
            cs = ax.contourf(cx, cy, res, levels=np.linspace(0, max(res.max(), 1e-9), 11), cmap="jet")
            if self.cb_cbar.isChecked():
                cb = fig.colorbar(cs, ax=ax, ticks=np.linspace(0, res.max(), 11))
                cb.set_label("% of poles per 1% hemisphere area")
        elif len(d) and not self._clusters:
            tre, plu = st.poles(d[:, 0], d[:, 1])
            x, y = st.project(tre, plu, upper, ea)
            ax.scatter(x, y, s=25, marker="s", facecolors="none", edgecolors="b", linewidths=1.3)
        ax.scatter([0], [0], s=60, marker="+", c="k", linewidths=1)
        t = np.linspace(0, 2 * np.pi, 361)
        ax.plot(np.cos(t), np.sin(t), "k", linewidth=1)
        for i in range(36):
            a = np.pi / 18 * i
            ax.plot([np.cos(a), 1.05 * np.cos(a)], [np.sin(a), 1.05 * np.sin(a)], "k", linewidth=0.8)
        for txt, (x, y) in (("N", (-0.04, 1.15)), ("S", (-0.04, -1.15)), ("E", (1.1, 0)), ("W", (-1.2, 0))):
            ax.text(x, y, txt, fontsize=16, fontweight="bold")
        if self.cb_net.isChecked():
            did = np.deg2rad(90 + self.sl_net.value())
            for x, y in st.net_lines(did, ea):
                ax.plot(x, y, ":k", linewidth=0.8)
        for di, did in self._circles:
            x, y = st.great_circle(di, did, upper, ea)
            ax.plot(x, y, "r")
            tre, plu = did + np.pi, np.pi / 2 - di
            px, py = st.project(tre, plu, upper, ea)
            ax.plot(px, py, "s", color="r", markersize=5)
            ax.text(px, py - 0.05, f"{np.rad2deg(di):.1f}, {np.rad2deg(did):.1f}", fontsize=10)
        for w in self._windows:
            for x, y in w.outline:
                ax.plot(x, y, "r", linewidth=1)
            if w.mean_vec is not None:
                di, did = np.deg2rad(w.mean_dip_deg), np.deg2rad(w.mean_dipdir_deg)
                x, y = st.great_circle(di, did, upper, ea)
                ax.plot(x, y, "r")
                px, py = st.project(did + np.pi, np.pi / 2 - di, upper, ea)
                ax.plot(px, py, "rs", markersize=5)
                ax.text(px, py - 0.05, f"{w.mean_dip_deg:.1f}, {w.mean_dipdir_deg:.1f}", fontsize=10)
        for i, c in enumerate(self._clusters):
            color = COLORS[i % len(COLORS)]
            v = st.pole_vectors(d[:, 0], d[:, 1])[c.members]
            tre, plu = st.vec_to_trend_plunge(v[:, 0], v[:, 1], v[:, 2])
            x, y = st.project(tre, plu, upper, ea)
            ax.plot(x, y, "o", color=color, markersize=4, markerfacecolor="none", linewidth=1.3)
            t_c, p_c = st.vec_to_trend_plunge(*c.center_vec)
            cx, cy = st.project(t_c, p_c, upper, ea)
            ax.plot(cx, cy, "x", color=color, markersize=15, markeredgewidth=3)
            ax.text(float(cx[0]), float(cy[0]) - 0.05, f"{c.dip_deg:.1f}, {c.dipdir_deg:.1f}", fontsize=10)
        title = ("Equal-Angle" if ea else "Equal-Area") + ", " + ("Upper" if upper else "Lower") + " Hemisphere"
        ax.set_title(title, fontsize=14)
        ax.set_xlim(-1.3, 1.3); ax.set_ylim(-1.3, 1.3)
        ax.set_aspect("equal"); ax.set_axis_off()
        self.plot.draw()
