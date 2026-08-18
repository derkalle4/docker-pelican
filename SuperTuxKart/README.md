# Pelican / Pterodactyl SuperTuxKart dedicated server

This egg downloads the official SuperTuxKart Linux build from GitHub and runs it as a LAN dedicated server.

## Install

Reinstalling the server downloads the release again and replaces `bin/`, `data/`, `lib/`, and `run_game.sh`. Existing `config.xml` files are kept.

Give the server at least **2 GiB** disk. The official Linux archive is about 700 MB and unpacks to a similar size. The install writes to the server volume only; a small container `/tmp` is not enough.

Default version is **1.5**. Change `STK_VERSION` to another GitHub release tag if needed.

## Startup

The default command starts a LAN server. To publish a WAN server in the SuperTuxKart online lobby, replace `--lan-server=` with `--wan-server=` and log in with a [SuperTuxKart account](https://online.supertuxkart.net/) first (`supertuxkart --init-user --login=USER --password=PASS`).

## Ports

| Port | Default |
| --- | --- |
| Game | 2759 |
