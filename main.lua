local anim8 = require ("anim8")
HC = require 'hardoncollider'
local AI = require ("ai")
local enemies = require("enemies")

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
	checkEnemyRemoval(enemies)

    if #world.debugtext.level > 20 then
        table.remove(world.debugtext.level, 1)
    end

    while #world.debugtext.entity > 40 do
    	table.remove(world.debugtext.entity, 1)
    end

    
    --Give all of the player animations the time
    --for i, animation in pairs(player.animations) do
		--animation:update(dt)
	--end

	player.animations.jab:update(dt)
	player.animations.walkanimation:update(dt)	
	player.animations.cross:update(dt)
	player.animations.standstill:update(dt)
	
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
	doEnemyProcessing(dt, enemies)
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
		love.graphics.print("Status: " .. tostring(player.animations.jab.status), 340,50)
		love.graphics.print("isAttacking: " .. tostring(player.isAttacking), 340,60)
		love.graphics.print("Player X: " .. tostring(player.x) .. "Player Y: " .. tostring(player.y), 340,70)
		love.graphics.print("Action: " .. tostring(player.action), 340,80, math.rad(30))
		--love.graphics.print("Test: " .. tostring(player.type), 340,90, math.rad(30))
	end

	--Draw Player
	if player.animation == 'walk' and not player.isAttacking then
		player.animations.walkanimation:draw(playersheet, player.x,player.y)
	elseif player.animation == 'idle' and not player.isAttacking then
		player.animations.standstill:draw(playersheet, player.x,player.y)
	elseif player.isAttacking and player.action == "jab" then	--Draw jab animation
		player.animations.jab:draw(playersheet, player.x, player.y)	
	elseif player.isAttacking and player.action == "hook" then
		player.animations.cross:draw(playersheet, player.x, player.y)
	elseif player.isAttacking and player.isFacingRight and player.action == "kick" then
		love.graphics.print("Kick", player.x + 38, player.y + player.boundingbox.offset_moveto_foot_y-6) ----Draw "Kick" on shin kick
	elseif player.isAttacking and not player.isFacingRight and player.action == "kick" then
		love.graphics.print("Kick", player.x - 8, player.y + player.boundingbox.offset_moveto_foot_y-6)
	elseif player.isAttacking and player.isFacingRight and player.action == "frontkick" then
		love.graphics.print("FKick", player.x + 38, player.y + player.boundingbox.offset_moveto_foot_y-6) -- --Draw "FKick" on front kick
	elseif player.isAttacking and not player.isFacingRight and player.action == "frontkick" then
		love.graphics.print("FKick", player.x - 8, player.y + player.boundingbox.offset_moveto_foot_y-6)
	end
	
	--Draw Enemies
	for i, value in ipairs(enemies) do

		
		if value.animation_state == 'idle' then
			value.animation.standstillanimation:draw(enemysheet, value.x,value.y)
		elseif value.animation_state == 'walk' then
			value.animation.walkanimation:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'run' then
			value.animation.runanimation:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'punched' then
			value.animation.jabbed_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'kicked' then
			value.animation.shinkick_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'decked' then
			value.animation.decked_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'frontkicked' then
			value.animation.frontkick_l1:draw(enemysheet, value.x, value.y)
		end



		if world.debug.enemies then			
			love.graphics.print(string.format("Enemy (%s): VelX: %s - X: %s - facingRight: %s - isAnimationFlipped: %s", 
				i, math.floor(value.velocity.x), math.floor(value.x), tostring(value.isFacingRight), tostring(value.isAnimationFlipped)),
				 	0, value.debugtextloc)
			love.graphics.print("NumOfEnemies: " .. tostring(#enemies), 800, 10)
			love.graphics.print(string.format("DisX: %s DisY: %s", tostring(value.player_tracker.distanceToPlayer_x), tostring(value.player_tracker.distanceToPlayer_y)), value.x-50, value.y)

		end
	end

	if world.debug.collision_entity then
		--Draw player Entity collision stuff
		love.graphics.setColor(255,255,12, 255)
		player.boundingbox.entity_main:draw('line')
		love.graphics.setColor(255,player.boundingbox.fist_color,player.boundingbox.fist_color, 255)
		--player.boundingbox.fist_box:draw('line')
		--player.boundingbox.foot_box:draw('line')
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
		love.event.push("quit") -- Quit the game
	end

	
	if key == "e" and (love.keyboard.isDown("a") or love.keyboard.isDown("d") ) then -- Hook
		player.action = "hook"
		player.energy = player.energy - 2
	elseif key == " " and (love.keyboard.isDown("a") or love.keyboard.isDown("d") ) then -- Front Kick
		player.action = "frontkick"
		player.energy = player.energy - 2
	elseif key == "e" then
		player.action = "jab"
		player.energy = player.energy - 0.5
	elseif key == " " then  --Spacebar
		player.action = "kick"
		player.energy = player.energy - 0.2
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
			player.boundingbox.fist_box:moveTo(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_fist_y*2)
			player.boundingbox.foot_box:moveTo(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_foot_y)
		else
			player.boundingbox.level:moveTo(player.x + player.boundingbox.offset_moveto_level_x+20, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_main:moveTo(player.x + player.boundingbox.offset_moveto_level_x + 18, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_top_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x+15, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_top_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x+15, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_bottom_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x+15, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.entity_bottom_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x+15, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.fist_box:moveTo(player.x + 10, player.y + player.boundingbox.offset_moveto_fist_y*2)
			player.boundingbox.foot_box:moveTo(player.x + 5, player.y + player.boundingbox.offset_moveto_foot_y)

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

				for i, animation in pairs(player.animations) do
					animation:flipH()
				end

				moveplayer('left',dt)
			end
		end

		if key == "d" then
			if player.isFacingRight then
				moveplayer('right',dt)
			elseif player.isFacingRight == false then
				player.x = player.x + player.turnoffset
				player.isFacingRight = true

				for i, animation in pairs(player.animations) do
					animation:flipH()
				end

				moveplayer('right',dt)
			end
		end

		if key == 'fall' then
			moveplayer('down',dt)
		end
end

function playerAttack(type, dt)
	
	local function isTheShapeAGhost(colliderInstance, shape)
		for i, value in pairs(colliderInstance._active_shapes) do -- Iterate over active
			if value == shape then --Do you find the shape?
				return true
			end
		end

		return false
	end

	local function doAttack(boundingbox, stop)


		if not stop then 
			player.animTimer = love.timer.getTime() + player.jabspeed
			player.isAttacking = true
			
			if not isTheShapeAGhost(entityCollider, boundingbox) then
				entityCollider:setSolid(boundingbox)
			end
		end

		if stop then			
			player.action = false
			player.isAttacking = false
						

			if isTheShapeAGhost(entityCollider, boundingbox) then
				entityCollider:setGhost(boundingbox)
			end	
		end

	end

	if type == "jab" and player.isAttacking == false then
		player.animations.jab:resume()
		doAttack(player.boundingbox.fist_box, false)		
	elseif type == "jab" and player.isAttacking and love.timer.getTime() > player.animTimer then		
		player.animations.jab:pauseAtStart()
		doAttack(player.boundingbox.fist_box, true)
		
		
	end

	if type == 'hook' and player.isAttacking == false and love.timer.getTime() > player.animTimer then		
		doAttack(player.boundingbox.fist_box)
	elseif type == 'hook' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		doAttack(player.boundingbox.fist_box, true)
	end

	if type == 'kick' and player.isAttacking == false then
		doAttack(player.kickspeed, player.boundingbox.foot_box)
	elseif type == 'kick' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		doAttack(player.kickspeed, player.boundingbox.foot_box, true)
	end

	if type == 'frontkick' and player.isAttacking == false then
		doAttack(player.frontkickspeed, player.boundingbox.foot_box)
	elseif type == 'frontkick' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		doAttack(player.frontkickspeed, player.boundingbox.foot_box, true)
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
	end
	
	
	if player.action then --If an action has been performed
		
		if player.action == "jab" or player.action == "hook" or 
			player.action == "kick" or player.action == "frontkick" then --The action is an attack

			playerAttack(player.action, dt)
		end
	end

	if player.isOnGround == false then		
		player.y = player.y + player.velocity.y
		doPlayerAnimation('fall',dt)
		snapPlayerBoundingBoxes()
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
					if isEnemy then    --If that something is an enemy
						if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then --If it collides with the enemies body bounding box
							enemyIndex.velocity.x = 0			
							enemyIndex.velocity.x = enemyIndex.velocity.x + -mtv_x
							snapEnemyBoundingBoxes(enemyIndex)
					
							player.velocity.x = 0
							if mtv_x > 4 then
								player.x = player.x + mtv_x*dt
							elseif mtv_x < -4 then
								player.x = player.x - mtv_x*dt
							end
							player.velocity.x = player.velocity.x + mtv_x
							snapPlayerBoundingBoxes()				
						end
					end
			end
		elseif isEnemy then  -- If an enemy has come in contact with something
			if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then  --If that something is another enemies bounding box
				if isEnemy2 then

						
				
					if enemyIndex.animation_state == 'frontkicked' then  --

						enemyIndex.velocity.x = 0						
						enemyIndex.velocity.x = enemyIndex.velocity.x + mtv_x*dt+4
						snapEnemyBoundingBoxes(enemyIndex)

						enemyIndex2.velocity.x = 0						
						enemyIndex2.velocity.x = enemyIndex2.velocity.x + -mtv_x*dt-4
						snapEnemyBoundingBoxes(enemyIndex2)
						enemyIndex2.velocity.x = enemyIndex.velocity.x
						
						if enemyIndex.velocity.x > 0 then
							world.debugtext.entity[#world.debugtext.entity+1] = string.format("ShiftingLeft: %s - isEnemy2:  %s ",tostring(enemyIndex.reference), tostring(enemyIndex2.reference))
							enemyIndex2.velocity.x = enemyIndex2.velocity.x - 150
							snapEnemyBoundingBoxes(enemyIndex2)
							snapEnemyBoundingBoxes(enemyIndex)
						elseif enemyIndex.velocity.x < 0 then
							world.debugtext.entity[#world.debugtext.entity+1] = string.format("ShiftingRight: %s - isEnemy2:  %s ",tostring(enemyIndex.reference), tostring(enemyIndex2.reference))
							enemyIndex2.velocity.x = enemyIndex2.velocity.x + 150
							snapEnemyBoundingBoxes(enemyIndex2)
							snapEnemyBoundingBoxes(enemyIndex)
						end
					elseif enemyIndex2.animation_state == 'frontkicked' then
					
						enemyIndex.velocity.x = enemyIndex2.velocity.x
						
						if enemyIndex2.velocity.x > 0 then
							enemyIndex.velocity.x = enemyIndex.velocity.x - 150
							enemyIndex.health = enemyIndex.health - 50*dt
							snapEnemyBoundingBoxes(enemyIndex2)
							snapEnemyBoundingBoxes(enemyIndex)
						elseif enemyIndex2.velocity.x < 0 then
							enemyIndex.velocity.x = enemyIndex.velocity.x + 150
							enemyIndex.health = enemyIndex.health - 50*dt
							snapEnemyBoundingBoxes(enemyIndex2)
							snapEnemyBoundingBoxes(enemyIndex)
						end
					end
				end
			end
		end

		if checkCollisionContainers({player.boundingbox.fist_box}, isPlayer) then -- If the punching box comes in contact with something
				
			if isEnemy then  -- If that something happens to be an ENEMY!!!
				if checkCollisionContainers({enemyIndex.boundingbox.entity_top_left,enemyIndex.boundingbox.entity_top_right}, isEnemy) then --If you're hitting their top bounding boxes
					
					if not enemyIndex.isJabbed and not enemyIndex.isDecked and enemyIndex.isAlive and player.action == "jab" then --If they're not already being punched and they're hit with a jab
						enemyIndex.isJabbed = true
						enemyIndex.health = enemyIndex.health - player.punchDamage
						entityCollider:setGhost(player.boundingbox.fist_box) -- Turn the collision box off until activated by punch again	
					elseif not enemyIndex.isJabbed and not enemyIndex.isDecked and enemyIndex.isAlive and player.action == "hook" then --If they're not already being punched and they're hit with a jab
						enemyIndex.isDecked = true
						enemyIndex.health = enemyIndex.health - player.punchDamage*2
						entityCollider:setGhost(player.boundingbox.fist_box) -- Turn the collision box off until activated by punch again
						if checkCollisionContainers({enemyIndex.boundingbox.entity_top_right}, isEnemy) then
							enemyIndex.velocity.x = enemyIndex.velocity.x + -80
						else
							enemyIndex.velocity.x = enemyIndex.velocity.x + 80
						end
					end

				end
			end
		end

		if checkCollisionContainers({player.boundingbox.foot_box}, isPlayer) then -- If the kicking box comes in contact with something
				
			if isEnemy then  -- If that something happens to be an ENEMY!!!
				if checkCollisionContainers({enemyIndex.boundingbox.entity_bottom_left,enemyIndex.boundingbox.entity_bottom_right}, isEnemy) then --If you're hitting their bottom bounding boxes
					
					if not enemyIndex.isKicked and enemyIndex.isAlive and player.action == "kick" then --If they're not already being kicked and the player is shin kicking
						enemyIndex.isKicked = true
						enemyIndex.health = enemyIndex.health - player.kickDamage
						entityCollider:setGhost(player.boundingbox.foot_box) -- Turn the collision box off until activated by kick again	

					elseif not enemyIndex.isFrontKicked and enemyIndex.isAlive and player.action == "frontkick" then
						enemyIndex.isFrontKicked = true
						enemyIndex.health = enemyIndex.health - (player.kickDamage - 6)
						entityCollider:setGhost(player.boundingbox.foot_box) -- Turn the collision box off until you kick again
						
						if checkCollisionContainers({enemyIndex.boundingbox.entity_bottom_right}, isEnemy) then  --If you front kick them on the right they'll go left...
							enemyIndex.velocity.x = enemyIndex.velocity.x - 480	
							enemyIndex.velocity.y = enemyIndex.velocity.y - 5
							enemyIndex.isOnGround = false
						else  --If you front kick them on the left they'll go right...
							enemyIndex.velocity.x = enemyIndex.velocity.x + 480	
							enemyIndex.velocity.y = enemyIndex.velocity.y - 5
							enemyIndex.isOnGround = false
						end
					end
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
	--charactersheet = love.graphics.newImage("/assets/CharacterSheet.png")
	enemysheet = love.graphics.newImage("/assets/enemy_sheet.png")
	background = love.graphics.newImage("/assets/Background.jpg")
	playersheet = love.graphics.newImage("/assets/player_sheet.png")

	

	--agrid = anim8.newGrid(60, 100, charactersheet:getWidth(), charactersheet:getHeight())
	enemygrid = anim8.newGrid(90,100, enemysheet:getWidth(), enemysheet:getHeight())
	playergrid = anim8.newGrid(99, 110, playersheet:getWidth(), playersheet:getHeight())
	
	--standstill = anim8.newAnimation(agrid(1, 1), 0.1)
	--walkanimation = anim8.newAnimation(agrid('2-7', 1), 0.1)
	--weakenemystandstill = anim8.newAnimation(agrid(1, 2), 0.1)
	--weakenemywalkanimation = anim8.newAnimation(agrid('2-7', 2), 0.1)


	standstill = anim8.newAnimation(playergrid(1,1), 0.1)
	walkanimation = anim8.newAnimation(playergrid(1, 1), 0.1)
	
	cross = anim8.newAnimation(playergrid(4, 1), 0.4, 'pause')

	

	--Medium Enemy animation loads and designations
	mediumenemystandstill = anim8.newAnimation(enemygrid(3,3, 2,4, 1,5, 4,3, 3,4 ), 0.3)
	mediumenemydance = anim8.newAnimation(enemygrid('2-5',1,'2-2', 2,'3-4', 2), 0.14)
	mediumenemyrunanimation = anim8.newAnimation(enemygrid(8,2,7,3,6,4,10,1,9,2,8,3,7,4,6,5,11,1,10,2,9,3,8,4,7,5,11,2,10,3,9,4,8,5), 0.04)
	mediumenemywalkanimation = anim8.newAnimation(enemygrid(1,7,3,6,2,7,1,8,4,6,3,7,2,8,1,9,5,6,4,7,3,8,2,9), 0.1)
	mediumenemystunned = anim8.newAnimation(enemygrid(11,3,	10,4,9,5,11,4,10,5,	11,5,1,6,2,6), 0.1)
	mediumenemyjabbed_l1 = anim8.newAnimation(enemygrid(2,5, 5,3, 4,4, 4,4, 5,3, 2,5), 0.03, 'pause')	
	mediumenemyjabbed_l2 = anim8.newAnimation(enemygrid(2,5, 5,3, 4,4, 3,5,  5,4 , 5,4,5,4,  3,5, 4,4, 5,3, 2,5), 0.03, 'pause') -- 5,4's in the middle are neck snapped back
	mediumenemyshinkick_l1 = anim8.newAnimation(enemygrid(3,2, 3,2, 4,2,4,2,4,2, 3,2), 0.2, 'pause')
	mediumenemydecked_l1 = anim8.newAnimation(enemygrid(1,1, 2,1, 1,2, 2,1, 1,1), 0.05, 'pause')
	mediumenemydecked_l2 = anim8.newAnimation(enemygrid(1,1, 2,1, 1,2, 2,2, 3,1, 2,2, 1,2, 2,1, 1,1), .046, 'pause')
	mediumenemydecked_l3 = anim8.newAnimation(enemygrid(4,1,3,2,5,1,4,2,5,2,1,3,2,3,1,4,6,2,8,1,7,2,6,3,9,1,11,4,10,5,11,5,1,6,2,6,1,6,11,5,10,5,11,4,9,5,10,4,11,3), 0.1, 'pause')
	mediumenemyfrontkick_l1 = anim8.newAnimation(enemygrid(9,1, 8,1, 4,2, 5,1), 0.08, 'pause')
	


end

function create_player()
	player = {}
	player.x = 300
	player.y = 400
	player.jabspeed = 1
	player.animations = {}
	player.animations.standstill = standstill:clone()
	player.animations.walkanimation = walkanimation:clone()
	player.animations.jab = anim8.newAnimation(playergrid(1,1, 2,1, 1,2), player.jabspeed, 'pause')
	player.animations.cross = cross:clone()


	player.punchDamage = 25
	player.punchMultiplier = 1
	player.kickDamage = 12.5
	player.kickMultipler = 1

	player.isOnGround = false
	player.action = 'idle'
	player.speed = 400
	
	player.hookspeed = .7
	player.kickspeed = .3
	player.frontkickspeed = .8
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
	player.boundingbox.offset_moveto_fist_y = 10
	player.boundingbox.offset_moveto_foot_y = 80
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
	player.boundingbox.fist_box = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_fist_y, 20, 15)
	player.boundingbox.foot_box = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_foot_y, 25, 15)
	--Ghost fist box until player attacks - prevents needless collision calls

	player.boundingbox.container = {player.boundingbox.entity_top_left, player.boundingbox.entity_top_right,
									player.boundingbox.entity_bottom_left, player.boundingbox.entity_bottom_right,
									player.boundingbox.entity_main, player.boundingbox.fist_box, player.boundingbox.foot_box}
	Collider:addToGroup("players", player.boundingbox.level)
	entityCollider:addToGroup("internalBoundingBoxes", player.boundingbox.entity_top_left, 
			player.boundingbox.entity_top_right, player.boundingbox.entity_bottom_right, 
			player.boundingbox.entity_bottom_left,player.boundingbox.entity_main,
			player.boundingbox.foot_box, player.boundingbox.fist_box)
		entityCollider:setGhost(player.boundingbox.fist_box)
	entityCollider:setGhost(player.boundingbox.foot_box)

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

	--Collider:setGhost(world.rightwall)
end

function createEnemies(number)
	
	
	for i = 1, number, 1 do 
		local enemy = {}
		math.random()
		enemy.spawn = math.random(#world.spawnLocations)

		enemy.type = 'medium'
		enemy.animation = {}

		if enemy.type == 'weak' then
			enemy.health = 100
			enemy.animation.walkanimation = weakenemywalkanimation:clone()
			enemy.animation.standstillanimation = weakenemystandstill:clone()
		elseif enemy.type == 'medium' then
			enemy.health = 150
			enemy.animation.walkanimation = mediumenemywalkanimation:clone()
			enemy.animation.standstillanimation = mediumenemystandstill:clone()
			enemy.animation.runanimation = mediumenemyrunanimation:clone()
			enemy.animation.stunned = mediumenemystunned:clone()
			enemy.animation.jabbed_l1 = mediumenemyjabbed_l1:clone()
			enemy.animation.jabbed_l2 = mediumenemyjabbed_l2:clone()
			enemy.animation.shinkick_l1 = mediumenemyshinkick_l1:clone()
			enemy.animation.decked_l1 = mediumenemydecked_l1:clone()
			enemy.animation.frontkick_l1 = mediumenemyfrontkick_l1:clone()
		elseif enemy.type == 'hard' then
			enemy.health = 250
			enemy.animation.walkanimation = hardenemywalkanimation:clone()
			enemy.animation.standstillanimation = hardenemystandstill:clone()
		end
		enemy.jabspeed = .1
		enemy.kickspeed = .3
		enemy.maxspeed = 150
		
		enemy.debugtextloc = #enemies * 10
		enemy.debug = true
		enemy.speed = 400	
		enemy.stoppingSpeed = 12

		--Enemy States
		enemy.isFacingRight = true
		enemy.action = false
		enemy.isMoving = false
		enemy.isAnimationFlipped = false
		enemy.isAttacking = false
		enemy.isAlive = true
		enemy.isPunching = false
		enemy.isKicking = false
		enemy.isShooting = false
		enemy.isOnGround = false
		enemy.isRunning = false
		enemy.isJabbed = false
		enemy.isKicked = false
		enemy.isDecked = false
		enemy.isFrontKicked = false



		--Enemy AI States
		enemy.wantsToRun = true		
		enemy.talking = false
		enemy.player_tracker = {}
		enemy.player_tracker.playerSpotted = false
		enemy.player_tracker.near = false
		enemy.player_tracker.isScary = false
		enemy.player_tracker.distanceToPlayer_x = 0
		enemy.player_tracker.distanceToPlayer_y = 0
		enemy.isAggresive = false


		--Location and speed variables
		enemy.velocity = {}
		enemy.velocity.x = 0
		enemy.velocity.y = 0
		enemy.x = world.spawnLocations[enemy.spawn][1]
		enemy.y = world.spawnLocations[enemy.spawn][2]


		
		enemy.animation_state = 'idle'
		
		enemy.animTimer = 0
		enemy.turnoffset = 13
		enemy.boundingbox = {}
		enemy.boundingbox.offset_moveto_entity_left_x = 35
		enemy.boundingbox.offset_moveto_entity_top_y = 25
		enemy.boundingbox.offset_moveto_entity_right_x = 50 
		enemy.boundingbox.offset_moveto_entity_bottom_y = 75
		enemy.boundingbox.offset_moveto_level_x = 39
		enemy.boundingbox.offset_moveto_level_y = 50
		enemy.boundingbox.level_sizeX = 38
		enemy.boundingbox.level_sizeY = 85
		enemy.boundingbox.entity_sizeX = 15
		enemy.boundingbox.entity_sizeY = 50

		--Bounding Box for level collision (wraps around the enemys body)
		enemy.boundingbox.level = Collider:addRectangle(enemy.x, enemy.y, enemy.boundingbox.level_sizeX, enemy.boundingbox.level_sizeY)
		--Bounding box for entity -> entity collision (wraps around the enemys body)
		enemy.boundingbox.entity_main = entityCollider:addRectangle(enemy.x + 4, enemy.y, enemy.boundingbox.level_sizeX + 2, enemy.boundingbox.level_sizeY)
		--Boundingboxes for hit/attack detection
		enemy.boundingbox.entity_top_left = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x/2, enemy.y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_top_right = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x, enemy.y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_bottom_right = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x, 
																		enemy.y + enemy.boundingbox.offset_moveto_level_y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )
		enemy.boundingbox.entity_bottom_left = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_entity_left_x/2, 
																		enemy.y + enemy.boundingbox.offset_moveto_level_y, enemy.boundingbox.entity_sizeX, enemy.boundingbox.entity_sizeY )

		
		


		enemy.boundingbox.container = {enemy.boundingbox.entity_top_left, enemy.boundingbox.entity_top_right,
										enemy.boundingbox.entity_bottom_right, enemy.boundingbox.entity_bottom_left,
										enemy.boundingbox.entity_main}
		--enemy.reference = "Enemy" .. tostring(#enemies)
		enemy.reference = tostring(#enemies)
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

