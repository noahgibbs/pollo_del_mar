class PDM

  def self.websocket_game_message(msg_name, *args)
    MultiJson.dump ["game_msg", msg_name, *args]
  end

  def self.websocket_handler(env)
    ws = Faye::WebSocket.new(env)

    ws.on :open do |event|
      puts "Server open"
      ws.send PDM.websocket_game_message("start")
      @app.on_open(ws) if @app && @app.respond_to?(:on_open)
    end

    ws.on :message do |event|
      data = MultiJson.load event.data
      puts "Got message: #{data.inspect}"
      handle_message ws, data
    end

    ws.on :error do |event|
      puts "Protocol error: #{event.inspect}"
      @app.on_error(ws) if @app && @app.respond_to?(:on_error)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason].inspect
      @app.on_close(ws) if @app && @app.respond_to?(:on_close)
      ws = nil
    end

    # Return async Rack response
    ws.rack_response
  end

  def self.handle_message(ws, data)
    if data[0] == "gamePing"
      ws.send websocket_game_message("gamePong")
      return
    end
    @app.on_message(ws) if @app && @app.respond_to?(:on_message)
  end
end
