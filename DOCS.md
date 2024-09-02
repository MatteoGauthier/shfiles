# Documentation for Shell Utilities

This document provides an overview of the various shell utilities and aliases available in the configuration.

## Aliases

### General Aliases

- `y`: Shortcut for `yarn`.
- `modern_tsconfig`: Downloads a modern TypeScript configuration file.
- `pnpx`: Shortcut for `pnpm dlx`.
- `jsonbat`: Formats JSON using `json_pp` and `bat`.
- `tempfile`: Creates a temporary file, opens it in `nano`, and prints the file path.
- `search`: Searches for a pattern in a temporary file.
- `p`: Shortcut for `pnpm`.
- `prettyjson`: Pretty-prints JSON from stdin.
- `logjson`: Logs JSON from stdin.
- `logstdin`: Logs stdin.
- `nodearch`: Prints the architecture of the current Node.js process.
- `getrepos`: Lists repositories of the user `MatteoGauthier` sorted by the last push date.
- `publicip`: Fetches the public IP address.
- `localip`: Fetches the local IP address.
- `e`: Lists files with icons and sorts by date using `eza`.
- `ez`: Alias for `eza -l --icons -s date`.
- `lg`: Opens `lazygit`.
- `lzd`: Opens `lazydocker`.
- `dps`: Lists running Docker containers with formatted output.
- `h`: Searches command history using `fzf`.
- `xcd`: Changes directory using `xplr`.

### macOS Specific Aliases

- `tailscale`: Shortcut to run Tailscale from the Applications directory.

## Functions

### `readenv`

Reads environment variables from a specified file (default is `.env`) and exports them.

**Usage:**
```
readenv [filePath]
```

### `qrcode`

Generates a QR code from the input string or stdin.

**Usage:**
```
qrcode [input]
```

### `qrsvg`

Generates a QR code in SVG format from the input string or stdin.

**
