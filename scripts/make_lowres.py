import argparse

import nibabel as nib
import numpy as np


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Write a decimated copy of a NIfTI volume for fast threshold previews."
    )
    parser.add_argument("src", help="source .nii.gz volume")
    parser.add_argument("dst", help="where to write the downsampled volume")
    parser.add_argument(
        "factor",
        type=int,
        help="per-axis decimation step; voxel count shrinks by factor^3",
    )
    args = parser.parse_args()
    step = args.factor

    img = nib.load(args.src)
    data = img.get_fdata(dtype=np.float32)
    low = data[::step, ::step, ::step]

    # Keeping every step-th voxel stretches each voxel by `step` in world space.
    decimation = np.diag([step, step, step, 1.0])
    new_affine = img.affine @ decimation

    low_img = nib.Nifti1Image(low.astype(np.float32), new_affine, img.header)
    low_img.header.set_data_dtype(np.float32)
    nib.save(low_img, args.dst)
    print(f"wrote {args.dst} shape={low.shape} (from {data.shape})")


if __name__ == "__main__":
    main()
