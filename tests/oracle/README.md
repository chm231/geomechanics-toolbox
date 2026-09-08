# Test oracles

`generate_dfn_v1.py` is an unmodified copy of `handoffv2/dfn generator v1/python/generate_dfn.py`
from the DFN modeling project (github.com/chm231/DFN, commit 33f318a, 2026-09-02). It is imported by
`tests/test_dfn_rockmass.py` only, to check that `geomech.core.dfn_rockmass` reproduces it exactly.
