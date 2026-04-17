{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "weaver-free";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "whizbangdevelopers-org";
    repo = "Weaver-Free";
    rev = "v${version}";
    # Populated by .github/workflows/update-weaver.yml on weaver-release dispatch.
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # Single hash covers all workspace deps (root + backend + tui) — Weaver uses npm workspaces.
  # Populated by the update workflow; matches code/nixos/package.nix in the dev repo.
  npmDepsHash = "sha256-UlUtKz8JQBrLHPFdVUXMe/BALJ0U5+lW5+Lq626qfmY=";

  makeCacheWritable = true;
  nodejs = nodejs_24;

  buildPhase = ''
    # Remove sass-embedded (ships pre-built dart binary that fails in Nix sandbox).
    # Vite falls back to pure-JS "sass" package which is already installed.
    rm -rf node_modules/sass-embedded node_modules/sass-embedded-*

    # Build backend (workspace — deps already installed by npmConfigHook)
    pushd backend
    patchShebangs node_modules 2>/dev/null || true
    npm run build
    popd

    # Build TUI (workspace)
    pushd tui
    patchShebangs node_modules 2>/dev/null || true
    npm run build
    popd

    # Build frontend PWA
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/lib/weaver/backend
    mkdir -p $out/lib/weaver/frontend
    mkdir -p $out/lib/weaver/tui

    # Backend
    cp -r backend/dist/* $out/lib/weaver/backend/
    cp backend/package.json $out/lib/weaver/backend/

    # Frontend PWA
    cp -r dist/pwa/* $out/lib/weaver/frontend/

    # TUI
    cp -r tui/dist/* $out/lib/weaver/tui/
    cp tui/package.json $out/lib/weaver/tui/

    # Shared node_modules (workspaces hoist — one tree serves all three)
    cp -r node_modules $out/lib/weaver/

    # Launcher
    mkdir -p $out/bin
    cat > $out/bin/weaver << LAUNCHER
    #!${nodejs_24}/bin/bash
    export STATIC_DIR="\''${STATIC_DIR:-$out/lib/weaver/frontend}"
    exec ${nodejs_24}/bin/node "$out/lib/weaver/backend/index.js" "\$@"
    LAUNCHER
    chmod +x $out/bin/weaver
  '';

  meta = {
    description = "NixOS workload isolation — unified container and MicroVM management";
    homepage = "https://github.com/whizbangdevelopers-org/Weaver-Free";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "weaver";
  };
}
