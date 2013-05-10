local anim8 = require ("anim8")
HC = require 'hardoncollider'

function love.load()
	--ScreenWidth
	screenwidth = 1024
	screenheight = 768
	
	math.randomseed(os.time())
	--Set some mouse variables and parameters
	love.mouse.setVisible(false)
	mousex = love.mouse.getX()
	mousey = love.mouse.getY()


	--Create HardonCollider instance -> Collider
	Collider = HC(100, ground_collision, ground_collision_stop)
	entityCollider = HC(100, entity_collision, entity_collision_stop)

	--LoadSpritesheets and create animations
	load_graphics()
	--Create Player Variables
	create_player()
	create_world()

	--Create Enemies Table
	enemies = {}
	

end  -- End Load Function




function love.update(dt)


    if #world.debugtext.level > 20 then
        table.remove(world.debugtext.level, 1)
    end

    while #world.debugtext.entity > 20 do
    	table.remove(world.debugtext.entity, 1)
    end

    Collider:update(dt)
    entityCollider:update(dt)
	standstill:update(dt)
	walkanimation:update(dt)
	weakenemystandstill:update(dt)
	weakenemywalkanimation:update(dt)
	mediumenemystandstill:update(dt)
	mediumeneywalkanimation:update(dt)



	if love.keyboard.isDown("a") then
		doPlayerAnimation('a')
	end
	if love.keyboard.isDown("d") then
		doPlayerAnimation('d')
	end

	if love.keyboard.isDown("s") then
		player.y = player.y + 10
		player.boundingbox.level:move(0, 10)
	end
	if love.keyboard.isDown("w") then
		player.y = player.y - 10
		player.boundingbox.level:move(0, -10)
	end

	doPlayerProcessing(dt)
	doEnemyProcessing(dt)
end  --End Updated function

