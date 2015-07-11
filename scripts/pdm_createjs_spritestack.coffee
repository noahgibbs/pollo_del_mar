class PDM.CreatejsDisplay.CreatejsSpriteStack
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
            sprites[h][w].setTransform(w * @sheet.tilewidth, h * @sheet.tileheight)
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
