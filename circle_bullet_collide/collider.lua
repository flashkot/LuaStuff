-- Check if circle collides with bullet
--
-- Input:
--
-- bx, by - bullet coordinates at start
-- bu, bv - bullet speed
--
-- cx, cy - circle coordinates at start
-- cu, cv - circle speed
-- cr - circle radius
--
-- dt - time span
--
-- Output:
--
-- collided - true or false
-- t1_or_nil - time of first collision (within dt) or nil
-- t2_or_nil - time of second collision (within dt) or nil
--
function bullet_collide_circle(bx,by,bu,bv,cx,cy,cu,cv,cr,dt)
    local a, b, c, D, t, t2

    -- Lets find dt when distance between bullet and circle centers are equal to circle radius

    -- x1 = bx + bu * dt
    -- y1 = by + bv * dt
    
    -- x2 = cx + cu * dt
    -- y2 = cy + cv * dt
    
    -- cr^2 = (bx + bu * dt - cx - cu * dt)^2 + (by + bv * dt - cy - cv * dt)^2 
    -- cr^2 = (dt * (bu - cu) + bx - cx)^2 + (dt * (bv - cv) + by - cy)^2 
    
    -- cr^2 = dt^2 * (bu - cu) ^ 2 + 2 * dt * (bu - cu) * (bx - cx) + (bx - cx)^2 +
    --        dt^2 * (bv - cv) ^ 2 + 2 * dt * (bv - cv) * (by - cy) + (by - cy)^2

    -- Lets solve this quadratic equation
           
    a = (bu - cu) ^ 2 + (bv - cv) ^ 2
    b = 2 * ((bu - cu) * (bx - cx) + (bv - cv) * (by - cy))
    c = (bx - cx)^2 + (by - cy)^2 - cr^2
    
    D = b^2 - 4 * a * c
    
    -- No collision
    if D < 0 then return false end
    
    -- One collision. Check what it is within dt
    if D == 0 then
        t = -0.5 * b / a
        if t >= 0 and t <= dt then
            return true, t
        else
            return false
        end
    end
    
    t  = (-b + math.sqrt(D)) / 2 / a
    t2 = (-b - math.sqrt(D)) / 2 / a

    -- Two collision. Check what they are within dt
    if t >= 0 and t <= dt and t2 >= 0 and t2 <= dt then
        return true, t, t2
    elseif t >= 0 and t <= dt then
        return true, t
    elseif t2 >= 0 and t2 <= dt then
        return true, t2
    else
        return false
    end
end
