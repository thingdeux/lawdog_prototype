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
	--checkEnemyRemoval()
	


    if #world.debugtext.level > 20 then
        table.remove(world.debugtext.level, 1)
    end

    while #world.debugtext.entity > 40 do
    	table.remove(world.debugtext.entity, 1)
    end


	standstill:update(dt)
	walkanimation:update(dt)
	weakenemystandstill:update(dt)
	weakenemywalkanimation:update(dt)
	mediumenemystandstill:update(dt)
	mediumenemywalkanimation:update(dt)
	mediumenemyrunanimation:update(dt)
	mediumenemystunned:update(dt)
	mediumenemyjabbed_l1:update(dt)
	mediumenemyjabbed_l2:update(dt)
	mediumenemystandstill:update(dt)



	if love.keyboard.isDown("a") then
		doPlayerAnimation('a',dt)
	end
	if love.keyboard.isDown("d") then
		doPlayerAnimation('d',dt)
	end

	if love.keyboard.isDown("s") then
		player.y = player.y + 10
		snapPlayerBoundingBoxes()
	end
	if love.keyboard.isDown("w") then
		player.y = player.y - 10
		snapPlayerBoundingBoxes()
	end

	
	doPlayerProcessing(dt)
	doEnemyProcessing(dt)
	Collider:update(dt)
    entityCollider:update(dt)


end  --End Updated function

