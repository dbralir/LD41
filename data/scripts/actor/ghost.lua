function update(eid, delta)
    local epos = entities:get_component(eid, component.position)
    local newVel = entities:get_component(eid, component.velocity)
    local speed = entities:get_component(eid, component.speed)
    local dest = path_logic[#path_logic]
    local dx = dest.x - epos.x
    local dy = dest.y - epos.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist ~= 0 then
        newVel.vx = dx * speed.speedness / dist
        newVel.vy = dy * speed.speedness / dist
    end
    if dist < 0.0625 then
        entities:create_component(eid, component.death_timer.new())
    end
end

function on_collide(eid1, eid2, aabb)
    local is_bullet = entities:has_component(eid2, component.bullet_tag)
    local is_enemy = entities:has_component(eid2, component.enemy_tag)

    if is_bullet then
        local health = entities:get_component(eid1, component.health)
        local bullet = entities:get_component(eid2, component.bullet)
        local detector = entities:get_component(bullet.tower, component.detector)
        local tower = entities:get_component(bullet.tower, component.tower)

        health.max_health = health.max_health - tower.damage
        if health.max_health <= 0 then
            local idx = detector.entity_list:find(eid1)
            if idx then
                detector.entity_list:erase(idx)
            end
            entities:create_component(eid1, component.death_timer.new())
        end

        entities:create_component(eid2, component.death_timer.new())
    elseif not is_enemy and entities:has_component(eid2, component.health) then
        local other_health = entities:get_component(eid2, component.health)

        play_sfx("playergethit")
        other_health.max_health = other_health.max_health - 1

        entities:create_component(eid1, component.death_timer.new())

        if other_health.max_health <= 0 then
            entities:create_component(eid2, component.death_timer.new())
            set_game_state("game_over")
        end
    end
end
