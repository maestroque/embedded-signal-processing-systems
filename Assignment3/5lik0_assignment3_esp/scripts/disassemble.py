import argparse
import os
from pathlib import Path


P_ROOT = Path(__file__).parent.parent


def main(args: dict):
    p_build: Path = args["build-directory"]
    p_cmake_cache: Path = p_build / "CMakeCache.txt"

    # Find CMAKE_CXX_COMPILER in CMakeCache.txt
    p_tools: Path | None = None
    with open(p_cmake_cache, "r") as f:
        for line in f:
            if "CMAKE_LINKER:FILEPATH" in line:
                p_tools = Path(line.split("=")[1].strip()).parent
                break
            
    if p_tools is None:
        raise FileNotFoundError(f"Could not find ESP32 tools path in {p_cmake_cache}")
    
    p_objdump = next(p_tools.glob("xtensa-esp32-elf-objdump*"))
    if not p_objdump.exists():
        raise FileNotFoundError(f"Could not find objdump at {p_objdump}")

    # Find the filter binary
    p_filter = p_build / "esp-idf/filter/libfilter.a"
    if not p_filter.exists():
        raise FileNotFoundError(f"Could not find filter at {p_filter}")

    # Disassemble the filter
    os.system(f"{p_objdump} --disassemble=filter_process -S {p_filter}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "Filter Disassemble", description="Disassembles the filter code"
    )

    parser.add_argument(
        "build-directory",
        type=str,
        help="Path to the build directory",
        default=P_ROOT / "build",
        nargs="?",
    )

    args = parser.parse_args()
    main(vars(args))
