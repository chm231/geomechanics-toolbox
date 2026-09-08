"""Rock-mass DFN mode (multi-set, P32-based generator of the DFN project)."""
from __future__ import annotations

import numpy as np
from matplotlib.collections import LineCollection
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QComboBox, QFileDialog, QGridLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit, QMessageBox,
    QPushButton, QScrollArea, QTabWidget, QTableWidget, QTableWidgetItem, QVBoxLayout, QWidget,
)

from geomech.core import dfn_rockmass as rm
from geomech.gui.mplcanvas import MplWidget
from geomech.gui.worker import run_async

SET_COLORS = ["#4878CF", "#6ACC65", "#D65F5F", "#B47CC7", "#C4AD66", "#77BEDB", "#8C613C"]
COLUMNS = ["Name", "P32 (m²/m³)", "Size dist.", "kr", "r0 (m)", "rmin (m)", "rmax (m)", "mu", "sigma", "Trend (°)", "Plunge (°)", "kappa"]
MAX_FRACTURES = 3_000_000
MAX_DISPLAY = 5000          # polygons drawn in the 3-D view (largest first); more makes rotation crawl
EDGE_LIMIT = 2000           # draw polygon edges only up to this many


def _edit(text: str, width: int = 70) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class DFNRockMassPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.dfn: rm.RockMassDFN | None = None
        self.tunnel: np.ndarray | None = None
        self._clip_cache: tuple | None = None    # (key, ClippedDFN) shared by the 3-D view and trace maps
        self._build()

    def _build(self):
        root = QHBoxLayout(self)
        left_w = QWidget(); left = QVBoxLayout(left_w)
        scroll = QScrollArea(); scroll.setWidgetResizable(True); scroll.setWidget(left_w); scroll.setMinimumWidth(560)
        root.addWidget(scroll, 0)

        left.addWidget(QLabel("Coordinates: x = East, y = North, z = Up. Fracture size = disc radius. "
                              "Pole trend / plunge (plunge positive downward)."))
        g = QGroupBox("Generation box and cutoffs")
        grid = QGridLayout(g)
        self.in_size, self.in_rmin, self.in_rmax, self.in_seed = _edit("50"), _edit("0.5"), _edit("250"), _edit("42")
        grid.addWidget(QLabel("Cube size (m)"), 0, 0); grid.addWidget(self.in_size, 0, 1)
        grid.addWidget(QLabel("rmin (m)"), 0, 2); grid.addWidget(self.in_rmin, 0, 3)
        grid.addWidget(QLabel("rmax (m)"), 0, 4); grid.addWidget(self.in_rmax, 0, 5)
        grid.addWidget(QLabel("Seed"), 1, 0); grid.addWidget(self.in_seed, 1, 1)
        grid.addWidget(QLabel("Preset"), 1, 2)
        self.cb_site = QComboBox(); self.cb_site.addItems(["forsmark", "laxemar"])
        grid.addWidget(self.cb_site, 1, 3)
        b = QPushButton("Load preset"); b.clicked.connect(self.load_preset); grid.addWidget(b, 1, 4)
        b = QPushButton("Load JSON config…"); b.clicked.connect(self.load_config); grid.addWidget(b, 1, 5)
        left.addWidget(g)

        g = QGroupBox("Fracture sets")
        v = QVBoxLayout(g)
        self.table = QTableWidget(0, len(COLUMNS))
        self.table.setHorizontalHeaderLabels(COLUMNS)
        for c, w in enumerate((60, 80, 90, 45, 55, 60, 60, 45, 50, 65, 65, 55)):
            self.table.setColumnWidth(c, w)
        self.table.setMinimumHeight(190)
        v.addWidget(self.table)
        row = QHBoxLayout()
        b = QPushButton("Add set"); b.clicked.connect(self.add_set); row.addWidget(b)
        b = QPushButton("Remove selected"); b.clicked.connect(self.remove_set); row.addWidget(b)
        row.addStretch(1)
        v.addLayout(row)
        v.addWidget(QLabel("Size dist.: powerlaw (kr, r0, rmin=max(rmin, r0)), exponential (mean r0), lognormal (mu, sigma), uniform."))
        left.addWidget(g)

        row = QHBoxLayout()
        self.btn_gen = QPushButton("Generate"); self.btn_gen.setStyleSheet("font-weight: bold;"); self.btn_gen.clicked.connect(self.generate)
        self.btn_count = QPushButton("Count only"); self.btn_count.clicked.connect(self.count_only)
        row.addWidget(self.btn_gen); row.addWidget(self.btn_count)
        left.addLayout(row)
        self.lbl_info = QLabel(""); self.lbl_info.setWordWrap(True); self.lbl_info.setMinimumHeight(120)
        self.lbl_info.setAlignment(Qt.AlignmentFlag.AlignTop); left.addWidget(self.lbl_info)

        g = QGroupBox("Crop box, plots and export")
        grid = QGridLayout(g)
        self.in_crop = _edit("25")
        grid.addWidget(QLabel("Crop box half-size (m)"), 0, 0); grid.addWidget(self.in_crop, 0, 1)
        b = QPushButton("Tunnel polygon (.dat)…"); b.clicked.connect(self.load_tunnel); grid.addWidget(b, 0, 2)
        self.lbl_tunnel = QLabel("no tunnel"); grid.addWidget(self.lbl_tunnel, 0, 3)
        self.in_maxshow = _edit(str(MAX_DISPLAY))
        grid.addWidget(QLabel("Max polygons shown"), 0, 4); grid.addWidget(self.in_maxshow, 0, 5)
        self._plot_buttons = []
        for col, (text, fn) in enumerate((("3D clipped DFN", lambda: self.plot_3d(False)),
                                          ("Tunnel-intersecting only", lambda: self.plot_3d(True)),
                                          ("2D trace maps", self.plot_traces), ("Validation", self.plot_validation))):
            b = QPushButton(text); b.clicked.connect(fn); grid.addWidget(b, 1, col); self._plot_buttons.append(b)
        b = QPushButton("Export HDF5…"); b.clicked.connect(self.export_h5); grid.addWidget(b, 2, 0)
        b = QPushButton("Export CSV…"); b.clicked.connect(self.export_csv); grid.addWidget(b, 2, 1)
        left.addWidget(g)
        left.addStretch(1)

        self.tabs = QTabWidget()
        self.plot3d = MplWidget(projection="3d")
        self.plot_tr = MplWidget()
        self.plot_val = MplWidget()
        self.plot_st = MplWidget()
        for w, t in ((self.plot3d, "3D clipped DFN"), (self.plot_tr, "2D trace maps"), (self.plot_val, "Size distributions"), (self.plot_st, "Stereonet density")):
            self.tabs.addTab(w, t)
        root.addWidget(self.tabs, 1)
        self.load_preset()

    # ------------------------------------------------------------ sets
    def _set_row(self, r: int, s: rm.FractureSet):
        vals = [s.name, f"{s.P32:g}", s.dist_type, f"{s.kr:g}", f"{s.r0:g}", f"{s.rmin:g}", f"{s.rmax:g}",
                f"{s.mu:g}", f"{s.sigma:g}", f"{s.trend:g}", f"{s.plunge:g}", f"{s.kappa:g}"]
        for c, v in enumerate(vals):
            if c == 2:
                cb = QComboBox(); cb.addItems(rm.DIST_TYPES); cb.setCurrentText(v)
                self.table.setCellWidget(r, c, cb)
            else:
                self.table.setItem(r, c, QTableWidgetItem(v))

    def set_sets(self, sets: list[rm.FractureSet]):
        self.table.setRowCount(len(sets))
        for r, s in enumerate(sets):
            self._set_row(r, s)

    def sets(self) -> list[rm.FractureSet]:
        out = []
        for r in range(self.table.rowCount()):
            g = lambda c: self.table.item(r, c).text().strip()  # noqa: E731
            dist = self.table.cellWidget(r, 2).currentText()
            out.append(rm.FractureSet(g(0), float(g(1)), dist, float(g(3)), float(g(4)), float(g(5)), float(g(6)),
                                      float(g(7)), float(g(8)), float(g(9)), float(g(10)), float(g(11))))
        if not out:
            raise ValueError("no fracture sets defined")
        return out

    def load_preset(self):
        try:
            self.set_sets(rm.preset_sets(self.cb_site.currentText(), float(self.in_rmin.text()), float(self.in_rmax.text())))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Rock-mass DFN", f"Invalid cutoffs:\n{e}")

    def load_config(self):
        path, _ = QFileDialog.getOpenFileName(self, "Load set config", "", "JSON (*.json)")
        if path:
            try:
                self.set_sets(rm.load_config(path, float(self.in_rmin.text()), float(self.in_rmax.text())))
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Rock-mass DFN", f"Could not read config:\n{e}")

    def add_set(self):
        r = self.table.rowCount(); self.table.insertRow(r)
        self._set_row(r, rm.FractureSet(f"Set_{r + 1}", 1.0, "powerlaw", 3.0, 0.25, float(self.in_rmin.text()), float(self.in_rmax.text())))

    def remove_set(self):
        r = self.table.currentRow()
        if r >= 0:
            self.table.removeRow(r)

    # ------------------------------------------------------------ actions
    def count_only(self):
        try:
            sets = self.sets(); size = float(self.in_size.text())
            lines = []
            total = 0
            for s in sets:
                p32 = rm.scaled_P32(s); n = rm.num_fractures_from_P32(p32, s.size_dist(), size**3); total += n
                lines.append(f"{s.name}: scaled P32 = {p32:.4f}, N = {n:,}")
            self.lbl_info.setText("\n".join(lines) + f"\nTotal N = {total:,}")
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Rock-mass DFN", f"Invalid input:\n{e}")

    def generate(self):
        try:
            sets = self.sets()
            seed = int(float(self.in_seed.text())) if self.in_seed.text().strip() else None
            size = float(self.in_size.text())
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Rock-mass DFN", f"Invalid input:\n{e}")
            return
        run_async(self, rm.generate, self._on_generated, title="Rock-mass DFN generation",
                  busy=(self.btn_gen, self.btn_count, *self._plot_buttons), status=self.lbl_info,
                  args=(sets, size, seed), kwargs={"max_total": MAX_FRACTURES})

    def _on_generated(self, dfn: rm.RockMassDFN):
        self.dfn = dfn
        self._clip_cache = None
        lines = [f"{s.name}: target N = {n:,}, scaled P32 = {p:.4f}, realized P32 = {q:.4f}"
                 for s, n, p, q in zip(dfn.sets, dfn.targets, dfn.scaled_p32, dfn.realized_p32)]
        self.lbl_info.setText("\n".join(lines) + f"\nTotal fractures: {dfn.n:,}")
        self.plot_3d(False)

    def _cb(self) -> dict:
        return rm.crop_box_dict(float(self.in_crop.text()))

    def _clipped(self, cb: dict) -> rm.ClippedDFN:
        """Crop-box clipping, cached per (DFN, crop box): the 3-D views and the three trace maps share it."""
        key = (id(self.dfn), tuple(sorted(cb.items())))
        if self._clip_cache is None or self._clip_cache[0] != key:
            self._clip_cache = (key, rm.clip_to_crop_box(self.dfn, cb))
        return self._clip_cache[1]

    def load_tunnel(self):
        path, _ = QFileDialog.getOpenFileName(self, "Tunnel polygon", "", "DAT files (*.dat);;All files (*)")
        if path:
            try:
                self.tunnel = rm.read_tunnel_polygon(path)
                self.lbl_tunnel.setText(f"{len(self.tunnel) - 1} vertices")
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Rock-mass DFN", f"Could not read tunnel polygon:\n{e}")

    def plot_3d(self, tunnel_only: bool):
        if self.dfn is None:
            return
        if tunnel_only and self.tunnel is None:
            QMessageBox.information(self, "Rock-mass DFN", "Load a tunnel polygon first.")
            return
        try:
            cb = self._cb()
        except ValueError as e:
            QMessageBox.critical(self, "Rock-mass DFN", f"Invalid crop box:\n{e}")
            return
        run_async(self, self._clipped, lambda c: self._draw_3d(c, cb, tunnel_only), title="Crop-box clipping",
                  busy=self._plot_buttons, args=(cb,))

    def _draw_3d(self, c: rm.ClippedDFN, cb: dict, tunnel_only: bool):
        if tunnel_only:
            c = rm.tunnel_subset(c, self.tunnel)
        try:
            max_show = max(1, int(float(self.in_maxshow.text())))
        except ValueError:
            max_show = MAX_DISPLAY
        ax = self.plot3d.clear()
        shown = len(c.polygons)
        if c.polygons:
            order = np.arange(len(c.polygons))
            if len(order) > max_show:                     # keep the largest ones
                order = np.sort(np.argsort(c.areas)[::-1][:max_show])
            shown = len(order)
            edges = shown <= EDGE_LIMIT
            col = Poly3DCollection([c.polygons[i] for i in order], alpha=0.4,
                                   linewidth=0.3 if edges else 0.0, edgecolor=(0.5, 0.5, 0.5) if edges else "none")
            col.set_facecolor([SET_COLORS[(s - 1) % len(SET_COLORS)] for s in c.set_id[order]])
            ax.add_collection3d(col)
        xs, ys, zs = (cb["xmin"], cb["xmax"]), (cb["ymin"], cb["ymax"]), (cb["zmin"], cb["zmax"])
        for y in ys:
            for z in zs:
                ax.plot(xs, [y, y], [z, z], "k-", lw=0.5)
        for x in xs:
            for z in zs:
                ax.plot([x, x], ys, [z, z], "k-", lw=0.5)
            for y in ys:
                ax.plot([x, x], [y, y], zs, "k-", lw=0.5)
        if self.tunnel is not None:
            for xv in xs:
                ax.plot([xv] * len(self.tunnel), self.tunnel[:, 0], self.tunnel[:, 1], "r-", lw=1.5)
        ax.set_xlim(*xs); ax.set_ylim(*ys); ax.set_zlim(*zs); ax.set_box_aspect((1, 1, 1))
        ax.set_xlabel("x East [m]"); ax.set_ylabel("y North [m]"); ax.set_zlabel("z Up [m]")
        ax.set_title(f"Clipped DFN in crop box{' (tunnel-intersecting)' if tunnel_only else ''}: "
                     f"{len(c.polygons)} fractures, P32 = {c.p32:.3f} m²/m³"
                     + (f"\n(showing the {shown} largest; raise 'Max polygons shown' to see more)" if shown < len(c.polygons) else ""))
        ax.view_init(elev=20, azim=-35)
        self.plot3d.draw()
        self.tabs.setCurrentWidget(self.plot3d)

    def plot_traces(self):
        if self.dfn is None:
            return
        try:
            cb = self._cb()
        except ValueError as e:
            QMessageBox.critical(self, "Rock-mass DFN", f"Invalid crop box:\n{e}")
            return
        run_async(self, self._clipped, lambda c: self._draw_traces(c, cb), title="Trace maps",
                  busy=self._plot_buttons, args=(cb,))

    def _draw_traces(self, c: rm.ClippedDFN, cb: dict):
        fig = self.plot_tr.figure; fig.clear()
        for k, axis in enumerate("xyz"):
            tm = rm.trace_map(c, cb, axis, 0.0)
            ax = fig.add_subplot(1, 3, k + 1)
            if tm.segments:
                segs = np.array(tm.segments)[:, :, [tm.h_index, tm.v_index]]      # (n, 2, 2)
                ax.add_collection(LineCollection(segs, colors=[SET_COLORS[(s - 1) % len(SET_COLORS)] for s in tm.set_id],
                                                 linewidths=0.6))
            lo = [cb["xmin"], cb["ymin"], cb["zmin"]]; hi = [cb["xmax"], cb["ymax"], cb["zmax"]]
            h, v = tm.h_index, tm.v_index
            ax.plot([lo[h], hi[h], hi[h], lo[h], lo[h]], [lo[v], lo[v], hi[v], hi[v], lo[v]], "k-", lw=1)
            if axis == "x" and self.tunnel is not None:
                ax.plot(self.tunnel[:, 0], self.tunnel[:, 1], "r-", lw=2)
            ax.set_aspect("equal"); ax.grid(True, linewidth=0.3)
            ax.set_xlabel("xyz"[h].upper() + " [m]"); ax.set_ylabel("xyz"[v].upper() + " [m]")
            ax.set_title(f"{axis.upper()} = 0: {len(tm.segments)} traces, P21 = {tm.p21:.3f} /m", fontsize=9)
        self.plot_tr.draw()
        self.tabs.setCurrentWidget(self.plot_tr)

    def plot_validation(self):
        if self.dfn is None:
            return
        d = self.dfn
        fig = self.plot_val.figure; fig.clear()
        n_sets = len(d.sets)
        cols = min(3, n_sets); rows = int(np.ceil(n_sets / cols))
        for i, s in enumerate(d.sets):
            ax = fig.add_subplot(rows, cols, i + 1)
            x, y = rm.size_histogram_loglog(d.radii[d.set_id == i + 1], 1.0, s.rmax)
            if len(x):
                ax.scatter(x, y, s=10, label="Generated")
                if s.dist_type == "powerlaw":
                    C = y[0] + s.kr * x[0]
                    ax.plot(x, -s.kr * x + C, "r-", label=f"Theory (kr={s.kr:.2f})")
                ax.legend(fontsize=7)
            ax.grid(True); ax.set_title(f"{s.name} size distribution", fontsize=9)
            ax.set_xlabel("log10(radius) [m]"); ax.set_ylabel("log10(count)")
        self.plot_val.draw()
        ax = self.plot_st.clear()
        t = np.linspace(0, 2 * np.pi, 100)
        ax.plot(np.cos(t), np.sin(t), "k-", lw=1.5)
        GX, GY, dens = rm.pole_density_equal_angle(d.normals)
        cs = ax.contourf(GX, GY, dens, levels=12, cmap="jet")
        self.plot_st.figure.colorbar(cs, ax=ax, label="Pole density count")
        for i, s in enumerate(d.sets):
            mx, my = rm.mean_pole_projection(s)
            ax.plot(mx, my, "rp", ms=12, mec="black"); ax.text(mx + 0.05, my + 0.05, f"Set {i + 1}", color="red", weight="bold")
        for txt, (x, y) in (("N", (0, 1.05)), ("E", (1.05, 0)), ("S", (0, -1.05)), ("W", (-1.05, 0))):
            ax.text(x, y, txt, ha="center", va="center", weight="bold")
        ax.set_xlim(-1.15, 1.15); ax.set_ylim(-1.15, 1.15); ax.set_aspect("equal"); ax.axis("off")
        ax.set_title("Pole density (equal-angle, lower hemisphere)")
        self.plot_st.draw()
        self.tabs.setCurrentWidget(self.plot_val)

    def export_h5(self):
        if self.dfn is None:
            return
        path, _ = QFileDialog.getSaveFileName(self, "Export HDF5", "dfn_export_for_python.h5", "HDF5 (*.h5)")
        if path:
            try:
                rm.export_hdf5(self.dfn, path, float(self.in_rmin.text()), float(self.in_rmax.text()), self.cb_site.currentText(),
                               float(self.in_crop.text()), self.tunnel)
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Rock-mass DFN", f"Export failed:\n{e}")

    def export_csv(self):
        if self.dfn is None:
            return
        path, _ = QFileDialog.getSaveFileName(self, "Export CSV", "dfn.csv", "CSV (*.csv *.txt)")
        if path:
            rm.export_csv(self.dfn, path)
