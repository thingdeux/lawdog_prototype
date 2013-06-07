local anim8 = require ("/libraries/anim8")
HC = require '/libraries/hardoncollider'
local Camera = require("/libraries/camera")
local AI = require ("ai")
local enemies = require("enemies")
local collision = require("collision")
local playa = require("player")

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
	cam = Camera(screenwidth /2, screenheight/2, 1.1)
	
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
    for i, animation in pairs(player.animations) do
		animation:update(dt)
	end
	
	if love.keyboard.isDown("a") then
		doPlayerAnimation('a',dt)
	end
	if love.keyboard.isDown("d") then
		doPlayerAnimation('d',dt)
	end

	if love.keyboard.isDown("s") then

		if player.canEnterStairs and not player.isOnStairs then
			player.isOnStairs = true
			player.y = player.y + 30
		end
		snapPlayerBoundingBoxes()
	end
	if love.keyboard.isDown("w") then
		if player.canEnterStairs then
			player.isOnStairs = true
		end		
	end
	if love.keyboard.isDown("lshift") then
		player.isRunning = true
	end

	
	doPlayerProcessing(dt)
	doEnemyProcessing(dt, enemies)	
	Collider:update(dt)	
    entityCollider:update(dt)
    updateCamera(dt)


end  --End Updated function

function passEnemies()	
	return enemies
end

function updateCamera(dt)

	if not world.inACinematic then
		if player.x < 515 then
			cam:lookAt(515, player.y - 120)
		elseif player.x >= 716 then
			cam:lookAt(716, player.y - 120)
		else
			cam:lookAt(player.x, player.y - 120)
		end
	end

end


