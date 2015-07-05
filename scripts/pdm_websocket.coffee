send_api_message = (ws, msg_name, args) ->
  # Serialize as JSON, send
  msg_data = JSON.stringify([ "game_msg", msg_name, args ])
  ws.send msg_data

api_handler = (ws, msg_type, args) ->
  console.log "Handling game msg: #{msg_type}", args
  if msg_type == "start"
    send_api_message ws, "login", ["a", "b", "c"]

class PDM.WebsocketTransport extends PDM.Transport
  constructor: (@pdm, @ws) ->

  setup: () ->
    ws = @ws
    ws.onmessage = (evt) ->
      console.log "message received"
      data = JSON.parse evt.data
      if data[0] != "game_msg"
        console.log "Unexpected message type: #{data[0]}"
        return

      api_handler ws, data[1], data.slice(2)

    ws.onclose = () ->
      console.log "socket closed"

    ws.onopen = () ->
      console.log "connected..."
