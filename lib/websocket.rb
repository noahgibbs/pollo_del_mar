def websocket_handler(env)
  ws = Faye::WebSocket.new(env)

  ws.on :message do |event|
    puts "Echo server got message!"
    ws.send(event.data)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason].inspect
    ws = nil
  end

  # Return async Rack response
  ws.rack_response
end
