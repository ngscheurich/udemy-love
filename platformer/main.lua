function love.load()
  love.window.setMode(900, 700)
  love.graphics.setBackgroundColor(155, 214, 255)

  blip_sound = love.audio.newSource("sounds/blip.wav", "static")
  blip_sound:setPitch(3)

  nature_music = love.audio.newSource("sounds/nature.ogg")
  nature_music:play()

  require("player")
  require("coin")
  require("lib/show_table")
  anim8 = require("lib/anim8")
  sti = require("lib/sti")
  hump_camera = require("lib/hump/camera")

  camera = hump_camera()

  world = love.physics.newWorld(0, 500, false)
  world:setCallbacks(begin_contact, end_contact, pre_solve, post_solve)

  sprites = {}
  sprites.coin_sheet = love.graphics.newImage("sprites/coin_sheet.png")
  sprites.player_stand = love.graphics.newImage("sprites/player_stand.png");
  sprites.player_jump = love.graphics.newImage("sprites/player_jump.png");

  player_load(sprites)

  platforms = {}
  game_map = sti("maps/game_map.lua")
  game_state = 0
  my_font = love.graphics.newFont(30)
  timer = 0

  save_data = {}
  save_data.best_time = 999
  if love.filesystem.exists("data.lua") then
    local data = love.filesystem.load("data.lua")
    data()
  end

  for i,obj in pairs(game_map.layers["platforms"].objects) do
    spawn_platform(obj.x, obj.y, obj.width, obj.height)
  end

  spawn_coins()
end

function love.update(dt)
  world:update(dt)
  player_update(dt)
  game_map:update(dt)
  coin_update(dt)

  camera:lookAt(player.body:getX(), love.graphics.getHeight() / 2)

  for i,c in ipairs(coins) do
    c.animation:update(dt)
  end

  if game_state == 1 then
    timer = timer + dt
  end

  if #coins == 0 and game_state == 1 then
    game_state = 0
    player.body:setPosition(player.initPos.x, player.initPos.y)
    spawn_coins()

    if timer < save_data.best_time then
      save_data.best_time = math.floor(timer)
      love.filesystem.write("data.lua", table.show(save_data, "save_data"))
    end
  end
end

function love.draw()
  camera:attach()

  game_map:drawLayer(game_map.layers["tiles"])

  player_draw()

  for i,c in ipairs(coins) do
    c.animation:draw(sprites.coin_sheet, c.x, c.y)
  end

  camera:detach()

  if game_state == 0 then
    love.graphics.setFont(my_font)
    love.graphics.printf("Press any key to begin", 0, 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Best time: " .. save_data.best_time, 0, 150, love.graphics.getWidth(), "center")
  end

  love.graphics.print("Time: " .. math.floor(timer), 10, 660)
end

function love.keypressed(key, scancode, isrepeat) 
  player_keypressed(key)

  if game_state == 0 then
    game_state = 1
    timer = 0
  end
end

function spawn_platform(x, y, width, height)
  local platform = {};
  platform.body = love.physics.newBody(world, x, y, "static")
  platform.shape = love.physics.newRectangleShape(width / 2, height / 2, width, height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape)
  platform.width = width
  platform.height = height

  table.insert(platforms, platform)
end

function begin_contact(a, b, coll)
  player.grounded = true
end

function end_contact(a, b, coll)
  player.grounded = false
end

function distance_between(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function spawn_coins()
  for i,obj in pairs(game_map.layers["coins"].objects) do
    spawn_coin(obj.x, obj.y, obj.width, obj.height)
  end
end
