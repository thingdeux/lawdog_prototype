--Player Functions
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

function playerAttack(attacktype, dt)

	local function forwardMotionOnAction(typeofaction)
		local speed = 0
		if typeofaction == 'kick' then
			speed = 60
		elseif typeofaction == 'frontkick' then
			speed = 80
		elseif typeofaction == 'hook' then
			speed = 80
		elseif typeofaction == 'cross' then
			speed = 45
		end

		if player.isFacingRight then
			player.velocity.x = player.velocity.x + speed
		else
			player.velocity.x = player.velocity.x - speed
		end

	end
	
	local function isTheShapeAGhost(colliderInstance, shape)
		for i, value in pairs(colliderInstance._active_shapes) do -- Iterate over active
			if value == shape then --Do you find the shape?
				return true
			end
		end

		return false
	end

	local function doAttack(speed,boundingbox, stop)

		if not stop then
			player.animTimer = love.timer.getTime() + speed
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

	if attacktype == "jab" and player.isAttacking == false then
		player.animations.jab:gotoFrame(1)
		doAttack(player.jabspeed,player.boundingbox.fist_box, false)		
	elseif attacktype == "jab" and player.isAttacking and love.timer.getTime() > player.animTimer then				
		doAttack(player.jabspeed,player.boundingbox.fist_box, true)
	end

	if attacktype == "cross" and player.isAttacking == false then
		player.animations.cross:gotoFrame(1)
		forwardMotionOnAction('cross') --Give the player some forward motion when they hook punch
		doAttack(player.crossspeed, player.boundingbox.fist_box, false)
	elseif attacktype == "cross" and player.isAttacking and love.timer.getTime() > player.animTimer then		
		doAttack(player.crossspeed,player.boundingbox.fist_box, true)
	end

	if attacktype == 'hook' and player.isAttacking == false and love.timer.getTime() > player.animTimer then
		player.animations.cross:gotoFrame(1)
		forwardMotionOnAction('hook') --Give the player some forward motion when they hook punch
		doAttack(player.hookspeed,player.boundingbox.fist_box, false)
	elseif attacktype == 'hook' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		doAttack(player.hookspeed,player.boundingbox.fist_box, true)
	end

	if attacktype == 'kick' and player.isAttacking == false then
		player.animations.kick:gotoFrame(1)		
		forwardMotionOnAction('kick') --Give the player some forward motion when they kick
		doAttack(player.kickspeed, player.boundingbox.foot_box, false)
	elseif attacktype == 'kick' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
		doAttack(player.kickspeed, player.boundingbox.foot_box, true)
	end

	if attacktype == 'frontkick' and player.isAttacking == false then
		player.animations.frontkick:gotoFrame(1)		
		forwardMotionOnAction('frontkick') --Give the player some forward motion when they frontkick
		doAttack(player.frontkickspeed, player.boundingbox.foot_box, false)
	elseif attacktype == 'frontkick' and player.isAttacking == true and love.timer.getTime() > player.animTimer then
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
			player.action == "kick" or player.action == "frontkick" or 
			player.action == "cross" then --The action is an attack

			playerAttack(player.action, dt)
		end
	end

	if player.isOnGround == false then		
		player.y = player.y + player.velocity.y
		doPlayerAnimation('fall',dt)
		snapPlayerBoundingBoxes()
	end
	
end

function snapPlayerBoundingBoxes()
	
		if player.isFacingRight then
			player.boundingbox.level:moveTo(player.x + player.boundingbox.offset_moveto_level_x + 4, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_main:moveTo(player.x + player.boundingbox.offset_moveto_level_x + 4, player.y + player.boundingbox.offset_moveto_level_y)

			player.boundingbox.entity_top_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_top_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_bottom_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.entity_bottom_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)

			player.boundingbox.fist_box:moveTo(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_fist_y*2)
			player.boundingbox.foot_box:moveTo(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_foot_y)
		else
			player.boundingbox.level:moveTo(player.x + player.boundingbox.offset_moveto_level_x, player.y + player.boundingbox.offset_moveto_level_y)
			player.boundingbox.entity_main:moveTo(player.x + player.boundingbox.offset_moveto_level_x, player.y + player.boundingbox.offset_moveto_level_y)

			player.boundingbox.entity_top_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_top_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_top_y)
			player.boundingbox.entity_bottom_right:moveTo(player.x + player.boundingbox.offset_moveto_entity_right_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)
			player.boundingbox.entity_bottom_left:moveTo(player.x + player.boundingbox.offset_moveto_entity_left_x, player.y + player.boundingbox.offset_moveto_entity_bottom_y)

			player.boundingbox.fist_box:moveTo(player.x + 14, player.y + player.boundingbox.offset_moveto_fist_y*2)
			player.boundingbox.foot_box:moveTo(player.x + 14, player.y + player.boundingbox.offset_moveto_foot_y)

		end
end

function create_player()
	player = {}
	player.x = 300
	player.y = 400
	player.health = 100
	player.jabspeed = .18
	player.crossspeed = .18
	player.hookspeed = .6
	player.kickspeed = .3
	player.frontkickspeed = .4
	player.animations = {}
	player.animations.standstill = mainPlayer_standstill:clone()
	player.animations.walkanimation = mainPlayer_walkanimation:clone()
	player.animations.jab = mainPlayer_jab:clone()
	player.animations.cross = mainPlayer_cross:clone()
	player.animations.kick = mainPlayer_kick:clone()
	player.animations.frontkick = mainPlayer_frontkick:clone()


	player.punchDamage = 25
	player.punchMultiplier = 1
	player.kickDamage = 12.5
	player.kickMultipler = 1

	player.isOnGround = false
	player.action = 'idle'
	player.speed = 600
	

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
	player.isHit = false
	player.animTimer = 0
	player.isAttacking = false
	player.boundingbox = {}

	--Offset measurements for snapping the bounding box to the player
	player.turnoffset = 0
	player.boundingbox.offset_moveto_fist_x = 84
	player.boundingbox.offset_moveto_fist_y = 26
	player.boundingbox.offset_moveto_foot_y = 80
	player.boundingbox.fist_color = 120
	player.boundingbox.offset_moveto_entity_left_x = 60
	player.boundingbox.offset_moveto_entity_top_y = 25
	player.boundingbox.offset_moveto_entity_right_x = 40 
	player.boundingbox.offset_moveto_entity_bottom_y = 75
	player.boundingbox.offset_moveto_level_x = 46
	player.boundingbox.offset_moveto_level_y = 55
	player.boundingbox.level_sizeX = 46
	player.boundingbox.level_sizeY = 90
	player.boundingbox.entity_sizeX = 20
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
	player.boundingbox.foot_box = entityCollider:addRectangle(player.x + player.boundingbox.offset_moveto_fist_x, player.y + player.boundingbox.offset_moveto_foot_y, 15, 15)
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