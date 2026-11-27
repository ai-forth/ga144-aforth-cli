# Current Status

## Verification

`./ga --run examples/lucas-series.aforth` completes successfully.

`make check` currently fails. The compiler test suite reports a mismatch for
the node-205 forward-reference/tail-jump layout case in
`tests/test-compiler.rkt`: the compiler emits a call to address 18 where the
test expects address 19, and places the tail jump after `done` rather than
before it.

The failure is genuine: the compiler test harness now exits nonzero when a
compiler check fails, so Make stops before running the simulator suite.

## Next Investigation

Diagnose and repair the compiler's forward-reference relocation and word-shift
logic for the node-205 case, then rerun `make check`.
