local tick = require("lib/tick")
local tiny = require("lib/tiny")
local baton = require("lib/baton")
local push = require("lib/push")

local GAME_WIDTH = 1024
local GAME_HEIGHT = 768
local MAX_FPS = 60
local MS_PER_UPDATE = (1 / 60)
local DEFAULT_TIMESCALE = 1.0

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
    toggleStat = {'key:f1', 'button:back'}
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
	local playerInput = e.playerInput

	if not playerInput.isAllowInput then
		return
	end

	local x, y = input:get("move")
	local direction = { x, y }

	direction.x = x
	direction.y = y

	local magnitude = math.sqrt((direction.x * direction.x) + (direction.y * direction.y))

	if magnitude > 1.0 then
		direction.x = (direction.x / magnitude)
		direction.y = (direction.y / magnitude)
	end

	e.moveDirection = direction
end

local movementSystem = tiny.processingSystem()
movementSystem.filter = tiny.requireAll("position", "moveDirection", "velocity")

function movementSystem:process(e, dt)
	local velocity = e.velocity
	local position = e.position
	local moveDirection = e.moveDirection

	velocity.x = (moveDirection.x * e.moveSpeed)
	velocity.y = (moveDirection.y * e.moveSpeed)

	position.px = position.x
	position.py = position.y

	position.x = position.px + (velocity.x * dt)
	position.y = position.py + (velocity.y * dt)
end

local primitiveRenderSystem = tiny.processingSystem()
primitiveRenderSystem.isDrawSystem = true
primitiveRenderSystem.filter = tiny.requireAll("position", "primitiveShape")

function primitiveRenderSystem:process(e, dt)
	local position = e.position
	local primitiveShape = e.primitiveShape

	if (primitiveShape.shape == "circle") then
        local color = primitiveShape.color
        local x = position.px + (position.x - position.px) * dt
        local y = position.py + (position.y - position.py) * dt
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.circle("fill", x, y, primitiveShape.radius, primitiveShape.segment)
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
		x = GAME_WIDTH * 0.5,
		y = GAME_HEIGHT * 0.5,
		px = 0,
		py = 0
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
	tick.framerate = MAX_FPS
	tick.rate = MS_PER_UPDATE
	tick.timescale = DEFAULT_TIMESCALE
	love.window.setFullscreen(true)
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    --local gameScale = 0.5
    --push:setupScreen(screenWidth * gameScale, screenHeight * gameScale, screenWidth, screenHeight, { fullscreen = true, resizable = false })
    push:setupScreen(GAME_WIDTH, GAME_HEIGHT, screenWidth, screenHeight, { fullscreen = true, resizable = false })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    player.position.px = player.position.x
    player.position.py = player.position.y
    player.position.x = x
    player.position.y = y
    print(("Touch pressed : [ %.2f, %.2f ]"):format(x, y))
end

--local counter = 0
function love.update(dt)
	input:update()
	if input:pressed("toggleStat") then
		shouldShowDebugStat = not shouldShowDebugStat
	end
	gameWorld:update(dt, updateFilter)
	--counter = counter + 1
	--print(("counter: %d, dt: %.3f"):format(counter, dt))
end

function love.draw()
	local renderDelta = (tick.accum / MS_PER_UPDATE)
    push:start()
	love.graphics.clear(0.2, 0.2, 0.2, 1)
	--print(("render(dt): %.3f"):format(renderDT))
	gameWorld:update(renderDelta, drawFilter)
	if shouldShowDebugStat then
		drawStat()
	end
    push:finish()
end

-- Debug Stats
function drawStat()
    local debugStats = {
        ("FPS: %.1f"):format(love.timer.getFPS()),
        ("dt: %.3f"):format(tick.rate),
        ("X: %.3f"):format(player.position.x),
        ("Y: %.3f"):format(player.position.y)
    }

    local x, y = 20, 10
    local offset = 20

    for key,value in pairs(debugStats) do
        love.graphics.print(debugStats[key], x, y)
        y = y + offset
    end
end

