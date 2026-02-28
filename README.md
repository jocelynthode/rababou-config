# rababou-config

## Bootstrap

1. Clone this repository and enter it:
   - `git clone <repo-url>`
   - `cd rababou-config`
2. Run the bootstrap script for the target host:
   - Replace `<host>` with the host name defined in this repo.
   - Replace `<ip>` with the target machine IP address.
   - Optional: set `--user` (default: `root`) and `--port` (default: `22`).

```sh
./bootstrap.sh --host <host> --ip <ip>
```

## Using Colmena

Make sure to have a ssh config with `rababou` and your user as well as hostname setup

Common workflows:

```sh

# Build
colmena build

# Apply changes to all hosts
colmena apply

# Apply changes to a single host
colmena apply --on <host>
```

If you work in a dirty repo (not everything committed) add `--impure` at the end of your colmena command
