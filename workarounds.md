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
| zellij fish integration | `home-manager/terminal.nix:275` | 2026-02-18 | home-manager PR #6695 lands in the pinned rev |
| SDDM → KWallet startup fix | `common.nix:153` | 2026-01-13 | KWallet starts under SDDM without `forceRun` |
| Monitor EDID override (BenQ XL2420G) | `nixos/desktop.nix:11` | 2025-08-21 | monitor reports a usable EDID on AMD |
| Framework ambient light sensor | `nixie/laptop.nix:37` | 2026-02-27 | bugs.kde.org#502122 resolves |
| Framework tlp disabled for tuned | `nixie/laptop.nix:27` | 2025-08-29 | (intentional; keep while using tuned) |
| esp32 plugdev group | `nixos/esp32.nix:9` | — | a module declares `plugdev` for us |
| NetworkManager-wait-online disabled | `common.nix:78` | 2025-12-04 | boot no longer hangs on it |

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
