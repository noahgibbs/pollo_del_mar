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
