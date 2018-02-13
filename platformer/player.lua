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
end

function player_update(dt)
  if game_state == 1 then
    if love.keyboard.isDown("a") then
      player.body:setX(player.body:getX() - player.speed * dt)
      player.facing = -1
    end

    if love.keyboard.isDown("d") then
      player.body:setX(player.body:getX() + player.speed * dt)
      player.facing = 1
    end

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

function player_keypressed(key)
  if game_state == 1 and key == "w" and player.grounded then
    player.body:applyLinearImpulse(0, -3000)
  end
end
