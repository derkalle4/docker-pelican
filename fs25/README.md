# Pelican / Pterodactyl Battlefield Bad Company 2 Dedicated Server

This egg allows one to host a Battlefield Bad Company 2 Server within the Pelican or Pterodactyl Panel. I've created a docker container (~3.67GB currently), will be optimized in future and an automatically created wine-environment for the game itself. Total size including server-files around 1GB.

## FAQ

#### where do I find the battlfield bad company 2 server files?

Search the internet. I do not provide them to you. Please do not ask!

#### How does the egg install the game server files?

You have to upload the game server files as a .zip file somewhere and fill in the environemnt variable of the egg. The installation script will automatically download and extract the files for you. It would be more optimized to include the dedicated server files within the docker container. But to avoid legal consequences I won't do this.

The .zip file should contain the following files and folders:

- dist (folder)
- instance (folder)
- Scripts (folder)
- binkw32.dll
- branch.txt
- changelist_bin.txt
- changelist_data.txt
- D3DCompiler_42.dll
- d3dx10_42.dll
- d3dx11_42.dll
- D3DX9_42.dll
- database.dbmanifest
- DejaDLL.Win32.dll
- dinput8.dll
- Frost.Game.Main_Win32_Final.exe
- info.txt
- launcher.ini
- launcher.log
- libeay32.dll
- ProviderID.dat
- ssleay32.dll
- tibems.dll
- Win32Game.cfg
- zlib1.dll
