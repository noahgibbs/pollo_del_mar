when_sheet_complete = (sheet, handler) ->
  return handler() if sheet.loaded
  sheet.addEventListener "complete", handler

class PDM.CreatejsDisplay.CreatejsSpriteStack
  constructor: (@sheet, data, @exposure) ->
    @top_container = new createjs.Container
    @x = data.x || 0
    @y = data.y || 0
    @top_container.setTransform @x, @y
    @layers = {}
    @layer_order = []
    @width = data.width
    @height = data.height

    when_sheet_complete @sheet, () =>
      for layer in data.layers
        continue unless layer.visible

        @layer_order.push layer.name
        container = new createjs.Container
        container.alpha = layer.opacity
        @top_container.addChild container

        @layers[layer.name] = { sprites: [], container: container, data: layer.data }

      @setExposure @exposure

  setExposure: (@exposure) ->
    @top_container.setTransform @x - (@exposure.x || 0), @y - (@exposure.y || 0)

    height = Math.min @exposure.height, @height
    width = Math.min @exposure.width, @width

    for layer_name in @layer_order
      layer = @layers[layer_name]
      sprites = layer.sprites = []
      ld = layer.data

      for h in [0..(height - 1)]
        sprites[h] = []
        for w in [0..(width - 1)]
          sprite = sprites[h][w]
          unless sprite
            sprite = sprites[h][w] = @sheet.create_sprite()
            layer.container.addChild sprite

          if ld[h][w] is 0
            sprite.visible = false
          else
            sprite.visible = true
            sprite.setTransform w * @sheet.tilewidth, h * @sheet.tileheight
            sprite.gotoAndStop @sheet.ss_frame_to_cjs_frame ld[h][w]

  addToStage: (stage) ->
    stage.addChild @top_container

  animateTile: (layer_name, h, w, anim) ->
    when_sheet_complete @sheet, () =>
      layer = @layers[layer_name]
      sprite = layer.sprites[h][w]
      sprite.gotoAndPlay(anim)

  moveTo: (x, y, opts) ->
    new_x = x * @sheet.tilewidth
    new_y = y * @sheet.tileheight
    duration = opts.duration || 1.0
    when_sheet_complete @sheet, () =>
      createjs.Tween.get(@top_container)
        .to({x: new_x, y: new_y}, duration * 1000.0, createjs.Ease.linear)
        .call (tween) =>  # on complete, set new @x and @y
          @x = x
          @y = y
