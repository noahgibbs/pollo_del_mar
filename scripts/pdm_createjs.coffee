# Variables this library adds to window:
#
# init_graphics - a callback to set up createjs stuff
# stage - a createjs stage
# overlay_container - a container for stuff above the humanoid sprite layer
# loader - a createjs image preload queue
# terrain_tilesheet - a tilesheet for the terrain layer
#
# Variables expected in window, sometimes optional:
#
# humanoids - see humanoids.js.coffee
# Variables for terrains, see tilesheets.js.coffee
# on_cjs_init - a callback prior to createjs ticks on the stage
# on_cjs_tick - a callback for each createjs tick on the stage

messageMap = {
  "displayNewSpriteSheet": "newSpriteSheet",
}

class PDM.CreatejsDisplay extends PDM.Display
  constructor: (@pdm) ->
    @spritesheets = {}
  setup: () ->
    # New displayCanvas, new stage
    @stage = new createjs.Stage "displayCanvas"
    @overlay_container = new createjs.Container
    @stage.addChild(window.overlay_container)
    createjs.Ticker.timingMode = createjs.Ticker.RAF

  message: (msgName, argArray) ->
    console.log "Processing display message: #{msgName}, args:", argArray
    handler = messageMap[msgName]
    unless handler?
      console.warn "Couldn't handle message type #{msgName}!"
      return
    this[handler](argArray...)

  newSpriteSheet: (data) ->
    console.log "New sprite sheet!", data
    ss = new createjs.SpriteSheet frames: { width: 32, height: 32 }, images: [ "/tiles/terrain.png" ]
    @spritesheets[data.name] = ss
