require "tmx"

# TODO: terrain animations
# TODO: object layers
# TODO: image layers

class PDM
  def self.sprites_from_tmx(filename)
    spritesheet = {}
    spritestack = {}

    # This recursively loads things like tileset .tsx files
    tiles = Tmx.load filename

    spritestack[:name] = tiles.name
    spritestack[:width] = tiles.width
    spritestack[:height] = tiles.height
    spritestack[:properties] = tiles.properties

    spritesheet[:tilewidth] = tiles.tilewidth
    spritesheet[:tileheight] = tiles.tileheight

    spritesheet[:images] = tiles.tilesets.map do |tileset|
      {
        firstgid: tileset.firstgid,
        tileset_name: tileset.name,
        image: "/tiles/" + tileset.image.split("/")[-1],
        image_width: tileset.imagewidth,
        image_height: tileset.imageheight,
        properties: tileset.properties,
      }
    end
    spritesheet[:cyclic_animations] = animations_from_tilesets tiles.tilesets

    spritesheet[:properties] = spritesheet[:images].map { |i| i[:properties] }.inject({}, &:merge)
    spritesheet[:name] = spritesheet[:images].map { |i| i[:tileset_name] }.join("/")
    spritestack[:spritesheet] = spritesheet[:name]

    if spritesheet[:images].map { |ts| ts[:tile_width] }.uniq.length > 1 ||
       spritesheet[:images].map { |ts| ts[:tile_height] }.uniq.length > 1
      raise "Can't have more than one tilewidth or tileheight in the same SpriteSheet right now!"
    end

    spritestack[:layers] = tiles.layers.map do |layer|
      data = layer.data.each_slice(layer.width).to_a
      {
        name: layer.name,
        data: data,
        visible: layer.visible,
        opacity: layer.opacity,
        properties: layer.properties
      }
    end

    { spritesheet: spritesheet, spritestack: spritestack }
  end

  def self.animations_from_tilesets tilesets
    tilesets.flat_map do |tileset|
      tileset.tiles.map do |tile|
        p = tile["properties"]
        if p && p["animation-frame0"]
          section = 0
          anim = []
          # TODO: animation delays
          while p["animation-frame#{section}"]
            section_hash = {
              frame: p["animation-frame#{section}"].to_i + tileset[:firstgid],
              duration: p["animation-delay#{section}"].to_i
            }
            anim.push section_hash
            section += 1
          end
          { "tile_anim_#{tile["id"].to_i + tileset[:firstgid]}".to_sym => anim }
        else
          nil
        end
      end.compact
    end.inject({}, &:merge)
  end

end
