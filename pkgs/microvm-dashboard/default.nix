{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "microvm-dashboard";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "whizbangdevelopers-org";
    repo = "MicroVM-Dashboard";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nodejs = nodejs_24;

  buildPhase = ''
    # Build backend
    cd backend
    npm run build
    cd ..

    # Build frontend SPA
    npx quasar build
  '';

  installPhase = ''
    mkdir -p $out/lib/microvm-dashboard/backend
    mkdir -p $out/lib/microvm-dashboard/frontend

    # Backend
    cp -r backend/dist/* $out/lib/microvm-dashboard/backend/
    cp backend/package.json $out/lib/microvm-dashboard/backend/
    cp -r backend/node_modules $out/lib/microvm-dashboard/backend/

    # Frontend SPA
    cp -r dist/spa/* $out/lib/microvm-dashboard/frontend/

    # Launcher
    mkdir -p $out/bin
    cat > $out/bin/microvm-dashboard << 'LAUNCHER'
    #!/usr/bin/env bash
    export STATIC_DIR="''${STATIC_DIR:-$(dirname "$0")/../lib/microvm-dashboard/frontend}"
    exec ${nodejs_24}/bin/node "$(dirname "$0")/../lib/microvm-dashboard/backend/index.js" "$@"
    LAUNCHER
    chmod +x $out/bin/microvm-dashboard
  '';

  meta = with lib; {
    description = "NixOS MicroVM Management Dashboard";
    homepage = "https://github.com/whizbangdevelopers-org/MicroVM-Dashboard";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "microvm-dashboard";
  };
}
