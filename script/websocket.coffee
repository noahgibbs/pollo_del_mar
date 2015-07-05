api_handler = (msg_type, args) ->
  console.log "API msg: #{msg_type}", args

window.setup_websocket_handler = (ws) ->
  ws.onmessage = (evt) ->
    console.log "message received"
    data = eval "(#{evt.data})"
    if data[0] != "game_msg"
      console.log "Unexpected message type: #{data[0]}"
      return

    api_handler data[1], data.slice(2)

  ws.onclose = () ->
    console.log "socket closed"

  ws.onopen = () ->
    console.log "connected..."
