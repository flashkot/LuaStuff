--
-- possible types: int (-32,768 to 32,767), bool (true or false)

structure = {
	{typ = "int", name = "x"},
	{typ = "int", name = "y"},
	{typ = "flags", name = "flags 1", names = {"IsActive", "IsHidden", "IsRunning"}},
	{typ = "int", name = "angle"}
}

func_type = 1
functypes = {"from structure", "hardcoded", "strings"}

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

function BitPack_hc(struct, data)
	local result = string.char((32768 + data.x) % 256) .. string.char(math.floor((32768 + data.x) / 256))
		.. string.char((32768 + data.y) % 256) .. string.char(math.floor((32768 + data.y) / 256))
	
	local byte = 0
	if data.IsActive then
		byte = byte + 1
	end
	if data.IsHidden then
		byte = byte + 2
	end
	if data.IsRunning then
		byte = byte + 4
	end
	result = result .. string.char(byte)
	
	return result .. string.char((32768 + data.angle) % 256) .. string.char(math.floor((32768 + data.angle) / 256))
end

function BitPack_strings(struct, data)
	local result = data.x .. "," .. data.y .. ","
	
	if data.IsActive then
		result = result .. "1,"
	else
		result = result .. "0,"
	end
	
	if data.IsHidden then
		result = result .. "1,"
	else
		result = result .. "0,"
	end
	
	if data.IsRunning then
		result = result .. "1,"
	else
		result = result .. "0,"
	end
	
	return result .. data.angle
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

function BitUnpack_hc(struct, data)
	local result = {}
	local bytes = {string.byte(data, 1, 7)}

	result.x = bytes[1] + bytes[2] * 256 - 32768
	result.y = bytes[3] + bytes[4] * 256 - 32768
	result.angle = bytes[6] + bytes[7] * 256 - 32768

	local rem = 0
	local byte = bytes[5]
	byte, rem = math.modf(byte/2)
	result.IsActive = rem >= 0.5
	byte, rem = math.modf(byte/2)
	result.IsHidden = rem >= 0.5
	byte, rem = math.modf(byte/2)
	result.IsRunning = rem >= 0.5

	return result
end

function BitUnpack_strings(struct, data)
	local result = {}

	result["x"], 
	result["y"], 
	result["IsActive"], 
	result["IsHidden"], 
	result["IsRunning"], 
	result["angle"] = data:match("^(%-?%d+)%,(%-?%d+)%,([01])%,([01])%,([01])%,(%-?%d+)$")

	result.x = tonumber(result.x)
	result.y = tonumber(result.y)
	result.angle = tonumber(result.angle)

	result.IsActive = result.IsActive == "1"
	result.IsHidden = result.IsHidden == "1"
	result.IsRunning = result.IsRunning == "1"

	return result
end

function love.load()

		
end

function love.draw()
	local bytes = ""

	if func_type ~= 3 then
		for i = 1, #packed_data, 1 do
			bytes = bytes .. string.byte(packed_data, i) .. " "
		end
	else
		bytes = packed_data
	end

    love.graphics.print("Packed bytes: " .. bytes
    	.. "\nPacked length: "..tostring(#packed_data)
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
        .. "\nFunctions type: "..functypes[func_type]
        , 10, 10)

end

function love.update(dt)
	current_dt = dt

	for i = 1, 4000, 1 do

		data = {
			x = math.random(-32768, 32767),
			y = math.random(-32768, 32767),
			IsActive = math.random() >= 0.5,
			IsHidden = math.random() >= 0.5,
			IsRunning = math.random() >= 0.5,
			angle = math.random(-32768, 32767)
		}

		if func_type == 1 then
			packed_data = BitPack(structure, data)
			unpacked_data = BitUnpack(structure, packed_data)
		elseif func_type == 2 then
			packed_data = BitPack_hc(structure, data)
			unpacked_data = BitUnpack_hc(structure, packed_data)
		else
			packed_data = BitPack_strings(structure, data)
			unpacked_data = BitUnpack_strings(structure, packed_data)
		end

		assert (data.x == unpacked_data.x and
		    	data.y         == unpacked_data.y and
		    	data.angle     == unpacked_data.angle and
		    	data.IsActive  == unpacked_data.IsActive and
		    	data.IsHidden  == unpacked_data.IsHidden and
		    	data.IsRunning == unpacked_data.IsRunning, "Unpacked data does not match packed original data!")
	end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    if key == " " then
        func_type = func_type + 1
        if func_type == 4 then
        	func_type = 1
        end
    end
end
