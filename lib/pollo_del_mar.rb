# Load local requires. Don't need this for Gems, we do that with Bundler.
require "pollo_del_mar/websocket"
require "pollo_del_mar/humanoid_animation"
require "pollo_del_mar/tmx_support"

class PDM
  def self.run app
    @app = app
  end
end
