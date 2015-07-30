TEST_HUM_SPRITESHEET = {
  "name" => "test_humanoid_spritesheet",
  "tilewidth" => 64,
  "tileheight" => 64,
  "properties" => {},
  "animations" => PDM.animation_with_offset("body_", 1).merge(PDM.animation_with_offset("hat_", 95)),
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
  "anim" => "body_walk_left"
}

TEST_ANIM_2 = {
  "stack" => "test_humanoid_stack",
  "layer" => "Hat",
  "w" => 0,
  "h" => 0,
  "anim" => "hat_walk_left"
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

    pdm_terrain = PDM.sprites_from_manasource_tmx File.join(__dir__, "tmx", "evol-boat.tmx")
    @boat_spritesheet = pdm_terrain[:spritesheet]
    @boat_spritestack = pdm_terrain[:spritestack]
    @boat_collision = pdm_terrain[:collision]
    @boat_spritestack["name"] = "evol-boat"

    @zone = PDM::Zone.new spritestack: @boat_spritestack, spritesheet: @boat_spritesheet
  end

  def on_open(options)
    socket = options[:transport]
    player = options[:player]
    player.zone = @zone
    player.transport = PDM::Transport.new socket
    player.spritesheet = TEST_HUM_SPRITESHEET
    player.spritestack = TEST_HUMANOID

    player.display
    player.message "displayStartAnimation", TEST_ANIM
    player.message "displayStartAnimation", TEST_ANIM_2
    player.message "displayMoveStackTo", "test_humanoid_stack", 3, 3, "duration" => 3.0
    EM.add_timer(3.0) do
      player.message "displayPanStackTo", @boat_spritestack["name"], 500, 500, "duration" => 10.0
    end
    EM.add_timer(13.0) do
      player.message "displayStartAnimation", TEST_ANIM_3
      player.message "displayStartAnimation", TEST_ANIM_4
    end
  end
end

PDM.record_traffic
PDM.run GoodShip.new
