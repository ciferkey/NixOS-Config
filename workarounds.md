# Workarounds

Catalog of the workarounds and fixes for upstream bugs, `stateVersion` transitions, and
hardware quirks scattered across this config. Each entry records the underlying issue, the
fix (with a `file:line` pointer), when it was added, and the trigger for removing it — so
they can be pruned as upstream resolves them. Update this file whenever a workaround is
added or removed.

_Not listed_ (considered and deliberately left out — intentional config, not
removable-on-fix): zswap/swappiness tuning, the `linuxPackages_latest` pin, `btop`
`rocmSupport`, Firefox `speechSynthesisSupport`, lanzaboote secure-boot setup, fzf/atuin
Ctrl-R, ghostty ssh integration, the `nxv` hosted-API wrap, and third-party flake inputs.

## Summary

| Workaround | File | Added | Remove when |
|---|---|---|---|
| Obsidian electron_41 crash | `home-manager/personal.nix:33` | 2026-07-17 | nixpkgs obsidian ships a patched electron_41 |
| vesktop hibernate hang | `home-manager/personal.nix:43` | 2026-07-12 | vesktop HW-accel works on AMD/Wayland |
| electron-40 EOL insecure exception | `home-manager/home.nix:46` | 2026-07-17 | vesktop bumps electron |
| Firefox profile path pin | `home-manager/personal.nix:108` | 2026-06-23 | fresh `stateVersion` ≥ 26.05 install |
| claude-code auto-compact window | `home-manager/terminal.nix:51` | 2026-06-23 | anthropics/claude-code#43989 resolves |
| claude-code installation checks | `home-manager/terminal.nix:54` | 2026-06-23 | anthropics/claude-code#17289 resolves |
| opencode lsp flag | `home-manager/personal.nix:137` | — | anomalyco/opencode#23566 resolves |
| opencode kagi auth header token rewrite | `home-manager/personal.nix:151` | 2026-07-17 | opencode's `{file:}` resolver gains shell expansion |
| opencode experimental-subagents env var | `home-manager/personal.nix:166` | 2026-07-17 | a scoped env mechanism exists |
| thunderbird-mcp two-half version skew | `home-manager/terminal.nix:97` | 2026-07-30 | upstream adds a version handshake, or the add-on is declarative |
| zellij fish integration | `home-manager/terminal.nix:300` | 2026-02-18 | home-manager PR #6695 lands in the pinned rev |
| SDDM → KWallet startup fix | `common.nix:153` | 2026-01-13 | KWallet starts under SDDM without `forceRun` |
| Monitor EDID override (BenQ XL2420G) | `nixos/desktop.nix:11` | 2025-08-21 | monitor reports a usable EDID on AMD |
| Framework ambient light sensor | `nixie/laptop.nix:37` | 2026-02-27 | bugs.kde.org#502122 resolves |
| Framework tlp disabled for tuned | `nixie/laptop.nix:27` | 2025-08-29 | (intentional; keep while using tuned) |
| esp32 plugdev group | `nixos/esp32.nix:9` | — | a module declares `plugdev` for us |
| NetworkManager-wait-online disabled | `common.nix:78` | 2025-12-04 | boot no longer hangs on it |
| uv standalone Python `/etc/ssl/cert.pem` | `common.nix:168` | 2026-08-04 | nixpkgs ships `/etc/ssl/cert.pem`, or python-build-standalone finds NixOS certs |
| mcp-nixos HM option search | `home-manager/terminal.nix:92` | 2026-08-04 | mcp-nixos release > 2.4.3 with the print.html loader is in the pinned nixpkgs |

---

## Electron / AMD

### Obsidian electron_41 crash

