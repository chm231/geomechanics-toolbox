# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller build of the Python toolbox as a single windowed executable.

    pip install pyinstaller
    pyinstaller --noconfirm GeomechanicsToolbox.spec      ->  dist/GeomechanicsToolbox.exe
    dist/GeomechanicsToolbox.exe --smoke-test              ->  exit code 0 when every module runs

The GUI reads data only through file dialogs, so no data files are bundled.
"""
import glob
import os
import sys

ROOT = os.path.abspath(SPECPATH)

# conda keeps the C runtime DLLs of the stdlib extension modules (_ctypes -> ffi.dll,
# _lzma -> liblzma.dll, ...) in Library/bin, which PyInstaller only finds when that folder is
# on PATH; add them explicitly so the build works from any shell.
binaries = []
conda_bin = os.path.join(sys.prefix, "Library", "bin")
if os.path.isdir(conda_bin):
    for pattern in ("ffi*.dll", "libexpat.dll", "liblzma.dll", "libbz2.dll", "libmpdec*.dll",
                    "sqlite3.dll", "zlib.dll", "libssl*.dll", "libcrypto*.dll"):
        binaries += [(path, ".") for path in glob.glob(os.path.join(conda_bin, pattern))]

a = Analysis(
    [os.path.join(ROOT, "tools", "launch.py")],
    pathex=[ROOT],
    binaries=binaries,
    datas=[],
    hiddenimports=[
        "matplotlib.backends.backend_qtagg",
        "scipy.special._special_ufuncs",
        "scipy.spatial.transform._rotation_groups",
    ],
    hookspath=[],
    runtime_hooks=[],
    excludes=[
        # not used by the toolbox; leaving them out keeps the exe small
        "tkinter", "_tkinter", "PyQt5", "PyQt6", "pandas", "IPython", "jupyter", "notebook",
        "pytest", "setuptools", "pip", "wheel", "sphinx", "PIL.ImageQt",
        # optional array backends referenced by scipy._lib.array_api_compat (GPU libraries, dask, ...)
        "cupy", "cupy_backends", "cupyx", "torch", "jax", "jaxlib", "dask", "sparse", "ndonnx",
        "array_api_strict", "skimage", "sympy", "pyarrow", "numba",
        "PySide6.QtWebEngineCore", "PySide6.QtWebEngineWidgets", "PySide6.QtQml", "PySide6.QtQuick",
        "PySide6.Qt3DCore", "PySide6.QtMultimedia", "PySide6.QtCharts", "PySide6.QtDataVisualization",
        "PySide6.QtPdf", "PySide6.QtBluetooth", "PySide6.QtNetwork", "PySide6.QtSql", "PySide6.QtTest",
    ],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="GeomechanicsToolbox",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    runtime_tmpdir=None,
    console=False,          # windowed: no console window behind the launcher
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
