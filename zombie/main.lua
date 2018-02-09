function love.load()
  sprites = {}
  sprites.player = love.graphics.newImage("sprites/player.png")
  sprites.bullet = love.graphics.newImage("sprites/bullet.png")
  sprites.zombie = love.graphics.newImage("sprites/zombie.png")
  sprites.background = love.graphics.newImage("sprites/background.png")

  player = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    speed = 180
  }
  zombies = {}
  bullets = {}
  zombie_screen_offset = 30
  game_state = 0
  max_time = 2
  timer = max_time
  score = 0
  large_font = love.graphics.newFont(30)
end

function love.update(dt)
  if game_state == 1 then
    if love.keyboard.isDown("w") and player.y > 0 then
      player.y = player.y - player.speed * dt
    end

    if love.keyboard.isDown("a") and player.x > 0 then
      player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end

    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end
  end

  for i, zombie in ipairs(zombies) do
    angle = player_zombie_angle(zombie)
    zombie.x = zombie.x + math.cos(angle) * zombie.speed * dt
    zombie.y = zombie.y + math.sin(angle) * zombie.speed * dt

    distance = distance_between(zombie.x, zombie.y,
                                player.x, player.y) 
    if distance < 30 then
      for k,v in pairs(zombies) do zombies[k]=nil end
      game_state = 0
      score = 0
      player.x = love.graphics.getWidth() / 2
      player.y = love.graphics.getHeight() / 2
    end

    for j, bullet in ipairs(bullets) do
      distance = distance_between(zombie.x, zombie.y,
                                  bullet.x, bullet.y) 
      if distance < 20 then
        score = score + 1
        table.remove(zombies, i)
        table.remove(bullets, j)
      end
    end
  end

  for i, bullet in ipairs(bullets) do
    bullet.x = bullet.x + math.cos(bullet.direction) * bullet.speed * dt 
    bullet.y = bullet.y + math.sin(bullet.direction) * bullet.speed * dt 
  end

  for i = #bullets, 1, -1 do
    local b = bullets[i]
    if is_offscreen(b) then
      table.remove(bullets, i)
    end
  end

  if game_state == 1 then
    timer = timer - dt
    if timer <= 0 then
      spawn_zombie()
      max_time = max_time * 0.95
      timer = max_time
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)

  rotation = game_state == 0 and 0 or player_mouse_angle()
  draw_sprite(player, sprites.player, rotation)

  for i, zombie in ipairs(zombies) do
    rotation = player_zombie_angle(zombie)
    draw_sprite(zombie, sprites.zombie, rotation)
  end

  for i, bullet in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, bullet.x, bullet.y,
                       nil, 0.5, 0.5,
                       sprites.bullet:getWidth() / 2,
                       sprites.bullet:getHeight() / 2)
  end

  if game_state == 0 then
    love.graphics.setFont(large_font)
    love.graphics.printf("Click to begin!", 0, 50,
                         love.graphics.getWidth(), "center")
  end

  love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

function love.mousepressed(x, y, button, istouch)
  if button == 1 then
    if game_state == 0 then
      game_state = 1
      max_time = 2
      timer = max_time
    else
      spawn_bullet()
    end
  end
end

function is_offscreen(e)
  rightEdge = love.graphics.getWidth()
  bottomEdge = love.graphics.getHeight()
  return e.x < 0 or e.y < 0 or e.x > rightEdge or e.y > bottomEdge
end

function draw_sprite(entity, sprite, rotation)
  love.graphics.draw(sprite, entity.x, entity.y, rotation, nil, nil,
                     sprite:getWidth() / 2, sprite:getHeight() / 2)
end

function player_mouse_angle()
  return math.atan2(player.y - love.mouse.getY(),
                    player.x - love.mouse.getX()) + math.pi
end

function player_zombie_angle(zombie)
  return math.atan2(player.y - zombie.y,
                    player.x - zombie.x)
end

function spawn_zombie()
  zombie = {
    x = 0,
    y = 0,
    speed = 140,
    dead = false
  }

  local side = math.random(1, 4)

  if side == 1 then
    zombie.x = -zombie_screen_offset
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -zombie_screen_offset
  elseif side == 3 then
    zombie.x = love.graphics.getWidth() + zombie_screen_offset
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 4 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + zombie_screen_offset
  end

  table.insert(zombies, zombie)
end

function spawn_bullet()
  bullet = {
    x = player.x,
    y = player.y,
    speed = 500,
    direction = player_mouse_angle(),
    dead = false
  }

  table.insert(bullets, bullet)
end

function distance_between(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
