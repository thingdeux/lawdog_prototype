
--Enemy Functions
function snapEnemyBoundingBoxes(index)
	
	if index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 2, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 2, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
	elseif not index.isFacingRight then
		index.boundingbox.level:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 12, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_main:moveTo(index.x + index.boundingbox.offset_moveto_level_x + 12, index.y + index.boundingbox.offset_moveto_level_y)
		index.boundingbox.entity_top_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_top_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_top_y)
		index.boundingbox.entity_bottom_right:moveTo(index.x + index.boundingbox.offset_moveto_entity_right_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)
		index.boundingbox.entity_bottom_left:moveTo(index.x + index.boundingbox.offset_moveto_entity_left_x+15, index.y + index.boundingbox.offset_moveto_entity_bottom_y)

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
		think(enemyindex, player)

		if enemyindex.isFacingRight and enemyindex.isMoving then  -- Enemy walking right
			if enemyindex.velocity.x < enemyindex.maxspeed then
				enemyindex.isRunning = false
				enemyindex.velocity.x = enemyindex.velocity.x + enemyindex.speed*dt
				doEnemyAnimation("walk", enemyindex)
			elseif enemyindex.velocity.x >= enemyindex.maxspeed and enemyindex.velocity.x < enemyindex.maxspeed*2  and enemyindex.wantsToRun then-- Running		
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
			elseif enemyindex.velocity.x <= -enemyindex.maxspeed and enemyindex.velocity.x > -enemyindex.maxspeed*2  and enemyindex.wantsToRun then-- Running		
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

		if not enemyindex.isMoving then
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

		if action == 'run' then
			indexie.animation_state = 'run'
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