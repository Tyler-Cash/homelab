#!/usr/bin/env python3
import os
import sys
import subprocess
import shlex
from typing import Any, Set, List, Tuple

try:
    import yaml  # type: ignore
except Exception:
    yaml = None

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
HELM_DIR = os.path.join(ROOT, "kubernetes", "helm")


def iter_yaml_files(base: str):
    for dirpath, _, filenames in os.walk(base):
        for name in filenames:
            if name.lower().endswith(('.yml', '.yaml')):
                yield os.path.join(dirpath, name)


def is_chart_dir(path: str) -> bool:
    return os.path.isfile(os.path.join(path, "Chart.yaml"))


def iter_chart_dirs(base: str):
    for dirpath, dirnames, filenames in os.walk(base):
        if "Chart.yaml" in filenames:
            yield dirpath


def extract_images_from_obj(obj: Any, out: Set[str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            # Pattern 1: image is a string (e.g., "ghcr.io/org/app:tag@sha256:...")
            if k == "image" and isinstance(v, str):
                add_image(v, out)
            # Pattern 2: image is a mapping with repository+tag
            if k == "image" and isinstance(v, dict):
                repo = v.get("repository")
                tag = v.get("tag")
                if isinstance(repo, str) and repo:
                    if isinstance(tag, str) and tag:
                        add_image(f"{repo}:{tag}", out)
                    else:
                        # If only repository given, add repository as-is (scanner will pull latest)
                        add_image(repo, out)
            # Recurse
            extract_images_from_obj(v, out)
    elif isinstance(obj, list):
        for item in obj:
            extract_images_from_obj(item, out)


def add_image(image: str, out: Set[str]):
    image = image.strip()
    if not image:
        return
    # Some charts may set tag separately or include digest; keep as provided
    out.add(image)


def run(cmd: List[str], cwd: str | None = None, timeout: int = 300) -> Tuple[int, str, str]:
    try:
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return proc.returncode, proc.stdout, proc.stderr
    except Exception as e:
        return 1, "", str(e)


def helm_available() -> bool:
    code, out, err = run(["helm", "version", "--short"])
    return code == 0


def render_chart(chart_dir: str) -> str:
    # Try to build dependencies (best-effort)
    run(["helm", "dependency", "build"], cwd=chart_dir)

    # Prepare template command; prefer values.yaml if present
    values_path = os.path.join(chart_dir, "values.yaml")
    cmd = ["helm", "template", "rendered", chart_dir]
    if os.path.isfile(values_path):
        cmd.extend(["-f", values_path])

    code, out, err = run(cmd, cwd=chart_dir)
    if code != 0:
        # Return empty on failure; caller may fallback
        return ""
    return out


def parse_yaml_stream(stream: str, images: Set[str]):
    if not stream or yaml is None:
        return
    try:
        for doc in yaml.safe_load_all(stream):
            if doc is None:
                continue
            extract_images_from_obj(doc, images)
    except Exception:
        # ignore
        return


def parse_raw_values(images: Set[str]):
    # Fallback: parse all YAML files in HELM_DIR as before
    for path in iter_yaml_files(HELM_DIR):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            if not content.strip():
                continue
            if yaml is None:
                for line in content.splitlines():
                    s = line.strip()
                    if s.startswith('image:'):
                        val = s.split(':', 1)[1].strip().strip('"').strip("'")
                        if val:
                            add_image(val, images)
                continue
            for doc in yaml.safe_load_all(content):
                if doc is None:
                    continue
                extract_images_from_obj(doc, images)
        except Exception:
            continue


def main():
    if not os.path.isdir(HELM_DIR):
        print("", end="")
        return

    images: Set[str] = set()

    used_render = False
    if helm_available():
        for chart_dir in iter_chart_dirs(HELM_DIR):
            rendered = render_chart(chart_dir)
            if rendered:
                used_render = True
                parse_yaml_stream(rendered, images)

    if not images and not used_render:
        # Helm not available, or render produced nothing — fallback to raw parse
        parse_raw_values(images)

    for img in sorted(images):
        print(img)


if __name__ == "__main__":
    main()
