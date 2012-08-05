local server_thread

function love.load()
    server_thread = love.thread.newThread( "server", "server.lua" )
    server_thread:start()        
end

function love.draw()
end

function love.update(dt)
    local value = server_thread:get("error")
    if value then print(value) end 
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end
end
