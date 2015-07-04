# Pollo Del Mar

This is an attempt to adapt Surveyor(https://github.com/noahgibbs/surveyor) to
an EventMachine server. For a tiled game, an evented server of some kind is
clearly superior to a Rails-style per-request server.

I'm currently gluing together the following technologies:

Faye-Websockets
Puma (not Thin - Faye needs an extra adapter call for that)
CoffeeScript
TMX (format for the Tiled editor - mapeditor.org)
