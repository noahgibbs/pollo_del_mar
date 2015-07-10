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

  message: (msgName, argArray) ->
    handler = messageMap[msgName]
    unless handler?
      console.warn "Couldn't handle message type #{msgName}!"
      return
    this[handler](argArray...)

  newSpriteSheet: (data) ->
    images = (imgdata.image for imgdata in data.images)
    # TODO: translate animations
    @spritesheets[data.name] = new CreatejsSpriteSheet(data.tilewidth, data.tileheight, images, data.animations)

  newSpriteStack: (data) ->
    sheet = @spritesheets[data["spritesheet"]]
    unless sheet?
      console.warn "Can't find spritesheet #{data["spritesheet"]} for sprite #{data["name"]}!"
      return

    stack = new CreatejsSpriteStack(sheet, data)
    @spritestacks[data.name] = stack
    stack.addToStage(@stage)

  startAnimation: (data) ->
    stack = @spritestacks[data.stack]
    stack.animateTile data.layer, data.h, data.w, data.anim

  moveStackTo: (stack, x, y, options) ->
    stack = @spritestacks[stack]
    stack.moveTo x, y, duration: options.duration || 1.0

class CreatejsSpriteSheet
  constructor: (@tilewidth, @tileheight, @images, @animations) ->
    @sheet = new createjs.SpriteSheet frames: { width: @tilewidth, height:  @tileheight }, images: @images, animations: @animations

  create_sprite: () ->
    new createjs.Sprite(@sheet)

class CreatejsSpriteStack
  constructor: (spritesheet, data) ->
    @top_container = new createjs.Container
    @layers = {}
    @layer_order = []
    @sheet = spritesheet
    @width = data.width
    @height = data.height

    for layer in data.layers
      continue unless layer.visible

      @layer_order.push layer.name

      container = new createjs.Container
      container.setTransform(data.x || 0, data.y || 0)
      container.alpha = layer.opacity
      @top_container.addChild container

      sprites = []
      @layers[layer.name] = {
        "sprites": sprites
      }

      ld = layer.data
      for h in [0..(data.height - 1)]
        sprites[h] = []
        for w in [0..(data.width - 1)]
          unless ld[h][w] is 0
            sprites[h][w] = @sheet.create_sprite()
            sprites[h][w].setTransform(w * data.tilewidth, h * data.tileheight)
            # TODO: FIX HARDCODING OF GID TO ONE IMAGE!
            sprites[h][w].gotoAndStop(ld[h][w] - 1)
            container.addChild sprites[h][w]

  addToStage: (stage) ->
    stage.addChild @top_container

  animateTile: (layer, h, w, anim) ->
    layer = @layers[layer]
    sprite = layer.sprites[h][w]
    sprite.gotoAndPlay anim

  moveTo: (x, y, opts) ->
    new_x = x * @sheet.tilewidth
    new_y = y * @sheet.tileheight
    duration = opts.duration || 1.0
    createjs.Tween.get(@top_container)
      .to({x: new_x, y: new_y}, duration * 1000.0, createjs.Ease.linear)
      .call (tween) =>  # on complete, set new @x and @y
        @x = x
        @y = y
