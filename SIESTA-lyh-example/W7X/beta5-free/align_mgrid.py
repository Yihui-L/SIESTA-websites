"""Convert the W7-X MAKEGRID S-grid to the BMW field-per-ampere convention."""

import argparse
from pathlib import Path
import re
import shutil

import numpy as np
from scipy.interpolate import RegularGridInterpolator
from scipy.io import netcdf_file


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("wout", type=Path, help="Case-local, converged free-boundary VMEC WOUT")
    parser.add_argument("--raw", type=Path, default=Path("mgrid_w7x.nc"))
    parser.add_argument("--output", type=Path, default=Path("mgrid_w7x_bmw.nc"))
    args = parser.parse_args()

    with netcdf_file(args.raw, "r", mmap=False) as raw, netcdf_file(args.wout, "r", mmap=False) as wout:
        grid = raw.variables
        state = wout.variables
        if grid["mgrid_mode"].data.tobytes() != b"S":
            raise ValueError("Expected MAKEGRID S mode in the raw grid")
        if state["mgrid_mode"].data.tobytes() not in (b"R", b"S"):
            raise ValueError("Expected a free-boundary WOUT with R or S mode")
        if state["ier_flag"].data.item() != 0:
            raise ValueError("Expected a converged VMEC WOUT")
        if grid["nfp"].data.item() != state["nfp"].data.item():
            raise ValueError("MGRID and WOUT field periods disagree")

        turns = grid["raw_coil_cur"].data.astype(float)
        currents = state["extcur"].data.astype(float)
        if not np.array_equal(turns, [108, 108, 108, 108, 108, 36, 36]):
            raise ValueError("Unexpected W7-X winding turns")
        if currents.shape != turns.shape or not np.isfinite(currents).all():
            raise ValueError("WOUT coil current groups disagree with MAKEGRID")

        r_axis = float(state["raxis_cc"].data.sum())
        poloidal_zero = state["xm_nyq"].data == 0
        wout_bphi = float(r_axis * state["bsupvmnc"].data[1, poloidal_zero].sum())
        r = np.linspace(grid["rmin"].data.item(), grid["rmax"].data.item(), grid["ir"].data.item())
        z = np.linspace(grid["zmin"].data.item(), grid["zmax"].data.item(), grid["jz"].data.item())
        bphi = sum(
            current * winding * grid[f"bp_{group:03}"].data[0]
            for group, (current, winding) in enumerate(zip(currents, turns), start=1)
        )
        raw_bphi = float(RegularGridInterpolator((z, r), bphi)([0, r_axis])[0])
        sign = float(np.sign(wout_bphi * raw_bphi))
        if not np.isfinite(sign) or sign == 0:
            raise ValueError("Cannot determine the toroidal-field orientation")

    shutil.copyfile(args.raw, args.output)
    with netcdf_file(args.output, "a", mmap=False) as output:
        output.w7x_t41_note = (
            b"BMW per ampere grid, derived from ORNL scaled per ampere-turn grid; "
            b"restore winding turns and use the reproduced T4-1 WOUT orientation for all B and A components."
        )
        output.w7x_t41_orientation_sign = sign
        for name, variable in output.variables.items():
            match = re.fullmatch(r"[ab][rpz]_(\d{3})", name)
            if match:
                variable[:] = variable.data * (sign * turns[int(match[1]) - 1])

    print(f"WOUT axis Bphi={wout_bphi:.9f} T, raw coils={raw_bphi:.9f} T, orientation={sign:+.0f}")
    print(f"Created {args.output}")


if __name__ == "__main__":
    main()
