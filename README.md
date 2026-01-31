# whizBANG Developers NUR Packages

[![Build](https://github.com/whizbangdevelopers-org/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/whizbangdevelopers-org/nur-packages/actions/workflows/build.yml)

Nix User Repository packages from [whizBANG Developers](https://github.com/whizbangdevelopers-org).

## Packages

| Package | Description |
|---------|-------------|
| `qepton` | AI Prompt and Code Snippet Manager powered by GitHub Gist |

## Usage

### With Flakes

```nix
{
  inputs.whizbang-nur.url = "github:whizbangdevelopers-org/nur-packages";

  outputs = { self, nixpkgs, whizbang-nur }: {
    # Use in your configuration
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            whizbang-nur.packages.${pkgs.system}.qepton
          ];
        })
      ];
    };
  };
}
```

### With NUR

Once registered with NUR, you can use:

```nix
{ pkgs, ... }:

let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
in
{
  environment.systemPackages = [
    nur.repos.whizbangdevelopers.qepton
  ];
}
```

### Direct Installation

```bash
# Try it out
nix run github:whizbangdevelopers-org/nur-packages#qepton

# Or build it
nix build github:whizbangdevelopers-org/nur-packages#qepton
```

## Development

```bash
# Build all packages
nix-build

# Build specific package
nix-build -A qepton

# Enter dev shell
nix develop
```
