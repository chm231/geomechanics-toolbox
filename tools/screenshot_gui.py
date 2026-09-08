"""Open the launcher and each panel, run its default case, save screenshots and exit.

    python tools/screenshot_gui.py out_dir [scenario ...]
        scenarios: hydrofrac thermal mohr anisotropy borehole hydroshear stereonet dfn

The steps live in geomech.gui.smoke (shared with `geomech --smoke-test`).
"""
from __future__ import annotations

import sys
from pathlib import Path

from geomech.gui import smoke


def main() -> int:
    out = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    names = sys.argv[2:] or None
    rc = smoke.run(out=out, names=names)
    print("screenshots written to", out)
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
