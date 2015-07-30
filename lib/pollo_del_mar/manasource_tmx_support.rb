module PDM
  # This is to support TMX files for ManaSource, ManaWorld, Land of
  # Fire, Source of Tales and other Mana Project games. It can't be
  # perfect since there's some variation between them, but it can
  # follow most major conventions.

  # TODO: ambient layers from properties, a la Evol (see 000-0.tmx)

  def self.sprites_from_manasource_tmx(filename)
    objs = sprites_from_tmx filename
    sheet = objs[:spritesheet]
    stack = objs[:spritestack]

    stack_layers = stack[:layers]

    # Remove the collision layer, add as separate collision top-level entry
    collision_index = stack_layers.index { |l| l[:name].downcase == "collision" }
    collision_layer = stack_layers.delete_at collision_index

    # Some games make this true/false, others have separate visibility
    # or swimmability in it. In general, we'll just expose the data.
    objs[:collision] = collision_layer[:data]

    fringe_index = stack_layers.index { |l| l[:name].downcase == "fringe" }
    stack_layers.each_with_index do |layer, index|
      # Assign a Z value based on layer depth, with fringe = 0 as a special case
      layer["z"] = (index - fringe_index) * 10.0
    end

    objs
  end
end
