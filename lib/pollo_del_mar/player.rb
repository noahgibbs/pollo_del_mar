class PDM::Player
  attr :zone, true
  attr :x, true
  attr :y, true
  attr :transport, true
  attr :humanoid, true

  def initialize options
    @transport = options[:transport]
    @name = options[:name] || "player"
    @layers = [ "skeleton", "kettle_hat_male" ]
    @humanoid = PDM::ManaHumanoid.new @name, @layers, "png"
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

  def send_animation anim_name
    @layers.each do |layer|
      anim_msg = {
        "stack" => "#{@name}_stack",
        "layer" => layer,
        "w" => 0,
        "h" => 0,
        "anim" => "#{layer}_#{anim_name}"
      }
      message "displayStartAnimation", anim_msg
    end
  end

  # This moves to a location in the current zone
  def move_to(x, y, options = {})
    message "displayMoveStackTo", "#{@name}_stack", x, y, options
  end
end
