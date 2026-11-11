"""Generate a deterministic markdown inventory for calculator package ZIP releases."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import zipfile

RUNTIME_LIBRARIES = {"libload.8xv", "graphx.8xv", "keypadc.8xv", "fileioc.8xv"}


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def classify(filename: str, suffix: str) -> tuple[str, str]:
    lower_name = filename.casefold()
    upper_stem = Path(filename).stem.upper()

    if suffix == ".8xp":
        if upper_stem.startswith("SCO"):
            return "program", "Scouts"
        if upper_stem.startswith("PED"):
            return "program", "Pedro"
        raise SystemExit(f"Unsupported program filename: {filename}")

    if lower_name in RUNTIME_LIBRARIES:
        return "runtime", Path(filename).stem

    if suffix == ".8xv":
        if upper_stem.startswith("SCA"):
            return "game_data", "Scouts"
        if upper_stem.startswith("PD"):
            return "game_data", "Pedro"

    raise SystemExit(f"Unsupported calculator file in manifest: {filename}")


def render_table(title: str, rows: list[dict[str, object]]) -> str:
    lines = [
        f"## {title}",
        "",
        "| filename | group/game | bytes | SHA-256 |",
        "| --- | --- | ---: | --- |",
    ]
    for row in rows:
        lines.append(
            f"| {row['filename']} | {row['group']} | {row['bytes']} | {row['sha256']} |"
        )
    lines.append("")
    return "\n".join(lines)


def generate_inventory(zip_path: Path, output_path: Path) -> None:
    zip_bytes = zip_path.read_bytes()
    zip_sha256 = sha256_hex(zip_bytes)

    with zipfile.ZipFile(zip_path) as archive:
        manifest_paths = sorted(
            name for name in archive.namelist() if name == "manifest.json" or name.endswith("/manifest.json")
        )
        if len(manifest_paths) != 1:
            raise SystemExit(
                f"Expected exactly one manifest.json in ZIP, found {len(manifest_paths)}: {manifest_paths}"
            )

        manifest_member = manifest_paths[0]
        prefix = manifest_member.removesuffix("manifest.json")
        manifest = json.loads(archive.read(manifest_member))
        if not isinstance(manifest, dict):
            raise SystemExit("manifest.json must be a JSON object keyed by filename")

        rows: list[dict[str, object]] = []
        for filename in sorted(manifest):
            entry = manifest[filename]
            if not isinstance(entry, dict):
                raise SystemExit(f"Manifest entry for {filename} must be an object")

            if "bytes" not in entry or "sha256" not in entry:
                raise SystemExit(f"Manifest entry for {filename} must include bytes and sha256")

            member_name = prefix + filename
            if member_name not in archive.namelist():
                raise SystemExit(f"Manifest references missing ZIP member: {filename}")

            data = archive.read(member_name)
            actual_bytes = len(data)
            actual_sha256 = sha256_hex(data)

            expected_bytes = entry["bytes"]
            expected_sha256 = str(entry["sha256"]).casefold()
            if actual_bytes != expected_bytes or actual_sha256 != expected_sha256:
                raise SystemExit(
                    "Manifest mismatch for "
                    f"{filename}: expected bytes={expected_bytes}, sha256={expected_sha256}; "
                    f"got bytes={actual_bytes}, sha256={actual_sha256}"
                )

            suffix = Path(filename).suffix.casefold()
            category, group = classify(filename, suffix)
            rows.append(
                {
                    "filename": filename,
                    "group": group,
                    "bytes": actual_bytes,
                    "sha256": actual_sha256,
                    "category": category,
                }
            )

    programs = [row for row in rows if row["category"] == "program"]
    game_data = [row for row in rows if row["category"] == "game_data"]
    runtime = [row for row in rows if row["category"] == "runtime"]

    if len(programs) != 2 or len(game_data) != 61 or len(runtime) != 4:
        raise SystemExit(
            "Unexpected inventory counts: "
            f"programs={len(programs)}, game_data={len(game_data)}, runtime={len(runtime)}"
        )

    total_files = len(rows)
    total_bytes = sum(int(row["bytes"]) for row in rows)

    lines = [
        "# Flash Games CE v9 Resource Inventory",
        "",
        "Deterministic inventory generated from the validated v9 calculator package ZIP.",
        "",
        f"- ZIP: `{zip_path.name}`",
        f"- ZIP SHA-256: `{zip_sha256}`",
        f"- Calculator files: **{total_files}**",
        f"- Total calculator bytes: **{total_bytes}**",
        "",
    ]
    lines.append(render_table("Programs (2)", programs))
    lines.append(render_table("Game-data AppVars (61)", game_data))
    lines.append(render_table("Runtime libraries (4)", runtime))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="utf-8", newline="\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--zip", required=True, type=Path, help="Path to release ZIP")
    parser.add_argument("--output", required=True, type=Path, help="Output markdown path")
    args = parser.parse_args()

    generate_inventory(args.zip, args.output)


if __name__ == "__main__":
    main()
