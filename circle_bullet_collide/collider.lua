function bullet_collide_circle(bx,by,bu,bv,cx,cy,cu,cv,cr,dt)
    local a, b, c, D, t, t2
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
    c = (bx - cx)^2 + (by - cy)^2 - cr^2
    
    D = b^2 - 4 * a * c
    
    if D < 0 then return false end
    
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
