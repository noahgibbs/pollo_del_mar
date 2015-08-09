TEST_ANIM = {
  "stack" => "player_stack",
  "layer" => "skeleton",
  "w" => 0,
  "h" => 0,
  "anim" => "skeleton_walk_left"
}

TEST_ANIM_2 = {
  "stack" => "player_stack",
  "layer" => "kettle_hat_male",
  "w" => 0,
  "h" => 0,
  "anim" => "kettle_hat_male_walk_left"
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
    player = PDM::Player.new transport: PDM::Transport.new(socket), name: "player"
    player.zone = @zone

    player.display
    player.send_animation "walk_left"
    player.message "displayMoveStackTo", "player_stack", 3, 3, "duration" => 3.0
    EM.add_timer(3.0) do
      player.message "displayPanStackTo", @boat_spritestack["name"], 500, 500, "duration" => 10.0
    end
    EM.add_timer(13.0) do
      player.send_animation "stand_right"
    end
  end
end

PDM.record_traffic
PDM.run GoodShip.new
