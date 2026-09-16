#!/usr/bin/env bash
# Fail if PROJECT-MAP.yaml drifts from the layout contract.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

python3 - <<'PY'
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("check-layout-map: PyYAML required (pip install pyyaml)")

errors = []
text = Path("PROJECT-MAP.yaml").read_text()

try:
    m = yaml.safe_load(text)
except yaml.YAMLError as exc:
    sys.exit(f"check-layout-map: PROJECT-MAP.yaml is not valid YAML: {exc}")

EXPECTED_KINDS = ["workspace", "product", "extract", "archive", "generated", "private"]
kinds = (m.get("layout") or {}).get("kinds")
if kinds != EXPECTED_KINDS:
    errors.append(f"layout.kinds must be {EXPECTED_KINDS}, got {kinds}")

if (m.get("layout") or {}).get("paths") != "repository-relative":
    errors.append("layout.paths must be repository-relative")

root_node = m.get("root") or {}
if root_node.get("kind") != "workspace":
    errors.append(f"root.kind must be workspace, got {root_node.get('kind')!r}")
if root_node.get("edit") is not False:
    errors.append("root.edit must be false (umbrella is not a product)")

for rel in root_node.get("edit_paths") or []:
    if not Path(rel).exists():
        errors.append(f"root.edit_paths entry does not exist: {rel}")

# Machine-specific paths must not leak into the contract.
for lineno, line in enumerate(text.splitlines(), 1):
    if "/Users/" in line or "/home/" in line:
        errors.append(f"absolute machine path at PROJECT-MAP.yaml:{lineno}")


def walk(node, trail):
    if isinstance(node, dict):
        kind = node.get("kind")
        if kind is not None:
            if kind not in EXPECTED_KINDS:
                errors.append(f"{trail}: unknown kind {kind!r}")
            if kind == "product" and node.get("edit") is True:
                products.append(trail)
            if kind in ("extract", "archive", "private") and node.get("edit") is not False:
                errors.append(f"{trail}: kind={kind} must set edit: false")
        for key, value in node.items():
            walk(value, f"{trail}.{key}" if trail else str(key))
    elif isinstance(node, list):
        for i, value in enumerate(node):
            walk(value, f"{trail}[{i}]")


products: list[str] = []
walk(m.get("projects") or {}, "projects")

EXPECTED_PRODUCTS = {"projects.Core", "projects.Community", "projects.Web.official"}
if set(products) != EXPECTED_PRODUCTS:
    errors.append(
        f"product+edit set must be {sorted(EXPECTED_PRODUCTS)}, got {sorted(products)}"
    )

if errors:
    print("✗ check-layout-map failed:")
    for e in errors:
        print(f"  {e}")
    sys.exit(1)

print(f"✓ PROJECT-MAP.yaml OK (root=workspace, {len(products)} product+edit paths)")
PY