function love.draw()
	--Draw Background and UI Elements
	love.graphics.draw(background, 0, 0)
	love.graphics.print("Player Energy: " .. tostring(player.energy), 800, 0)

	--Draw Player variables if debug flag is set
	if world.debug.player then
		love.graphics.print("Velocity: " .. tostring(player.velocity.y), 40,40)
		love.graphics.print("AnimTimer: " .. tostring(player.animTimer), 40,50)
		love.graphics.print("isAttacking: " .. tostring(player.isAttacking), 40,60)
		love.graphics.print("Mouse X: " .. tostring(mousex) .. "Mouse Y: " .. tostring(mousey), 40,70)
	end




	--Draw Player
	if player.animation == 'walk' then
		walkanimation:draw(charactersheet, player.x,player.y)
	elseif player.animation == 'idle' then
		standstill:draw(charactersheet, player.x,player.y)
	end

	--Player Attacks
	if player.isAttacking then
		love.graphics.print("Punch", player.x + 40, player.y)
	end
	
	--Draw Enemies
	for i, value in ipairs(enemies) do
		
		if value.animation == 'idle' and value.type == 'weak' then
			value.standstillanimation:draw(charactersheet, value.x,value.y)
		elseif value.animation == 'walk' and value.type == 'weak' then
			value.walkanimation:draw(charactersheet, value.x, value.y)
		end

		if world.debug.enemies then
			love.graphics.print("Enemy(" .. tostring(i) .. "): " .. "Velocity: " .. tostring(value.velocity.y), 0, value.debugtextloc)
		end
	end

	if world.debug.collision_entity then
		--Draw player Entity collision stuff
		--player.boundingbox.entity_main:draw('line')
		player.boundingbox.entity_top_left:draw('line')
		player.boundingbox.entity_top_right:draw('line')
		player.boundingbox.entity_bottom_left:draw('line')
		player.boundingbox.entity_bottom_right:draw('line')

		--Draw Enemy Entity collision boxes
		for i, enemy in ipairs(enemies) do
			--enemy.boundingbox.entity_main:draw('line')
			enemy.boundingbox.entity_top_left:draw('line')
			enemy.boundingbox.entity_top_right:draw('line')
			enemy.boundingbox.entity_bottom_left:draw('line')
			enemy.boundingbox.entity_bottom_right:draw('line')
		end

		for i = 1,#world.debugtext.entity do
        	--love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        	love.graphics.print(world.debugtext.entity[#world.debugtext.entity - (i-1)], 10, i * 15)
    	end
	end

	--Draw World Bounding Boxes if debug flag is set
	if world.debug.collision_level then
		world.leftwall:draw('line')
		world.rightwall:draw('line')
		world.roof:draw('line')
		world.ground:draw('line')
		player.boundingbox.level:draw('line')

		for i, enemy in ipairs(enemies) do
			enemy.boundingbox.level:draw('line')
		end

		-- print messages collision text
    	for i = 1,#world.debugtext.level do
        	--love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        	love.graphics.print(world.debugtext.level[#world.debugtext.level - (i-1)], 10, i * 15)
    	end

	end

end   --End Draw Function




function love.keypressed(key)

	if key == "f1" then
		local state = not world.debug.player
		world.debug.player = state
	end
	if key == "f2" then
		local state = not world.debug.enemies
		world.debug.enemies = state
	end
	if key == "f3" then
		local state = not world.debug.collision_level
		world.debug.collision_level = state
	end
	if key == "f4" then
		local state = not world.debug.collision_entity
		world.debug.collision_entity = state
	end


	if key == "tab" then
		local state = not love.mouse.isVisible()
		love.mouse.setVisible(state)
		local grab = not love.mouse.isGrabbed()
		love.mouse.setGrab(grab)
	end

	if key == "escape" then
		love.event.push("quit") -- Quit the app
	end

	if key == "e" then
		player.action = "punch"
		player.energy = player.energy - 0.5
	end

	if key == '1' then
		createEnemies(1)
	elseif key == '2' then
		createEnemies(2)
	elseif key == '3' then
		createEnemies(3)
	end
end

function love.keyreleased(key)
	if key == "d" then
		player.animation = 'idle'
	end

	if key == "a" then
		player.animation = 'idle'
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		mousex = love.mouse.getX()
		mousey = love.mouse.getY()
	end

	if button == "r" then
		player.isOnGround = false
	end
end



--Player Functions
function doPlayerAnimation(key)
	local function moveplayer(direction)
		if direction == 'right' then
			if player.velocity.x < player.maxspeed then
				player.velocity.x = player.velocity.x + player.speed
				player.animation = 'walk'
			end
		elseif direction == 'left' then
			if  player.velocity.x > -player.maxspeed then
				player.velocity.x = player.velocity.x - player.speed
				player.animation = 'walk'
			end
		end

		if direction == 'down' then
			if player.velocity.y < 20 then
				player.velocity.y = player.velocity.y + world.gravity
			end
		end

		player.boundingbox.level:moveTo(player.x + 28, player.y + 50)
		--player.boundingbox.entity_main:moveTo(player.x  + 28, player.y + 50)
		player.boundingbox.entity_top_left:moveTo(player.x + 20, player.y + 25)
		player.boundingbox.entity_top_right:moveTo(player.x + 40, player.y + 25)
		player.boundingbox.entity_bottom_right:moveTo(player.x + 20, player.y + 75)
		player.boundingbox.entity_bottom_left:moveTo(player.x + 40, player.y + 75)

	end
		
		if key == "a" then
			if player.isFacingRight == false then
				moveplayer('left')
			elseif player.isFacingRight then
				player.isFacingRight = false
				walkanimation:flipH()
				standstill:flipH()
				moveplayer('left')
			end
		end

		if key == "d" then
			if player.isFacingRight then
				moveplayer('right')
			elseif player.isFacingRight == false then				
				player.isFacingRight = true
				walkanimation:flipH()
				standstill:flipH()
				moveplayer('right')
			end
		end

		if key == 'fall' then
			moveplayer('down')
		end


end

function playerAttack(type, dt)


	if type == 'punch' and player.isAttacking == false then
		player.isAttacking = true
		player.animTimer = love.timer.getTime() + player.punchspeed
	elseif type == 'punch' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		player.isAttacking = false
		player.action = false
	end
end

function doPlayerProcessing(dt)

	if player.isFacingRight then
		if player.velocity.x > 0 then
			player.velocity.x = -world.windResistance + player.velocity.x
			player.x = player.x + player.velocity.x*dt
		end
	elseif player.isFacingRight == false then
		if player.velocity.x < 0 then
			player.velocity.x = world.windResistance + player.velocity.x
			player.x = player.x + player.velocity.x*dt
		end
	end

	if player.action then
		if playerAttack then
			playerAttack(player.action, dt)
		end
	end

	if player.isOnGround == false then		
		player.y = player.y + player.velocity.y
		doPlayerAnimation('fall')
	end

end

--Enemy Functions
function doEnemyProcessing(dt)
	
	for i, value in ipairs(enemies) do
		if value.isFacingRight and value.isMoving then  -- Enemy should move Right
			doEnemyAnimation('d', value)
			if value.velocity.x > 0 then
				value.velocity.x = -world.windResistance + value.velocity.x
				value.x = value.x + value.velocity.x*dt
			end
		elseif value.isFacingRight == false and value.isMoving then -- Enemy should move Left
			doEnemyAnimation('a', value)
			if value.velocity.x < 0 then
				value.velocity.x = world.windResistance + value.velocity.x
				value.x = value.x + value.velocity.x*dt
			end
		end

		if value.action then
			if enemyAttack then
				enemyAttack(value.action, dt)
			end
		end

		if value.isOnGround == false then		
			value.y = value.y + value.velocity.y
			doEnemyAnimation('fall', value)
		end
	
	end

end

function doEnemyAnimation(action, indexie)
	
	local function moveEnemy(direction)
		if direction == 'right' and indexie.isMoving then
			if indexie.velocity.x < indexie.maxspeed then
				indexie.velocity.x = indexie.velocity.x + indexie.speed
				indexie.animation = 'walk'
			end
		elseif direction == 'left' and indexie.isMoving then
			if  indexie.velocity.x > -indexie.maxspeed then
				indexie.velocity.x = indexie.velocity.x - indexie.speed
				indexie.animation = 'walk'
			end
		end

		if direction == 'down' then
			if indexie.velocity.y < 20 then
				indexie.velocity.y = indexie.velocity.y + world.gravity
			end
		end
		indexie.boundingbox.level:moveTo(indexie.x + 28, indexie.y + 50)
		--indexie.boundingbox.entity_main:moveTo(indexie.x  + 28, indexie.y + 50)
		indexie.boundingbox.entity_top_left:moveTo(indexie.x + 20, indexie.y + 25)
		indexie.boundingbox.entity_top_right:moveTo(indexie.x + 40, indexie.y + 25)
		indexie.boundingbox.entity_bottom_right:moveTo(indexie.x + 20, indexie.y + 75)
		indexie.boundingbox.entity_bottom_left:moveTo(indexie.x + 40, indexie.y + 75)

	end
		
		if action == "a" then
			if indexie.isFacingRight == false then
				moveEnemy('left')
			elseif indexie.isFacingRight then
				indexie.isFacingRight = false
				indexie.walkanimation:flipH()
				indexie.standstillanimation:flipH()
				moveEnemy('left')
			end
		end

		if action == "d" then
			if indexie.isFacingRight then
				moveEnemy('right')
			elseif indexie.isFacingRight == false then				
				indexie.isFacingRight = true
				indexie.walkanimation:flipH()
				indexie.standstillanimation:flipH()
				moveEnemy('right')
			end
		end

		if action == 'fall' then
			moveEnemy('down')
		end
end


function ground_collision (dt, shape_a, shape_b, mtv_x, mtv_y)
	world.debugtext.level[#world.debugtext.level+1] = string.format("Colliding. mtv = (%s, %s)",
											mtv_x, mtv_y)

	local function levelChecks(shape, shapetype, indexie)
		if shape_a == world.leftwall or world.rightwall or shape_b == world.leftwall or world.rightwall then
			if shapetype == 'p' then
				shape:move(mtv_x, 0)
				player.x = player.x + mtv_x
				player.velocity.x = 0
			end
			if shapetype == 'e' then
				shape:move(mtv_x, 0)
				indexie.x = indexie.x + mtv_x
				indexie.velocity.x = 0
			end
		end
	
		if shape_a == world.ground or shape_b == world.ground then
			if shapetype == 'p' then
				shape:move(0, mtv_y - 2)
				player.y = player.y + mtv_y - 2
				player.isOnGround = true
				player.velocity.y = 0
			end
			if shapetype == 'e' then
				shape:move(0, mtv_y - 2)
				indexie.y = indexie.y + mtv_y - 2
				indexie.isOnGround = true
				indexie.velocity.y = 0
			end
		end
	end

	local playa = nil

	if shape_a == player.boundingbox.level then
		playa = shape_a
		levelChecks(playa, 'p', nil)
	elseif shape_b == player.boundingbox.level then
		playa = shape_b
		levelChecks(playa, 'p', nil)
	end

	--Check enemy collisions
	for i, value in ipairs(enemies) do
		if shape_a == value.boundingbox.level then
			levelChecks(shape_a, 'e', value)
		elseif shape_b == value.boundingbox.level then
			levelChecks(shape_b, 'e', value)
		end	
		
	end
end

function ground_collision_stop(dt, shape_a, shape_b)
	world.debugtext.level[#world.debugtext.level+1] = "Stopped Colliding"
end	

function entity_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	--world.debugtext.entity[#world.debugtext.entity+1] = string.format("Colliding. mtv = (%s, %s)",mtv_x, mtv_y)

	local function entityTouching(pl)

		if findBox(pl, {player.boundingbox.entity_top_right,
						player.boundingbox.entity_bottom_right}) then			
			pl:move(mtv_x, mtv_y)
			player.x = player.x + mtv_x
			player.velocity.x = 0
		elseif findBox(pl, {player.boundingbox.entity_top_left,
							player.boundingbox.entity_bottom_left}) then
			pl:move(mtv_x, mtv_y)
			player.x = player.x + mtv_x
			player.velocity.x = 0
		end
	end

	if findCollisionBox(shape_a, shape_b, {player.boundingbox.entity_top_right,
									  player.boundingbox.entity_top_left,
									  player.boundingbox.entity_bottom_right,
									  player.boundingbox.entity_bottom_left}) then

		local playa_tr = findInteractions(shape_a, shape_b, {player.boundingbox.entity_top_right,
										   					player.boundingbox.entity_top_left, 
										   					player.boundingbox.entity_bottom_right,
										   					player.boundingbox.entity_bottom_left} )
		
		
		entityTouching(playa_tr)
	end

	

end


function entity_collision_stop(dt, shape_a, shape_b)
	--world.debugtext.entity[#world.debugtext.entity+1] = "Stopped Colliding"
end

function load_graphics()
	--Load Graphics and init animations	
	charactersheet = love.graphics.newImage("CharacterSheet.png")
	background = love.graphics.newImage("Background.jpg")
	agrid = anim8.newGrid(60, 100, charactersheet:getWidth(), charactersheet:getHeight())
	standstill = anim8.newAnimation(agrid(1, 1), 0.1)
	walkanimation = anim8.newAnimation(agrid('2-7', 1), 0.1)
	weakenemystandstill = anim8.newAnimation(agrid(1, 2), 0.1)
	weakenemywalkanimation = anim8.newAnimation(agrid('2-7', 2), 0.1)
	mediumenemystandstill = anim8.newAnimation(agrid(1, 3), 0.1)
	mediumeneywalkanimation = anim8.newAnimation(agrid('2-7', 3), 0.1)
end

function create_player()
	player = {}
	player.x = 100
	player.y = 400
	player.isOnGround = false
	player.action = false
	player.speed = 50
	player.punchspeed = .2
	player.kickspeed = .4
	player.maxspeed = 100
	player.velocity = {}
	player.velocity.x = 0
	player.velocity.y = 0
	player.energy = 100
	player.animation = 'idle'
	player.isFacingRight = true
	player.isAlive = true
	player.isPunching = false
	player.isKicking = false
	player.animTimer = 0
	player.isAttacking = false
	player.boundingbox = {}
	player.boundingbox.level = Collider:addRectangle(player.x, player.y, 38, 100)
	--player.boundingbox.entity_main = entityCollider:addRectangle(player.x-20, player.y, 88, 100)
	player.boundingbox.entity_top_left = entityCollider:addRectangle(player.x, player.y, 20, 50 )
	player.boundingbox.entity_top_right = entityCollider:addRectangle(player.x + 20, player.y, 20, 50 )
	player.boundingbox.entity_bottom_right = entityCollider:addRectangle(player.x + 20, player.y + 50, 20, 50 )
	player.boundingbox.entity_bottom_left = entityCollider:addRectangle(player.x, player.y + 50, 20, 50 )
	Collider:addToGroup("players", player.boundingbox.level)
	entityCollider:addToGroup("internalBoundingBoxes", player.boundingbox.entity_top_left, 
			player.boundingbox.entity_top_right, player.boundingbox.entity_bottom_right, 
			player.boundingbox.entity_bottom_left)

end

function create_world()
	--Create Debugtext containers
	world = {}
	world.debugtext = {}
	world.debugtext.level = {}
	world.debugtext.entity = {}

	--Debug flags
	world.debug = {}
	world.debug.player = false
	world.debug.enemies = false
	world.debug.collision_level = false
	world.debug.collision_entity = true

	--Level Geometry and collision box creation
	world.groundpos = 640
	world.leftwall = Collider:addRectangle(0, 20, 60, screenheight -20)
	world.rightwall = Collider:addRectangle(900, 323, 20, screenheight -20)
	world.roof = Collider:addRectangle(0, 0, screenwidth, 20)
	world.ground = Collider:addRectangle(60,world.groundpos, screenwidth - 64, 20)
	Collider:addToGroup("level", world.leftwall, world.rightwall, world.roof, world.ground)
	Collider:setPassive(world.leftwall, world.rightwall, world.roof, world.ground)

	world.level = 1
	world.gravity = 1
	world.windResistance = 10
	world.spawnLocations = {{215, 214},
							{509, 236},
							{403, 510},
							{993, 227},
							{191, 497} }
end

function createEnemies(number)
	
	
	for i = 1, number, 1 do 
		enemy = {}
		enemy.health = 100
		math.random()
		enemy.spawn = math.random(#world.spawnLocations)
		enemy.x = world.spawnLocations[enemy.spawn][1]
		enemy.y = world.spawnLocations[enemy.spawn][2]
		enemy.type = 'weak'

		if enemy.type == 'weak' then
			enemy.walkanimation = weakenemywalkanimation
			enemy.standstillanimation = weakenemystandstill
		elseif enemy.type == 'medium' then
			enemy.walkanimation = mediumenemywalkanimation
			enemy.standstillanimation = mediumenemystandstill
		end
		enemy.punchspeed = .2
		enemy.kickspeed = .4
		enemy.maxspeed = 100
		enemy.debugtextloc = #enemies * 10
		enemy.debug = true
		enemy.speed = 40	
		enemy.isFacingRight = true
		enemy.action = 'a'
		enemy.isAttacking = false
		enemy.isOnGround = false
		enemy.velocity = {}
		enemy.velocity.x = 0
		enemy.velocity.y = 0
		enemy.isOnGround = false
		enemy.animation = 'idle'
		enemy.isAlive = true
		enemy.isPunching = false
		enemy.isKicking = false
		enemy.isShooting = false
		enemy.animTimer = 0
		enemy.boundingbox = {}
		enemy.boundingbox.level = Collider:addRectangle(enemy.x, enemy.y, 38, 100)
		--enemy.boundingbox.entity_main = entityCollider:addRectangle(enemy.x-20, enemy.y, 88, 100)
		enemy.boundingbox.entity_top_left = entityCollider:addRectangle(enemy.x, enemy.y, 20, 50 )
		enemy.boundingbox.entity_top_right = entityCollider:addRectangle(enemy.x + 20, enemy.y, 20, 50 )
		enemy.boundingbox.entity_bottom_right = entityCollider:addRectangle(enemy.x + 20, enemy.y + 50, 20, 50 )
		enemy.boundingbox.entity_bottom_left = entityCollider:addRectangle(enemy.x, enemy.y + 50, 20, 50 )
		entityCollider:addToGroup("enemyInternalBoundingBoxes", enemy.boundingbox.entity_top_left, 
			enemy.boundingbox.entity_top_right, enemy.boundingbox.entity_bottom_right, 
			enemy.boundingbox.entity_bottom_left)
		enemy.isMoving = true
		enemy.isInGroup = false
		table.insert(enemies, enemy)
	end

	for i, value in ipairs(enemies) do
		if value.isInGroup == false then
			Collider:addToGroup("players", value.boundingbox.level)
			value.isInGroup = true
		end

	end
end


function findCollisionBox(shape_a, shape_b, var_name)
	

	for i,value in pairs(var_name) do		
		if shape_a == value then
			return true
		elseif shape_b == value then
			return true
		end
	end

	return false
end

function findBox(shape, var_name)

	for i, value in pairs(var_name) do
		if shape == value then
			return true
		end
	end
	return false

end


function findInteractions(shape, shape2, var_name)
	for i,value in pairs(var_name) do
		if shape == value then
			return shape
		elseif shape2 == value then 
			return shape
		end
	end

	return false
end