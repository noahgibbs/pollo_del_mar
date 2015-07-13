class GoodShip
  def on_open(socket)
    socket.send PDM.websocket_game_message("displayNewSpriteSheet", TEST_SPRITESHEET)
    socket.send PDM.websocket_game_message("displayNewSpriteStack", TEST_SPRITESTACK)
    socket.send PDM.websocket_game_message("displayNewSpriteSheet", TEST_HUM_SPRITESHEET)
    socket.send PDM.websocket_game_message("displayNewSpriteStack", TEST_HUMANOID)
    socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM)
    socket.send PDM.websocket_game_message("displayStartAnimation", TEST_ANIM_2)
    socket.send PDM.websocket_game_message("displayMoveStackTo", "test_humanoid_stack", 3, 3, "duration" => 3.0)
  end
end

PDM.run GoodShip.new
