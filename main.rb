#!/usr/bin/env ruby

require 'em-websocket'
require 'em-http-server'

class HTTPHandler < EM::HttpServer::Server

    def process_http_request
          puts  @http_request_method
          puts  @http_request_uri
          puts  @http_query_string
          puts  @http_protocol
          puts  @http_content
          puts  @http[:cookie]
          puts  @http[:content_type]
          # you have all the http headers in this hash
          puts  @http.inspect

          response = EM::DelegatedHttpResponse.new(self)
          response.status = 200
          response.content_type 'text/html'
          response.content = 'It works'
          response.send_response
    end

    def http_request_errback e
      # printing the whole exception
      puts e.inspect
    end

end

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8765) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      ws.send "Pong: #{msg}"
    }
  end

  EM::start_server("0.0.0.0", 8766, HTTPHandler)
}
