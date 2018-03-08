function player_load(sprites)
  player = {}
  player.initPos = {x = 130, y = 443}
  player.body = love.physics.newBody(world, player.initPos.x, player.initPos.y, "dynamic");
  player.shape = love.physics.newRectangleShape(66, 92);
  player.fixture = love.physics.newFixture(player.body, player.shape);
  player.speed = 200
  player.grounded = false
  player.facing = 1
  player.sprite = sprites.player_stand
  player.body:setFixedRotation(true)
  player.jumps = 0
  player.jumpLimit = 4

  local joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]
end

function player_update(dt)
  if game_state == 1 then
    if not joystick then return end

    local dir = joystick:getAxis(1)
    player.body:setX(player.body:getX() + player.speed * dir * dt)

    player.facing = dir >= 0 and 1 or -1
    player.sprite =
      player.grounded and sprites.player_stand or sprites.player_jump
  end
end

function player_draw()
  love.graphics.draw(
    player.sprite,
    player.body:getX(),
    player.body:getY(),
    nil,
    player.facing,
    1,
    sprites.player_stand:getWidth() / 2,
    sprites.player_stand:getHeight() / 2
  );
end

function can_jump(button)
  local wants_to_jump = game_state == 1 and button == "a"
  return wants_to_jump and player.grounded or wants_to_jump and player.jumps < player.jumpLimit
end

function love.gamepadpressed(_joystick, button)
  if game_state == 0 then
    game_state = 1
    timer = 0
  else 
    if can_jump(button) then
      player.body:applyLinearImpulse(0, -3000)
      player.jumps = player.jumps + 1
    end
  end
end
