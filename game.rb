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

TEST_ANIM_3 = {
  "stack" => "test_humanoid_stack",
  "layer" => "Body",
  "w" => 0,
  "h" => 0,
  "anim" => "body_stand_right"
}

TEST_ANIM_4 = {
  "stack" => "test_humanoid_stack",
  "layer" => "Hat",
  "w" => 0,
  "h" => 0,
  "anim" => "hat_stand_right"
}

class GoodShip
  def initialize
    pdm_terrain = PDM.sprites_from_tmx File.join(__dir__, "tmx", "terrain-test.tmx")
    @terrain_spritesheet = pdm_terrain[:spritesheet]
    @terrain_spritestack = pdm_terrain[:spritestack]
    @terrain_spritestack["name"] = "terrain-test"
  end

  def on_open(socket)
    socket.send PDM.websocket_game_message("displayNewSpriteSheet", @terrain_spritesheet)
    socket.send PDM.websocket_game_message("displayNewSpriteStack", @terrain_spritestack)
    socket.send PDM.websocket_game_message("displayNewSpriteSheet", TEST_HUM_SPRITESHEET)
    socket.send PDM.websocket_game_message("displayNewSpriteStack", TEST_HUMANOID)
    socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM)
    socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM_2)
    socket.send PDM.websocket_game_message("displayMoveStackTo", "test_humanoid_stack", 3, 3, "duration" => 3.0)
    EM.add_timer(3.0) do
      socket.send PDM.websocket_game_message("displayPanStackTo", @terrain_spritestack["name"], 500, 500, "duration" => 10.0)
    end
    EM.add_timer(13.0) do
      socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM_3)
      socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM_4)
    end
  end
end

PDM.run GoodShip.new
