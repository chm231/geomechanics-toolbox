"""Read/write the TherCal project text file (File > Open / Save As in TherCal.m).

Format (tab separated, see src/reservTemp_projects/saveTest.txt)::

    Thermal calculator data file
    Last updated date: 2016-08-11, 23:02:28

    Thermal model: Gringarten equation
    Base data
    Parameter<TAB>Value<TAB>Unit
    Specific heat of rock<TAB>800<TAB>J/kg°C
    ...
    Variables
    ...
    Calculation results
    Outlet fluid temperature<TAB>161.67<TAB>°C
    Rock temperature distribution
    Z<TAB>X<TAB>Temperature
    m<TAB>m<TAB>°C
    0.00<TAB>0.00<TAB>60.00
    ...
"""
from __future__ import annotations

from datetime import datetime
from pathlib import Path

import numpy as np

from geomech.core.thermal import ThermalParams, TemperatureField

_MODEL_NAMES = {"bodvarsson": "Bodvarsson equation", "gringarten": "Gringarten equation",
                "radial": "Radial fracture"}
_BASE = [("Specific heat of rock", "c_r", "J/kg°C"), ("Specific heat of fluid", "c_w", "J/kg°C"),
         ("Rock density", "rho_r", "kg/m^3"), ("Thermal conductivity of rock, k", "K_r", "W/m°C"),
         ("Initial rock temperature", "T_ro", "°C"), ("Injection fluid temperature", "T_wo", "°C")]
_VARS = [("Width of fracture", "L", "m"), ("Mass flow rate", "Q_m", "kg/s"),
         ("Number of fractures", "N", ""), ("Fracture spacing", "spacing", "m"),
         ("Distance from injection", "z", "m"), ("Time", "t_year", "years")]


def save_project(path: str | Path, model: str, p: ThermalParams,
                 outlet: float | None = None, field: TemperatureField | None = None) -> None:
    lines = ["Thermal calculator data file",
             "Last updated date: " + datetime.now().strftime("%Y-%m-%d, %H:%M:%S"), "",
             "Thermal model: " + _MODEL_NAMES[model], "Base data", "Parameter\tValue\tUnit\t"]
    lines += [f"{name}\t{getattr(p, attr):g}\t{unit}\t" for name, attr, unit in _BASE]
    lines += ["", "Variables", "Variable\tValue\tUnit\t"]
    lines += [f"{name}\t{getattr(p, attr):g}\t{unit}\t" for name, attr, unit in _VARS]
    lines += ["", "Calculation results",
              f"Outlet fluid temperature\t{'' if outlet is None else f'{outlet:.2f}'}\t°C\t",
              "Rock temperature distribution",
              ("R" if model == "radial" else "Z") + "\tX\tTemperature\t", "m\tm\t°C\t"]
    if field is not None:
        for i in range(field.T.shape[0]):
            for j in range(field.T.shape[1]):
                lines.append(f"{field.along[i, j]:.2f}\t{field.normal[i, j]:.2f}\t{field.T[i, j]:.2f}\t")
    Path(path).write_text("\r\n".join(lines) + "\r\n", encoding="utf-8")


def load_project(path: str | Path) -> tuple[str, ThermalParams, float | None]:
    """Returns (model, params, outlet_temperature_or_None). Tolerates cp949 files from MATLAB."""
    raw = Path(path).read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("cp949", errors="replace")
    values: dict[str, float] = {}
    model = None
    for line in text.splitlines():
        if line.startswith("Thermal model:"):
            name = line.split(":", 1)[1].strip().lower()
            model = ("bodvarsson" if name.startswith("bodvarsson") else
                     "gringarten" if name.startswith("gringarten") else "radial")
            continue
        cells = line.split("\t")
        for name, attr, _ in _BASE + _VARS + [("Outlet fluid temperature", "outlet", "")]:
            if cells[0] == name and len(cells) > 1 and cells[1].strip():
                values[attr] = float(cells[1])
    if model is None:
        raise ValueError("not a TherCal project file (no 'Thermal model:' line)")
    outlet = values.pop("outlet", None)
    values["N"] = int(values.get("N", 1))
    missing = [a for _, a, _ in _BASE + _VARS if a not in values]
    if missing:
        raise ValueError(f"project file is missing: {', '.join(missing)}")
    return model, ThermalParams(**values), outlet
