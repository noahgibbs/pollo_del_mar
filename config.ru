Bundler.require :default

$LOAD_PATH.push File.join(__dir__, "lib")

require "pollo_del_mar"

# Log synchronously to log/puma_master.txt
file = File.new File.join(__dir__, "log", "puma_master.txt"), "a+"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions

# Serve .js files from .coffee files dynamically
use Rack::Coffee, :urls => ""
use Rack::Static, :urls => ["/tiles", "/sprites"]

def combined_handler
  Proc.new do |env|
    if Faye::WebSocket.websocket? env
      websocket_handler env
    else
      [200, {'Content-Type' => 'text/html'}, [File.read("index.html")]]
    end
  end
end

EM.error_handler do |e|
  STDERR.puts "ERROR: #{e.message}\n#{e.backtrace.join "\n"}\n"
end

run combined_handler
