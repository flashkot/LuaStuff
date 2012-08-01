require "collider"

local current_dt, animation_time, animate = 0, 0, true
local bullet_x, bullet_y, circle_x, circle_y, circle_r = 0, 0, 0, 0, 100
local col_circle_x1, col_circle_y1, col_circle_x2, col_circle_y2
local col_bullet_x1, col_bullet_y1, col_bullet_x2, col_bullet_y2

local draggables = {}
local circle_start, circle_end, bullet_start, bullet_end

function length_vect(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function norm_vect(x1, y1, x2, y2)
    return (x2 - x1) / length_vect(x1, y1, x2, y2),
        (y2 - y1) / length_vect(x1, y1, x2, y2)
end

function love.load()
    circle_start = {x = 100, y = 100, width = 20, height = 20, 
        dragging = { active = false, diffX = 0, diffY = 0 }, draw_shadow = 1}

    circle_end = {x = 300, y = 300, width = 20, height = 20, 
        dragging = { active = false, diffX = 0, diffY = 0 }, draw_shadow = 1}

    bullet_start = {x = 100, y = 300, width = 20, height = 20, 
        dragging = { active = false, diffX = 0, diffY = 0 }, draw_shadow = 1}

    bullet_end = {x = 300, y = 100, width = 20, height = 20, 
        dragging = { active = false, diffX = 0, diffY = 0 }, draw_shadow = 1}

    table.insert(draggables, circle_start)
    table.insert(draggables, circle_end)
    table.insert(draggables, bullet_start)
    table.insert(draggables, bullet_end)

end

function love.update(dt)
    current_dt = dt

    if animate then
        animation_time = animation_time + dt / 10
    end

    if animation_time > 1 then
        animation_time = 0
    end

    local circle_path_length = length_vect(circle_start.x + circle_start.width/2, circle_start.y + circle_start.height/2, 
        circle_end.x + circle_start.width/2, circle_end.y + circle_start.height/2)

    local bullet_path_length = length_vect(bullet_start.x + bullet_start.width/2, bullet_start.y + bullet_start.height/2, 
        bullet_end.x + bullet_end.width/2, bullet_end.y + bullet_end.height/2)

    local circle_u, circle_v = norm_vect(circle_start.x + circle_start.width/2, circle_start.y + circle_start.height/2, 
        circle_end.x + circle_start.width/2, circle_end.y + circle_start.height/2) 
        
    local bullet_u, bullet_v = norm_vect(bullet_start.x + bullet_start.width/2, bullet_start.y + bullet_start.height/2, 
        bullet_end.x + bullet_end.width/2, bullet_end.y + bullet_end.height/2)
    
    circle_u = circle_u * circle_path_length
    circle_v = circle_v * circle_path_length

    bullet_u = bullet_u * bullet_path_length
    bullet_v = bullet_v * bullet_path_length

    circle_x = circle_start.x + circle_start.width/2 + circle_u * animation_time
    circle_y = circle_start.y + circle_start.height/2 + circle_v * animation_time
    
    bullet_x = bullet_start.x + bullet_start.width/2 + bullet_u * animation_time
    bullet_y = bullet_start.y + bullet_start.height/2 + bullet_v * animation_time

    local collided, collide_t1_or_nil, collide_t2_or_nil = bullet_collide_circle (
        bullet_start.x + bullet_start.width/2, bullet_start.y + bullet_start.height/2, bullet_u, bullet_v,
        circle_start.x + circle_start.width/2, circle_start.y + circle_start.height/2, circle_u, circle_v,
        circle_r, 1
    )

    if not collided then
        col_circle_x1, col_circle_y1, col_circle_x2, col_circle_y2 = nil, nil, nil, nil
        col_bullet_x1, col_bullet_y1, col_bullet_x2, col_bullet_y2 = nil, nil, nil, nil
    else
        if collide_t1_or_nil then
            col_circle_x1 = circle_start.x + circle_start.width/2 + circle_u * collide_t1_or_nil
            col_circle_y1 = circle_start.y + circle_start.height/2 + circle_v * collide_t1_or_nil
            col_bullet_x1 = bullet_start.x + bullet_start.width/2 + bullet_u * collide_t1_or_nil
            col_bullet_y1 = bullet_start.y + bullet_start.height/2 + bullet_v * collide_t1_or_nil
        else
            col_circle_x1, col_circle_y1, col_bullet_x1, col_bullet_y1 = nil, nil, nil, nil
        end
        if collide_t2_or_nil then
            col_circle_x2 = circle_start.x + circle_start.width/2 + circle_u * collide_t2_or_nil
            col_circle_y2 = circle_start.y + circle_start.height/2 + circle_v * collide_t2_or_nil
            col_bullet_x2 = bullet_start.x + bullet_start.width/2 + bullet_u * collide_t2_or_nil
            col_bullet_y2 = bullet_start.y + bullet_start.height/2 + bullet_v * collide_t2_or_nil
        else
            col_circle_x2, col_circle_y2, col_bullet_x2, col_bullet_y2 = nil, nil, nil, nil
        end
    end


    for i,rect in ipairs(draggables) do
        if rect.dragging.active then
            rect.x = love.mouse.getX() - rect.dragging.diffX
            rect.y = love.mouse.getY() - rect.dragging.diffY
        end
    end
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Press <space> to play/pause animation. Playing: "..tostring(animate), 10, 25)

    love.graphics.setColor(255, 255, 255, 32)
    love.graphics.line(circle_start.x + circle_start.width/2, circle_start.y + circle_start.height/2, 
        circle_end.x + circle_start.width/2, circle_end.y + circle_start.height/2)
    love.graphics.line(bullet_start.x + bullet_start.width/2, bullet_start.y + bullet_start.height/2, 
        bullet_end.x + bullet_end.width/2, bullet_end.y + bullet_end.height/2)
 
    love.graphics.setColor(255, 0, 0, 127)

    if col_circle_x1 then
        love.graphics.circle("line", col_circle_x1, col_circle_y1, circle_r)
        love.graphics.circle("fill", col_circle_x1, col_circle_y1, 2)
        love.graphics.circle("fill", col_bullet_x1, col_bullet_y1, 5)
    end

    if col_circle_x2 then
        love.graphics.circle("line", col_circle_x2, col_circle_y2, circle_r)
        love.graphics.circle("fill", col_circle_x2, col_circle_y2, 2)
        love.graphics.circle("fill", col_bullet_x2, col_bullet_y2, 5)
    end

    love.graphics.setColor(0, 127, 127, 255)
    love.graphics.circle("line", circle_x, circle_y, circle_r)
    love.graphics.circle("fill", circle_x, circle_y, 2)
    love.graphics.circle("fill", bullet_x, bullet_y, 5)

    love.graphics.setColor(0, 127, 0, 255)
    for i,rect in ipairs(draggables) do
        love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)
    end
end

function love.mousepressed(x, y, button)
    if button == "l" then
        for i, rect in ipairs(draggables) do
            if x > rect.x and x < rect.x + rect.width
                and y > rect.y and y < rect.y + rect.height then
                
                rect.dragging.active = true
                rect.dragging.diffX = x - rect.x
                rect.dragging.diffY = y - rect.y
                
                break
            end
        end
    end

end

function love.mousereleased(x, y, button)
    if button == "l" then 
        for i,rect in ipairs(draggables) do
            rect.dragging.active = false
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    if key == " " then
        animate = not animate
    end
end
