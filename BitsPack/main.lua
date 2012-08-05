--
-- possible types: int (-32,768 to 32,767), bool (true or false)

structure = {
	{typ = "int", name = "x"},
	{typ = "int", name = "y"},
	{typ = "flags", name = "flags 1", names = {"IsActive", "IsHidden", "IsRunning"}},
	{typ = "int", name = "angle"}
}

local data, packed_data, unpacked_data
local current_dt


function BitPack(struct, data)
	local result = ""
	
	for i,value in ipairs(struct) do
		if value.typ == "int" then
			local int = 32768 + data[value.name]
			result = result .. string.char(int % 256) .. string.char(math.floor(int / 256))
		elseif value.typ == "flags" then
			local byte = 0
			for bit, flagname in ipairs(value.names) do				
				if data[flagname] then
					byte = byte + 2 ^ (bit - 1)
				end
			end
			result = result .. string.char(byte)
		end
	end
	return result
end

function BitUnpack(struct, data)
	local result = {}
	local pos = 1
	local rem = false

	for name,value in ipairs(struct) do
		if value.typ == "int" then
			result[value.name] = string.byte(data, pos) + string.byte(data, pos + 1) * 256 - 32768
			pos = pos + 2
		elseif value.typ == "flags" then
			local byte = string.byte(data, pos)
			for bit, flagname in ipairs(value.names) do
				byte, rem = math.modf(byte/2)
				result[flagname] = rem >= 0.5
			end
			pos = pos + 1
		end
	end
	return result
end


function love.load()

end

function love.draw()

	local bytes = ""

	for i = 1, #packed_data, 1 do
		bytes = bytes .. string.byte(packed_data, i) .. " "
	end

    love.graphics.print("Packed bytes: " .. bytes
    	.. "\n------------------------------------------"
        .. "\nunpacked_data.x         = "..tostring(unpacked_data.x)
        .. "\nunpacked_data.y         = "..tostring(unpacked_data.y)
        .. "\nunpacked_data.angle     = "..tostring(unpacked_data.angle)
        .. "\nunpacked_data.IsActive  = "..tostring(unpacked_data.IsActive)
        .. "\nunpacked_data.IsHidden  = "..tostring(unpacked_data.IsHidden)
        .. "\nunpacked_data.IsRunning = "..tostring(unpacked_data.IsRunning)
        .. "\n------------------------------------------"
        .. "\ndata.x         = "..tostring(data.x)
        .. "\ndata.y         = "..tostring(data.y)
        .. "\ndata.angle     = "..tostring(data.angle)
        .. "\ndata.IsActive  = "..tostring(data.IsActive)
        .. "\ndata.IsHidden  = "..tostring(data.IsHidden)
        .. "\ndata.IsRunning = "..tostring(data.IsRunning)
        .. "\n------------------------------------------"
        .. "\ndt         = "..tostring(current_dt)
    , 10, 10)

end

function love.update(dt)

	current_dt = dt

		for i = 1, 10000, 1 do

		data = {
			x = math.random(-32768, 32767),
			y = math.random(-32768, 32767),
			IsActive = math.random() >= 0.5,
			IsHidden = math.random() >= 0.5,
			IsRunning = math.random() >= 0.5,
			angle = math.random(-32768, 32767)
		}

		packed_data = BitPack(structure, data)

		unpacked_data = BitUnpack(structure, packed_data)

		assert (data.x == unpacked_data.x and
		    	data.y         == unpacked_data.y and
		    	data.angle     == unpacked_data.angle and
		    	data.IsActive  == unpacked_data.IsActive and
		    	data.IsHidden  == unpacked_data.IsHidden and
		    	data.IsRunning == unpacked_data.IsRunning, "Unpacked data does not match packed original data!")
		end
end
