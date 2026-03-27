# NixOS Configuration

Flake-based NixOS configuration managing two machines with standalone home-manager.

- **nixos** — Desktop (AMD, NVME, ext4, systemd-boot)
- **nixie** — Framework AMD laptop (BTRFS+LUKS, Lanzaboote secure boot, hibernation)

## Secrets Management

Secrets are managed with [agenix-rekey](https://github.com/oddlama/agenix-rekey) using YubiKey-backed age encryption. The devshell provides the necessary tools (`age`, `age-plugin-yubikey`, `agenix-rekey`).

### YubiKey Identity Setup (new machine)

1. Enter the devshell:
   ```sh
   nix develop
   ```

2. Generate a YubiKey age identity (interactive — follow the prompts):
   ```sh
   age-plugin-yubikey --generate
   ```

3. Export the identity file:
   ```sh
   age-plugin-yubikey --identity --slot 1 > ~/.ssh/yubikey-identity.txt
   ```

4. List the public recipient (for reference or adding to configs):
   ```sh
   age-plugin-yubikey --list
   ```

The identity file path must match the `masterIdentities` entry in `home-manager/terminal.nix` (`/home/ciferkey/.ssh/yubikey-identity.txt`).

### Creating/Editing Secrets

Open or create a secret (opens `$EDITOR`, encrypts on save):
```sh
agenix edit secrets/<name>.age
```

Encrypt from an existing plaintext file:
```sh
agenix edit -i plaintext.txt secrets/<name>.age
```

Then define the secret in nix (e.g. in `home-manager/terminal.nix`):
```nix
age.secrets.<name>.rekeyFile = ../secrets/<name>.age;
```

### Rekeying

Re-encrypt all secrets for each host's public key:
```sh
agenix rekey -a
```

Then git-add the rekeyed output from `home-manager/secrets/`.

### Rebuilding

After adding or changing secrets, rebuild home-manager:
```sh
rehome
```
