local tiny = require("tiny")
local logs = {}

-- Talking System
local talkingSystem = tiny.processingSystem()
talkingSystem.filter = tiny.requireAll("id", "name", "mass", "phrase")

function talkingSystem:process(e, dt)
	e.mass = e.mass + (dt * 3)
	local strLogMessaage = ("%s who weighs %d pounds, says %q."):format(e.name, e.mass, e.phrase)
	logs[e.id] = "[LOG]: "..strLogMessaage
	print(strLogMessaage)
end

-- Movement System
local movementSystem = tiny.processingSystem()
movementSystem.filter = tiny.requireAll("position", "moveDirection", "velocity")

function movementSystem:process(e, dt)
	e.velocity.x = (e.moveDirection.x * e.moveSpeed)
	e.velocity.y = (e.moveDirection.y * e.moveSpeed)
	e.position.x = e.position.x + (e.velocity.x * dt)
	e.position.y = e.position.y + (e.velocity.y * dt)
end

-- Entity
local someEntity = {
	id = 0,
	name = "John, Smith",
	phrase = "I'm gonna save the world.",
	mass = 64,
	hariColor = "brown"
}

local circleEntity = {
	moveSpeed = 600,
	position = {
		x = 400,
		y = 200
	},
	moveDirection = {
		x = 0,
		y = 0
	},
	velocity = {
		x = 10,
		y = 0
	},
	shape = "circle",
	radius = 40,
	segment = 50,
	color = {
		r = 1,
		g = 1,
		b = 1,
		a = 1
	}
}

local testWorld = tiny.world(talkingSystem, someEntity)
local gameWorld = tiny.world(movementSystem, circleEntity)

function love.load(args)
	print("*** Begin Loading ***")
	love.window.setFullscreen(true)
	--[[
	print("*** System: Test World ***")
	for i = 1, 10 do
		testWorld:update(1)
	end
	]]--
	for i = 1, 10 do
		print(("Test stdout on android (logcat) : %d"):format(i))
	end
	print("*** End Loading ***")
end

-- TODO : add input system
function love.update(dt)
	local direction = { x, y }

	if love.keyboard.isDown("left") then
		-- print("Pressed : left")
		direction.x = -1
	elseif love.keyboard.isDown("right") then
		-- print("Pressed : right")
		direction.x = 1
	else
		direction.x = 0
	end

	if love.keyboard.isDown("up") then
		-- print("Pressed : up")
		direction.y = -1
	elseif love.keyboard.isDown("down") then
		-- print("Pressed : down")
		direction.y = 1
	else
		direction.y = 0
	end

	magnitude = math.sqrt((direction.x * direction.x) + (direction.y * direction.y))

	if magnitude > 1.0 then
		direction.x = (direction.x / magnitude)
		direction.y = (direction.y / magnitude)
	end

	circleEntity.moveDirection = direction
	gameWorld:update(dt)
end

-- TODO : add render system
function love.draw()
	love.graphics.clear(0, 0, 1, 1)
	love.graphics.print(("FPS: %.1f"):format(love.timer.getFPS()), 20, 20)
	love.graphics.print(("X: %.3f"):format(circleEntity.position.x), 20, 50)
	love.graphics.print(("Y: %.3f"):format(circleEntity.position.y), 20, 80)

	love.graphics.setColor(circleEntity.color.r, circleEntity.color.g, circleEntity.color.b, circleEntity.color.a)
	--love.graphics.circle("fill", circleEntity.position.x, circleEntity.position.y, 40, 100)
	love.graphics.circle("fill", circleEntity.position.x, circleEntity.position.y, circleEntity.radius, circleEntity.segment)
	--[[
	local offsetY = 10
	for index, value in pairs(logs) do
		love.graphics.print(value, 300, (100 + offsetY))
		offsetY = offsetY + 4
	end
	]]--
end
