{ pkgs, stdenv, contrailPkgs }:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  dump = stdenv.mkDerivation {
    name = "cassandra-dump";
    src = ./cassandra-dump.tgz;
    setSourceRoot = "sourceRoot=`pwd`";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  machine = { config, ... }: {
    imports = [
      ../modules/contrail-database-loader.nix
      ../modules/gremlin-server.nix
    ];
    config = {
      _module.args = { inherit pkgs contrailPkgs; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      contrail.databaseLoader = {
        enable = true;
        cassandraDumpPath = dump;
      };

      gremlin.server.enable = true;

    };
  };

  testScript = ''
    $machine->waitForOpenPort(8182);
    $machine->succeed("${pkgs.contrailGremlin}/bin/gremlin-send 'g.V().count()'");
  '';

in
  makeTest { name = "gremlin-dump"; nodes = { inherit machine; }; inherit testScript; }
