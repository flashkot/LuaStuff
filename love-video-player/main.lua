-- Copyright 2012 flashkot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local img1, img2
local first_image = true
local wait_image = false
local loader_thread

local cur_frame = 0
local next_load = 3

local frame_width, frame_height = 360, 200
local scale_factor = 2
local frames_in_row, rows_num = 4, 4
local video_fps, video_spf = 25, 1/25

local frames_per_image = frames_in_row * rows_num

local quads = {}
local curent_quad = 1
local frame_time = 0

local audio_position, audio_dt = 0, 0

local sound

function create_quads (width, height, num_x, num_y)
	local i,j

	for j = 0, num_y - 1, 1 do
		for i = 0, num_x - 1, 1 do
			table.insert(quads, love.graphics.newQuad(width * i, height * j, width, height, width * num_x, height * num_y ))
		end
	end
end



function love.load()
		loader_thread = love.thread.newThread( "loader_thread", "loader_thread.lua" )
    	loader_thread:start()
    	
    	loader_thread:set("filename", "media/sec_001.jpg")
    	imagedata = loader_thread:demand("imagedata")

		img1 = love.graphics.newImage(  imagedata )

		loader_thread:set("filename", "media/sec_002.jpg")
    	imagedata = loader_thread:demand("imagedata")

		img2 = love.graphics.newImage( imagedata )

		create_quads(frame_width, frame_height, frames_in_row, rows_num)
		
		sound = love.audio.newSource("media/audio.ogg")

		love.graphics.setMode(frame_width * scale_factor, frame_height * scale_factor)

		love.audio.play(sound)
end

function love.draw()	
	if first_image then
		love.graphics.drawq(img1, quads[curent_quad], 0, 0, 0, scale_factor, scale_factor)
	else
		love.graphics.drawq(img2, quads[curent_quad], 0, 0, 0, scale_factor, scale_factor)
	end
end

function love.update(dt)
	collectgarbage("collect")

	dt = sound:tell() - audio_position
	audio_position = sound:tell()
	if sound:isStopped() then
		love.event.push("quit")
	end

	frame_time = frame_time + dt

	if wait_image then
		imagedata = loader_thread:demand("imagedata")
		if imagedata then
			if first_image then
				img2 = love.graphics.newImage(  imagedata )
			else
				img1 = love.graphics.newImage(  imagedata )
			end
			wait_image = false
		end

	end

	if frame_time >= video_spf then
		frame_time = frame_time - video_spf
		curent_quad = curent_quad + 1
		if curent_quad > frames_per_image then
			curent_quad = 1

			loader_thread:set("filename", string.format("media/sec_%03d.jpg", next_load))
			wait_image = true
			next_load = next_load + 1

			if first_image then
				first_image = false
			else
				first_image = true
			end

		end
	end

end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end
end
