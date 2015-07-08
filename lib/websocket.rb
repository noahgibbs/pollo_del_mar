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
  "tilewidth" => 32,
  "tileheight" => 32,
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

HUMANOID_DEFAULT_ANIMATIONS = {
  "stand_up" => [1],
  "walk_up" => [2, 9],
  "stand_left" => [10],
  "walk_left" => [11, 18],
  "stand_down" => [19],
  "walk_down" => [20, 27],
  "stand_right" => [28],
  "walk_right" => [29, 36],
  "hurt" => [37, 42, "hurt", 0.25],
  "slash_up" => [43, 48],
  "slash_left" => [49, 54],
  "slash_down" => [55, 60],
  "slash_right" => [61, 66],
  "spellcast_up" => [67, 73],
  "spellcast_left" => [74, 80],
  "spellcast_down" => [81, 87],
  "spellcast_right" => [88, 94],
}

TEST_HUM_SPRITESHEET = {
  "name" => "test_humanoid_spritesheet",
  "tilewidth" => 64,
  "tileheight" => 64,
  "properties" => {},
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
  ],
  "" => "",
}

TEST_HUMANOID = {
  "name" => "test_humanoid_stack",
  "width" => 1,
  "height" => 1,
  "tilewidth" => 64,
  "tileheight" => 64,
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
  ],
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
