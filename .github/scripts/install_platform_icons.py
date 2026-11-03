from pathlib import Path
import json
import re
import shutil


root = Path(__file__).resolve().parents[2]
icons = root / "safety-observation-icons"

android_source = icons / "android" / "res"
android_resources = root / "android" / "app" / "src" / "main" / "res"
for source_dir in android_source.iterdir():
    if source_dir.is_dir():
        shutil.copytree(
            source_dir,
            android_resources / source_dir.name,
            dirs_exist_ok=True,
        )

ios_source = icons / "ios"
ios_target = (
    root
    / "ios"
    / "Runner"
    / "Assets.xcassets"
    / "AppIcon.appiconset"
)
ios_target.mkdir(parents=True, exist_ok=True)
for source_file in ios_source.iterdir():
    if source_file.is_file():
        shutil.copy2(source_file, ios_target / source_file.name)

web_source = icons / "web"
web_target = root / "web"
for filename in (
    "apple-touch-icon.png",
    "favicon.ico",
    "icon-192-maskable.png",
    "icon-192.png",
    "icon-512-maskable.png",
    "icon-512.png",
):
    shutil.copy2(web_source / filename, web_target / filename)

manifest_file = web_target / "manifest.json"
manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
manifest["name"] = "Safety Observation"
manifest["short_name"] = "Safety Observation"
manifest["icons"] = [
    {
        "src": "favicon.ico",
        "type": "image/x-icon",
        "sizes": "16x16 32x32",
    },
    {"src": "icon-192.png", "type": "image/png", "sizes": "192x192"},
    {"src": "icon-512.png", "type": "image/png", "sizes": "512x512"},
    {
        "src": "icon-192-maskable.png",
        "type": "image/png",
        "sizes": "192x192",
        "purpose": "maskable",
    },
    {
        "src": "icon-512-maskable.png",
        "type": "image/png",
        "sizes": "512x512",
        "purpose": "maskable",
    },
]
manifest_file.write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

index_file = web_target / "index.html"
html = index_file.read_text(encoding="utf-8")
html = re.sub(r"<title>.*?</title>", "<title>Safety Observation</title>", html, count=1, flags=re.I | re.S)
html = re.sub(
    r"\s*<link\b[^>]*\brel=['\"](?:icon|apple-touch-icon)['\"][^>]*>",
    "",
    html,
    flags=re.I,
)
icon_links = (
    '  <link rel="icon" href="favicon.ico" sizes="any">\n'
    '  <link rel="apple-touch-icon" href="apple-touch-icon.png">\n'
)
if not re.search(r"</head>", html, flags=re.I):
    raise SystemExit("Could not find the web document head")
html = re.sub(r"</head>", icon_links + "</head>", html, count=1, flags=re.I)
index_file.write_text(html, encoding="utf-8")
