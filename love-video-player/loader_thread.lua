require 'love.filesystem'
require 'love.image'

local self_thread = love.thread.getThread()
local running = true
local imageData

while running do
	collectgarbage("collect")

	filename = self_thread:demand("filename")

	if filename ~= "quit" then
		imageData = love.image.newImageData( filename )
		self_thread:set("imagedata", imageData)
	else
		running = false
	end

end
