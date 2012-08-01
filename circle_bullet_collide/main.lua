local current_dt

local targets = {}
local bullets = {}

function bullet_collide_circle(bx,by,bu,bv,cx,cy,cu,cv,cr,dt)

    -- x1 = bx + bu * dt
    -- y1 = by + bv * dt
    
    -- x2 = cx + cu * dt
    -- y2 = cy + cv * dt
    
    -- cr^2 = (bx + bu * dt - cx - cu * dt)^2 + (by + bv * dt - cy - cv * dt)^2 
    -- cr^2 = (dt * (bu - cu) + bx - cx)^2 + (dt * (bv - cv) + by - cy)^2 
    
    -- cr^2 = dt^2 * (bu - cu) ^ 2 + 2 * dt * (bu - cu) * (bx - cx) + (bx - cx)^2
           -- dt^2 * (bv - cv) ^ 2 + 2 * dt * (bv - cv) * (by - cy) + (by - cy)^2
           
    a = (bu - cu) ^ 2 + (bv - cv) ^ 2
    b = 2 * ((bu - cu) * (bx - cx) + (bv - cv) * (by - cy))
    c = (bx - cx)^2 + (by - cy)^2
    
    D = b^2 - 4 * a * c
    
    if D < 0 then return false end
    
    if D == 0 then
        t = -0.5 * b / a
        if t >= 0 and t <= dt then
            return true
        else
            return false
        end
    end
    
    t = (-b + math.sqrt(D)) / 2 / a
    if t >= 0 and t <= dt then
        return true
    end    

    t = (-b - math.sqrt(D)) / 2 / a
    if t >= 0 and t <= dt then
        return true
    else
        return false
    end
end

function love.load()
    for i = 1, 1000, 1 do
        table.insert(targets, { 
            x = math.random(0, 2048),
            y = math.random(0, 2048),
            u = math.random(0, 200), 
            v = math.random(0, 200) 
        })
        
        table.insert(bullets, { 
            x = math.random(0, 2048),
            y = math.random(0, 2048),
            u = math.random(0, 500), 
            v = math.random(0, 500) 
        })
    end
end

function love.update(dt)
    current_dt = dt
    

    
    for i,trgt in ipairs(targets) do
        for j,blt in ipairs(bullets) do
            local test = bullet_collide_circle(blt.x, blt.y, blt.u, blt.v,
                trgt.x, trgt.y, trgt.u, trgt.v, 10, dt)        
        end
    end
end

function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Current dt: "..tostring(current_dt), 10, 25)
end
