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

      @handleExposure()

  setExposure: (@exposure) ->
    @handleExposure()

  handleExposure: () ->
    @x = parseInt(@x)
    @y = parseInt(@y)
    @exposure.x = parseInt(@exposure.x)
    @exposure.y = parseInt(@exposure.y)
    @top_container.setTransform @x - (@exposure.x || 0), @y - (@exposure.y || 0)

    height = Math.min @exposure.height, @height
    width = Math.min @exposure.width, @width

    # Offsets of lowest visible tile
    start_tile_x = parseInt((@exposure.x - @x) / @sheet.tilewidth)
    start_tile_x = Math.max(start_tile_x, 0)
    start_tile_y = parseInt((@exposure.y - @y) / @sheet.tileheight)
    start_tile_y = Math.max(start_tile_y, 0)

    if start_tile_x == @last_start_tile_x && start_tile_y == @last_start_tile_y
      return
    @last_start_tile_x = start_tile_x
    @last_start_tile_y = start_tile_y

    # Offsets of highest visible tile
    end_tile_x = parseInt((@exposure.x - @x + @exposure.width + @sheet.tilewidth - 1) / @sheet.tilewidth)
    end_tile_x = Math.min(end_tile_x, @width - 1)
    end_tile_y = parseInt((@exposure.y - @y + @exposure.height + @sheet.tileheight - 1) / @sheet.tileheight)
    end_tile_y = Math.min(end_tile_y, @height - 1)
    @last_end_tile_x = end_tile_x
    @last_end_tile_y = end_tile_y

    # How many tiles high and wide might be exposed at most?
    width_tiles = end_tile_x - start_tile_x + 1
    height_tiles = end_tile_y - start_tile_y + 1

    for layer_name in @layer_order
      layer = @layers[layer_name]
      sprites = layer.sprites = []
      ld = layer.data

      for h in [start_tile_y..end_tile_y]
        h_ctr = h - start_tile_y
        sprites[h_ctr] = sprites[h_ctr] || []
        for w in [start_tile_x..end_tile_x]
          w_ctr = w - start_tile_x
          sprite = sprites[h_ctr][w_ctr]
          unless sprite
            sprite = sprites[h_ctr][w_ctr] = @sheet.create_sprite()
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
      return if h < @last_start_tile_y || w < @last_start_tile_x
      return if h > @last_end_tile_y || w > @last_end_tile_x
      sprite = layer.sprites[h][w]
      sprite.gotoAndPlay(anim)

  moveTo: (x, y, opts) ->
    new_x = x * @sheet.tilewidth
    new_y = y * @sheet.tileheight
    duration = opts.duration || 1.0
    when_sheet_complete @sheet, () =>
      createjs.Tween.get(this)
        .to({x: new_x, y: new_y}, duration * 1000.0, createjs.Ease.linear)
        .addEventListener("change", () => @handleExposure())
        .call (tween) =>  # on complete, set new @x and @y
          @x = x
          @y = y

  panToExposure: (new_exp_x, new_exp_y, opts) ->
    duration = opts.duration || 1.0
    when_sheet_complete @sheet, () =>
      createjs.Tween.get(@exposure)
        .to({x: new_exp_x, y: new_exp_y}, duration * 1000.0, createjs.Ease.linear)
        .addEventListener("change", () => @handleExposure())
        .call (tween) =>
          @exposure.x = new_exp_x
          @exposure.y = new_exp_y
