# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

Never run these on your own. Always tell me when to run them.

- `rebuild` — Rebuild and switch NixOS system configuration (`nh os switch .`)
- `rehome` — Rebuild and switch home-manager configuration (`nh home switch .`)
- `reflake` — Update all flake inputs (`nix flake update`)
- `repair` — Repair nix store (`sudo nix-store --repair --verify --check-contents`)

## Architecture

Flake-based NixOS configuration managing two machines with standalone home-manager.

### Systems
- **nixos** — Desktop (AMD, NVME, ext4, systemd-boot)
- **nixie** — Framework AMD laptop (BTRFS+LUKS, Lanzaboote secure boot, hibernation)

### Key Files
- `flake.nix` — Entry point. Defines both nixosConfigurations and homeConfigurations. Inputs: nixos-unstable, home-manager, lanzaboote, nixos-hardware.
- `common.nix` — Shared NixOS config applied to both systems (Plasma 6, PipeWire, Docker, Steam, Tailscale, etc.)
- `nixos/configuration.nix` + `nixos/desktop.nix` — Desktop-specific config (monitor EDID, hostname)
- `nixie/configuration.nix` + `nixie/laptop.nix` — Laptop-specific config (secure boot, LUKS, power management, hibernation)
- `home-manager/home.nix` — User packages and program configs (browsers, dev tools, gaming)
- `home-manager/terminal.nix` — Shell environment (Fish, Neovim, Git, Zellij, Ghostty, Claude Code CLI settings)
- `overlays/default.nix` + `pkgs/default.nix` — Custom overlays and packages (currently empty templates)
- `modules/` — NixOS and home-manager module exports (currently empty templates)
- `workarounds.md` — Catalog of upstream-bug / stateVersion / hardware workarounds and when each can be dropped.

### Design Patterns
- **Common + specific split**: `common.nix` holds shared config; `desktop.nix`/`laptop.nix` hold machine-specific overrides.
- **Hardware configs are auto-generated**: Don't edit `hardware-configuration.nix` files directly.
- **Home-manager is standalone**: Not a NixOS module. Has its own `homeConfigurations` in the flake and is rebuilt separately with `rehome`.
- **User**: `ciferkey` on both machines.

## Workarounds

See [`workarounds.md`](workarounds.md) for the catalog of upstream-bug, `stateVersion`, and
hardware workarounds (with `file:line` pointers and removal triggers). Update it whenever a
workaround is added or removed.

## References
 - Home Manager options: https://nix-community.github.io/home-manager/options/home-manager/index.html
   (the legacy `options.xhtml` is now a JS-redirect stub after the mdBook migration).
 - **`nxv`** — preferred tool for nixpkgs package/version lookups (`nxv search <pkg>`, `nxv history <pkg>`).
   Configured in `home-manager/terminal.nix` in hosted-API mode (`NXV_API_URL=https://nxv.urandom.io`), so
   it queries the live hosted index — no ~220 MB local DB, no manual `nxv update` (needs network per query).
 - **mcp-nixos option search is broken.** The `mcp-nixos` server (`programs.mcp.servers.nixos`) returns no
   results for home-manager / NixOS *option* searches because the HM docs moved to an mdBook site. Fix is in
   draft at https://github.com/utensils/mcp-nixos/pull/174 (open/draft as of 2026-07-22). Until it lands,
   look up options via the mdBook options page above. Note: `nxv` does **not** search options — package
   versions only — so it is not a substitute for option search.

 ## Conventions
  - Lint and format the nix files when making changes.
