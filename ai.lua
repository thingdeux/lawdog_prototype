local function gaugeDanger(enemyindex, player)
end

local function checkDistanceToPlayer(enemyindex, player)
	local distancex = math.floor(math.distX(enemyindex.x + enemyindex.boundingbox.offset_moveto_entity_right_x + 10, 
				 player.x) )

	local distancey = math.floor(math.distX(enemyindex.y + 50, player.y) )

	if enemyindex.x > player.x then
		enemyindex.player_tracker.distanceToPlayer_x = -distancex
	elseif enemyindex.x < player.x then
		enemyindex.player_tracker.distanceToPlayer_x = distancex
	end

	if enemyindex.y > player.y then
		enemyindex.player_tracker.distanceToPlayer_y = distancey
	elseif enemyindex.y < player.y then
		enemyindex.player_tracker.distanceToPlayer_y = -distancey
	end

end

local function battleTime(enemyindex, player)
end


function think(enemyindex, player)

	if enemyindex.player_tracker.playerSpotted then
	
		checkDistanceToPlayer(enemyindex, player)
	elseif not enemyindex.player_tracker.playerSpotted then
		checkDistanceToPlayer(enemyindex, player)
		--print("Not spotted")
	end
		

end





--[[
31 - 3rd Floor

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


