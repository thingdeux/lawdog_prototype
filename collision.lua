--[[--
Button 1-3 will spawn enemies
F1 Turns on player debug information
F2 Turns on enemy debug information
F3 Turns on collision level debug information
F4 Turns on collision entity debug information
F5 is a surprise
--]]

	--I keep references to each shape in a 'container' - for instance there are 5 boxes that makeup a container for a character
    --The MAIN box is the box that's used to determine collision between two people.  It's a box that's drawn over the whole character, and if it comes
    --in contact with another entity (ex: enemy) it will trigger collision events.  The name of the players main box is player.boundingbox.main
function checkCollisionContainers(var_names, shape)
	--This looks through the container that's passed for the given name of the 'shape' *example further down
	--When it finds the location of the requested container it passes it
	for i,name in pairs(var_names) do
		if shape == name then
			return true
		end
	end
	return false
end





--Ground Collision Functions (Level collision)
function ground_collision (dt, shape_a, shape_b, mtv_x, mtv_y)

	local isPlayer, isEnemy, isLevel = nil
	local enemyIndex, levelIndex = nil
	--world.debugtext.level[#world.debugtext.level+1] = string.format("Colliding. mtv = (%s, %s)", mtv_x, mtv_y)		

	local function levelChecks()

		if checkCollisionContainers(world.groundContainer, isLevel) then
			if isPlayer and not player.isOnStairs then
				player.y = player.y + mtv_y - 2
				snapPlayerBoundingBoxes()
				player.velocity.y = 0				
				player.isOnGround = true				
			elseif isEnemy then
				enemyIndex.y = enemyIndex.y + mtv_y - 2
				snapEnemyBoundingBoxes(enemyIndex)
				enemyIndex.velocity.y = 0				
				enemyIndex.isOnGround = true
			end
		end

		if checkCollisionContainers(world.stairContainer, isLevel) then
			
			if isPlayer then
				--world.debugtext.level[#world.debugtext.level+1] = string.format("Colliding w/ Stairs: mtv = (%s, %s)", mtv_x, mtv_y)
				--player.isOnStairs = true
				if player.velocity.x > 0 and player.isOnStairs then
					player.y = player.y + mtv_y
					player.x = player.x + mtv_x					
				elseif player.velocity.x < 0 and player.isOnStairs then
					player.y = player.y + mtv_y
					player.x = player.x + mtv_x					
				end
				snapPlayerBoundingBoxes()
			end
		end
		if checkCollisionContainers(world.wallContainer, isLevel) then
			if isPlayer then
				player.x = player.x + mtv_x - 2
				snapPlayerBoundingBoxes()
				player.velocity.x = 0
			elseif isEnemy then
				enemyIndex.x = enemyIndex.x + mtv_x - 2
				snapEnemyBoundingBoxes(enemyIndex)
				enemyIndex.velocity.x = 0
			end
		end

		if checkCollisionContainers(world.stairEntryContainer, isLevel) then
			player.canEnterStairs = true
		end

		if checkCollisionContainers(world.stairTerminationContainer, isLevel) then 
			if player.isOnStairs and not player.canEnterStairs then
				player.isOnStairs = false
				player.isOnGround = false				
			end
		end

	end

		--Determines the objects that are colliding
	local function determineCollisionObjects(shapes)
		local enemies = passEnemies()	--Ignore this		

		for i, value in pairs(shapes) do
			
			for i, levelbox in ipairs(world.levelContainer) do				
				if checkCollisionContainers({levelbox}, value) then				
					isLevel = value		
					levelIndex = levelbox
				end
			end

			--If a player is somewhere in this collision then set the 'isPlayer' flag to 'true'
			if checkCollisionContainers({player.boundingbox.level}, value) then
				isPlayer = value  --This is the shape			
			end

			--If an enemy is somewhere in this collision then set the 'isEnemy' flag to 'true'
			--Also track the memory location of the currently interacting enemy in enemyIndex (will come into play during resolve)
			for i, enem in ipairs(enemies) do
				if checkCollisionContainers({enem.boundingbox.level}, value) and not isEnemy then
					isEnemy = value
					enemyIndex = enem  --This is the table index for the enemy							
				end
			end



		end

	end


	determineCollisionObjects(  {shape_a, shape_b} )
	levelChecks()

end

function ground_collision_stop(dt, shape_a, shape_b)
	--local enemies = passEnemies()
	--world.debugtext.level[#world.debugtext.level+1] = "Stopped Colliding"
	local shapes = {shape_a, shape_b}

	for _, box in ipairs(shapes) do
		if checkCollisionContainers(world.stairEntryContainer, box) then
			player.canEnterStairs = false
		end
	end

end
--End Ground Collision Functions




--Entity (or person to person/object collision)
--This is called whenever two boxes that aren't in the same group collide.
function entity_collision(dt, shape_a, shape_b, mtv_x, mtv_y) 
	--Unfortunately the boxes don't identify themselves automatically so I create these 'flags' for use later in identifying them.
	local isPlayer, isEnemy, enemyIndex, isEnemy2, enemyIndex2 = nil

	local function resolveCollision()
		
		if isPlayer then  --If a player is colliding with something			
			--If the players main body bounding box is collindg with something
			if checkCollisionContainers({player.boundingbox.entity_main}, isPlayer) then					
					if isEnemy then    --If that something is an enemy												
						if checkCollisionContainers({enemyIndex.boundingbox.entity_main}, isEnemy) then --If it collides with the enemies body bounding box
																					
							enemyIndex.velocity.x = 0	--Set the enemies velocity to 0 so he is no longer moving	

							-- Push add some negative velocity to push the enemy back a bit
							if enemyIndex.x < player.x then																				
								enemyIndex.velocity.x = enemyIndex.velocity.x - 4200*dt
							else								
								enemyIndex.velocity.x = enemyIndex.velocity.x + 4200*dt
							end
							
							snapEnemyBoundingBoxes(enemyIndex) --This is what keeps the bounding boxes attached to the enemies, the boxes move with them because of this

							player.velocity.x = 0 --Set the enemies velocity to 0 as well so he isn't moving either

							--This is a "patch" I applied because sometimes the speeds of the two colliding objects is so high they warp through each other
							--Comment it out to see what things are like without it. This may be what needs fixing.
							--[[if mtv_x > 4 then
								player.x = player.x + mtv_x*dt
							elseif mtv_x < -4 then
								player.x = player.x - mtv_x*dt
							end  --]]
							
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
								enemyIndex.velocity.x = enemyIndex.velocity.x - 300
								enemyIndex.velocity.y = enemyIndex.velocity.y - 6
								enemyIndex.isOnGround = false
							else  --If you front kick them on the left they'll go right...
								enemyIndex.velocity.x = enemyIndex.velocity.x + 300	
								enemyIndex.velocity.y = enemyIndex.velocity.y - 6
								enemyIndex.isOnGround = false
							end
						end
					end
				end
			end
		end

	end

	--Determines the objects that are colliding
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
