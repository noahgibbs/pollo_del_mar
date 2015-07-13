require "tmx"

def pdm_from_tmx(filename)
  out = {}

  # This recursively loads things like tileset .tsx files
  tiles = Tmx.load filename

  out["width"] = tiles.width
  out["height"] = tiles.height
  out["tilewidth"] = tiles.tilewidth
  out["tileheight"] = tiles.tileheight

  out["tilesets"] = tiles.tilesets.map do |tileset|
    {
      firstgid: tileset.firstgid,
      image: "/tiles/" + tileset.image.split("/")[-1],
      image_width: tileset.imagewidth,
      image_height: tileset.imageheight,
      tile_width: tileset.tilewidth,
      tile_height: tileset.tileheight,
      properties: tileset.properties,
    }
  end

  if out["tilesets"].map { |ts| ts[:tile_width] }.uniq.length > 1 ||
     out["tilesets"].map { |ts| ts[:tile_height] }.uniq.length > 1
    raise "Can't have more than one tilewidth or tileheight in the same SpriteSheet right now!"
  end

  out["layers"] = tiles.layers.map do |layer|
    data = layer.data.each_slice(layer.width).to_a
    {
      name: layer.name,
      data: data,
      visible: layer.visible,
      opacity: layer.opacity,
      properties: layer.properties
    }
  end

end

TEST_SPRITESHEET = {
  "name" => "test_spritesheet",
  "tilewidth" => 32,
  "tileheight" => 32,
  "properties" => {},
  "images" => [{
    "firstgid" => 1,
    "image" => "/tiles/terrain.png",
    "max_tiles" => (512 / 32) * (928 / 32),
    "image_width" => 512,
    "image_height" => 928,
  }],
  "" => "",
}

TEST_SPRITESTACK = {
  "name" => "test_spritestack",
  "width" => 3,
  "height" => 3,
  "spritesheet" => "test_spritesheet",
  "layers" => [
    {
      "name" => "Ground",
      "data" => [ [1, 3, 1], [3, 1, 3], [1, 3, 1] ],
      "visible" => true,
      "opacity" => 1.0,
      # width, height? Nope.
    },
    {
      "name" => "Fringe",
      "data" => [ [5, 0, 0], [0, 0, 0], [0, 0, 0] ],
      "visible" => true,
      "opacity" => 0.5,
    },
  ],
  # Object layers?
  # Image layers?
  "properties": {},
}

TEST_HUM_SPRITESHEET = {
  "name" => "test_humanoid_spritesheet",
  "tilewidth" => 64,
  "tileheight" => 64,
  "properties" => {},
  "animations" => animation_with_offset("body_", 1).merge(animation_with_offset("hat_", 95)),
  "images" => [
    {
      "firstgid" => 1,
      "image" => "/sprites/skeleton_walkcycle.png",
      "image_width" => 576,
      "image_height" => 256,
    },
    {
      "firstgid" => 37,
      "image" => "/sprites/skeleton_hurt.png",
      "image_width" => 384,
      "image_height" => 64,
    },
    {
      "firstgid" => 43,
      "image" => "/sprites/skeleton_slash.png",
      "image_width" => 384,
      "image_height" => 256,
    },
    {
      "firstgid" => 67,
      "image" => "/sprites/skeleton_spellcast.png",
      "image_width" => 448,
      "image_height" => 256,
    },
    {
      "firstgid" => 95,
      "image" => "/sprites/kettle_hat_male_walkcycle.png",
      "image_width" => 576,
      "image_height" => 256,
    },
    {
      "firstgid" => 131,
      "image" => "/sprites/kettle_hat_male_hurt.png",
      "image_width" => 384,
      "image_height" => 64,
    },
    {
      "firstgid" => 137,
      "image" => "/sprites/kettle_hat_male_slash.png",
      "image_width" => 384,
      "image_height" => 256,
    },
    {
      "firstgid" => 161,
      "image" => "/sprites/kettle_hat_male_spellcast.png",
      "image_width" => 448,
      "image_height" => 256,
    },
  ],
}

TEST_HUMANOID = {
  "name" => "test_humanoid_stack",
  "width" => 1,
  "height" => 1,
  #"x" => 0,
  #"y" => 32 * 3,
  "spritesheet" => "test_humanoid_spritesheet",
  "layers" => [
    {
      "name" => "Body",
      "data" => [ [1] ],
      "visible" => true,
      "opacity" => 1.0,
    },
    {
      "name" => "Hat",
      "data" => [ [179] ],
      "visible" => true,
      "opacity" => 1.0,
    },
  ],
}

TEST_ANIM = {
  "stack" => "test_humanoid_stack",
  "layer" => "Body",
  "w" => 0,
  "h" => 0,
  "anim" => "body_walk_right"
}

TEST_ANIM_2 = {
  "stack" => "test_humanoid_stack",
  "layer" => "Hat",
  "w" => 0,
  "h" => 0,
  "anim" => "hat_walk_right"
}
