local entities_manager = start_require "lib/private/entities/entities_manager"

local particles_manager = start_require "lib/private/gfx/particles_manager"
local audio_manager = start_require "lib/private/gfx/audio_manager"

logger.log("Patching the in-memory engine before start")

--- Патчим сущностей

local entities_despawn = entities.despawn
entities["despawn"] = function (eid)
    entities_despawn(eid)
    entities_manager.despawn(eid)
end

-- Патч частиц
do
    gfx = gfx or {}
    gfx.particles = gfx.particles or {}

    gfx.particles.emit = function (...)
        return particles_manager.emit(...)
    end

    gfx.particles.stop = function (id)
        particles_manager.stop(id)
    end

    gfx.particles.is_alive = function (id)
        if not particles_manager.get(id) then return false end
        return particles_manager.get(id) and true or false
    end

    gfx.particles.get_origin = function (id)
        if not particles_manager.get(id) then return nil end
        local particle = particles_manager.get(id)
        if not particle then return nil end
        return particle.origin
    end

    gfx.particles.set_origin = function (id, ...)
        if not particles_manager.get(id) then return nil end
        local particle = particles_manager.get(id)
        particle.origin(...)
    end
end

--  Патч звуков
do
    audio = audio or {}

    local methods = {
        "play_stream",
        "play_stream_2d",
        "play_sound",
        "play_sound_2d",
        "stop",
        "pause",
        "resume",
        "set_loop",
        "is_loop",
        "get_volume",
        "set_volume",
        "get_pitch",
        "set_pitch",
        "get_time",
        "set_time",
        "get_position",
        "set_position",
        "get_velocity",
        "set_velocity",
        "count_speakers",
        "count_streams"
    }

    for _, name in ipairs(methods) do
        audio[name] = function(...)
            --debug.print("called " .. name)
            return audio_manager[name](...)
        end
    end
end

--- Патчим корутины

-- local __vc_resume_coroutine_default = __vc_resume_coroutine
-- local __vc_coroutines = nil

-- for i = 1, math.huge do
--     local name, value = debug.getupvalue(__vc_resume_coroutine_default, i)
--     if not name then break end

--     if name == "__vc_coroutines" then
--         __vc_coroutines = value
--         break
--     end
-- end

-- if __vc_coroutines ~= nil then
--     __vc_resume_coroutine = function(id)
--         local co = __vc_coroutines[id]
--         if not co then return false end

--         local success, err = pcall(coroutine.resume, co)
--         if not success then
--             debug.error(err)
--             logger.log("Engine coroutine error: " .. tostring(err), 'P')
--         end

--         return coroutine.status(co) ~= "dead"
--     end
-- end

-- Патчим чтобы работало так, как в доках, а то хуня

-- local player_set_suspended = player.set_suspended
-- local player_is_suspended = player.is_suspended

-- function player.set_suspended(pid, susi)
--     player_set_suspended(pid, not susi)
-- end

-- function player.is_suspended(pid)
--     return not player_is_suspended(pid)
-- end
