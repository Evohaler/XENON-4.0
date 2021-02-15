io.stdout:setvbuf('no')
require ("conf")

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


isAlive = true
score = 0
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
enemyImg = nil -- Like other images we'll pull this in during out love.load functio
enemies = {} -- array of current enemies on screen

baddySpinImg = nil
baddySpin = {x=200,y=400, width= 30, height = 30, speed = 150, img = nil}

canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

bulletImg = nil
bullets = {} -- array of current bullets being drawn and updated
bulletCollision = false


player ={x=200, y=400, speed = 150, img=nil}
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

baddyScroll = 0
baddy_Scroll_Speed = 40
baddyLoop = 600
--for snake
music = love.audio.newSource("Audio/XenonMusic.wav","static")
gunSound = love.audio.newSource("Audio/LazerBlast.wav", "static")
explosionSound = love.audio.newSource("Audio/Eplosion.wav", "static")
animExplosion = false
animPowerUp = false
Snake_y = 0
Snake_x = -180
Snake_w = 30
Snake_h = 30
xdirection = 1
ydirection = 1

function love.load(arg)------------------------------------------------------
    love.graphics.setDefaultFilter('nearest', 'nearest')

  --music
  music:setVolume(0.3)
  music:setLooping(true)
  music:play()

  --Animation
  animUi = newAnimation(love.graphics.newImage("Sprites/DashText.png"), 30, 30)
  animSin = newAnimation(love.graphics.newImage("Sprites/SingW.png"), 30, 30)
  animation = newAnimation(love.graphics.newImage("Sprites/powerup.png"), 30, 30)
  animThrust = newAnimation(love.graphics.newImage("Sprites/RocketPlume.png"), 30, 30)
  animExplode = newAnimation(love.graphics.newImage("Sprites/Explosion.png"), 30, 30)
  animBaddySpin = newAnimation(love.graphics.newImage("Sprites/BaddySpin.png"), 30, 30)
  --Baddy
  enemyImg = love.graphics.newImage('Sprites/Baddie1.png')
  --For Snake
  sprites = {"Sprites/BaddySnakeBody.png","Sprites/BaddySnake.png"}
  image = love.graphics.newArrayImage(sprites)
  --player
  playerImg = love.graphics.newImage('Sprites/XenonShip.png')
  --Bullet
  bulletImg = love.graphics.newImage('Sprites/Bolt.png')
  --UI
  UIImg = love.graphics.newImage('Sprites/AnimCockpit.png')
  --BaddySpin
  baddySpinImg = love.graphics.newImage('Sprites/BaddySpin.png')
  --Alphaimg
  alphaNil = love.graphics.newImage('Sprites/AlphaNil.png')
end

function updateAnimation(animation, dt)
  animation.currentTime = animation.currentTime + dt
  if animation.currentTime >= animation.duration then
    animation.currentTime = animation.currentTime - animation.duration
  end
  return animation
end

function love.update(dt)------------------------------------------------------
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

    animExplode = updateAnimation(animExplode, dt);
    animBaddySpin = updateAnimation(animBaddySpin, dt);
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
  	  newEnemy = {
        x = randomNumber,
        y = -10,
        img = enemyImg,
        bulletCollision = false,
        explAnimation = newAnimation(love.graphics.newImage("Sprites/Explosion.png"), 30, 30)
      }
  	  table.insert(enemies, newEnemy)
    end
-- update the positions of enemies
    for i, enemy in ipairs(enemies) do
      if enemy.bulletCollision == false then
        enemy.y = enemy.y + (200 * dt)
      else
        enemy.explAnimation = updateAnimation(enemy.explAnimation, dt)
      end

    if enemy.y > 610 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end

-- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
 	 for j, bullet in ipairs(bullets) do
		   if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
	      table.remove(bullets, j)
	      score = score + 1
        explosionSound:play()
        enemy.bulletCollision = true
       end
    end
  end

	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
	   and isAlive then
		     table.remove(enemies, i)
		       isAlive = false
           explosionSound:play()
  end
  if MyCollision(Snake_x,Snake_y,Snake_w, Snake_h,player.x, player.y, player.img:getWidth(), player.img:getHeight())
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
  if player.y > 490 then
     player.y = 480
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
      baddySpin = {}
    	-- reset timers
    	canShootTimer = canShootTimerMax
    	createEnemyTimer = createEnemyTimerMax
    	-- move player back to default position
    	player.x = 200
    	player.y = 400
    	-- reset our game state
    	score = 0
      isAlive = true
end
end

function love.draw(dt)----------------------------------------------------

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

  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemy in ipairs(enemies) do
    if enemy.bulletCollision == false then
	     love.graphics.draw(enemy.img, enemy.x, enemy.y)
    else
      local spriteNum = math.floor(enemy.explAnimation.currentTime / enemy.explAnimation.duration * #animExplode.quads) + 1
      love.graphics.draw(animExplode.spriteSheet, animExplode.quads[spriteNum], enemy.x, enemy.y, 0, 1)

      if (spriteNum >= #animExplode.quads) then
         table.remove(enemies,i)
      end
    end
  end

  love.graphics.draw(ground,0,groundScroll,0,1,1,0,600)

  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 100, 100, 0, 1)

  if isAlive then
    local spriteNum = math.floor(animation.currentTime / animation.duration * #animThrust.quads) + 1
    love.graphics.draw(animThrust.spriteSheet, animThrust.quads[spriteNum], (player.x), (player.y+25), 0, 1)
  end

  local spriteNum = math.floor( (animBaddySpin.currentTime / animBaddySpin.duration) * #animBaddySpin.quads ) + 1
  love.graphics.draw(animBaddySpin.spriteSheet, animBaddySpin.quads[spriteNum], baddySpin.x, baddyScroll, -1)

  love.graphics.draw(UIImg, 0, 0, r, sx, sy, ox, oy, kx, ky)

  local spriteNum = math.floor(animUi.currentTime / animUi.duration * #animUi.quads) + 1
  love.graphics.draw(animUi.spriteSheet, animUi.quads[spriteNum],69,531,0,2,2,1)

  local spriteNum = math.floor(animation.currentTime / animation.duration * #animSin.quads) + 1
  love.graphics.draw(animSin.spriteSheet, animSin.quads[spriteNum],13,531,0,2,2,1)
  love.graphics.print("KILLS: " .. tostring(score), 308, 552)

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-100, love.graphics:getHeight()/2-10,0,2,2)
  end
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
    animation.done = false
    return animation
end
