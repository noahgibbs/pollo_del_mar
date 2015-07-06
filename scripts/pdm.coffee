# The top-level PDM library acts as a router between the Transport, the Display,
# the app and local UI and whatever else is necessary.

class window.PDM
  setTransport: (transport, args...) ->
    if transport == "websocket"
      @transport = new PDM.WebsocketTransport(this, args...)
      return
    throw "Unrecognized transport: #{transport}!"
  setDisplay: (display, args...) ->
    if display == "createjs"
      @display = new PDM.CreatejsDisplay(this, args...)
      return
    throw "Unrecognized display: #{display}!"

  getTransport: () -> @transport
  getDisplay: () -> @display
  setup: (options = {}) ->
    pdm_obj = this
    @transport.setHandler (msgName, args) -> pdm_obj.gotTransportCall(msgName, args)
    @transport.setup()
    @display.setup()

  gotTransportCall: (msgName, args) ->
    if msgName == "start"
      console.log "Got start message! Yay!"
      return

    if msgName.slice(0, 7) == "display"
      return @getDisplay().message(msgName, args)

    console.warn "Unknown message name: #{msgName}, args: #{args}"


# This is the parent class of Transport implementations for PDM.
# Transports like Ajax, WebSockets, and record/playback would
# inherit from this class.
class PDM.Transport
  constructor: (@pdm) ->
  setup: () ->

  # Accepts a function like: transportHandler(apiCallName, argArray)
  # This handler is called by the Transport when a message is received from
  # the server
  setHandler: (@handler) ->

  sendMessage: (msgName, args...) ->

# This is the parent class of Display implementations for PDM.
class PDM.Display
  constructor: (@pdm) ->
  setup: () ->
  message: (messageType, argArray) ->
