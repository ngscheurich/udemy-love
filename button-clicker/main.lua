function love.load()
  target = {}
  target.x = 50
  target.y = 50
  target.size = 50

  score = 0
  timer = 10
  gameState = 0
  highScore = 0

  scoreFont = love.graphics.newFont(20)
  timerFont = love.graphics.newFont(40)
end

function love.update(dt)
  if gameState == 1 then
    if timer > 0 then
      timer = timer - dt
    end

    if timer < 0 then
      timer = 0
      gameState = 0
      if score > highScore then
        highScore = score
      end
      score = 0
    end
  end
end

function love.draw()
  if gameState == 1 then
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", target.x, target.y, target.size)
  end

  love.graphics.setColor(255, 255, 255)

  love.graphics.setFont(scoreFont)
  love.graphics.print("Your Score: " .. score, 10, 10)
  love.graphics.print("High Score: " .. highScore, 10, 40)

  love.graphics.setFont(timerFont)
  love.graphics.print(math.ceil(timer), love.graphics.getWidth() - 70, 10)

  if gameState == 0 then
    love.graphics.printf("Click to begin!", 0, love.graphics.getHeight() / 2,
                         love.graphics.getWidth(), "center")
  end
end

function love.mousepressed(x, y, button, istouch)
  if gameState == 1 and button == 1 then
    if targetClicked({ x = x, y = y }, target) then
      score = score + 1 
      newPos = randomPosition()
      target.x = newPos.x
      target.y = newPos.y
    end
  end

  if gameState == 0 then
    gameState = 1
    timer = 10
  end
end

function targetClicked(mousePos, target)
  distance = distanceBetween(mousePos.x, mousePos.y, target.x, target.y)
  return distance < target.size
end

function randomPosition()
  maxWidth = love.graphics.getWidth() - target.size
  maxHeight = love.graphics.getHeight() - target.size

  return {
    x = math.random(target.size, maxWidth),
    y = math.random(target.size, maxHeight)
  }
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

