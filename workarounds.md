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
| Firefox profile path pin | `home-manager/personal.nix:99` | 2026-06-23 | fresh `stateVersion` ≥ 26.05 install |
| claude-code auto-compact window | `home-manager/terminal.nix:51` | 2026-06-23 | anthropics/claude-code#43989 resolves |
| claude-code installation checks | `home-manager/terminal.nix:56` | 2026-06-23 | anthropics/claude-code#17289 resolves |
| opencode lsp flag | `home-manager/personal.nix:116` | — | anomalyco/opencode#23566 resolves |
| opencode experimental-subagents env var | `home-manager/personal.nix:133` | 2026-07-17 | a scoped env mechanism exists |
| thunderbird-mcp two-half version skew | `home-manager/terminal.nix:106` | 2026-07-30 | upstream adds a version handshake, or the add-on is declarative |
| zellij fish integration | `home-manager/terminal.nix:321` | 2026-02-18 | home-manager PR #6695 lands in the pinned rev |
| SDDM → KWallet startup fix | `common.nix:153` | 2026-01-13 | KWallet starts under SDDM without `forceRun` |
| Monitor EDID override (BenQ XL2420G) | `nixos/desktop.nix:11` | 2025-08-21 | monitor reports a usable EDID on AMD |
| Steam Frame adapter 6 GHz regdom | `nixos/desktop.nix:19` | 2026-10-02 | NixOS selects a country automatically, or the adapter is retired |
| Framework ambient light sensor | `nixie/laptop.nix:37` | 2026-02-27 | bugs.kde.org#502122 resolves |
| Framework tlp disabled for tuned | `nixie/laptop.nix:27` | 2025-08-29 | (intentional; keep while using tuned) |
| Framework hibernate S4 rollback | `nixie/laptop.nix:45` | 2026-09-16 | the kernel stops wedging amdgpu on a hibernation rollback, or the spurious wakeup source is fixed |
| esp32 plugdev group | `nixos/esp32.nix:9` | — | a module declares `plugdev` for us |
| NetworkManager-wait-online disabled | `common.nix:78` | 2025-12-04 | boot no longer hangs on it |
| uv standalone Python `/etc/ssl/cert.pem` | `common.nix:168` | 2026-08-04 | nixpkgs ships `/etc/ssl/cert.pem`, or python-build-standalone finds NixOS certs |

---

## stateVersion 26.05 pins

These pin pre-26.05 home-manager defaults so the existing state keeps working. Drop each on
a fresh `stateVersion` ≥ 26.05 install.

### Firefox profile path pin

**Issue** — home-manager changed the default Firefox config path in 26.05; the existing
profile lives at the old path.

**Fix** — pin the pre-26.05 path. `home-manager/personal.nix:99-100`

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

**Fix** — disable them via env. `home-manager/terminal.nix:56`

```nix
DISABLE_INSTALLATION_CHECKS = "1";
```

**Added** — 2026-06-23

**Link** — https://github.com/anthropics/claude-code/issues/17289

---

### opencode lsp flag

**Issue** — opencode LSP integration needs to be explicitly enabled to work as expected.

**Fix** — set the flag. `home-manager/personal.nix:116`

```nix
lsp = true;
```

**Remove when** — anomalyco/opencode#23566 resolves.

**Link** — https://github.com/anomalyco/opencode/issues/23566

---

### opencode experimental-subagents env var

