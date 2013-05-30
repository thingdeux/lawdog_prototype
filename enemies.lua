
--Enemy Functions
function createEnemies(number)
	local enemies = passEnemies()
	
	for i = 1, number, 1 do 
		local enemy = {}
		local brain = { 'Coward', 'DumbPunk', 'SneakyDouche',
						'CautiousKitty', 'SneakyDouche', 'MeatBag',
						'SmartieMcFarty'}
		math.random()
		enemy.spawn = math.random(#world.spawnLocations)

		enemy.type = 'medium'
		enemy.personality = 'Coward'
		enemy.animation = {}

		if enemy.type == 'weak' then
			enemy.health = 100
			enemy.animation.walkanimation = weakenemywalkanimation:clone()
			enemy.animation.standstillanimation = weakenemystandstill:clone()
		elseif enemy.type == 'medium' then
			enemy.health = 150
			enemy.animation.walkanimation = mediumenemywalkanimation:clone()
			enemy.animation.standstillanimation = mediumenemystandstill:clone()
			enemy.animation.fightingstance = mediumenemyfightingstance:clone()
			enemy.animation.runanimation = mediumenemyrunanimation:clone()
			enemy.animation.stunned = mediumenemystunned:clone()
			enemy.animation.jabbed_l1 = mediumenemyjabbed_l1:clone()
			enemy.animation.jabbed_l2 = mediumenemyjabbed_l2:clone()
			enemy.animation.shinkick_l1 = mediumenemyshinkick_l1:clone()
			enemy.animation.decked_l1 = mediumenemydecked_l1:clone()
			enemy.animation.frontkick_l1 = mediumenemyfrontkick_l1:clone()
			enemy.animation.dance = mediumenemydance:clone()
		elseif enemy.type == 'hard' then
			enemy.health = 250
			enemy.animation.walkanimation = hardenemywalkanimation:clone()
			enemy.animation.standstillanimation = hardenemystandstill:clone()
		end
		enemy.jabspeed = .1
		enemy.kickspeed = .3
		enemy.maxspeed = 150
				
		enemy.debug = true
		enemy.speed = 400	
		enemy.stoppingSpeed = 12
		enemy.canDodge = {'jab', 'frontkick', 'kick', 'hook', 'cross'}
		enemy.dodged = false


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
		enemy.state = {}
		enemy.state.wantsToRun = false		
		enemy.state.talking = false
		enemy.state.isThreatened = false
		enemy.state.isFighting = false
		enemy.state.closeToAlly = false
		enemy.state.isFacingPlayer = false
		enemy.player_tracker = {}
		enemy.player_tracker.playerSpotted = false
		enemy.player_tracker.nearby = false
		enemy.player_tracker.isOnTheRight = false
		enemy.player_tracker.isBelowPlayer = false
		enemy.player_tracker.isScary = false
		enemy.player_tracker.distanceToPlayer_x = 0
		enemy.player_tracker.distanceToPlayer_y = 0
		
		--Location and speed variables
		enemy.velocity = {}
		enemy.velocity.x = 0
		enemy.velocity.y = 0
		enemy.x = world.spawnLocations[enemy.spawn][1]
		enemy.y = world.spawnLocations[enemy.spawn][2]
		enemy.debugtextloc = #enemies * 10
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
		enemy.boundingbox.offset_moveto_fist_x = 70
		enemy.boundingbox.offset_moveto_fist_y = 26
		enemy.boundingbox.offset_moveto_foot_y = 80
		enemy.boundingbox.fist_color = 180


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
		enemy.boundingbox.fist_box = entityCollider:addRectangle(enemy.x + enemy.boundingbox.offset_moveto_fist_x, enemy.y + enemy.boundingbox.offset_moveto_fist_y, 20, 15)

		
		


		enemy.boundingbox.container = {enemy.boundingbox.entity_top_left, enemy.boundingbox.entity_top_right,
										enemy.boundingbox.entity_bottom_right, enemy.boundingbox.entity_bottom_left,
										enemy.boundingbox.entity_main, enemy.boundingbox.fist_box}
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




function snapEnemyBoundingBoxes(index)
	
	if index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 2, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 2, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.fist_box:moveTo(index.x + index.boundingbox.offset_moveto_fist_x, index.y + index.boundingbox.offset_moveto_fist_y*2)
	elseif not index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 12, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 12, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.fist_box:moveTo(index.x + 20, index.y + index.boundingbox.offset_moveto_fist_y*2)

	end
end

function doEnemyProcessing(dt, enemies)

	local function applyForces(dt,enemyindex)
		if enemyindex.velocity.x > 50 then
			enemyindex.velocity.x = -world.windResistance*dt*enemyindex.stoppingSpeed + enemyindex.velocity.x
			enemyindex.x = enemyindex.x + enemyindex.velocity.x*dt			
		end

		if enemyindex.velocity.x < -50 then
			enemyindex.velocity.x = world.windResistance*dt*enemyindex.stoppingSpeed + enemyindex.velocity.x
			enemyindex.x = enemyindex.x + enemyindex.velocity.x*dt			
		end

		if enemyindex.velocity.x > -49 and enemyindex.velocity.x < 49 and enemyindex.velocity.x ~= 0 and enemyindex.animation_state == 'idle' then
			enemyindex.velocity.x = 0
		end

		if not enemyindex.isOnGround then

			if enemyindex.velocity.y < 20 then					
				enemyindex.velocity.y = enemyindex.velocity.y + world.gravity*dt
			end
			enemyindex.y = enemyindex.y + enemyindex.velocity.y
			doEnemyAnimation('fall', enemyindex)
		end
	end

	
	for i, enemyindex in ipairs(enemies) do
		--Process Enemy Thought
		think(enemyindex, player, enemies)

		if enemyindex.isFacingRight and enemyindex.isMoving then  -- Enemy walking right
			if enemyindex.velocity.x < enemyindex.maxspeed then
				enemyindex.isRunning = false
				enemyindex.velocity.x = enemyindex.velocity.x + enemyindex.speed*dt
				doEnemyAnimation("walk", enemyindex)
			elseif enemyindex.velocity.x >= enemyindex.maxspeed and enemyindex.velocity.x < enemyindex.maxspeed*2  and enemyindex.state.wantsToRun then-- Running		
				enemyindex.isRunning = true
				enemyindex.velocity.x = enemyindex.velocity.x + enemyindex.speed*dt
				doEnemyAnimation("run", enemyindex)
			end

			if not enemyindex.isRunning then
				enemyindex.animation.walkanimation:update(dt)
			elseif enemyindex.isRunning then
				enemyindex.animation.runanimation:update(dt)
			end
			
		end
		
		if not enemyindex.isFacingRight and enemyindex.isMoving then -- Enemy should move Left
			if enemyindex.velocity.x > -enemyindex.maxspeed then
				enemyindex.isRunning = false
				enemyindex.velocity.x = enemyindex.velocity.x - enemyindex.speed*dt
				doEnemyAnimation("walk", enemyindex, dt)
			elseif enemyindex.velocity.x <= -enemyindex.maxspeed and enemyindex.velocity.x > -enemyindex.maxspeed*2  and enemyindex.state.wantsToRun then-- Running		
				enemyindex.isRunning = true
				enemyindex.velocity.x = enemyindex.velocity.x - enemyindex.speed*dt
				doEnemyAnimation("run", enemyindex, dt)
			end

			if not enemyindex.isRunning then
				enemyindex.animation.walkanimation:update(dt)
			elseif enemyindex.isRunning then
				enemyindex.animation.runanimation:update(dt)
			end
		end

		applyForces(dt,enemyindex)



		--Fighting Stance
		if enemyindex.state.isFighting then
			doEnemyAnimation("fighting", enemyindex)
			enemyindex.animation.fightingstance:update(dt)
		end

		if not enemyindex.isMoving and not enemyindex.state.isFighting then
			doEnemyAnimation("idle", enemyindex, dt)
			enemyindex.animation.standstillanimation:update(dt)
		end


		--Punch Animations
		if enemyindex.isJabbed then
			doEnemyAnimation("punched", enemyindex)
			enemyindex.animation.jabbed_l1:update(dt)
			if enemyindex.animation.jabbed_l1.status == 'paused' then
				enemyindex.isJabbed = false
				doEnemyAnimation('idle', enemyindex)
				enemyindex.animation.jabbed_l1:resume()
			end
		end

		if enemyindex.isDecked then
			doEnemyAnimation("decked", enemyindex)
			enemyindex.animation.decked_l1:update(dt)
			if enemyindex.animation.decked_l1.status == 'paused' then
				enemyindex.isDecked = false
				doEnemyAnimation('idle', enemyindex)
				enemyindex.animation.decked_l1:resume()
			end
		end

		--Kick Animations
		if enemyindex.isKicked then
			if enemyindex.isJabbed then  --If the player interupts the kick animation with a punch, play that
				enemyindex.isJabbed = true
				enemyindex.isKicked = false
				enemyindex.animation.shinkick_l1:resume()
			end


			if not enemyindex.isJabbed then
				doEnemyAnimation("kicked", enemyindex)
				enemyindex.animation.shinkick_l1:update(dt)
				if enemyindex.animation.shinkick_l1.status == 'paused' then
					enemyindex.isKicked = false
					doEnemyAnimation('idle', enemyindex)
					enemyindex.animation.shinkick_l1:resume()
				end
			end

		end


		if enemyindex.isFrontKicked then
			doEnemyAnimation("frontkicked", enemyindex)
			enemyindex.animation.frontkick_l1:update(dt)
			if enemyindex.animation.frontkick_l1.status == 'paused' then
				enemyindex.isFrontKicked = false
				doEnemyAnimation('idle', enemyindex)
				enemyindex.animation.frontkick_l1:resume()
			end
		end

		--Dancing
		if world.dancetime then
			doEnemyAnimation("dance", enemyindex)
			enemyindex.animation.dance:update(dt)
		end


		
		snapEnemyBoundingBoxes(enemyindex)
	end  --Breaking out of enemies container

end

function doEnemyAnimation(action, indexie)	
	
		if indexie.isMoving then		
			indexie.animation_state = 'walk'
		end
		
		if indexie.isFacingRight == true and indexie.isAnimationFlipped then
			indexie.x = indexie.x + indexie.turnoffset
			for i, enemyindex in pairs(indexie.animation) do
				enemyindex:flipH()
			end
			indexie.isAnimationFlipped = false
		elseif not indexie.isFacingRight and not indexie.isAnimationFlipped then
			indexie.x = indexie.x - indexie.turnoffset
			for i, enemyindex in pairs(indexie.animation) do
				enemyindex:flipH()
			end
			indexie.isAnimationFlipped = true
		end
		


		if action == 'fall' then
			indexie.animation_state = 'idle'
		end

		if action == 'idle' then
			indexie.animation_state = 'idle'
		end

		if action == 'fighting' then
			indexie.animation_state = 'fighting'
		end

		if action == 'run' then
			indexie.animation_state = 'run'
		end

		if action == 'dance' then
			indexie.animation_state = 'dance'
		end

		

		if action == 'punched' then
			indexie.animation_state = 'punched'
		elseif action == 'kicked' then
			indexie.animation_state = 'kicked'	
		elseif action == 'decked' then
			indexie.animation_state = 'decked'
		elseif action == 'frontkicked' then
			indexie.animation_state = 'frontkicked'
		end
end

function checkEnemyRemoval(enemies)
	for i, value in ipairs(enemies) do

		if value.health <= 0 then
			value.isAlive = false
		end

		if value.x > screenwidth or value.x < 0 then
			value.isAlive = false
		elseif value.y > screenheight + 10 or value.y < 0 then
			value.isAlive = false
		end

		--Zero out the variables, remove the bounding boxes and kill the table reference for the enemy
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