function love.draw()
	--Draw Background and UI Elements
	--love.graphics.draw(background, 0, 0)
	love.graphics.print("Player Energy: " .. tostring(player.energy), 800, 0)

	--Draw Player variables if debug flag is set
	if world.debug.player then
		love.graphics.print("Velocity: " .. tostring(player.velocity.x), 340,40)
		love.graphics.print("AnimTimer: " .. tostring(player.animTimer), 340,50)
		love.graphics.print("isAttacking: " .. tostring(player.isAttacking), 340,60)
		love.graphics.print("Player X: " .. tostring(player.x) .. "Player Y: " .. tostring(player.y), 340,70)
		love.graphics.print("Player Yup: " .. tostring(player.yup), 340,80, math.rad(30))
	end

	--Draw Player
	if player.animation == 'walk' then
		walkanimation:draw(charactersheet, player.x,player.y)
	elseif player.animation == 'idle' then
		standstill:draw(charactersheet, player.x,player.y)
	end

	--Player Attacks
	if player.isAttacking and player.isFacingRight then
		love.graphics.print("Pow", player.x + 34, player.y)
	elseif player.isAttacking and not player.isFacingRight then
		love.graphics.print("Pow", player.x, player.y)
	end
	
	--Draw Enemies
	for i, value in ipairs(enemies) do
		
		if value.animation == 'idle' then
			value.standstillanimation:draw(enemysheet, value.x,value.y)
		elseif value.animation == 'walk' then
			value.walkanimation:draw(enemysheet, value.x, value.y)
		end

		if world.debug.enemies then			
			love.graphics.print(string.format("Enemy (%s): VelX: %s - X: %s - facingRight: %s - isWalkFlipped: %s", 
				i, math.floor(value.velocity.x), math.floor(value.x), tostring(value.isFacingRight), tostring(value.isWalkFlipped)),
				 	0, value.debugtextloc)
			love.graphics.print("NumOfEnemies: " .. tostring(#enemies), 800, 10)
		end
	end

	if world.debug.collision_entity then
		--Draw player Entity collision stuff
		love.graphics.setColor(255,255,12, 255)
		player.boundingbox.entity_main:draw('line')
		love.graphics.setColor(255,player.boundingbox.fist_color,player.boundingbox.fist_color, 255)
		player.boundingbox.fist_box:draw('line')
		love.graphics.setColor(255,255,255, 255)
		--player.boundingbox.entity_top_left:draw('line')
		--player.boundingbox.entity_top_right:draw('line')
		--player.boundingbox.entity_bottom_left:draw('line')
		--player.boundingbox.entity_bottom_right:draw('line')

		--Draw Enemy Entity collision boxes
		for i, enemy in ipairs(enemies) do

			enemy.boundingbox.entity_main:draw('line')
			--enemy.boundingbox.entity_top_left:draw('line')
			--enemy.boundingbox.entity_top_right:draw('line')
			--enemy.boundingbox.entity_bottom_left:draw('line')
			--enemy.boundingbox.entity_bottom_right:draw('line')
			
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

	if key == "f" then
		for i, enemyindex in ipairs(enemies) do
			local state = not enemyindex.isFacingRight
			enemyindex.isFacingRight = state
		end
	end

	if key == "m" then
		for i, enemyindex in ipairs(enemies) do
			if enemyindex.isMoving == false then
				enemyindex.isMoving = true
			else
				enemyindex.isMoving = false
			end
		end
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
		player.velocity.x  = player.velocity.x - player.stoppingSpeed*4
	end

	if key == "a" then
		player.animation = 'idle'
		player.velocity.x  = player.velocity.x + player.stoppingSpeed*4
	end

	if key == "w" then
		player.animation = 'idle'
	end

	if key == "s" then
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
function snapPlayerBoundingBoxes()
	
		
		if player.isFacingRight then
			player.boundingbox.level:moveTo(player.x + player.boundingbox.offset_moveto_level_x+4, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_main:moveTo(player.x + player.boundingbox.offset_moveto_level_x + 4, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_top_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_top_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_bottom_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.entity_bottom_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.fist_box:moveTo(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_entity_top_y - 18)
		else
			player.boundingbox.level:moveTo(player.x + player.boundingbox.offset_moveto_level_x+20, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_main:moveTo(player.x + player.boundingbox.offset_moveto_level_x + 18, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_top_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x+15, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_top_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x+15, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_bottom_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x+15, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.entity_bottom_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x+15, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.fist_box:moveTo(player.x + 10, player.y + player.boundingbox.offset_moveto_entity_top_y - 18)
		end
end

function doPlayerAnimation(key,dt)
	local function moveplayer(direction,dt)
		if direction == 'right' then
			if player.velocity.x < player.maxspeed then
				player.velocity.x = player.velocity.x + player.speed*dt
				player.animation = 'walk'
			end
		elseif direction == 'left' then
			if  player.velocity.x > -player.maxspeed then
				player.velocity.x = player.velocity.x - player.speed*dt
				player.animation = 'walk'
			end
		end

		if direction == 'down' then
			if player.velocity.y < world.terminalVelocity then
				player.velocity.y = player.velocity.y + world.gravity*dt
			end
		end
		snapPlayerBoundingBoxes()
	end
		
		if key == "a" then
			if player.isFacingRight == false then
				moveplayer('left',dt)
			elseif player.isFacingRight then
				player.x = player.x - player.turnoffset
				player.isFacingRight = false
				walkanimation:flipH()
				standstill:flipH()
				moveplayer('left',dt)
			end
		end

		if key == "d" then
			if player.isFacingRight then
				moveplayer('right',dt)
			elseif player.isFacingRight == false then
				player.x = player.x + player.turnoffset
				player.isFacingRight = true
				walkanimation:flipH()
				standstill:flipH()
				moveplayer('right',dt)
			end
		end

		if key == 'fall' then
			moveplayer('down',dt)
		end
end

function playerAttack(type, dt)


	if type == 'punch' and player.isAttacking == false then
		player.isAttacking = true
		player.animTimer = love.timer.getTime() + player.punchspeed
		entityCollider:setSolid(player.boundingbox.fist_box)
	elseif type == 'punch' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		player.isAttacking = false
		player.action = false
		entityCollider:setGhost(player.boundingbox.fist_box)
	end
end

function doPlayerProcessing(dt)

	
	if player.velocity.x > 50 then
		player.velocity.x = -world.windResistance*dt*player.stoppingSpeed + player.velocity.x
		player.x = player.x + player.velocity.x*dt
		snapPlayerBoundingBoxes()
	end

	if player.velocity.x < -50 then
		player.velocity.x = world.windResistance*dt*player.stoppingSpeed + player.velocity.x
		player.x = player.x + player.velocity.x*dt
		snapPlayerBoundingBoxes()
	end
	if player.velocity.x > -49 and player.velocity.x < 49 and player.velocity.x ~= 0 and player.animation == 'idle' then
		player.velocity.x = 0
		player.yup = true
	end
	

	if player.action then
		if playerAttack then
			playerAttack(player.action, dt)
		end
	end

	if player.isOnGround == false then		
		player.y = player.y + player.velocity.y
		doPlayerAnimation('fall',dt)
		snapPlayerBoundingBoxes()
	end
	
end

--Enemy Functions
function snapEnemyBoundingBoxes(index)
	
	if index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x+4, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 4, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
	elseif not index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x+20, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 18, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)

	end
end

function doEnemyProcessing(dt)

	local function applyForces(dt,enemyindex)
		if enemyindex.velocity.x > 50 then
			enemyindex.velocity.x = -world.windResistance*dt*enemyindex.stoppingSpeed + enemyindex.velocity.x
			enemyindex.x = enemyindex.x + enemyindex.velocity.x*dt			
		end

		if enemyindex.velocity.x < -50 then
			--enemyindex.velocity.x = enemyindex.velocity.x + enemyindex.speed*dt
			enemyindex.velocity.x = world.windResistance*dt*enemyindex.stoppingSpeed + enemyindex.velocity.x
			enemyindex.x = enemyindex.x + enemyindex.velocity.x*dt			
		end

		if enemyindex.velocity.x > -49 and enemyindex.velocity.x < 49 and enemyindex.velocity.x ~= 0 and enemyindex.animation == 'idle' then
			enemyindex.velocity.x = 0
		end

		if enemyindex.isOnGround == false then
			if enemyindex.velocity.y < 20 then					
				enemyindex.velocity.y = enemyindex.velocity.y + world.gravity*dt
			end
			enemyindex.y = enemyindex.y + enemyindex.velocity.y
			doEnemyAnimation('fall', enemyindex)
		end
	end

	
	for i, enemyindex in ipairs(enemies) do
		if enemyindex.isFacingRight and enemyindex.isMoving then  -- Enemy should move Right
			if enemyindex.velocity.x < enemyindex.maxspeed then
				enemyindex.velocity.x = enemyindex.velocity.x + enemyindex.speed*dt
			end
			doEnemyAnimation("walk", enemyindex, dt)
		end
		
		if not enemyindex.isFacingRight and enemyindex.isMoving then -- Enemy should move Left
			if enemyindex.velocity.x > -enemyindex.maxspeed then
				enemyindex.velocity.x = enemyindex.velocity.x - enemyindex.speed*dt
			end
			doEnemyAnimation("walk", enemyindex, dt)
		end


		applyForces(dt,enemyindex)
		if not enemyindex.isMoving then
			enemyindex.animation = 'idle'
		end

		snapEnemyBoundingBoxes(enemyindex)
	end  --Breaking out of enemies container

end

function doEnemyAnimation(action, indexie)	
	
		if indexie.isMoving then		
			indexie.animation = 'walk'
		end
		
		if action == "walk" then
			if indexie.isFacingRight == true and indexie.isWalkFlipped then
				indexie.x = indexie.x + indexie.turnoffset
				indexie.walkanimation:flipH()
				indexie.standstillanimation:flipH()
				indexie.isWalkFlipped = false
			elseif not indexie.isFacingRight and not indexie.isWalkFlipped then
				indexie.x = indexie.x - indexie.turnoffset
				indexie.walkanimation:flipH()
				indexie.standstillanimation:flipH()
				indexie.isWalkFlipped = true
			end
		end

		if action == 'fall' then
			indexie.animation = 'idle'
		end

		if action == 'idle' then
			indexie.animation = 'idle'
		end
end

function checkEnemyRemoval()
	for i, value in ipairs(enemies) do

		if value.x > screenwidth or value.x < 0 then
			value.isAlive = false
		elseif value.y > screenheight + 10 or value.y < 0 then
			value.isAlive = false
		end

		if value.isAlive == false then
			for is, col_var in pairs(value.boundingbox.container) do
				entityCollider:remove(col_var)
			end
			Collider:remove(value.boundingbox.level)
		
			for ix, enemy_var in pairs(value) do
				value[ix] = 0
				value[ix] = nil
			end
			value = nil
			table.remove(enemies,i)

		end

	end
end

--Collision Functions
function ground_collision (dt, shape_a, shape_b, mtv_x, mtv_y)
	world.debugtext.level[#world.debugtext.level+1] = string.format("Colliding. mtv = (%s, %s)", mtv_x, mtv_y)

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
	snapPlayerBoundingBoxes()
	
	for i, enemyIndex in ipairs(enemies) do
		snapEnemyBoundingBoxes(enemyIndex)
	end
end	

function entity_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	
	local isPlayer, isEnemy, enemyIndex, isEnemy2, enemyIndex2 = nil

	local function checkCollisionContainers(var_names, shape)
		for i,value in pairs(var_names) do
			if shape == value then
				return true
			end
		end
		return false
	end


	local function resolveCollision()
		
		if isPlayer then
			
			--If the players entity body bounding box collides with something
			if checkCollisionContainers({player.boundingbox.entity_main}, isPlayer) then
					--If that something is an enemy
					if isEnemy then
						--If it collides with the enemies body bounding box
						if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then
							enemyIndex.velocity.x = 0						
							enemyIndex.velocity.x = enemyIndex.velocity.x + -mtv_x
							snapEnemyBoundingBoxes(enemyIndex)
					
							player.velocity.x = 0
							player.velocity.x = player.velocity.x + mtv_x
							snapPlayerBoundingBoxes()						
							--world.debugtext.entity[#world.debugtext.entity+1] = string.format("PColliding. mtv/Vel = (%s, %s)",math.floor(-mtv_x), enemyIndex.velocity.x)
						end
					end
			end
		elseif isEnemy then
			if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then
				if isEnemy2 then
					enemyIndex.velocity.x = 0						
					enemyIndex.velocity.x = enemyIndex.velocity.x + mtv_x*dt+4
					snapEnemyBoundingBoxes(enemyIndex)

					enemyIndex2.velocity.x = 0						
					enemyIndex2.velocity.x = enemyIndex2.velocity.x + -mtv_x*dt-4
					snapEnemyBoundingBoxes(enemyIndex2)
				end
			end
		end

		if checkCollisionContainers({player.boundingbox.fist_box}, isPlayer) then
				
			if isEnemy then
				if enemyIndex.boundingbox.entity_top_left or enemyIndex.boundingbox.entity_top_right then
					world.debugtext.entity[#world.debugtext.entity+1] = tostring("Kapow")
				end
			end
		end

	end

	
	local function checkCollisionObjects(shapes)
		for i, value in pairs(shapes) do
			
			--If a player is somewhere in this collision
			if checkCollisionContainers(player.boundingbox.container, value) then
				isPlayer = value
			end

			for i, enem in ipairs(enemies) do
				if checkCollisionContainers(enem.boundingbox.container, value) and not isEnemy then
					isEnemy = value
					enemyIndex = enem
				elseif checkCollisionContainers(enem.boundingbox.container, value) and isEnemy then
					isEnemy2 = value
					enemyIndex2 = enem
				end

			end

		end
	end
		

	checkCollisionObjects(  {shape_a, shape_b}  )
	resolveCollision()
end


function entity_collision_stop(dt, shape_a, shape_b)
	--world.debugtext.entity[#world.debugtext.entity+1] = "Stopped Colliding"

end

function load_graphics()
	--Load Graphics and init animations	
	charactersheet = love.graphics.newImage("CharacterSheet.png")
	enemysheet = love.graphics.newImage("enemy_sheet.png")
	background = love.graphics.newImage("Background.jpg")

	enemyIdleAnim = { love.graphics.newQuad(420, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight())	}
	enemyWalkAnim = {
		--Row1
		love.graphics.newQuad(20, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),  love.graphics.newQuad(120, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(220, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(320, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(420, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(520, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(620, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(720, 0, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		--Row2
		love.graphics.newQuad(20, 112, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),	love.graphics.newQuad(120, 112, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(220, 112, 50, 100, enemysheet:getWidth(), enemysheet:getHeight()),love.graphics.newQuad(320, 112, 50, 100, enemysheet:getWidth(), enemysheet:getHeight())
	}
	enemyRunAnim = {
		--Row2
		love.graphics.newQuad(412, 112, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(514, 112, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(620, 112, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(730, 112, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		--Row3
		love.graphics.newQuad(20, 222, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(120, 222, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(210, 220, 82, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(310, 220, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(410, 220, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(510, 220, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(612, 222, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(712, 224, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		--Row4
		love.graphics.newQuad(20, 340, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),	love.graphics.newQuad(120, 340, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(220, 340, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()), love.graphics.newQuad(320, 340, 80, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(411, 340, 81, 100, enemysheet:getWidth(), enemysheet:getHeight())
	}
	enemyStunnedAnim = {
		--Row4
		--love.graphics.newQuad(511, 340, 60, 100, enemysheet:getWidth(), enemysheet:getHeight()), 
		--love.graphics.newQuad(611, 340, 60, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		--love.graphics.newQuad(711, 340, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),

		--Row 5
		love.graphics.newQuad(21, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(121, 450, 75, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(221, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(321, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(421, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight())
	}
	enemyJabbedL1 = {
		--Row 5
		love.graphics.newQuad(521, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()), 
		love.graphics.newQuad(621, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(721, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),

		--Row 6		
		--love.graphics.newQuad(721, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(621, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(521, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight())
	}
	enemyJabbedL2 = {
		--Row 5
		love.graphics.newQuad(521, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()), 
		love.graphics.newQuad(621, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(721, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),

		--Row 6
		love.graphics.newQuad(21, 560, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(121, 560, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),

		love.graphics.newQuad(21, 560, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(721, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(621, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
		love.graphics.newQuad(521, 450, 65, 100, enemysheet:getWidth(), enemysheet:getHeight()),
	}


	agrid = anim8.newGrid(60, 100, charactersheet:getWidth(), charactersheet:getHeight())
	enemygrid = anim8.newGrid(50,100, enemysheet:getWidth(), enemysheet:getHeight())
	standstill = anim8.newAnimation(agrid(1, 1), 0.1)
	walkanimation = anim8.newAnimation(agrid('2-7', 1), 0.1)
	weakenemystandstill = anim8.newAnimation(agrid(1, 2), 0.1)
	weakenemywalkanimation = anim8.newAnimation(agrid('2-7', 2), 0.1)
	
	mediumenemystandstill = anim8.newAnimation(enemyIdleAnim, 0.1)
	mediumenemywalkanimation = anim8.newAnimation(enemyWalkAnim, 0.09)
	mediumenemyrunanimation = anim8.newAnimation(enemyRunAnim, 0.09)
	mediumenemystunned = anim8.newAnimation(enemyStunnedAnim, 0.3)
	mediumenemyjabbed_l1 = anim8.newAnimation(enemyJabbedL1, 0.06)
	mediumenemyjabbed_l2 = anim8.newAnimation(enemyJabbedL2, 0.06)
	
end

function create_player()
	player = {}
	player.yup = false
	player.x = 300
	player.y = 400
	player.isOnGround = false
	player.action = false
	player.speed = 400
	player.punchspeed = .2
	player.kickspeed = .4
	player.maxspeed = 180
	player.stoppingSpeed = 12
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

	--Offset measurements for snapping the bounding box to the player
	player.turnoffset = 20
	player.boundingbox.offset_moveto_fist_x = 50
	player.boundingbox.fist_color = 120
	player.boundingbox.offset_moveto_entity_left_x = 15
	player.boundingbox.offset_moveto_entity_top_y = 25
	player.boundingbox.offset_moveto_entity_right_x = 30 
	player.boundingbox.offset_moveto_entity_bottom_y = 75
	player.boundingbox.offset_moveto_level_x = 18
	player.boundingbox.offset_moveto_level_y = 50
	player.boundingbox.level_sizeX = 38
	player.boundingbox.level_sizeY = 100
	player.boundingbox.entity_sizeX = 15
	player.boundingbox.entity_sizeY = 50

	--Bounding Box for level collision (wraps around the players body)
	player.boundingbox.level = Collider:addRectangle(player.x, player.y, player.boundingbox.level_sizeX, player.boundingbox.level_sizeY)
	--Bounding box for entity -> entity collision (wraps around the players body)
	player.boundingbox.entity_main = entityCollider:addRectangle(player.x + 4, player.y, player.boundingbox.level_sizeX + 2, player.boundingbox.level_sizeY)
	player.boundingbox.entity_top_left = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_entity_left_x/2, player.y, player.boundingbox.entity_sizeX, player.boundingbox.entity_sizeY )
	player.boundingbox.entity_top_right = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y, player.boundingbox.entity_sizeX, player.boundingbox.entity_sizeY )
	player.boundingbox.entity_bottom_right = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_entity_left_x, 
																		player.y + player.boundingbox.offset_moveto_level_y, player.boundingbox.entity_sizeX, player.boundingbox.entity_sizeY )
	player.boundingbox.entity_bottom_left = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_entity_left_x/2, 
																		player.y + player.boundingbox.offset_moveto_level_y, player.boundingbox.entity_sizeX, player.boundingbox.entity_sizeY )
	player.boundingbox.fist_box = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_fist_x, player.y, 20, 15)
	--Ghost fist box until player attacks - prevents needless collision calls
	entityCollider:setGhost(player.boundingbox.fist_box)
	player.boundingbox.container = {player.boundingbox.entity_top_left, player.boundingbox.entity_top_right,
									player.boundingbox.entity_bottom_left, player.boundingbox.entity_bottom_right,
									player.boundingbox.entity_main, player.boundingbox.fist_box}
	Collider:addToGroup("players", player.boundingbox.level)
	entityCollider:addToGroup("internalBoundingBoxes", player.boundingbox.entity_top_left, 
			player.boundingbox.entity_top_right, player.boundingbox.entity_bottom_right, 
			player.boundingbox.entity_bottom_left,player.boundingbox.entity_main)

end

function create_world()
	--Create Debugtext containers
	world = {}
	world.debugtext = {}
	world.debugtext.level = {}
	world.debugtext.entity = {}

	--Debug flags
	world.debug = {}
	world.debug.player = true
	world.debug.enemies = true
	world.debug.collision_level = false
	world.debug.collision_entity = false

	--Level Geometry and collision box creation
	world.groundpos = 640
	world.leftwall = Collider:addRectangle(0, 20, 60, screenheight -20)
	world.rightwall = Collider:addRectangle(900, 323, 40, screenheight -20)
	world.roof = Collider:addRectangle(0, 0, screenwidth, 20)
	world.ground = Collider:addRectangle(60,world.groundpos, screenwidth - 64, 20)
	Collider:addToGroup("level", world.leftwall, world.rightwall, world.roof, world.ground)
	Collider:setPassive(world.leftwall, world.rightwall, world.roof, world.ground)

	world.level = 1
	world.gravity = 50
	world.terminalVelocity = 150
	world.windResistance = 20
	world.spawnLocations = {{215, 214},
							--{509, 236},
							--{403, 510}, 
							--{993, 227},
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
		enemy.type = 'medium'

		if enemy.type == 'weak' then
			enemy.walkanimation = weakenemywalkanimation
			enemy.standstillanimation = weakenemystandstill
		elseif enemy.type == 'medium' then
			enemy.walkanimation = mediumenemywalkanimation
			enemy.standstillanimation = mediumenemystandstill
		end
		enemy.punchspeed = .2
		enemy.kickspeed = .4
		enemy.maxspeed = 150
		enemy.turnoffset = 20
		enemy.debugtextloc = #enemies * 10
		enemy.debug = true
		enemy.speed = 400	
		enemy.stoppingSpeed = 12
		enemy.isFacingRight = true
		enemy.action = 'd'
		enemy.isMoving = false
		enemy.isWalkFlipped = false
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
		
		enemy.boundingbox.offset_moveto_entity_left_x = 25
		enemy.boundingbox.offset_moveto_entity_top_y = 25
		enemy.boundingbox.offset_moveto_entity_right_x = 40 
		enemy.boundingbox.offset_moveto_entity_bottom_y = 75
		enemy.boundingbox.offset_moveto_level_x = 18
		enemy.boundingbox.offset_moveto_level_y = 50
		enemy.boundingbox.level_sizeX = 38
		enemy.boundingbox.level_sizeY = 100
		enemy.boundingbox.entity_sizeX = 15
		enemy.boundingbox.entity_sizeY = 50

		--Bounding Box for level collision (wraps around the enemys body)
		enemy.boundingbox.level = Collider:addRectangle(enemy.x, enemy.y, enemy.boundingbox.level_sizeX, enemy.boundingbox.level_sizeY)
		--Bounding box for entity -> entity collision (wraps around the enemys body)
		enemy.boundingbox.entity_main = entityCollider:addRectangle(enemy.x + 4, enemy.y, enemy.boundingbox.level_sizeX + 2, enemy.boundingbox.level_sizeY)
		enemy.boundingbox.entity_top_left = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x/2, enemy.y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_top_right = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x, enemy.y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_bottom_right = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x, 
																		enemy.y + enemy.boundingbox.offset_moveto_level_y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_bottom_left = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x/2, 
																		enemy.y + enemy.boundingbox.offset_moveto_level_y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )

		
		


		enemy.boundingbox.container = {enemy.boundingbox.entity_top_left, enemy.boundingbox.entity_top_right,
										enemy.boundingbox.entity_bottom_right, enemy.boundingbox.entity_bottom_left,
										enemy.boundingbox.entity_main}
		enemy.reference = "Enemy" .. tostring(#enemies)
		entityCollider:addToGroup(enemy.reference, enemy.boundingbox.entity_top_left, 
			enemy.boundingbox.entity_top_right, enemy.boundingbox.entity_bottom_right, 
			enemy.boundingbox.entity_bottom_left,enemy.boundingbox.entity_main)
		
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

