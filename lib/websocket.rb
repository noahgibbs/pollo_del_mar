def websocket_game_message(msg_name, *args)
  MultiJson.dump ["game_msg", msg_name, *args]
end

def websocket_handler(env)
  ws = Faye::WebSocket.new(env)

  ws.on :open do |event|
    puts "Server open"
    ws.send websocket_game_message("start")
  end

  ws.on :message do |event|
    puts "Echo server got message!"
    ws.send(event.data)
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
