"""Compatibility entry point for the current native data generator."""
from pathlib import Path
from runpy import run_path
run_path(str(Path(__file__).with_name("generate_data.py")),run_name="__main__")