function love.draw()
	--cam:attach()  --Attach the camera

	--Draw Background and UI Elements
	love.graphics.draw(background, 0, 0)
	love.graphics.setColor(1000,0,0, 255)
	love.graphics.print("Button 1-3 will spawn enemies", screenwidth - 300, 40)
	love.graphics.print("F1 Turns on player debug information", screenwidth - 300, 60)
	love.graphics.print("F2 Turns on enemy debug information", screenwidth - 300, 80)
	love.graphics.print("F3 Turns on collision level debug information", screenwidth - 300, 100)
	love.graphics.print("F4 Turns on collision entity debug information", screenwidth - 300, 120)
	love.graphics.print("F6 Turns off AI", screenwidth - 300, 140)

	love.graphics.setColor(1000,0,0, 255)
	if player.isFacingRight then  --Draw player energy	
		love.graphics.print("Energy: " .. tostring(player.energy), player.x+16, player.y+15, math.rad(90))
		love.graphics.print("Health: " .. tostring(player.health), player.x+26, player.y+15, math.rad(90))
	else		
		love.graphics.print("Energy: " .. tostring(player.energy), player.x + 90, player.y+15, math.rad(90))
		love.graphics.print("Health: " .. tostring(player.health), player.x+100, player.y+15, math.rad(90))
	end

	--Reset colors for the rest of the drawing
	love.graphics.setColor(255,255,255, 255)

	--Draw Player variables if debug flag is set
	if world.debug.player then
		love.graphics.print("Velocity: " .. tostring(player.velocity.x), 340,40)
		love.graphics.print("Status: " .. tostring(player.animations.jab.status), 340,50)
		love.graphics.print("isAttacking: " .. tostring(player.isAttacking), 340,60)
		love.graphics.print("Player X: " .. tostring(player.x) .. "Player Y: " .. tostring(player.y), 340,70)		
		love.graphics.print("isStairs: " .. tostring(player.isOnStairs), 340,90, math.rad(30))
	end

	--Draw Player animations
	if player.animation == 'walk' and not player.isAttacking then
		player.animations.walkanimation:draw(playersheet, player.x,player.y)
	elseif player.animation == 'idle' and not player.isAttacking then
		player.animations.standstill:draw(playersheet, player.x,player.y)
	elseif player.isAttacking and player.action == "jab" then
		player.animations.jab:draw(playersheet, player.x, player.y)
	elseif player.isAttacking and player.action == "cross" then
		player.animations.cross:draw(playersheet, player.x, player.y)
	elseif player.isAttacking and player.action == "hook" then
		player.animations.cross:draw(playersheet, player.x, player.y)
	elseif player.isAttacking and player.action == "kick" then
		player.animations.kick:draw(playersheet, player.x, player.y)
	elseif player.isAttacking and player.action == "frontkick" then
		player.animations.frontkick:draw(playersheet, player.x, player.y)		
	end

	--Draw Enemies
	for i, value in ipairs(enemies) do
		
		if value.animation_state == 'idle' then
			value.animation.standstillanimation:draw(enemysheet, value.x,value.y)
		elseif value.animation_state == 'walk' then
			value.animation.walkanimation:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'run' then
			value.animation.runanimation:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'punch' then
			value.animation.punch:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'punched' then
			value.animation.jabbed_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'kicked' then
			value.animation.shinkick_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'decked' then
			value.animation.decked_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'frontkicked' then
			value.animation.frontkick_l1:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'fighting' then
			value.animation.fightingstance:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'dance' then
			value.animation.dance:draw(enemysheet, value.x, value.y)
		elseif value.animation_state == 'dodge' then
			value.animation.dodge:draw(enemysheet, value.x, value.y)
		end		

		if world.debug.enemies then			
			
			local ix = 0 -- Variable for the state tables to display properly
			--Check the state table and display any true values above the enemy
			for i,values in pairs(value.player_tracker) do
				if values then
					love.graphics.print(tostring(i) .. ": " .. tostring(values), value.x, value.y - ix)
					ix = ix + 10
				end
			end
			
			--Check the state table and display any true values above the enemy
			for i,values in pairs(value.state) do
				if values then
					love.graphics.print(tostring(i) .. ": " .. tostring(values), value.x, value.y - ix)
					ix = ix + 10
				end
			end

		end
	end

	if world.debug.collision_entity then
		--Draw player Entity collision stuff
		love.graphics.setColor(255,255,12, 255)
		player.boundingbox.entity_main:draw('line')
		love.graphics.setColor(255,player.boundingbox.fist_color,player.boundingbox.fist_color, 255)
		player.boundingbox.fist_box:draw('line')
		player.boundingbox.foot_box:draw('line')
		love.graphics.setColor(255,255,255, 255)
		--player.boundingbox.entity_top_left:draw('line')
		--player.boundingbox.entity_top_right:draw('line')
		--player.boundingbox.entity_bottom_left:draw('line')
		--player.boundingbox.entity_bottom_right:draw('line')

		--Draw Enemy Entity collision boxes
		for i, enemy in ipairs(enemies) do

			enemy.boundingbox.entity_main:draw('line')
			--love.graphics.setColor(255,enemy.boundingbox.fist_color,enemy.boundingbox.fist_color, 255)
			--enemy.boundingbox.fist_box:draw('line')
			--enemy.boundingbox.entity_top_left:draw('line')
			--enemy.boundingbox.entity_top_right:draw('line')
			--enemy.boundingbox.entity_bottom_left:draw('line')
			--enemy.boundingbox.entity_bottom_right:draw('line')		
			love.graphics.setColor(255,255,255, 255)
		end

		for i = 1,#world.debugtext.entity do
        	--love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        	love.graphics.print(world.debugtext.entity[#world.debugtext.entity - (i-1)], 10, i * 15)
    	end
	end

	--Draw World Bounding Boxes if debug flag is set
	if world.debug.collision_level then
		for i, box in ipairs(world.levelContainer) do
			love.graphics.setColor(255,255,255, 255)
			if checkCollisionContainers(world.stairContainer, box) then
				love.graphics.setColor(100,255,255, 255)
			elseif checkCollisionContainers(world.stairEntryContainer, box) then
				love.graphics.setColor(255,255,51,255)
			end
			box:draw('line')
		end
		
		love.graphics.setColor(255,255,255, 255)
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
	--cam:detach()  -- Detach the camera

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
	if key == "f5" then
		local state = not world.dancetime
		world.dancetime = state
	end
	if key == "f6" then
		local state = not world.isAIEnabled
		world.isAIEnabled = state
	end


	if key == "c" then
		cam:zoomTo(2)
	elseif key == "g" then
		cam:zoomTo(1)
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

	if player.energy > 0 then
		if key == "e" and (love.keyboard.isDown("a") or love.keyboard.isDown("d") ) then -- Hook
			player.action = "hook"
			player.energy = player.energy - 2
		elseif key == " " and (love.keyboard.isDown("a") or love.keyboard.isDown("d") ) then -- Front Kick
			player.action = "frontkick"
			player.energy = player.energy - 2
		elseif key == "e" and player.action == "jab" then
			player.action = "cross"
			player.isAttacking = false
			player.energy = player.energy - 1
		elseif key == "e" and player.action == "cross" then
			player.action = "jab"
			player.isAttacking = false
			player.energy = player.energy - 1
		elseif key == "e" then
			player.action = "jab"
			player.energy = player.energy - 1
		elseif key == " " then  --Spacebar
			player.action = "kick"
			player.energy = player.energy - 0.5
		end
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

	if key == "lshift" then
		player.isRunning = false
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		mousex = love.mouse.getX()
		mousey = love.mouse.getY()
	end

	if button == "r" then
		player.isOnGround = false
		player.isOnStairs = false
	end
end

function load_graphics()
	--Load Graphics and init animations	
	enemysheet = love.graphics.newImage("/assets/enemy_sheet.png")
	background = love.graphics.newImage("/assets/Background.png")
	playersheet = love.graphics.newImage("/assets/player_sheet.png")
	enemygrid = anim8.newGrid(90,100, enemysheet:getWidth(), enemysheet:getHeight())
	playergrid = anim8.newGrid(99, 110, playersheet:getWidth(), playersheet:getHeight(), 3, 0)
	local crossspeed = 0.18
	local hookspeed = 0.6
	local kickspeed = 0.3
	local frontkickspeed = 0.4
	local jabspeed = .18

	--Medium Enemy animation loads and designations
	mediumenemystandstill = anim8.newAnimation(enemygrid(3,3, 2,4, 1,5, 4,3, 3,4 ), 0.3)
	mediumenemyfightingstance = anim8.newAnimation(enemygrid(5,5), 0.3)
	mediumenemydance = anim8.newAnimation(enemygrid('2-5',1,'2-2', 2,'3-4', 2), 0.14)
	mediumenemyrunanimation = anim8.newAnimation(enemygrid(8,2,7,3,6,4,10,1,9,2,8,3,7,4,6,5,11,1,10,2,9,3,8,4,7,5,11,2,10,3,9,4,8,5), 0.04)
	mediumenemywalkanimation = anim8.newAnimation(enemygrid(1,7,3,6,2,7,1,8,4,6,3,7,2,8,1,9,5,6,4,7,3,8,2,9), 0.1)
	mediumenemypunch = anim8.newAnimation(enemygrid(3, 1), .4)
	mediumenemystunned = anim8.newAnimation(enemygrid(11,3,	10,4,9,5,11,4,10,5,	11,5,1,6,2,6), 0.1)
	mediumenemyjabbed_l1 = anim8.newAnimation(enemygrid(2,5, 5,3, 4,4, 4,4, 5,3, 2,5), 0.03, 'pause')	
	mediumenemyjabbed_l2 = anim8.newAnimation(enemygrid(2,5, 5,3, 4,4, 3,5, 5,4, 5,4,5,4, 3,5, 4,4, 5,3, 2,5), 0.03, 'pause') -- 5,4's in the middle are neck snapped back
	mediumenemyshinkick_l1 = anim8.newAnimation(enemygrid(3,2, 3,2, 4,2,4,2,4,2, 3,2), 0.2, 'pause')
	mediumenemydecked_l1 = anim8.newAnimation(enemygrid(1,1, 2,1, 1,2, 2,1, 1,1), 0.05, 'pause')
	mediumenemydecked_l2 = anim8.newAnimation(enemygrid(1,1, 2,1, 1,2, 2,2, 3,1, 2,2, 1,2, 2,1, 1,1), .046, 'pause')
	mediumenemydecked_l3 = anim8.newAnimation(enemygrid(4,1,3,2,5,1,4,2,5,2,1,3,2,3,1,4,6,2,8,1,7,2,6,3,9,1,11,4,10,5,11,5,1,6,2,6,1,6,11,5,10,5,11,4,9,5,10,4,11,3), 0.1, 'pause')
	mediumenemyfrontkick_l1 = anim8.newAnimation(enemygrid(9,1, 8,1, 4,2, 5,1), 0.08, 'pause')
	mediumenemydodge = anim8.newAnimation(enemygrid(1,3), .2)

	--Main Player Graphics
	mainPlayer_standstill = anim8.newAnimation(playergrid(1,1, 2,1, 1,2), 0.3)
	mainPlayer_walkanimation = anim8.newAnimation(playergrid(3,3, 2,4, 4,3, 3,4, 5,3, 4,4), 0.12)
	mainPlayer_jab = anim8.newAnimation(playergrid(3,1, 4,1, 4,1), {0.03, jabspeed/2 +8,0.03} )
	mainPlayer_cross = anim8.newAnimation(playergrid(4, 2), 0.4, 'pause')
	mainPlayer_kick = anim8.newAnimation(playergrid(5,2, 1,3), {kickspeed/2,kickspeed/2 + .5} )
	mainPlayer_frontkick = anim8.newAnimation(playergrid(2,3, 1,4, 2,3), {0.08,frontkickspeed/2, frontkickspeed/2})
end



function create_world()
	--Create Debugtext containers

	world = {}
	world.debugtext = {}
	world.debugtext.level = {}
	world.debugtext.entity = {}
	world.dancetime = false
	world.inACinematic = false
	world.isAIEnabled = true

	--Debug flags
	world.debug = {}
	world.debug.player = false
	world.debug.enemies = false
	world.debug.collision_level = false
	world.debug.collision_entity = false

	--Level Geometry and collision box creation	
	world.leftwall = Collider:addRectangle(0, 20, 60, screenheight -20)
	world.rightwall = Collider:addRectangle(900, 423, 40, screenheight -20)
	world.roof = Collider:addRectangle(0, 0, screenwidth, 20)
	world.ground = Collider:addRectangle(60,600, screenwidth - 64, 20)
	world.secondFloor = Collider:addRectangle(60, 305, 1020, 30)
	world.stairsTop = Collider:addPolygon( 620, 492,   --Bottom Left
									   	   940,240, 	--Top Right
									   	   740, 290)   --Top Left
									   	    --700, 300)		   --Top Left

	world.stairsBottom = Collider:addPolygon( 640, 602,   --Bottom Left
									   		  1020,300, 	--Top Right
									   		  734, 580 )  --Bottom Right
	world.stairsBottomEntry = Collider:addPolygon(630, 493,
												630, 600,
												635, 600,
												640, 478)
	world.stairsTopEntry = Collider:addPolygon(940, 240,
												900, 290,
												945, 281,
												945, 280)
	world.stairsTerminateBottom = Collider:addPoint(600, 580)
	world.stairsTerminateTop = Collider:addPoint(1000, 220)
	
	--*****Make sure to put any newly created bounding boxes in this container
	world.levelContainer = {world.leftwall, world.rightwall, world.roof, world.ground, 
							world.secondFloor, world.stairsBottom, world.stairsTop, 
							world.stairsBottomEntry,world.stairsTopEntry,
							world.stairsTerminateBottom, world.stairsTerminateTop}
	
	--****Make sure to put all ground collision boxes in this container
	world.groundContainer = {world.ground, world.secondFloor}
	--****Make sure to put all wall collision boxes in this container
	world.wallContainer = {world.leftwall, world.rightwall}
	--****Make sure to put all stair collision boxes in this container
	world.stairContainer = {world.stairsBottom, world.stairsTop}
	--****Make sure to put all stair entry collision boxes in this container
	world.stairEntryContainer = {world.stairsBottomEntry, world.stairsTopEntry}
	--****Make sure to put all stair termination points in this container
	world.stairTerminationContainer = {world.stairsTerminateBottom, world.stairsTerminateTop}
	for i, box in ipairs(world.levelContainer) do
		Collider:addToGroup("level", box)
		Collider:setPassive(box)
	end

	world.level = 1
	world.gravity = 50
	world.terminalVelocity = 150
	world.windResistance = 20
	world.spawnLocations = {{215, 514},
							{509, 536},
							{403, 510},
							--{993, 227},
							{191, 540} }
end