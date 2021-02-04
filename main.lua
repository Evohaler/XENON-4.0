-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
User_interface = love.graphics.newImage('Sprites/XenonUI.png')
isAlive = true
score = 0

createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
enemyImg = nil -- Like other images we'll pull this in during out love.load functio
enemies = {} -- array of current enemies on screen

canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

bulletImg = nil
bullets = {} -- array of current bullets being drawn and updated

player ={x=300, y=500, speed = 150, img=nil}

--space
background = love.graphics.newImage('Sprites/space_1200.png')
backgroundScroll = 0
BACKGROUND_SCROLL_SPEED = 30
BACKGROUND_LOOP = 595
--wall
ground = love.graphics.newImage('Sprites/Xenon_wall1200.png')
groundScroll = 0
GROUND_SCROLL_SPEED = 60

function love.load(arg)
  --Animation
  animation = newAnimation(love.graphics.newImage("Sprites/powerup.png"), 30, 30, 0.5)
  animThrust = newAnimation(love.graphics.newImage("Sprites/RocketPlume.png"), 30, 30, 0.5)
  --player
  player.img = love.graphics.newImage('Sprites/XenonShip.png')
  bulletImg = love.graphics.newImage('Sprites/Bolt.png')
  enemyImg = love.graphics.newImage('Sprites/Baddie1.png')
end

function love.update(dt)
  --Animation
        animation.currentTime = animation.currentTime + dt
      if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
end
  -- Parallex
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
      % BACKGROUND_LOOP
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED *dt)
      % BACKGROUND_LOOP

  -- I always start with an easy way to exit the game
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end
  -- Time out enemy creation
    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
	     createEnemyTimer = createEnemyTimerMax

	-- Create an enemy
	randomNumber = math.random(10, love.graphics.getWidth() - 10)
	newEnemy = { x = randomNumber, y = -10, img = enemyImg }
	table.insert(enemies, newEnemy)
end
-- update the positions of enemies
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (200 * dt)

if enemy.y > 720 then -- remove enemies when they pass off the screen
  table.remove(enemies, i)
end
-- run our collision detection
-- Since there will be fewer enemies on screen than bullets we'll loop them first
-- Also, we need to see if the enemies hit our player
for i, enemy in ipairs(enemies) do
	for j, bullet in ipairs(bullets) do
		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
			table.remove(bullets, j)
			table.remove(enemies, i)
			score = score + 1
		end
	end

	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
	 and isAlive then
		   table.remove(enemies, i)
		   isAlive = false
	    end
  end
end
  -- Time out how far apart our shots can be.
      canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
      canShoot = true
  end
--Player control
  if love.keyboard.isDown('space') and canShoot then
	   -- Create some bullets
	 newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
	  table.insert(bullets, newBullet)
	   canShoot = false
	    canShootTimer = canShootTimerMax
  end
  for i, bullet in ipairs(bullets) do
	   bullet.y = bullet.y - (250 * dt)

     if bullet.y < 0 then -- remove bullets when they pass off the screen
		     table.remove(bullets, i)
	   end
  end
  if love.keyboard.isDown('right') then
      player.x = player.x + (player.speed * dt)
  elseif love.keyboard.isDown('left') then
      player.x = player.x - (player.speed * dt)
  end

  if love.keyboard.isDown('down') then
      player.y = player.y + (player.speed * dt)
  elseif love.keyboard.isDown('up') then
       player.y = player.y - (player.speed * dt)
  end
  if love.keyboard.isDown('right') then
      player.img = love.graphics.newImage('Sprites/XenonShipR.png')
  else player.img = love.graphics.newImage('Sprites/XenonShip.png')

  if love.keyboard.isDown('left') then
      player.img = love.graphics.newImage('Sprites/XenonShipL.png')
  else player.img = love.graphics.newImage('Sprites/XenonShip.png')
  end
 end
 if love.keyboard.isDown('down') then
        GROUND_SCROLL_SPEED = 10
        BACKGROUND_SCROLL_SPEED =10
   else GROUND_SCROLL_SPEED = 60
        BACKGROUND_SCROLL_SPEED =30
   end
 if not isAlive and love.keyboard.isDown('r') then
	-- remove all our bullets and enemies from screen
	bullets = {}
	enemies = {}
	-- reset timers
	canShootTimer = canShootTimerMax
	createEnemyTimer = createEnemyTimerMax
	-- move player back to default position
	player.x = 300
	player.y = 500
	-- reset our game state
	score = 0
	isAlive = true
end
end

function love.draw(dt)

  love.graphics.draw(background,0,backgroundScroll,0,1,1,0,600)
  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  for i, enemy in ipairs(enemies) do
	love.graphics.draw(enemy.img, enemy.x, enemy.y)
end
  love.graphics.draw(ground,0,groundScroll,0,1,1,0,600)
  love.graphics.draw(User_interface,0,0,0,1,1,0,0)
local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 200, 200, 0, 1)

  local spriteNum = math.floor(animation.currentTime / animation.duration * #animThrust.quads) + 1
        love.graphics.draw(animThrust.spriteSheet, animThrust.quads[spriteNum], (player.x), (player.y+25), 0, 1)
        love.graphics.print("SCORE: " .. tostring(score), 417, 110)
end
function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    animation.duration = duration or 1
    animation.currentTime = 0
    return animation
end
