# Battlefield Bad Company 2 (Pelican / Pterodactyl)

Docker egg for a BFBC2 dedicated server under Wine.

## Install

1. Host your server files as a `.zip` and set the egg’s download URL.
2. The install script downloads and extracts them, then prepares the Wine prefix.

Server files are **not** included. Do not ask for them.

Your `bfbc2_server.zip` should unpack like this:

```text
bfbc2_server/
├── dist/
├── instance/
├── Scripts/
├── Frost.Game.Main_Win32_Final.exe
├── Win32Game.cfg
├── launcher.ini
├── launcher.log
├── info.txt
├── branch.txt
├── changelist_bin.txt
├── changelist_data.txt
├── database.dbmanifest
├── ProviderID.dat
├── binkw32.dll
├── D3DCompiler_42.dll
├── d3dx10_42.dll
├── d3dx11_42.dll
├── D3DX9_42.dll
├── DejaDLL.Win32.dll
├── dinput8.dll
├── libeay32.dll
├── ssleay32.dll
├── tibems.dll
└── zlib1.dll
```


## Startup command

Edit **Startup** in the panel. The container always:

- cleans old `instance/*.log` / `*.dmp`
- runs your startup command
- tails the instance log when it appears

Keep the main game as the **last foreground** process.

### Default (main game only)

```bash
wine Frost.Game.Main_Win32_Final.exe -serverInstancePath instance -mapPack2Enabled 1 -port 0.0.0.0:{{SERVER_PORT}} -remoteAdminPort 0.0.0.0:{{SERVER_QUERY_PORT}} -timeStampLogNames -region {{SERVER_REGION}} -heartBeatInterval 20000 -displayErrors 1 -displayAsserts 1 -crashDumpAsserts 1 -plasmaServerLog 0 -crashDumpErrors 1 -Server.ThreadingEnable true -Core.JobProcessorCount 2
```

### One helper before the game

Start helpers with `&`, then the main exe **without** `&`:

```bash
wine NEMOSKALconfig.exe & wine Frost.Game.Main_Win32_Final.exe -serverInstancePath instance ... -region {{SERVER_REGION}} ...
```

### Multiple helpers

```bash
wine NEMOSKALconfig.exe & wine OtherHelper.exe --flag & wine Frost.Game.Main_Win32_Final.exe -serverInstancePath instance ... 
```

Rules:

- Put each helper as `wine Something.exe … &`
- Leave Frost as the last command (no trailing `&`) so the server stays “online” until Frost exits
- Panel variables like `{{SERVER_PORT}}` still work
- Helper exes must live in the server root (same folder as Frost), or use a path relative to `/home/container`
