local tiny = require("tiny")
local logs = {}

local talkingSystem = tiny.processingSystem()
talkingSystem.filter = tiny.requireAll("id", "name", "mass", "phrase")

function talkingSystem:process(e, dt)
	e.mass = e.mass + (dt * 3)
	logs[e.id] = ("%s who weighs %d pounds, says %q."):format(e.name, e.mass, e.phrase)
end

local someEntity =
{
	id = 0,
	name = "John, Smith",
	phrase = "I'm gonna save the world.",
	mass = 64,
	hariColor = "brown"
}

local world = tiny.world(talkingSystem, someEntity)

for i = 1, 10 do
	world:update(1)
end


function love.draw()
	love.graphics.clear(0, 0, 1, 1)
	love.graphics.print(("FPS: %.1f"):format(love.timer.getFPS()), 20, 20)

	local offsetY = 10
	for index, value in pairs(logs) do
		love.graphics.print(value, 300, (400 + offsetY))
		offsetY = offsetY + 4
	end
end
