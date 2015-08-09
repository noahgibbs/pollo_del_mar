class PDM::Player
  attr :zone, true
  attr :x, true
  attr :y, true
  attr :transport, true
  attr :humanoid, true

  def initialize options
    @transport = options[:transport]
    @name = options[:name] || "player"
    @humanoid = PDM::ManaHumanoid.new @name, [ "skeleton", "kettle_hat_male" ], "png"
  end

  def message(*args)
    @transport.game_message *args
  end

  def display
    if @zone
      self.message "displayNewSpriteSheet", @zone.spritesheet
      self.message "displayNewSpriteStack", @zone.spritestack
    end
    self.message "displayNewSpriteSheet", @humanoid.build_spritesheet_json
    self.message "displayNewSpriteStack", @humanoid.build_spritestack_json
  end

  # This moves to a location in the current zone
  def move_to(x, y)
  end
end
