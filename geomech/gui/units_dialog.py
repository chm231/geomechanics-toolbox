"""Units dialog (port of Units.fig / Units.m): input and output unit per quantity,
with load / save of unit-set files (src/HFsim_units/*.txt format)."""
from __future__ import annotations

from PySide6.QtWidgets import (
    QComboBox, QDialog, QDialogButtonBox, QFileDialog, QGridLayout, QHBoxLayout, QLabel, QLineEdit,
    QMessageBox, QPushButton, QVBoxLayout,
)

from geomech.core import units as U


class UnitsDialog(QDialog):
    def __init__(self, unit_set: U.UnitSet | None = None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Units")
        self.unit_set = unit_set or U.UnitSet()
        v = QVBoxLayout(self)
        row = QHBoxLayout()
        row.addWidget(QLabel("Description:"))
        self.in_desc = QLineEdit(self.unit_set.description)
        row.addWidget(self.in_desc, 1)
        v.addLayout(row)
        grid = QGridLayout()
        grid.addWidget(QLabel("<b>Parameter</b>"), 0, 0); grid.addWidget(QLabel("<b>Input unit</b>"), 0, 1); grid.addWidget(QLabel("<b>Output unit</b>"), 0, 2)
        self.combos: dict[str, tuple[QComboBox, QComboBox]] = {}
        for r, (label, kind) in enumerate(U.QUANTITIES, start=1):
            ci, co = QComboBox(), QComboBox()
            ci.addItems(U.choices(kind)); co.addItems(U.choices(kind))
            ci.setCurrentText(self.unit_set.input[kind]); co.setCurrentText(self.unit_set.output[kind])
            grid.addWidget(QLabel(label), r, 0); grid.addWidget(ci, r, 1); grid.addWidget(co, r, 2)
            self.combos[kind] = (ci, co)
        v.addLayout(grid)
        row = QHBoxLayout()
        b_load, b_save = QPushButton("Load…"), QPushButton("Save…")
        b_load.clicked.connect(self.load_file); b_save.clicked.connect(self.save_file)
        row.addWidget(b_load); row.addWidget(b_save); row.addStretch(1)
        v.addLayout(row)
        bb = QDialogButtonBox(QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel)
        bb.accepted.connect(self.accept); bb.rejected.connect(self.reject)
        v.addWidget(bb)

    def current(self) -> U.UnitSet:
        return U.UnitSet(self.in_desc.text(), {k: c[0].currentText() for k, c in self.combos.items()},
                         {k: c[1].currentText() for k, c in self.combos.items()})

    def _apply(self, s: U.UnitSet):
        self.in_desc.setText(s.description)
        for k, (ci, co) in self.combos.items():
            ci.setCurrentText(s.input[k]); co.setCurrentText(s.output[k])

    def load_file(self):
        path, _ = QFileDialog.getOpenFileName(self, "Load unit set", "", "Text files (*.txt)")
        if path:
            try:
                self._apply(U.UnitSet.load(path))
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Units", f"Could not load unit set:\n{e}")

    def save_file(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save unit set", "", "Text files (*.txt)")
        if path:
            try:
                self.current().save(path)
            except Exception as e:  # noqa: BLE001
                QMessageBox.critical(self, "Units", f"Could not save unit set:\n{e}")

    def accept(self):
        self.unit_set = self.current()
        super().accept()
