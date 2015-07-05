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
    @transport.setHandler gotTransportCall
    @transport.setup()
    @display.setup()

# This is the parent class of Transport implementations for PDM.
# Transports like Ajax, WebSockets, and record/playback would
# inherit from this class.
class PDM.Transport
  constructor: (@pdm) ->
  setup: () ->

  # Accepts a function like: transportHandler(apiCallName, argArray)
  setHandler: (@handler) ->


# This is the parent class of Display implementations for PDM.
class PDM.Display
  constructor: (@pdm) ->
  setup: () ->
  message: (messageType, argArray) ->


gotTransportCall = (msgName, args) ->
  if msgName == "login"
    console.log "Got login message! Yay!"

  if msgName.slice(0, 7) == "display"
    PDM.getDisplay().message(msgName, args)

  console.warning "Unknown message name: #{msgName}, args: #{args}"
