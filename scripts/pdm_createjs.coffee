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

class PDM.CreatejsDisplay extends PDM.Display

class PDM.CreatejsDisplay.Sprite

Sprite = PDM.CreatejsDisplay.Sprite

Sprite.init_graphics = () ->
  # Help clear out the old stage and keep it from
  # consuming resources.
  if window.stage
    window.stage.removeAllChildren()

  # New displayCanvas, new stage
  window.stage = new createjs.Stage "displayCanvas"

  window.overlay_container = new createjs.Container
  stage = window.stage

loader_images = []
already_loaded = false
window.Sprite.load_images = (images, handler = undefined) ->
  return if already_loaded
  already_loaded = true
  $("#loader")[0].className = "loader"
  loader_images.concat images

  manifest = []
  for image in images
    manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.addEventListener "complete", handler if handler?
  loader.loadManifest manifest
  window.loader = loader

handleSpritesLoaded = () ->
  $("#loader")[0].className = ""

  # Make sure overlay container is displayed on top
  window.stage.addChild(window.overlay_container)

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  #createjs.Ticker.removeEventListener("tick", tick);  # If present
  #createjs.Ticker.addEventListener("tick", tick)

#tick = (event) ->
#  if window.on_cjs_tick
#    window.on_cjs_tick(event)
#  window.stage.update(event)
