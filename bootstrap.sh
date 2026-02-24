#!/usr/bin/env bash
set -euo pipefail

host=""
ip=""
user="root"
port="22"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --host)
    host="$2"
    shift 2
    ;;
  --ip)
    ip="$2"
    shift 2
    ;;
  --user)
    user="$2"
    shift 2
    ;;
  --port)
    port="$2"
    shift 2
    ;;
  --help)
    echo "Usage: $0 --host <hostname> --ip <ip-address> [--user <user>] [--port <port>]"
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  esac
done

if [[ -z "$host" || -z "$ip" ]]; then
  echo "Error: --host and --ip are required" >&2
  echo "Usage: $0 --host <hostname> --ip <ip-address> [--user <user>] [--port <port>]" >&2
  exit 1
fi

temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"

ssh-keygen -q -t rsa -b 4096 -C "${host}" -N "" -f "$temp/etc/ssh/ssh_host_rsa_key"
ssh-keygen -t ed25519 -C "${host}" -N "" -f "$temp/etc/ssh/ssh_host_ed25519_key"

ssh-to-age -i "$temp/etc/ssh/ssh_host_ed25519_key.pub" -o /tmp/age.txt

nvim .sops.yaml /tmp/age.txt

shred -u /tmp/age.txt

sops updatekeys ./secrets/**/*.yaml

nixos-anywhere --extra-files "$temp" --flake ".#${host}" --target-host "${user}@${ip}" --ssh-port "$port" --generate-hardware-config nixos-facter ./machines/rababou/facter.json
