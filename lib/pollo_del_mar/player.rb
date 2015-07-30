class PDM::Player
  attr :zone, true
  attr :transport, true
  attr :spritesheet, true
  attr :spritestack, true

  def initialize options
    @transport = options[:transport]
    @spritesheet = options[:spritesheet]
    @spritestack = options[:spritestack]
  end

  def message(*args)
    @transport.game_message *args
  end

  def display
    if @zone
      self.message "displayNewSpriteSheet", @zone.spritesheet
      self.message "displayNewSpriteStack", @zone.spritestack
    end
    if @spritesheet && @spritestack
      self.message "displayNewSpriteSheet", @spritesheet
      self.message "displayNewSpriteStack", @spritestack
    end
  end
end
