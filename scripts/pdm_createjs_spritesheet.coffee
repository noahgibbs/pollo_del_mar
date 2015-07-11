class PDM.CreatejsDisplay.CreatejsSpriteSheet
  constructor: (@tilewidth, @tileheight, @images, @animations) ->
    PDM.CreatejsDisplay.loader.addHandler @imagesLoaded
    PDM.CreatejsDisplay.loader.addImages @images
    @sheet = new createjs.SpriteSheet frames: { width: @tilewidth, height:  @tileheight }, images: @images, animations: @animations

  create_sprite: () ->
    new createjs.Sprite(@sheet)

  ss_frame_to_cjs_frame: (frame_num) ->
    for image, offset of @images
      if frame_num >= tileset.firstgid && (!@images[offset + 1]? || frame_num < @images[offset + 1].firstgid)
        return (frame_num - @images[offset].firstgid) + @images[offset].cjs_offset
    console.warn "Can't map frame #{frame_num} into SpriteSheet!"
    undefined

  imagesLoaded: () ->