**Issue** — opencode reads `OPENCODE_EXPERIMENTAL_*` from the process environment, not its
config file (`opencode.json` has no `env` field, unlike claude-code's settings), and the
upstream `programs.opencode` home-manager module exposes no env option nor wraps the binary
with `--set`.

**Fix** — set it globally in the shell environment. `home-manager/personal.nix:132-137`

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
`home-manager/terminal.nix:106-111`:

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

**Fix** — enable it explicitly. `home-manager/terminal.nix:321`

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

### Steam Frame adapter 6 GHz regdom

**Issue** — the Steam Frame wireless adapter (`rtw89_8852cu`) links over 6 GHz. With no
country set, `cfg80211` uses the world regulatory domain (`00`), which disables 6 GHz. The
adapter interface hangs in NetworkManager `connecting (configuring)`, the headset never
attaches, and SteamVR fails with `VRInitError_Driver_WirelessHmdNotConnected (215)`.

**Fix** — set the country code on the `cfg80211` module. `nixos/desktop.nix:19-22`

```nix
boot.extraModprobeConfig = ''
  options cfg80211 ieee80211_regdom=US
'';
```

Needs a reboot, since `cfg80211` is already loaded. Verify:
`cat /sys/module/cfg80211/parameters/ieee80211_regdom` prints `US`.

**Added** — 2026-10-02

**Remove when** — NixOS selects a regulatory country automatically, or the adapter is no
longer used.

**Link** — https://wiki.nixos.org/wiki/Steam_Frame and
https://github.com/ValveSoftware/SteamOS/issues/2852

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

### Framework hibernate S4 rollback

**Issue** — hibernate on `nixie` (Framework 13, Ryzen AI 300) writes its image fine
(`PM: hibernation: Wrote 11329864 kbytes ...` → `PM: Image saving done`) and then aborts the
final power-off. With the default `HibernateMode`, systemd writes `platform` to
`/sys/power/disk`, so the kernel finishes through `hibernation_platform_enter()` (ACPI S4),
which re-checks `pm_wakeup_pending()` after the second `dpm_suspend_end()`. A stray wakeup
event makes it bail:

```
PM: hibernation: Wakeup event detected during hibernation, rolling back.
```

The rollback resumes devices, and amdgpu does not survive it — `ring sdma0 timeout` →
`Ring sdma0 reset failed` → `GPU reset begin!` → `Mode2 reset failed!` → `ASIC reset failed
with error, -5`. From there any process closing a DRM fd hangs forever in `amdgpu_vm_fini` /
`dma_fence_wait_timeout` (vesktop was the usual victim), and every
later sleep attempt fails with `1 tasks refusing to freeze` — hundreds of retries per boot,
ending in a lockup that needs a hard restart. Observed in 15 of the last 16 boots that
attempted hibernation.

Likely wakeup sources at the check: the touchpad `i2c-PIXA3854:00` (by far the top wakeup
activation count) and keyboard `serio0`, both wakeup-enabled — hibernate is triggered by
lid-close or by KDE's hybrid sleep, which leaves an input/resume event pending exactly when
the S4 enter looks for one.

**Fix** — `HibernateMode=shutdown` makes `power_down()` skip `hibernation_platform_enter()`
and call `kernel_power_off()` (S5) directly. `nixie/laptop.nix:44-45`

```nix
systemd.sleep.settings.Sleep.HibernateMode = "shutdown";
```

`/sys/power/disk` only selects *how the machine powers off after the image has already been
written*, so the snapshot and the resume path are untouched; only the final power-off call
changes, and with it the `pm_wakeup_pending()` check that causes the rollback. What is given
up is the ACPI S4 firmware handshake, so the `S4`-armed sources in `/proc/acpi/wakeup`
(`GPP0`, `NHI0`, …) no longer wake the machine — it wakes by power button, as it already did.

Use `systemd.sleep.settings` (the RFC-0042 settings option that writes
`/etc/systemd/sleep.conf`), **not** `systemd.sleep.extraConfig` — the latter is removed and
evaluates silently while producing nothing.

Verify: `systemd-analyze cat-config systemd/sleep.conf | grep HibernateMode` prints
`HibernateMode=shutdown`, `cat /sys/power/disk` reads `[shutdown]`, and after a hibernate
`journalctl -b -1 -k | grep -E "rolling back|ring sdma0|GPU reset begin|refusing to freeze"`
stays empty while `Image saving done` / `Image loaded` are both present.

**Added** — 2026-09-16

**Remove when** — the kernel no longer wedges amdgpu on a hibernation rollback, or the
spurious wakeup source is fixed.

**Link** — https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/261

Considered and rejected:

- **`pm_async=0`** — an n=1 community workaround for hibernate *restore* failures on this
  model. No restore failures here (the one clean hibernate resumed fine), so it treats a
  problem we don't have and confounds attribution.
- **udev rules disabling touchpad/keyboard wakeup** — attacks the trigger rather than the
  abort path, and costs touchpad/keyboard wake from S3. Held as a fallback if rollbacks
  persist; identify the culprit first with
  `sudo cat /sys/kernel/debug/wakeup_sources` right after a failed attempt.
- **`boot.resumeDevice`** — unset, and resume demonstrably works via systemd initrd's
  `HibernateLocation` EFI variable. Not a cause.

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

**Issue** — uv (`home-manager/terminal.nix:163`) downloads **python-build-standalone**
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
