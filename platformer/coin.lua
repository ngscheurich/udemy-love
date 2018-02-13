coins = {}

function spawn_coin(x, y)
  local coin = {}
  coin.x = x
  coin.y = y
  coin.grid = anim8.newGrid(41, 42, 123, 126)
  coin.animation = anim8.newAnimation(coin.grid('1-3', 1, '1-3', 2, '1-2', 3), 0.1)
  coin.collected = false

  table.insert(coins, coin)
end

function coin_update(dt)
  for i,c in ipairs(coins) do
    if distance_between(c.x, c.y, player.body:getX(), player.body:getY()) < 50 then
      c.collected = true
      blip_sound:play()
    end
  end

  for i=#coins,1, -1 do
    local c = coins[i]
    if c.collected then
      table.remove(coins, i)
    end
  end
end
