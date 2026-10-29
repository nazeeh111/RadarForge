# RadarForge

Explore a multimodal millimeter-wave radar dataset and its MATLAB scene synthesizer: camera images, stereo depth, CAD geometry, radar point clouds, and radar heatmaps.

![Original HawkEye dataset examples: RGB camera, stereo depth, 3D radar point clouds and radar heatmaps](Dataset/documentation/dataset_showcase.JPG)

*Retained dataset examples. These are not newly generated or independently validated RadarForge results.*

## Try the signal-processing check

Open MATLAB in the repository folder and run this complete example:

```matlab
run('tests/smoke_test.m')
```

The check constructs a deterministic synthetic tone at one receiver, processes a **400 × 40 × 40** signal tensor, and verifies a **96 × 64 × 32** heatmap with the expected range peak. It uses base MATLAB and does not require a sensor or a learned model. [Verification and limits](docs/VERIFICATION.md).

## Recompute a complete synthetic scene

```matlab
addpath('examples');
scene_to_heatmap('scene-6m', 6, 42);
scene_to_heatmap('scene-8m', 8, 43);
run('tests/synthesis_test.m');
```

GNU Octave is a free alternative for these headless examples. They build an original
box surface in metres, select visible geometry with the retained HawkEye method,
sample reflectors, simulate the full 400 × 40 × 40 signal and compute a
96 × 64 × 32 heatmap. New output directories contain `scene.mat` and JSON
measurements. Existing outputs are refused. Seeds and distance are explicit;
the second scene changes the input and peak range. No CAD/dataset download,
learned model or physical capture is needed for this generated surface example.

The example explicitly uses uniform base-runtime sampling with replacement and
noise-free simulation. Legacy reflector calls retain `datasample` behavior.
Simulation defaults still use -10 dB noise relative to the historical 0 dBW
assumed power; a base-runtime complex Gaussian fallback removes the mandatory
Communications Toolbox for this convention. See [checks](docs/VERIFICATION.md).

## Process your signals

```matlab
heatmap = radar_forge(signal_array);
```

`signal_array` contains **fast-time samples × receiver x positions × receiver z positions**, with 400 × 40 × 40 samples under the bundled configuration. Fast time samples the signal within one frequency sweep. The output uses **range × azimuth angle × elevation angle** bins. The entry point forwards to the retained `radar_dsp` function and preserves its numerical output and errors.

Processing first applies a Fourier transform along fast time to separate ranges, then combines receiver signals with angle-dependent phase weights to estimate arrival directions. The output is squared signal magnitude, not a learned reconstruction.

## Explore the retained workflows

| Material | Start here |
| --- | --- |
| Dataset layout and capture conventions | [HawkEye dataset guide](Dataset/documentation/HawkEye_Dataset.pdf) |
| CAD models, placement, and synthesis | [Synthesizer guide](Synthesizer/documentation/HawkEye_Synthesizer.pdf) |
| Legacy CAD-to-heatmap implementation | [Synthesizer/scripts/main.m](Synthesizer/scripts/main.m) |
| Radar frequency, sampling, and array configuration | [`variable_library_radar.m`](Synthesizer/scripts/variable_library_radar.m) |

The CAD-to-radar workflow selects visible geometry, samples point reflectors, simulates receiver signals, and applies radar processing. It is separate from the base-MATLAB check above. Point sampling calls `datasample` from Statistics and Machine Learning Toolbox; signal simulation uses `awgn` when available, with an equivalent-power base-runtime fallback. The original CAD corpus and dataset-wide replication remain unverified; the new bounded generated-surface workflow is separately recomputable. Original script and function names remain available.

The repository contains the dataset and synthesizer, **not the HawkEye cGAN training implementation or a trained neural reconstruction model**.

<a id="source-and-license"></a>

## License

[Synthesizer/COPYRIGHT.txt](Synthesizer/COPYRIGHT.txt) retains the university notice. [LICENSE-branding](LICENSE-branding) covers new documentation, artwork, wrapper, and checks. Dataset and asset terms remain separate. [Source provenance](NOTICE.md).
