# pdm_createjs.coffee

messageMap = {
  "displayNewSpriteSheet": "newSpriteSheet",
  "displayNewSpriteStack": "newSpriteStack",
  "displayStartAnimation": "startAnimation",
  "displayMoveStackTo": "moveStackTo",
}

class PDM.CreatejsDisplay extends PDM.Display
  constructor: (@pdm) ->
    @spritesheets = {}
    @spritestacks = {}
  setup: () ->
    # New displayCanvas, new stage
    @stage = new createjs.Stage "displayCanvas"
    @overlay_container = new createjs.Container
    @stage.addChild(window.overlay_container)
    createjs.Ticker.timingMode = createjs.Ticker.RAF
    createjs.Ticker.addEventListener "tick", (event) =>
      @stage.update event

  # Figure out how to expose CreateJS events:
  #   complete  (everything complete)
  #   error     (error while loading)
  #   progress  (total queue progress)
  #   fileload  (one file loaded)
  #   fileprogress  (progress in single file)
  on_load_update: (handler) ->
    @load_handler = handler
    PDM.CreatejsDisplay.loader.setHandler handler

  message: (msgName, argArray) ->
    handler = messageMap[msgName]
    unless handler?
      console.warn "Couldn't handle message type #{msgName}!"
      return
    this[handler](argArray...)

  # This method takes the following keys to its argument:
  #    name: the spritesheet name
  #    images: an array of images
  #    tilewidth: the width of each tile
  #    tileheight: the height of each tile
  #    animations: an object of animation names mapped to PDM animation specs (see animate methods)
  #
  # Here's an example:
  # {
  #   "name" => "test_humanoid_spritesheet",
  #   "tilewidth" => 64,
  #   "tileheight" => 64,
  #   "animations" => { "stand" => 1, "sit" => [2, 5], "jumpsit" => [6, 9, "sit", 200], "kersquibble" => {} },
  #   "images" => [
  #     {
  #       "firstgid" => 1,
  #       "image" => "/sprites/skeleton_walkcycle.png",
  #       "image_width" => 576,
  #       "image_height" => 256
  #     }
  # }
  #
  newSpriteSheet: (data) ->
    images = (imgdata.image for imgdata in data.images)
    # TODO: translate animations
    @spritesheets[data.name] = new PDM.CreatejsDisplay.CreatejsSpriteSheet(data.tilewidth, data.tileheight, images, data.animations)

  # Keys in data arg:
  #     name: name of spritestack
  #     spritesheet: name of spritesheet
  #     width:
  #     height:
  #     layers: { name: "", visible: true, opacity: 1.0, data: [ [1, 2, 3], [4, 5, 6], [7, 8, 9] ] }
  newSpriteStack: (data) ->
    sheet = @spritesheets[data.spritesheet]
    unless sheet?
      console.warn "Can't find spritesheet #{data.spritesheet} for sprite #{data.name}!"
      return

    stack = new PDM.CreatejsDisplay.CreatejsSpriteStack(sheet, data)
    @spritestacks[data.name] = stack
    stack.addToStage(@stage)

  startAnimation: (data) ->
    stack = @spritestacks[data.stack]
    stack.animateTile data.layer, data.h, data.w, data.anim

  moveStackTo: (stack, x, y, options) ->
    stack = @spritestacks[stack]
    stack.moveTo x, y, duration: options.duration || 1.0

