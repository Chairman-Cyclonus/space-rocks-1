"""Build a browser game and an itch.io ZIP without deleting existing files."""
import argparse
from pathlib import Path
import subprocess
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument("--godot", default="godot", help="Godot 4.7.2 executable")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
out = root / "build" / "web"
out.mkdir(parents=True, exist_ok=True)
subprocess.run([args.godot, "--headless", "--path", str(root), "--editor", "--import", "--quit"], check=True)
subprocess.run([args.godot, "--headless", "--path", str(root), "--export-release", "Web", str(out / "index.html")], check=True)
required = [out / ("index" + suffix) for suffix in [".html", ".js", ".wasm", ".pck"]]
for file in required:
    if not file.is_file() or file.stat().st_size == 0:
        raise SystemExit(f"Missing or empty export: {file}")
(out / ".nojekyll").touch()
archive = root / "build" / "space-rocks-itch.zip"
with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
    for file in sorted(out.iterdir()):
        if file.is_file():
            bundle.write(file, file.name)
with zipfile.ZipFile(archive) as bundle:
    assert bundle.testzip() is None
print(f"Ready for itch.io: {archive}")
print(f"GitHub Pages files: {out}")
