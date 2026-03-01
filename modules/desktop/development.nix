{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.host.desktop;
in
{
  config = mkIf cfg.development {
    environment.systemPackages = with pkgs; [
      jujutsu

      # Programming
      python3
      rustup
      gcc
      just
      typst
      mold
      wild
      zola

      # Profiling
      tracy

      # Language Servers
      superhtml # HTML
      vscode-css-languageserver # CSS
      vscode-json-languageserver # JSON
      protols # Protobuf
      taplo # TOML
      tinymist # Typst
      nil # Nix
      # rust-analyzer from rustup # Rust
    ];
  };
}
