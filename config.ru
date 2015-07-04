Bundler.require :default

use Rack::CommonLogger
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
