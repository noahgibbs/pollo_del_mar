require "pollo_del_mar/websocket"
require "pollo_del_mar/humanoid_animation"
require "pollo_del_mar/tmx_support"
require "pollo_del_mar/manasource_tmx_support"
require "pollo_del_mar/zone"

module PDM
  def self.run app
    @app = app
  end
end
