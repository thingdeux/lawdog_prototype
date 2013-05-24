local function gaugeDanger(enemyindex, player) --If the player has been spotted this will run
	
	--If the player attacks then the enemy is threatened
	if player.isAttacking then
		return true
	else
		return false
	end

end


local function checkDistanceToPlayer(enemyindex, player)
	local function lookForPlayer(enemyindex, player)
		--If the enemy gets within 200 pixels of the player and the enemy is facing the right way set spotted to yes.
		if enemyindex.isFacingRight then 
			if enemyindex.player_tracker.isOnTheRight and 
				enemyindex.player_tracker.distanceToPlayer_x <= 200 and enemyindex.player_tracker.distanceToPlayer_x > 0 then

				enemyindex.player_tracker.playerSpotted = true
			else
				if enemyindex.player_tracker.playerSpotted then
					enemyindex.player_tracker.playerSpotted = false
				end
			end
		elseif not enemyindex.isFacingRight then
			if not enemyindex.player_tracker.isOnTheRight and
				enemyindex.player_tracker.distanceToPlayer_x >= -300 and enemyindex.player_tracker.distanceToPlayer_x < -50 then				
				enemyindex.player_tracker.playerSpotted = true
			else
				if enemyindex.player_tracker.playerSpotted then
					enemyindex.player_tracker.playerSpotted = false
				end
			end
		end

	end

	local function checkIfNearbyPlayer(enemyindex)
		if enemyindex.isFacingRight and enemyindex.player_tracker.isOnTheRight then
			if enemyindex.player_tracker.distanceToPlayer_x < 50 and enemyindex.player_tracker.distanceToPlayer_x > 0 then
				enemyindex.player_tracker.nearby = true
			else
				enemyindex.player_tracker.nearby = false
			end
		elseif not enemyindex.isFacingRight and not enemyindex.player_tracker.isOnTheRight then
			if enemyindex.player_tracker.distanceToPlayer_x > -200 and enemyindex.player_tracker.distanceToPlayer_x < -100 then
				enemyindex.player_tracker.nearby = true
			else
				enemyindex.player_tracker.nearby = false
			end

		end

	end


	local distancex = math.floor(math.distX(enemyindex.x + enemyindex.boundingbox.offset_moveto_entity_right_x + 10, 
				 player.x) )

	local distancey = math.floor(math.distX(enemyindex.y + 50, player.y) )

	if enemyindex.x > player.x then
		enemyindex.player_tracker.distanceToPlayer_x = -distancex
		enemyindex.player_tracker.isOnTheRight = false
	elseif enemyindex.x < player.x then
		enemyindex.player_tracker.distanceToPlayer_x = distancex
		enemyindex.player_tracker.isOnTheRight = true
	end

	if enemyindex.y > player.y then
		enemyindex.player_tracker.distanceToPlayer_y = distancey
		enemyindex.player_tracker.isBelowPlayer = true
	elseif enemyindex.y < player.y then
		enemyindex.player_tracker.distanceToPlayer_y = -distancey
		enemyindex.player_tracker.isBelowPlayer = false
	end

	lookForPlayer(enemyindex, player)
	checkIfNearbyPlayer(enemyindex)

end

local function battleTime(enemyindex, player)

	if enemyindex.isMoving and enemyindex.isFacingRight then
		enemyindex.isMoving = false
		enemyindex.velocity.x = enemyindex.velocity.x - 80
		enemyindex.state.isFighting = true
	elseif enemyindex.isMoving and not enemyindex.isFacingRight then
		enemyindex.isMoving = false
		enemyindex.velocity.x = enemyindex.velocity.x + 80
		enemyindex.state.isFighting = true
	else 
		enemyindex.state.isFighting = true
	end

	local function amIGoodEnoughToDodge(enemyindex, player)
		enemyindex.dodged = false
		local dodgeChance = math.random(100)
		
		for i, dodgetype in pairs(enemyindex.canDodge) do
			if dodgetype == player.action then
				if dodgeChance > 90 then						
					enemyindex.dodged = true
				end
			end
		end
	end

	local function shouldIKeepFighting(enemyindex, player)
		if enemyindex.health > 10 then
			return true
		else
			return false
		end
	end

	local function shouldIAttack(enemyindex, player)
	end

	if enemyindex.player_tracker.nearby then
		if player.isAttacking then			
			amIGoodEnoughToDodge(enemyindex, player)

		elseif shouldIAttack then

		elseif shouldIKeepFighting then
		

		end
	end

end



local function closeDistanceToPlayer(enemyindex, player)

	enemyindex.state.wantsToRun = true
	
	if enemyindex.player_tracker.isOnTheRight and not enemyindex.player_tracker.nearby then
		enemyindex.isMoving = true		
		enemyindex.isFacingRight = true
	elseif not enemyindex.player_tracker.isOnTheRight then
		enemyindex.isMoving = true
		enemyindex.isFacingRight = false
	end

end

function think(enemyindex, player)

	if enemyindex.player_tracker.playerSpotted then  --If the enemy has been spotted
		checkDistanceToPlayer(enemyindex, player)
		
		if not enemyindex.state.isThreatened then
			enemyindex.state.isThreatened = gaugeDanger(enemyindex, player)
		end

		if enemyindex.state.isThreatened then

			if enemyindex.player_tracker.nearby then
				battleTime(enemyindex, player)				
			elseif not enemyindex.player_tracker.nearby then
				closeDistanceToPlayer(enemyindex, player)
			end
		end

	elseif not enemyindex.player_tracker.playerSpotted then  --If the enemy hasn't spotted the player
		checkDistanceToPlayer(enemyindex, player)			--Check the distance to the player
	end	



end





--[[
Enemy AI States:
	Idle ->
		playerSpotted? 
Yes: -> playerSpotted
No: nearEnemy?
	Yes: talkAnimation (to enemy) - walk other enemy through tree to see if they talk back

playerSpotted ->
		Yes: checkDistanceToPlayer
			Within Range of Player: enemyIsAggresive
								Yes:  battleTime
							No: gaugeDanger (Loop)
		No: closeDistanceToPlayer
								
		
	battleTime -> 
			isPlayerAttacking?
				Yes: amIGoodEnoughToDodge? (func to check Table of attacks the character can dodge/block)
Yes: chanceCalculater (includes luck and maybe speed of character reactions)
No: Ow! if I’m not aggresive, set enemyIsAggresive flag to yes
	shouldIKeepFighting? (Health is too low and are weapons or backup are nearby)
							No: 

]]--

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.distX(x1, x2) return ( (x2-x1)^2)^0.5 end
function math.distY(y1, y2) return ((y2-y1)^2)^0.5 end


