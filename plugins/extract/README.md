# extract

Universal archive extractor. No need to remember flags for each format.

## What it does

Extracts archives of any supported format into a subdirectory named after the archive.

Supported formats: `tar.bz2`, `tar.gz`, `tar.xz`, `tar.zst`, `tar`, `gz`, `bz2`, `xz`, `zip`, `jar`, `war`, `ear`, `7z`, `rar`, `zst`.

## Commands

| Command | Description |
|---------|-------------|
| `extract file.tar.gz` | Extract archive into `file/` |
| `x file.zip` | Short alias for extract |

## Notes

Requires standard system tools (`tar`, `unzip`, `gunzip`, etc.). For 7z and rar support, install `p7zip` and `unrar`.
