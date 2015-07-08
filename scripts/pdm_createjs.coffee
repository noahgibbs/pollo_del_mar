messageMap = {
  "displayNewSpriteSheet": "newSpriteSheet",
  "displayNewSpriteStack": "newSpriteStack",
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

  message: (msgName, argArray) ->
    handler = messageMap[msgName]
    unless handler?
      console.warn "Couldn't handle message type #{msgName}!"
      return
    this[handler](argArray...)

  newSpriteSheet: (data) ->
    images = (imgdata.image for imgdata in data.images)
    ss = new createjs.SpriteSheet frames: { width: data.tilewidth, height: data.tileheight }, images: images
    @spritesheets[data.name] = ss

  newSpriteStack: (data) ->
    sheet = @spritesheets[data["spritesheet"]]
    unless sheet?
      console.warn "Can't find spritesheet #{data["spritesheet"]} for sprite #{data["name"]}!"
      return

    for layer in data["layers"]
      console.log "Layer:", layer.name
      continue unless layer["visible"]

      sprites = []
      container = new createjs.Container
      container.setTransform(data["x"] || 0, data["y"] || 0)
      container.alpha = layer.opacity
      @stage.addChild container

      ld = layer.data
      for h in [0..(data.height - 1)]
        sprites[h] = []
        for w in [0..(data.width - 1)]
          unless ld[h][w] is 0
            sprites[h][w] = new createjs.Sprite(sheet)
            sprites[h][w].setTransform(w * data.tilewidth, h * data.tileheight)
            # TODO: FIX HARDCODING OF GID TO ONE IMAGE!
            sprites[h][w].gotoAndStop(ld[h][w] - 1)
            container.addChild sprites[h][w]