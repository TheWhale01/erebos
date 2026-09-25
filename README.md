# Erebos

NixOS system configuration for my self-hosted infrastructure, defining production and staging environments (`erebos` and `erebos-stage`) as reproducible systems with declarative services, secrets, and infrastructure managed via flakes.

> **Name origin:** *Erebos* (Ancient Greek: Ἔρεβος) means **"darkness"** or **"deep shadow"**, and in Greek mythology is the primordial personification of darkness.

## Overview

This repository defines:

- Two NixOS systems: `erebos` (prod) and `erebos-stage` (stage)
- Shared system configuration in `sys/`
- Home Manager configuration for user `hades`
- Encrypted secrets managed with `agenix`
- Disk layout modules via `disko`
- Infrastructure generation/apply workflow via `terranix` + OpenTofu

## Repository Structure

```text
.
├── flake.nix
├── flake.lock
├── sys/
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   ├── home.nix
│   ├── vars.nix
│   ├── packages.nix
│   ├── secrets.nix
│   ├── disko/
│   │   ├── prod.nix
│   │   └── stage.nix
│   ├── containers/
│   ├── services/
│   └── terraform/
└── secrets/
    ├── secrets.nix
    ├── shared/
    ├── prod/
    └── stage/
```

## Flake Outputs

- `nixosConfigurations.erebos` (env: `prod`)
- `nixosConfigurations.erebos-stage` (env: `stage`)
- `apps.<system>.apply` (terranix/opentofu apply for prod)
- `apps.<system>.apply-stage` (terranix/opentofu apply for stage)

## Prerequisites

- Nix with flakes enabled
- NixOS on the target machine
- Access to required `agenix` private keys for secret decryption

If needed, enable flakes in `/etc/nix/nix.conf`:

```conf
experimental-features = nix-command flakes
```

## Usage

### Rebuild NixOS

Prod:

```bash
sudo nixos-rebuild switch --flake .#erebos
```

Stage:

```bash
sudo nixos-rebuild switch --flake .#erebos-stage
```

### Test configuration without switching

```bash
sudo nixos-rebuild test --flake .#erebos
sudo nixos-rebuild test --flake .#erebos-stage
```

### Build only

```bash
sudo nixos-rebuild build --flake .#erebos
sudo nixos-rebuild build --flake .#erebos-stage
```

## Home Manager

Home Manager is integrated through the NixOS module and applies for user `hades` during system rebuild.

## Secrets (agenix)

Secrets are stored under `secrets/` as `.age` files and mapped in `secrets/secrets.nix`.

- `secrets/shared/` → shared between prod/stage
- `secrets/prod/` → prod-only secrets
- `secrets/stage/` → stage-only secrets

Never commit plaintext secrets.

## Terraform / OpenTofu workflow

The flake defines two helper apps that generate `config.tf.json` from Terranix and run OpenTofu:

Prod:

```bash
nix run .#apply
```

Stage:

```bash
nix run .#apply-stage
```

## Updating dependencies

```bash
nix flake update
```

Then rebuild target host:

```bash
sudo nixos-rebuild switch --flake .#erebos
```

## Useful checks

```bash
nix flake check
nix fmt
```
