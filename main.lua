local tiny = require("lib/tiny")
local baton = require("lib/baton")

local shouldShowDebugStat = true
local drawFilter = tiny.requireAll("isDrawSystem")
local updateFilter = tiny.rejectAny("isDrawSystem")

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

-- System
local playerInputSystem = tiny.processingSystem()
playerInputSystem.filter = tiny.requireAll("playerInput", "moveDirection")

function playerInputSystem:process(e, dt)
	playerInput = e.playerInput

	if not playerInput.isAllowInput then
		return
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

	e.moveDirection = direction
end

local movementSystem = tiny.processingSystem()
movementSystem.filter = tiny.requireAll("position", "moveDirection", "velocity")

function movementSystem:process(e, dt)
	velocity = e.velocity
	position = e.position
	moveDirection = e.moveDirection
	velocity.x = (moveDirection.x * e.moveSpeed)
	velocity.y = (moveDirection.y * e.moveSpeed)
	position.x = position.x + (velocity.x * dt)
	position.y = position.y + (velocity.y * dt)
end

local primitiveRenderSystem = tiny.processingSystem()
primitiveRenderSystem.isDrawSystem = true
primitiveRenderSystem.filter = tiny.requireAll("position", "primitiveShape")

function primitiveRenderSystem:process(e, dt)
	position = e.position
	primitiveShape = e.primitiveShape
	if primitiveShape.shape == "circle" then
		love.graphics.setColor(primitiveShape.color.r, primitiveShape.color.g, primitiveShape.color.b, primitiveShape.color.a)
		love.graphics.circle("fill", position.x, position.y, primitiveShape.radius, primitiveShape.segment)
	end
end

-- Entity
local player = {
	playerInput = {
		id = 0,
		isAllowInput = true
	},
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
	primitiveShape = {
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
}

local gameWorld = tiny.world(
	playerInputSystem,
	movementSystem,
	primitiveRenderSystem,
	player
)

function love.load(args)
	print("*** Begin Loading ***")
	love.window.setFullscreen(true)
	for i = 1, 10 do
		print(("Test stdout on android (logcat) : %d"):format(i))
	end
	print("*** End Loading ***")
end

function love.update(dt)
	input:update()

	if input:pressed("toggleStat") then
		shouldShowDebugStat = not shouldShowDebugStat
	end

	gameWorld:update(dt, updateFilter)
end

function love.draw()
	love.graphics.clear(0.2, 0.2, 0.2, 1)
	if shouldShowDebugStat then
		drawStat()
	end
	local dt = love.timer.getDelta()
	gameWorld:update(dt, drawFilter)
end

function drawStat()
	love.graphics.print(("FPS: %.1f"):format(love.timer.getFPS()), 20, 20)
	love.graphics.print(("X: %.3f"):format(player.position.x), 20, 50)
	love.graphics.print(("Y: %.3f"):format(player.position.y), 20, 80)
end
