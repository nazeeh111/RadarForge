# Verification

Tested locally with MATLAB R2026a Update 5 (26.1.0.3346908), using base MATLAB. Only MATLAB, Simulink and System Composer were installed; additional research toolboxes were not assumed available.

## Passed

The full configured radar DSP generated a 96 × 64 × 32 heatmap from a deterministic tone at one receiver in a 400 × 40 × 40 input. The facade matched exactly, the result was finite/nonnegative/nonzero, and the expected range peak was recovered.

The 827 retained source and asset files in [SOURCE-MANIFEST.json](SOURCE-MANIFEST.json) are SHA-256 identical to the pre-rebrand snapshot. This establishes source and asset preservation, not full scientific replication. New wrappers and smoke checks are separate from those files. No computational core was rewritten.

## Reproduce

From the repository root in MATLAB:

```matlab
run('tests/smoke_test.m')
```

The test uses only local synthetic inputs or bundled data. It does not acquire or transmit signals. Assertions fail if a checked condition is not satisfied.

## Limits

Full CAD-to-radar synthesis calls `datasample` from Statistics and Machine Learning Toolbox and `awgn` from Communications Toolbox. Dataset-wide replication, measured hardware, and learned reconstruction are not checked. No trained cGAN implementation is included in this repository.

The facade restores the MATLAB search path after a call. Legacy figure output and computational behavior are preserved. This release has new branding, documentation, artwork, and an entry-point facade; it does not claim a new underlying research algorithm.

## Current DSP check, 2026-10-23

The existing `tests/smoke_test.m` passed again at revision `3995466ebf265ea50f92e221d348957b68e7adcc` with MATLAB R2026a Update 5. This reconfirmed full configured output dimensions, exact facade parity, finite nonnegative nonzero output, and the expected range-bin peak. It did not validate arrival-angle accuracy or run the full CAD pipeline.

Neither `datasample` nor `awgn` was available in this installation. A three-reflector signal-simulation fixture reached the `awgn` call and stopped there with an undefined-function error. No substitute noise model was used and no full-synthesis result is claimed.


## Generated surface-to-heatmap checks (2026-10-29)

The new example uses original, procedurally generated box geometry, not any
retained dataset picture or CAD asset. `tests/synthesis_test.m` compares selected
actual simulated samples against an independent scalar bistatic-distance/phase
formula on one, two and four reflectors. It checks range/array units and a plane
wave's known range, azimuth and elevation peaks, Gaussian noise power and
complex symmetry, and changed-input 6m/8m complete scene runs. Inputs are metres;
x is right, y is forward, z is up. DSP azimuth is measured from +x, elevation
is the polar angle from +z, and range is half the bistatic TX/RX path length.

Two original defects prevented small-scene simulation: `length(Nx3)` miscounted
one/two-row inputs and `/` attempted matrix division by a 3D receiver-distance
array. These now use row count and elementwise path loss. Empty reflector
selection is now explicitly an empty Nx3 output. Existing DSP summation is
expressed as nested sums for Octave support; rounding differences across runtime
versions are possible and tested with numerical tolerances.

Native MATLAB here could not execute: the sandboxed process failed Qt's CPU
check, and the native invocation reported MathWorks service error5201. No license
or credentials were changed. The hosted free Octave job reproduces the original
failure from commit333f756a and executes the actual production MATLAB-compatible
functions. Check its exact-commit result before treating that gate as passed.
The optional legacy datasample path still requires Statistics Toolbox; base
sampling has the same replacement distribution, not a promised identical RNG
sequence. No measured radar validation, external CAD import, dataset license
clearance or learned reconstruction is established.
