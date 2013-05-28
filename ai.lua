local function gaugeDanger(enemyindex, player) --If the player has been spotted this will run
	
	--If the player attacks then the enemy is threatened
	if player.isAttacking then
		return true
	else
		return false
	end

end

local function within(y, y1, distance)
	if y >= y1 - distance and y <= y1 + distance then
		return true
	elseif y1 >= y - distance and y1 <= y + distance  then
		return true
	else
		return false
	end
end

local function isNear(indexA, indexB , distance)
	local distanceX = math.distX(indexA.x, indexB.x)
	local distanceY = math.distY(indexA.y, indexB.y)


	if within(indexA.y, indexB.y, 10) then
		if within(indexA.x, indexB.x, 20) then
 			print("A: " .. tostring(indexA.x) .. "B:" .. tostring(indexB.x))
			indexA.state.closeToAlly = true
			indexB.state.closeToAlly = true
			return true
		else
			indexA.state.closeToAlly = false
			indexB.state.closeToAlly = false
			return false
		end
		
	end
end

local function runFromPlayer(enemyindex, player)

	if enemy.player_tracker.isOnTheRight then
		if enemy.isFacingRight then
			enemy.isFacingRight = false
		elseif not enemy.player_tracker.isOnTheRight then
			if not enemy.isFacingRight then
				enemy.isFacingRight = true
			end
		end
		enemy.wantsToRun = true
		enemy.isMoving = true
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
		local chanceToAttack = math.random(100)

		if chanceToAttack > 70 then
			
		end


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

function think(enemyindex, player, enemies)

	if enemyindex.player_tracker.playerSpotted then  --If the player has been spotted
		checkDistanceToPlayer(enemyindex, player)
		
		if not enemyindex.state.isThreatened then  --Check to see if enemy has found danger
			enemyindex.state.isThreatened = gaugeDanger(enemyindex, player)
		end

		if enemyindex.state.isThreatened then --If the enemy feels threatened

			if enemyindex.personality == 'Coward' then
				coward(enemyindex, player, enemies)
			end

			if enemyindex.player_tracker.nearby then
				--battleTime(enemyindex, player)				
			elseif not enemyindex.player_tracker.nearby then
				--closeDistanceToPlayer(enemyindex, player)
			end
		end

	elseif not enemyindex.player_tracker.playerSpotted then  --If the enemy hasn't spotted the player
		checkDistanceToPlayer(enemyindex, player)			--Check the distance to the player
	end	

end

function curiousKitty (enemyindex, player, enemies)

end

function coward(enemyindex, player, enemies)
	local doIHaveBackup = false
	
	--Check to see if someone is near
	for i, enemy in ipairs(enemies) do 
		if #enemies > 1 then
			doIHaveBackup = isNear(enemyindex, enemy)
		end
	end

	if doIHaveBackup then
		--battleTime(enemyindex, player)
		print ("I have backup")
	elseif not doIHaveBackup then
		--runFromPlayer(enemyindex, player)
		print ("I'm running")
	end


	

end

function dumbPunk(enemyindex, player)
end

function sneakyDouche(enemyindex, player)
end

function cautiousKitty(enemyindex, player)
end

function meatBag(enemyindex, player)
end

function smartieMcFarty(enemyindex, player)
end


--[[
CautiousKitty - Mostly defensive, if alone will only parry and reposte else DP
	After threatened closetodistance of 200 feet then get in defensive stance
	If no enemies are within 200 feet of you stay in defense stance and wait for an attack
	If attacked run percentage to dodge and if you dodge succesfully return an attack
	*Chance to combo
	Back to the top


Coward - Runs from the player unless there's backup then turns into DP
	If threatened and not within 200 feet of another enemy put distance between player and self
	If more than one enemy is around attack as DP - lower dodge chance

DumbPunk - Runs at the player with flurries of punches
	If threatened runs full bore throwing punches - does not stop for go does not collect 200 dollahs

MeatBag - Used to drain the players energy...takes a ton of hits
	Occasionally throws punches at random and takes lots of damage

SneakyDouche - Tries to get behind the player and hold them

SmartieMcFarty - Smart enemy



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