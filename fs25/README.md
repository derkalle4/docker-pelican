# Pelican / Pterodactyl Farm Simulator 2025 dedicated server

This egg allows one to host a Farm Simulator 2025 Server within the Pelican or Pterodactyl Panel.

## FAQ

#### where do I find the Farm Simulator 2025 server files?

Buy them from their website. Steam is not supported.

#### how can I see what happens on the server gui?

Take a screenshot:

xwd -display :0 -root -silent | convert xwd:- png:/home/container/screenshot.png

#### how can I add the key via the command line?

After the first start the game is awaiting keyboard input to set a CD key. You can enter this key with:

xdotool type --delay 100 "MY-KEY"
xdotool key "Return"
