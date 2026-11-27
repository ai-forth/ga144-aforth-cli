# ga144-aforth-cli

An aForth development toolchain for the GreenArrays GA144 manycore chip. It
compiles aForth source, produces GA144 bootstreams, can load them over serial
to hardware, and runs programs in a non-interactive simulator.

It is a Racket command-line application: no Emacs installation or generated
editor launcher is required.

## What is included

- `src/` — Racket CLI, compiler, bootstream generator, and GA144 model.
- `examples/` — aForth programs, including the Lucas-series hardware example.
- `lib/` — reusable aForth support libraries.
- `tests/` — compiler, simulator, breakpoint, pin, and target-chip tests.
- `ga-load` — serial bootstream loader and listener for a connected GA144.
- `ref/` — reference material and conversion utilities.

## Requirements

- Racket for the CLI and tests.
- Python 3 with `pyserial` only when using `ga-load` with real hardware.
- Linux is the tested host platform.

## Quick start

Make the local command-line tools executable:

```sh
make
```

The commands run directly from the checkout; no compilation step is needed.

Compile an aForth program and print the default JSON-formatted compilation
data:

```sh
./ga examples/lucas-series.aforth
```

Useful compiler options include:

```sh
./ga --pretty examples/lucas-series.aforth  # human-readable output
./ga --bootstream examples/lucas-series.aforth
./ga --only-bootstream examples/lucas-series.aforth
./ga --symbols examples/lucas-series.aforth
./ga --help
```

Run a program until simulated nodes suspend:

```sh
./ga --run examples/lucas-series.aforth
```

## Tests

Run the Racket test suite with:

```sh
make check
```

The CLI also exposes the same Racket test suites:

```sh
./ga --test       # compiler tests
./ga --test-all   # compiler and simulator tests; slower
```

## Loading hardware

With a GA144 connected on a serial device, generate, transmit, and then listen
for output from a bootstream:

```sh
./ga-load examples/lucas-series.aforth /dev/ttyUSB0 --speed 460800
```

The default bootstream type is `async` (node 708 serial). `2wire` and
`async-target` are also supported:

```sh
./ga-load program.aforth /dev/ttyUSB0 --bootstream 2wire
```

Use the serial device appropriate to the connected board; on Linux it can
often be identified after connection with `dmesg` or by inspecting `/dev`.

## License

This project is distributed under the GNU General Public License, version 3.
