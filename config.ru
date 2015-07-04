Bundler.require :default

# Log synchronously to log.txt in this dir
file = File.new File.join(__dir__, "log.txt"), "a+"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions

# Serve .js files from .coffee files dynamically
use Rack::Coffee, :urls => ""

#use Rack::Static, :root => "public", :urls => ["/public"]

def get_index_html
  # Can cache here later
  File.read "index.html"
end

my_app = Proc.new do |env|
  if Faye::WebSocket.websocket?(env)
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

  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/html'}, [get_index_html]]
  end
end

run my_app
