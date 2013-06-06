--[[--
Button 1-3 will spawn enemies
F1 Turns on player debug information
F2 Turns on enemy debug information
F3 Turns on collision level debug information
F4 Turns on collision entity debug information
F5 is a surprise
--]]



--Ground Collision Functions (Level collision)
function ground_collision (dt, shape_a, shape_b, mtv_x, mtv_y)
	local enemies = passEnemies()	
	--world.debugtext.level[#world.debugtext.level+1] = string.format("Colliding. mtv = (%s, %s)", mtv_x, mtv_y)		

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
	local enemies = passEnemies()
	world.debugtext.level[#world.debugtext.level+1] = "Stopped Colliding"
	snapPlayerBoundingBoxes()

	for i, enemyIndex in ipairs(enemies) do
		snapEnemyBoundingBoxes(enemyIndex)
	end
end
--End Ground Collision Functions




--Entity (or person to person/object collision)
--This is called whenever two boxes that aren't in the same group collide.
function entity_collision(dt, shape_a, shape_b, mtv_x, mtv_y) 
	--Unfortunately the boxes don't identify themselves automatically so I create these 'flags' for use later in identifying them.
	local isPlayer, isEnemy, enemyIndex, isEnemy2, enemyIndex2 = nil

	--I keep references to each shape in a 'container' - for instance there are 5 boxes that makeup a container for a character
    --The MAIN box is the box that's used to determine collision between two people.  It's a box that's drawn over the whole character, and if it comes
    --in contact with another entity (ex: enemy) it will trigger collision events.  The name of the players main box is player.boundingbox.main
	local function checkCollisionContainers(var_names, shape)
		--This looks through the container that's passed for the given name of the 'shape' *example further down
		--When it finds the location of the requested container it passes it
		for i,value in pairs(var_names) do
			if shape == value then
				return true
			end
		end
		return false
	end


	local function resolveCollision()
		
		if isPlayer then  --If a player is colliding with something			
			--If the players main body bounding box is collindg with something
			if checkCollisionContainers({player.boundingbox.entity_main}, isPlayer) then					
					if isEnemy then    --If that something is an enemy						
						world.debugtext.entity[#world.debugtext.entity+1] = string.format("PCol. mtv = (%s, %s)", mtv_x, mtv_y)		
						if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then --If it collides with the enemies body bounding box
							
							
							-- Push the enemy back a bit mtv_x is how much the shapes collide							
							enemyIndex.velocity.x = 0	--Set the enemies velocity to 0 so he is no longer moving	

							if enemyIndex.x < player.x then																				
								enemyIndex.velocity.x = enemyIndex.velocity.x - 4200*dt
							else								
								enemyIndex.velocity.x = enemyIndex.velocity.x + 4200*dt
							end
							
							snapEnemyBoundingBoxes(enemyIndex) --This is what keeps the bounding boxes attached to the enemies, the boxes move with them because of this

							player.velocity.x = 0 --Set the enemies velocity to 0 as well so he isn't moving either

							--This is a "patch" I applied because sometimes the speeds of the two colliding objects is so high they warp through each other
							--Comment it out to see what things are like without it. This may be what needs fixing.
							if mtv_x > 4 then
								player.x = player.x + mtv_x*dt
							elseif mtv_x < -4 then
								player.x = player.x - mtv_x*dt
							end

							--Not sure why I'm setting the player velocity twice....may need to research this*
							--player.velocity.x = player.velocity.x + mtv_x
							snapPlayerBoundingBoxes()	--This is what keeps the bounding boxes attached to the player, the boxes move with them because of this
						end

						if checkCollisionContainers({enemyIndex.boundingbox.fist_box}, isEnemy) and not player.isHit then
							player.health = player.health - 5
							player.isHit = true
						end
					end
			end
		elseif isEnemy then  -- If an enemy has come in contact with something
			if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then  --If that something is another enemies bounding box
				if isEnemy2 then  --If the thing it has come in contact with is another enemy
						
					if enemyIndex.animation_state == 'frontkicked' then  --If that enemy is flying backwards from a front kick

						-- Start pushing back the person kicked
						enemyIndex.velocity.x = 0						
						enemyIndex.velocity.x = enemyIndex.velocity.x + mtv_x*dt+4 
						snapEnemyBoundingBoxes(enemyIndex)

						enemyIndex2.velocity.x = 0						
						enemyIndex2.velocity.x = enemyIndex2.velocity.x + -mtv_x*dt-4
						snapEnemyBoundingBoxes(enemyIndex2)
						enemyIndex2.velocity.x = enemyIndex.velocity.x
						
						if enemyIndex.velocity.x > 0 then
							--world.debugtext.entity[#world.debugtext.entity+1] = string.format("ShiftingLeft: %s - isEnemy2:  %s ",tostring(enemyIndex.reference), tostring(enemyIndex2.reference))
							enemyIndex2.velocity.x = enemyIndex2.velocity.x - 150
							snapEnemyBoundingBoxes(enemyIndex2)
							snapEnemyBoundingBoxes(enemyIndex)
						elseif enemyIndex.velocity.x < 0 then
							--world.debugtext.entity[#world.debugtext.entity+1] = string.format("ShiftingRight: %s - isEnemy2:  %s ",tostring(enemyIndex.reference), tostring(enemyIndex2.reference))
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
					
					if not enemyIndex.isJabbed and not enemyIndex.isDecked and enemyIndex.isAlive and player.action == "jab"  or player.action == "cross" then 
			  			
			  			if not enemyIndex.dodged then
			  				--If they're not already being punched and they're hit with a jab
							enemyIndex.isJabbed = true
							enemyIndex.health = enemyIndex.health - player.punchDamage
						end
						entityCollider:setGhost(player.boundingbox.fist_box) -- Turn the collision box off until activated by punch again	


					elseif not enemyIndex.isJabbed and not enemyIndex.isDecked and enemyIndex.isAlive and player.action == "hook" then--If they're not already being punched and they're hit with a hook
							   
						if not enemyIndex.dodged then --If they haven't dodged
							enemyIndex.isDecked = true
							enemyIndex.health = enemyIndex.health - player.punchDamage*2							
							if checkCollisionContainers({enemyIndex.boundingbox.entity_top_right}, isEnemy) then
								enemyIndex.velocity.x = enemyIndex.velocity.x + -80
							else
								enemyIndex.velocity.x = enemyIndex.velocity.x + 80
							end
						end

						entityCollider:setGhost(player.boundingbox.fist_box) -- Turn the collision box off until activated by punch again

					end

				end
			end
		end

		if checkCollisionContainers({player.boundingbox.foot_box}, isPlayer) then -- If the kicking box comes in contact with something
				
			if isEnemy then  -- If that something happens to be an ENEMY!!!
				if checkCollisionContainers({enemyIndex.boundingbox.entity_bottom_left,enemyIndex.boundingbox.entity_bottom_right}, isEnemy) then --If you're hitting their bottom bounding boxes
					
					if not enemyIndex.isKicked and enemyIndex.isAlive and player.action == "kick" then --If they're not already being kicked and the player is shin kicking
						if not enemyIndex.dodged then --If they haven't dodged
							enemyIndex.isKicked = true
							enemyIndex.health = enemyIndex.health - player.kickDamage
						end
						entityCollider:setGhost(player.boundingbox.foot_box) -- Turn the collision box off until activated by kick again	

					elseif not enemyIndex.isFrontKicked and enemyIndex.isAlive and player.action == "frontkick" then
						
						if not enemyIndex.dodged then --If they haven't dodged
							enemyIndex.isFrontKicked = true
							enemyIndex.health = enemyIndex.health - (player.kickDamage - 6)							
						end
							entityCollider:setGhost(player.boundingbox.foot_box) -- Turn the collision box off until you kick again

						if not enemyIndex.dodged then
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




	end

	--Because (as mentioned earlier) the collision function doesn't know which shapes are interacting, this function determines
	--whether you're dealing with the player character and an enemy or an enemy and another enemy
	local function determineCollisionObjects(shapes)
		local enemies = passEnemies()	--Ignore this	

		for i, value in pairs(shapes) do
			
			--If a player is somewhere in this collision then set the 'isPlayer' flag to 'true'
			if checkCollisionContainers(player.boundingbox.container, value) then
				isPlayer = value
			end

			
			--If an enemy is somewhere in this collision then set the 'isEnemy' flag to 'true'
			--Also track the memory location of the currently interacting enemy in enemyIndex (will come into play during resolve)
			for i, enem in ipairs(enemies) do
				if checkCollisionContainers(enem.boundingbox.container, value) and not isEnemy then
					isEnemy = value
					enemyIndex = enem

				--If there are no players in the collision and instead two enemies set the isEnemy2 flag to yes and track its location
				elseif checkCollisionContainers(enem.boundingbox.container, value) and isEnemy then
					isEnemy2 = value
					enemyIndex2 = enem
				end

			end

		end
	end
		

	--This is when the actual determination of the two shapes is performed, they were only 'configured' before, this is when it runs
	determineCollisionObjects(  {shape_a, shape_b}  )
	--Now that the function knows what two objects it's dealing with, go to the collision rules to figure out what to do.
	resolveCollision()
end


--This runs after the collision has stopped
function entity_collision_stop(dt, shape_a, shape_b)
	--world.debugtext.entity[#world.debugtext.entity+1] = "Stopped Colliding"
end
--End entity collision