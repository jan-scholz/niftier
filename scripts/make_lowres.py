import sys

import nibabel as nib
import numpy as np


def main() -> None:
    src_path, dst_path = sys.argv[1], sys.argv[2]
    step = int(sys.argv[3]) if len(sys.argv) > 3 else 3

    img = nib.load(src_path)
    data = img.get_fdata(dtype=np.float32)
    low = data[::step, ::step, ::step]

    scale = np.eye(4)
    scale[0, 0] = step
    scale[1, 1] = step
    scale[2, 2] = step
    new_affine = img.affine @ scale

    low_img = nib.Nifti1Image(low.astype(np.float32), new_affine, img.header)
    low_img.header.set_data_dtype(np.float32)
    nib.save(low_img, dst_path)
    print(f"wrote {dst_path} shape={low.shape} (from {data.shape})")


if __name__ == "__main__":
    main()
