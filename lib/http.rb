def get_index_html
  # Can cache here later
  File.read "index.html"
end

def http_handler(env)
  # Normal HTTP request
  [200, {'Content-Type' => 'text/html'}, [get_index_html]]
end
