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

function MyCollision(Snake_x,Snake_y,Snake_w,Snake_h,x1,y1,w1,h1)
  return x1 < Snake_x+Snake_w and
         Snake_x < x1+w1 and
         y1 < Snake_y+Snake_h and
         Snake_y < y1+h1
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
animExplode = false
animPowerUp = false

--space
background = love.graphics.newImage('Sprites/space_1200.png')
backgroundScroll = 0
BACKGROUND_SCROLL_SPEED = 30
BACKGROUND_LOOP = 595
--wall
ground = love.graphics.newImage('Sprites/Xenon_wall1200.png')
groundScroll = 0
GROUND_SCROLL_SPEED = 60
--sound
baddySpin = love.graphics.newImage('Sprites/BaddySpin.png')
baddyScroll = 0
baddy_Scroll_Speed = 40
baddyLoop = 600
--for snake
music = love.audio.newSource("Audio/XenonMusic.wav","static")
gunSound = love.audio.newSource("Audio/LazerBlast.wav", "static")
explosionSound =love.audio.newSource("Audio/Eplosion.wav", "static")

Snake_y = 0
Snake_x = -180
Snake_w = 30
Snake_h = 30
xdirection = 1
ydirection = 1
function love.load(arg)
  --music

  music:setVolume(0.3)
  music:setLooping(true)
  music:play()

  --For Snake
  sprites = {"Sprites/BaddySnakeBody.png","Sprites/BaddySnake.png"}
  image = love.graphics.newArrayImage(sprites)
  --Animation
  animation = newAnimation(love.graphics.newImage("Sprites/powerup.png"), 30, 30, 0.5)
  animThrust = newAnimation(love.graphics.newImage("Sprites/RocketPlume.png"), 30, 30, 0.5)
  animExplosion =newAnimation(love.graphics.newImage("Sprites/Explosion.png"), 30, 30, 0.5)
  animBaddySpin =newAnimation(love.graphics.newImage("Sprites/BaddySpin.png"), 30, 30, 0.5)
  --player
  playerImg = love.graphics.newImage('Sprites/XenonShip.png')
  bulletImg = love.graphics.newImage('Sprites/Bolt.png')
  enemyImg = love.graphics.newImage('Sprites/Baddie1.png')
end

function love.update(dt)
-- For Snake movement

   Snake_y = Snake_y + 2
if Snake_y > 610 then
   Snake_y = - 1
end
     Snake_x=Snake_x+(2*xdirection)
if  (Snake_x==20) or (Snake_x<-180) then
     xdirection = xdirection * -1
end
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
    baddyScroll =(baddyScroll + baddy_Scroll_Speed *dt)
      % baddyLoop

-- Game quit
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

-- Also, we need to see if the enemies hit our player
for i, enemy in ipairs(enemies) do
	for j, bullet in ipairs(bullets) do
		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
			table.remove(bullets, j)
			table.remove(enemies, i)
			score = score + 1
      explosionSound:play()
		end
	end
end

	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
	 and isAlive then
		   table.remove(enemies, i)
		   isAlive = false
       explosionSound:play()
  end
if MyCollision(Snake_x,Snake_y,enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
  and isAlive then
      isAlive = false
      explosionSound:play()
end
end
  -- Time out how far apart our shots can be.
      canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
      canShoot = true
  end
--Player control
  if player.y > 570 then
     player.y = 560
  end
  if player.x >= 350 then
     player.x = 340
  end
  if player.x < 10 then
     player.x = 20
  end

  if love.keyboard.isDown('space') and canShoot and isAlive then
	      newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg, gunSound:play() }
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
  --love.graphics.draw(baddySpin,300,backgroundScroll,0,10,0,0,400)
  love.graphics.drawLayer(image, 1, Snake_x, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+25, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+50, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+75, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+100, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+125, Snake_y)
  love.graphics.drawLayer(image, 1, Snake_x+150, Snake_y)
  love.graphics.drawLayer(image, 2, Snake_x+175, Snake_y)

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-150, love.graphics:getHeight()/2-10,0,2,2)
  end
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  for i, enemy in ipairs(enemies) do
	love.graphics.draw(enemy.img, enemy.x, enemy.y)
end
  love.graphics.draw(ground,0,groundScroll,0,1,1,0,600)
local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 100, 100, 0, 1)

if isAlive then
local spriteNum = math.floor(animation.currentTime / animation.duration * #animThrust.quads) + 1
        love.graphics.draw(animThrust.spriteSheet, animThrust.quads[spriteNum], (player.x), (player.y+25), 0, 1)
end
local spriteNum = math.floor(animation.currentTime / animation.duration * #animExplosion.quads) + 1
        love.graphics.draw(animExplosion.spriteSheet, animExplosion.quads[spriteNum], 300, 100, 0, 1)
        love.graphics.print("SCORE: " .. tostring(score), 417, 110)

local spriteNum = math.floor(animation.currentTime / animation.duration * #animBaddySpin.quads) + 1
        love.graphics.draw(animBaddySpin.spriteSheet, animBaddySpin.quads[spriteNum],200,baddyScroll,-1)
        love.graphics.draw(User_interface,0,0,0,1,1,0,0)
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
