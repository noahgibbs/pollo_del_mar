require "pollo_del_mar/websocket"
require "pollo_del_mar/tmx_support"
require "pollo_del_mar/manasource_tmx_support"
require "pollo_del_mar/transport"

require "pollo_del_mar/zone"
require "pollo_del_mar/humanoid"
require "pollo_del_mar/player"

module PDM
  def self.run app
    @app = app
  end
end
