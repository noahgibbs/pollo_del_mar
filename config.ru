Bundler.require :default

$LOAD_PATH.push __dir__

# Load local requires. Don't need this for Gems, we do that with Bundler.
require "lib/websocket"
require "lib/http"

# Log synchronously to log.txt in this dir
file = File.new File.join(__dir__, "log.txt"), "a+"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions

# Serve .js files from .coffee files dynamically
use Rack::Coffee, :urls => ""

#use Rack::Static, :root => "public", :urls => ["/public"]

def combined_handler
  Proc.new do |env|
    if Faye::WebSocket.websocket? env
      websocket_handler env
    else
      http_handler env
    end
  end
end

run combined_handler
