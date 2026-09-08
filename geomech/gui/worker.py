"""Run a computation off the Qt main thread and hand the result back on it.

    run_async(panel, fn, on_done, busy=(button, ...), status=label, args=(...))

`fn(*args, **kwargs)` runs in the global QThreadPool; `on_done(result)` is called on the
GUI thread. While the job runs the `busy` widgets are disabled and the wait cursor is
shown; an exception in `fn` ends in a message box. With SYNC = True (tests, screenshots)
the job runs inline, so callers behave exactly as before.
"""
from __future__ import annotations

import traceback

from PySide6.QtCore import QObject, QRunnable, Qt, QThreadPool, Signal, Slot
from PySide6.QtGui import QCursor
from PySide6.QtWidgets import QApplication, QMessageBox, QWidget

SYNC = False


class _Signals(QObject):
    done = Signal(object)
    failed = Signal(str)


class _Job(QRunnable):
    def __init__(self, fn, args, kwargs):
        super().__init__()
        self.fn, self.args, self.kwargs = fn, args, kwargs
        self.signals = _Signals()

    @Slot()
    def run(self):
        try:
            result = self.fn(*self.args, **self.kwargs)
        except Exception as e:  # noqa: BLE001
            self.signals.failed.emit(f"{e}\n\n{traceback.format_exc(limit=2)}")
            return
        self.signals.done.emit(result)


def run_async(owner: QWidget, fn, on_done, *, title: str = "Computation", busy=(), status=None,
              args=(), kwargs=None) -> None:
    kwargs = kwargs or {}
    if SYNC:
        try:
            result = fn(*args, **kwargs)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(owner, title, f"{title} failed:\n{e}")
            return
        on_done(result)
        return

    for w in busy:
        w.setEnabled(False)
    if status is not None:
        status.setText("Computing…")
    QApplication.setOverrideCursor(QCursor(Qt.CursorShape.WaitCursor))
    job = _Job(fn, args, kwargs)
    jobs = owner.__dict__.setdefault("_async_jobs", [])   # keep the job (and its signals) alive
    jobs.append(job)

    def finish():
        QApplication.restoreOverrideCursor()
        for w in busy:
            w.setEnabled(True)
        if job in jobs:
            jobs.remove(job)

    def ok(result):
        finish()
        try:
            on_done(result)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(owner, title, f"{title} failed:\n{e}")

    def bad(msg):
        finish()
        if status is not None:
            status.setText("")
        QMessageBox.critical(owner, title, f"{title} failed:\n{msg}")

    job.signals.done.connect(ok, Qt.ConnectionType.QueuedConnection)
    job.signals.failed.connect(bad, Qt.ConnectionType.QueuedConnection)
    QThreadPool.globalInstance().start(job)
