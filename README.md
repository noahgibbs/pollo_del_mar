# Pollo Del Mar

This is an attempt to adapt Surveyor(https://github.com/noahgibbs/surveyor) to
an EventMachine server. For a tiled game, an evented server of some kind is
clearly superior to a Rails-style per-request server.

I'm currently gluing together the following technologies:

* Faye-Websockets
* Thin (Faye needs a specific adapter)
* Puma (not any more - kept getting weird hangs on startup)
* CoffeeScript
* CreateJS / EaselJS (createjs.com)
* TMX (format for the Tiled editor - mapeditor.org)

## Setup

Run Bundler to install the appropriate gems.

## Running

    $ thin start -R config.ru -p 3001
    $ puma config.ru -p 3001  # Old way

# References and Technical Influences

The Tiled Map Editor
Source of Tales
The Mana Project / The Mana World
Evol Online
