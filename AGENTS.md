# Repository Guidelines

## Project Structure & Module Organization

This repository is a shell-based installer for Clash/mihomo on Linux. Top-level entry points are `install.sh` and `uninstall.sh`. Shared command logic lives in `scripts/cmd/`, with Bash and Fish command wrappers plus `common.sh` helpers. Installation preflight, download, archive, and init-system detection logic is in `scripts/preflight.sh`. Service templates for supported init systems are in `scripts/init/`. Runtime assets and default configuration live under `resources/`, including `mixin.yaml`, profile metadata, GeoIP/geosite data, and the bundled Web UI archive at `resources/zip/dist.zip`.

## Build, Test, and Development Commands

- `bash -n install.sh uninstall.sh scripts/**/*.sh`: check shell syntax before committing.
- `shellcheck install.sh uninstall.sh scripts/**/*.sh`: run static analysis using the repository `.shellcheckrc`.
- `bash install.sh [mihomo|clash] [subscription-url]`: exercise a local install flow. This may download binaries and write to the configured `CLASH_BASE_DIR`.
- `bash uninstall.sh`: remove an installation created by the installer.

There is no build step; scripts are run directly. Avoid running install tests on a production machine unless you understand the `.env` target paths.

## Coding Style & Naming Conventions

Use LF line endings and two-space indentation, as defined in `.editorconfig`. Keep scripts POSIX-compatible where practical, but Bash is acceptable for existing Bash entry points. Function names in command helpers use lowercase with leading underscores for internal helpers, for example `_valid_config` and `_download_config`. Environment-style settings use uppercase names such as `CLASH_BASE_DIR` and `VERSION_MIHOMO`. Prefer existing logging helpers like `_okcat`, `_failcat`, and `_error_quit` for user-facing output.

## Testing Guidelines

No automated test suite is currently present. For script changes, run `bash -n` and `shellcheck`, then manually test the affected command path. For installer changes, verify both root and regular-user assumptions when possible, and include the init system tested, such as `systemd`, `OpenRC`, `runit`, `SysVinit`, or `nohup`.

## Commit & Pull Request Guidelines

The Git history follows concise Conventional Commit-style messages, for example `feat(mixin): ...`, `fix: ...`, and `docs: ...`. Keep commits focused on one behavior or documentation change. Pull requests should describe the user-visible change, list validation commands run, link related issues, and include terminal output or screenshots when UI/control-panel behavior changes.

## Security & Configuration Tips

Do not commit personal subscription URLs, generated `config.yaml*` files, or local profile data. Keep secrets out of `.env`; document new configuration keys with safe defaults.
