TEST_SPRITESHEET = {
  "name" => "test_spritesheet",
  "tile_width" => 32,
  "tile_height" => 32,
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
