HUMANOID_BASE_ANIMATION = {
  "stand_up" => [0],
  "walk_up" => [1, 8],
  "stand_left" => [9],
  "walk_left" => [10, 17, "walk_left", 0.25],
  "stand_down" => [18],
  "walk_down" => [19, 26],
  "stand_right" => [27],
  "walk_right" => [28, 35, "walk_right", 0.25],
  "hurt" => [36, 41, "hurt", 0.25],
  "slash_up" => [42, 47],
  "slash_left" => [48, 53],
  "slash_down" => [54, 59],
  "slash_right" => [60, 65],
  "spellcast_up" => [66, 72],
  "spellcast_left" => [73, 79],
  "spellcast_down" => [80, 86],
  "spellcast_right" => [87, 93],
}

module PDM
  # Return a humanoid animation, offset by a constant number of frames.
  # This is used to have, say, multiple body or equipment animations in
  # the same spritesheet.
  def self.animation_with_offset(prefix, offset)
    anim = {}
    HUMANOID_BASE_ANIMATION.each do |key, value|
      anim[prefix + key] = value.map { |f| f.is_a?(Fixnum) ? f + offset : f }
    end
    anim
  end
end