**Issue** — `electron_41` (obsidian's bundled default) crashes on startup with a
WASM-streaming renderer fault.

**Fix** — override to `electron_42` (>= 42.4.1 has the patch). `home-manager/personal.nix:33-36`

```nix
(obsidian.override {electron = electron_42;})
```

**Added** — 2026-07-17

**Remove when** — nixpkgs' obsidian picks up a patched `electron_41`.

**Link** — https://github.com/electron/electron/issues/52178

---

### vesktop hibernate hang

**Issue** — vesktop's Electron GPU process holds an amdgpu DMA fence that never signals
during the hibernate freeze → `amdgpu_vm_fini` / `dma_fence_wait_timeout` hangs and
hibernate aborts with "Device or resource busy".

**Fix** — wrap the binary with `--disable-gpu` via `symlinkJoin` + `wrapProgram`, forcing
the GPU off so hibernate works with vesktop running. `home-manager/personal.nix:43-53`

```nix
(pkgs.symlinkJoin {
  name = "vesktop";
  paths = [pkgs.vesktop];
  nativeBuildInputs = [pkgs.makeWrapper];
  postBuild = "wrapProgram $out/bin/vesktop --add-flags \"--disable-gpu\"";
})
```

**Added** — 2026-07-12

**Remove when** — vesktop HW-accel works on AMD/Wayland.

**Link** — https://github.com/Vencord/Vesktop/issues/1009

---

### electron-40 EOL insecure exception

**Issue** — vesktop pins `electron_40`, which went EOL 2026-07 and is flagged as an
insecure package.

**Fix** — allow the specific insecure package. `home-manager/home.nix:46-49`

```nix
permittedInsecurePackages = [
  "electron-40.10.5"
];
```

**Added** — 2026-07-17

**Remove when** — vesktop bumps electron.

---

## stateVersion 26.05 pins

These pin pre-26.05 home-manager defaults so the existing state keeps working. Drop each on
a fresh `stateVersion` ≥ 26.05 install.

### Firefox profile path pin

**Issue** — home-manager changed the default Firefox config path in 26.05; the existing
profile lives at the old path.

**Fix** — pin the pre-26.05 path. `home-manager/personal.nix:108-109`

```nix
configPath = ".mozilla/firefox";
```

**Added** — 2026-06-23

**Remove when** — set up on a fresh `stateVersion` ≥ 26.05 install.

---

## Claude Code / opencode

### claude-code auto-compact window

**Issue** — the default auto-compact window triggers context compaction earlier than wanted.

**Fix** — raise it via env. `home-manager/terminal.nix:51`

```nix
CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
```

**Added** — 2026-06-23

**Link** — https://github.com/anthropics/claude-code/issues/43989

---

### claude-code installation checks

**Issue** — claude-code's installation checks misbehave under the Nix-managed install.

**Fix** — disable them via env. `home-manager/terminal.nix:54`

```nix
DISABLE_INSTALLATION_CHECKS = "1";
```

**Added** — 2026-06-23

**Link** — https://github.com/anthropics/claude-code/issues/17289

---

### opencode lsp flag

**Issue** — opencode LSP integration needs to be explicitly enabled to work as expected.

**Fix** — set the flag. `home-manager/personal.nix:137`

```nix
lsp = true;
```

**Remove when** — anomalyco/opencode#23566 resolves.

**Link** — https://github.com/anomalyco/opencode/issues/23566

---

### opencode kagi auth header token rewrite

**Issue** — opencode's `{file:}` resolver can't shell-expand `${XDG_RUNTIME_DIR}` in the
agenix secret path, and it trims file contents (dropping the secret's trailing newline).

**Fix** — `lib.replaceStrings` rewrites `${XDG_RUNTIME_DIR}` to opencode's own `{env:}`
token, which runs in the env pass before the file pass. `home-manager/personal.nix:151-157`

```nix
headers.Authorization = "Bearer {file:${
  lib.replaceStrings ["\${XDG_RUNTIME_DIR}"] ["{env:XDG_RUNTIME_DIR}"]
  config.age.secrets.kagi-api-key.path
}}";
```

**Added** — 2026-07-17

**Remove when** — opencode's `{file:}` resolver gains shell expansion.

---

### opencode experimental-subagents env var

**Issue** — opencode reads `OPENCODE_EXPERIMENTAL_*` from the process environment, not its
config file (`opencode.json` has no `env` field, unlike claude-code's settings), and the
upstream `programs.opencode` home-manager module exposes no env option nor wraps the binary
with `--set`.

**Fix** — set it globally in the shell environment. `home-manager/personal.nix:166-171`

```nix
home.sessionVariables.OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = "true";
```

**Added** — 2026-07-17

**Remove when** — a scoped env mechanism (shell wrapper / upstream env option) exists.

---

### thunderbird-mcp two-half version skew

**Issue** — thunderbird-mcp ships as two halves that must agree on a protocol: the Node stdio
bridge (`pkgs.thunderbird-mcp`, pinned to 0.7.4 by the locked nixpkgs) and a Thunderbird
add-on (XPI) that runs the in-Thunderbird HTTP server. Only the bridge is declared here. The
add-on is installed manually through Thunderbird's UI and, from v0.7.3 on, **self-updates**
via Thunderbird's add-on updater — so it can move ahead of the Nix-pinned bridge with no
signal, and there is no version-negotiation handshake to catch the mismatch.

The add-on isn't declarable in this config: it's a GitHub release asset, not in the Nix output
(the source tarball's `files` list omits `dist/`), and this config uses `pkgs.thunderbird` as a
plain package rather than the `programs.thunderbird` module — managing extensions there would
mean declaring profiles and accounts. Pinning an XPI in the store would also fight the
self-updater.

**Fix** — none available; documented instead. The bridge is declared at
`home-manager/terminal.nix:97-102`:

```nix
servers.thunderbird = {
  command = lib.getExe pkgs.thunderbird-mcp;
  enabled = true;
};
```

Symptom of skew: the bridge connects (`/tmp/thunderbird-mcp/connection.json` exists) but tool
calls fail or return malformed results. Realign by bumping the nixpkgs pin, or by installing
the XPI matching the bridge version from the upstream releases page.

**Added** — 2026-07-30

**Remove when** — upstream ships a version-negotiation handshake between bridge and add-on, or
the add-on becomes declaratively manageable.

**Link** — https://github.com/TKasperczyk/thunderbird-mcp

---

### zellij fish integration

**Issue** — home-manager's zellij module didn't wire up fish integration until PR #6695.

**Fix** — enable it explicitly. `home-manager/terminal.nix:275`

```nix
enableFishIntegration = true;
```

**Added** — 2026-02-18

**Remove when** — home-manager PR #6695 is in the pinned rev and provides this by default.

**Link** — https://github.com/nix-community/home-manager/pull/6695 (the inline comment has a
`6695clade` → `6695` typo worth fixing next time that line is touched).

---

## KDE / Plasma

### SDDM → KWallet startup fix

**Issue** — SDDM didn't start KWallet properly, and the lockscreen password also needs to
unlock/start KWallet.

**Fix** — enable the `plasma-login-manager.kwallet` and `kde.kwallet` PAM services with
`forceRun = true`. `common.nix:153-160`

```nix
plasma-login-manager.kwallet = {
  enable = true; # Fix to allow SDDM to start KWallet properly
  forceRun = true;
};
kde.kwallet = {
  enable = true; # Allow lockscreen password to also start KWallet
  forceRun = true;
};
```

**Added** — 2026-01-13 / 2026-02-11

**Remove when** — KWallet starts correctly under SDDM without `forceRun`.

---

## Hardware

### Monitor EDID override (BenQ XL2420G on AMD)

**Issue** — the BenQ XL2420G reports a bad/insufficient EDID on the AMD desktop, so the mode
needs to be forced.

**Fix** — supply a known-good EDID and mode. `nixos/desktop.nix:11-14`

```nix
hardware.display.edid.linuxhw."XL2420G_2014" = ["BNQ7F39" "XL2420G" "2014" "2E7C0DC569A3"];
hardware.display.outputs."DP-2".edid = "XL2420G_2014.bin";
hardware.display.outputs."DP-2".mode = "e";
```

**Added** — 2025-08-21

**Remove when** — the monitor reports a usable EDID on AMD (hardware-specific; likely
permanent while this monitor is in use).

---

### Framework ambient light sensor (KDE 6.6)

**Issue** — the Framework laptop's ambient light sensor isn't picked up by KDE 6.6 without
the iio sensor proxy.

**Fix** — enable it. `nixie/laptop.nix:37-39`

```nix
hardware.sensor.iio.enable = true;
```

**Added** — 2026-02-27

**Remove when** — bugs.kde.org#502122 resolves.

**Link** — https://bugs.kde.org/show_bug.cgi?id=502122

---

### Framework: tlp disabled for tuned

**Issue** — the `nixos-hardware` Framework module enables `tlp`, but Framework recommends
_against_ using tlp; this config uses `tuned` instead.

**Fix** — force tlp off. `nixie/laptop.nix:27-35`

```nix
services.tlp.enable = false;
```

**Added** — 2025-08-29

**Remove when** — intentional; keep while `tuned` is the chosen power manager. (Not an
upstream bug — listed because it counteracts a `nixos-hardware` default.)

---

### esp32 plugdev group

**Issue** — the `plugdev` group (used for esp32 serial/flash access) isn't declared by any
module, so it has to be created explicitly.

**Fix** — declare it. `nixos/esp32.nix:9`

```nix
users.groups.plugdev = {}; # need to make explicitly
```

**Remove when** — a module we import declares `plugdev` for us.

---

## Boot / system

### NetworkManager-wait-online disabled

**Issue** — `NetworkManager-wait-online` stalls boot waiting for the network.

**Fix** — disable the unit. `common.nix:78`

```nix
systemd.services.NetworkManager-wait-online.enable = false;
```

**Added** — 2025-12-04

**Remove when** — boot no longer hangs on it (or a service genuinely needs network-online
ordering).

---

## TLS / certificates

### uv standalone Python `/etc/ssl/cert.pem`

**Issue** — uv (`home-manager/terminal.nix:140`) downloads **python-build-standalone**
interpreters into `~/.local/share/uv/python/`. Those builds compile OpenSSL with
`openssldir=/etc/ssl` (the Debian layout), so their compiled-in defaults are
`SSL_CERT_FILE=/etc/ssl/cert.pem` and `SSL_CERT_DIR=/etc/ssl/certs` (looked up by *hashed*
filename). NixOS satisfies neither: `nixos/modules/security/ca.nix` ships
`/etc/ssl/certs/ca-bundle.crt`, `/etc/ssl/certs/ca-certificates.crt`, and
`/etc/pki/tls/certs/ca-bundle.crt`, but no `/etc/ssl/cert.pem`, and `/etc/ssl/certs` holds
only those bundles — no hash symlinks. Both lookup paths miss, so every HTTPS call from a
uv-managed Python fails with `CERTIFICATE_VERIFY_FAILED`.

**Fix** — provide the compatibility path system-wide. `common.nix:165-168`

```nix
environment.etc."ssl/cert.pem".source = config.security.pki.caBundle;
```

Sourced from `config.security.pki.caBundle` (the read-only store path `ca.nix` itself uses)
rather than chaining through another `/etc` symlink; this also picks up
`security.pki.certificateFiles` additions and the `useCompatibleBundle` setting
automatically.

**Added** — 2026-08-04

**Remove when** — nixpkgs ships `/etc/ssl/cert.pem` itself (NixOS/nixpkgs#8247, the open
meta-issue on how libs/apps find certs by default), or python-build-standalone learns to find
NixOS' cert store. Note the merged fix for python-build-standalone#858 reads OpenSSL config
from `/etc/pki/tls` when present — NixOS has no `/etc/pki/tls/openssl.cnf`, so it does not
cover us. Both sides are long-lived; treat this as durable.

**Link** —
https://discourse.nixos.org/t/fix-ssl-sslcertverificationerror-with-uvs-standalone-python/71138
and https://github.com/astral-sh/python-build-standalone/issues/858

---

## Tooling

### mcp-nixos Home Manager option search

**Issue** — the `mcp-nixos` server (`home-manager/terminal.nix:92-95`) returns nothing for
Home Manager option queries: `search`, `browse`, and `stats` on `source=home-manager` all come
back empty. The pinned 2.4.3 fetches `HOME_MANAGER_URL =
"https://nix-community.github.io/home-manager/options.xhtml"` (`config.py:34`), which after the
mdBook migration is a redirect stub containing only "Redirecting to
options/home-manager/index.html." — no options to parse.

Scope is Home Manager **only**. NixOS option search, nix-darwin, and nixvim all work; don't
avoid the server wholesale.

**Fix** — none in this config; documented instead. Look Home Manager options up via the mdBook
options page (linked in `CLAUDE.md`). `nxv` is packages/versions only and is not a substitute.

**Added** — 2026-08-04

**Remove when** — an mcp-nixos release later than 2.4.3 carrying the `print.html` loader
reaches the pinned nixpkgs. Upstream `main` already sets `HOME_MANAGER_URL` to
`https://nix-community.github.io/home-manager/print.html`, which is verified to serve the full
~4.1 MB option catalogue — but the latest release is v2.4.3 (2026-04-25), which predates it.
Re-test with a `source=home-manager` search after a version bump.

Note: PR #174 was closed **unmerged** on 2026-08-04 ("the current Home Manager print.html
loader is the implementation we re-verified and are retaining") — do not wait on it.

**Link** — https://github.com/utensils/mcp-nixos/pull/174 (closed, unmerged)

---

## Housekeeping

Non-workaround cleanup items found alongside the above — flagged here so they get addressed.

- **`flake.lock.orig`** — stray git merge-conflict leftover in the repo root (still contains
  conflict markers, from the obsidian-fix merge). Untracked; safe to delete.
- **docker `autoEnable`** — `common.nix:226` is commented out with "this mysteriously
  stopped working". Flag for revisiting.
- **`nixpkgs-patcher`** — `flake.nix:43,78-81,110-121`: the whole build routes through
  `gepbird/nixpkgs-patcher`, but no PR patches are currently wired in (pure pass-through).
  The mechanism exists but is idle — either it's meant to carry patches, or it can be
  removed.
