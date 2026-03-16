#!/usr/bin/env python3

import argparse
import http.client
import json
import pathlib
import sys
import uuid


def request(method: str, orderer: str, path: str, body: bytes | None = None, headers: dict[str, str] | None = None):
    host, port = orderer.split(":", 1)
    conn = http.client.HTTPConnection(host, int(port), timeout=30)
    conn.request(method, path, body=body, headers=headers or {})
    resp = conn.getresponse()
    payload = resp.read().decode("utf-8", errors="replace")
    conn.close()
    return resp.status, payload


def encode_block_upload(block_path: pathlib.Path):
    boundary = f"----codex-{uuid.uuid4().hex}"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="config-block"; filename="{block_path.name}"\r\n'
        "Content-Type: application/octet-stream\r\n\r\n"
    ).encode("utf-8") + block_path.read_bytes() + f"\r\n--{boundary}--\r\n".encode("utf-8")
    headers = {"Content-Type": f"multipart/form-data; boundary={boundary}"}
    return body, headers


def list_channels(orderer: str):
    status, payload = request("GET", orderer, "/participation/v1/channels")
    if status != 200:
        raise RuntimeError(f"{orderer}: GET failed with {status}: {payload}")
    data = json.loads(payload)
    channels = data.get("channels") or []
    return [item["name"] for item in channels]


def join_channel(orderers: list[str], channel: str, block: pathlib.Path):
    body, headers = encode_block_upload(block)
    for orderer in orderers:
        status, payload = request("POST", orderer, "/participation/v1/channels", body=body, headers=headers)
        if status not in (200, 201, 202):
            if status == 405 and "channel already exists" in payload:
                print(f"{orderer}: channel {channel} already exists")
            else:
                raise RuntimeError(f"{orderer}: join failed with {status}: {payload}")
        else:
            print(f"{orderer}: join accepted {payload}")

        channels = list_channels(orderer)
        if channel not in channels:
            raise RuntimeError(f"{orderer}: channel {channel} not found after join, channels={channels}")
        print(f"{orderer}: channels={','.join(channels)}")


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    join_parser = subparsers.add_parser("join")
    join_parser.add_argument("--channel", required=True)
    join_parser.add_argument("--block", required=True)
    join_parser.add_argument("--orderer", action="append", required=True)

    list_parser = subparsers.add_parser("list")
    list_parser.add_argument("--orderer", action="append", required=True)

    args = parser.parse_args()

    try:
        if args.command == "join":
            join_channel(args.orderer, args.channel, pathlib.Path(args.block))
        elif args.command == "list":
            for orderer in args.orderer:
                channels = list_channels(orderer)
                print(f"{orderer}: {','.join(channels) if channels else '(none)'}")
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
