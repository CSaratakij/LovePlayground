local tiny = require("lib/tiny")
local tactile = require("lib/tactile")
local baton = require("lib/baton")

local shouldShowStat = true

-- Input
local input = baton.new {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    action = {'key:x', 'button:a'},
    toggleStat = {'key:f1'}
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}

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
	for i = 1, 10 do
		print(("Test stdout on android (logcat) : %d"):format(i))
	end
	print("*** End Loading ***")
end

-- TODO : add input system
function love.update(dt)
	input:update()

	if input:pressed("toggleStat") then
		shouldShowStat = not shouldShowStat
	end

	local x, y = input:get("move")
	local direction = { x, y }

	direction.x = x
	direction.y = y

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
	love.graphics.clear(0.2, 0.2, 0.2, 1)
	if shouldShowStat == true then
		love.graphics.print(("FPS: %.1f"):format(love.timer.getFPS()), 20, 20)
		love.graphics.print(("X: %.3f"):format(circleEntity.position.x), 20, 50)
		love.graphics.print(("Y: %.3f"):format(circleEntity.position.y), 20, 80)
	end
	love.graphics.setColor(circleEntity.color.r, circleEntity.color.g, circleEntity.color.b, circleEntity.color.a)
	love.graphics.circle("fill", circleEntity.position.x, circleEntity.position.y, circleEntity.radius, circleEntity.segment)
end
