require "lib/humanoid_animation"

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

def websocket_game_message(msg_name, *args)
  MultiJson.dump ["game_msg", msg_name, *args]
end

def websocket_handler(env)
  ws = Faye::WebSocket.new(env)

  ws.on :open do |event|
    puts "Server open"
    ws.send websocket_game_message("start")
    ws.send websocket_game_message("displayNewSpriteSheet", TEST_SPRITESHEET)
    ws.send websocket_game_message("displayNewSpriteStack", TEST_SPRITESTACK)
    ws.send websocket_game_message("displayNewSpriteSheet", TEST_HUM_SPRITESHEET)
    ws.send websocket_game_message("displayNewSpriteStack", TEST_HUMANOID)
    ws.send websocket_game_message("displayStartAnimation", TEST_ANIM)
    ws.send websocket_game_message("displayStartAnimation", TEST_ANIM_2)
    ws.send websocket_game_message("displayMoveStackTo", "test_humanoid_stack", 3, 3, "duration" => 3.0)
  end

  ws.on :message do |event|
    data = MultiJson.load event.data
    puts "Got message: #{data.inspect}"
    handle_message ws, data
  end

  ws.on :error do |event|
    puts "Protocol error: #{event.inspect}"
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason].inspect
    ws = nil
  end

  # Return async Rack response
  ws.rack_response
end

def handle_message(ws, data)
  if data[0] == "gamePing"
    ws.send websocket_game_message("gamePong")
  end
  puts "Unrecognized message: #{data.inspect}!"
end
