# Niftier Viewer

A small [NiiVue](https://niivue.com/) viewer, with slice/3D render controls
and interactive intensity thresholding.

## Usage

1. Put your volume at `data/volume.nii.gz` (gitignored — not checked in), or
   use any other path via `DATA`, e.g. `data/my_volume.nii.gz`.
2. `make install`
3. `make run` (or `make run DATA=data/my_volume.nii.gz`), then open the
   URL it prints — the `?data=...` in it is required; `view.html` alone
   won't load a volume. Change that query param to switch files without
   restarting the server.

## Threshold previews

Dragging the min/max threshold sliders against the full-res volume is slow,
because NiiVue rebuilds the entire GPU texture on every update. To keep
dragging smooth, `make run` also builds a downsampled preview volume next to
the source (`data/volume_lowres.nii.gz`, see `scripts/make_lowres.py`) that's
swapped in while a slider is held and swapped back to full-res on release.

The downsample factor defaults to 3x per axis (27x fewer voxels) and can be
overridden, e.g. `make run LOWRES_FACTOR=4`.
