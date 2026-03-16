#!/usr/bin/env python3

import argparse
import json
import pathlib
import shutil
import subprocess
import tarfile
import tempfile


def run(cmd, cwd=None):
    subprocess.run(cmd, cwd=cwd, check=True)


def add_tree(tf, root, arc_prefix):
    for path in sorted(root.rglob("*")):
        name = path.name
        if name.startswith("._") or name == ".DS_Store":
            continue
        arcname = pathlib.Path(arc_prefix) / path.relative_to(root)
        tf.add(path, arcname=str(arcname), recursive=False)


def main():
    parser = argparse.ArgumentParser(description="Create a Fabric lifecycle chaincode package on the host")
    parser.add_argument("--source", required=True, help="Path to the chaincode source directory")
    parser.add_argument("--path", help="metadata.json path field")
    parser.add_argument("--label", required=True, help="metadata.json label field")
    parser.add_argument("--output", required=True, help="Output .tar.gz path")
    parser.add_argument(
        "--kind",
        choices=("golang", "external", "ccaas"),
        default="golang",
        help="Lifecycle package type",
    )
    parser.add_argument("--connection-address", help="External chaincode server address")
    parser.add_argument(
        "--connection-timeout",
        default="10s",
        help="External chaincode dial timeout",
    )
    args = parser.parse_args()

    source_dir = pathlib.Path(args.source).resolve()
    output_file = pathlib.Path(args.output).resolve()
    if not source_dir.is_dir():
        raise SystemExit(f"chaincode source not found: {source_dir}")

    if args.kind == "golang" and not args.path:
        raise SystemExit("--path is required for golang packages")
    if args.kind in ("external", "ccaas") and not args.connection_address:
        raise SystemExit("--connection-address is required for external packages")

    if args.kind == "golang" and (source_dir / "go.mod").exists():
        run(["go", "mod", "vendor"], cwd=str(source_dir))

    output_file.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="fabric-ccpkg-") as tmp_dir:
        tmp_root = pathlib.Path(tmp_dir)
        metadata = {"type": args.kind, "label": args.label}
        if args.kind == "golang":
            src_root = tmp_root / "src" / pathlib.Path(args.path)
            src_root.parent.mkdir(parents=True, exist_ok=True)
            shutil.copytree(
                source_dir,
                src_root,
                dirs_exist_ok=True,
                ignore=shutil.ignore_patterns("._*", ".DS_Store"),
            )
            metadata["path"] = args.path

        metadata_file = tmp_root / "metadata.json"
        metadata_file.write_text(json.dumps(metadata, separators=(",", ":")), encoding="utf-8")

        code_archive = tmp_root / "code.tar.gz"
        with tarfile.open(code_archive, "w:gz", format=tarfile.PAX_FORMAT) as tf:
            if args.kind == "golang":
                add_tree(tf, tmp_root / "src", "src")
            else:
                connection = {
                    "address": args.connection_address,
                    "dial_timeout": args.connection_timeout,
                    "tls_required": False,
                }
                connection_file = tmp_root / "connection.json"
                connection_file.write_text(
                    json.dumps(connection, separators=(",", ":")),
                    encoding="utf-8",
                )
                tf.add(connection_file, arcname="connection.json", recursive=False)

        with tarfile.open(output_file, "w:gz", format=tarfile.PAX_FORMAT) as tf:
            tf.add(metadata_file, arcname="metadata.json", recursive=False)
            tf.add(code_archive, arcname="code.tar.gz", recursive=False)

    print(output_file)


if __name__ == "__main__":
    main()
