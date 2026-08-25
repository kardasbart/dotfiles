-- ===================================================================
-- SCRIPT: Configurable Navigation (Video Frame-Sync vs Image Mode)
-- Plik zapisać jako: sync_pos.lua w katalogu scripts/
-- ===================================================================

local options = require 'mp.options'

local opts = {
    mode = "video"
}
options.read_options(opts, "sync_pos")

local saved_pos = nil
local saved_pause = false
local busy = false

local function navigate(direction)
    if busy then return end
    busy = true

    if opts.mode == "video" then
        saved_pos = mp.get_property_number("time-pos")
        saved_pause = mp.get_property_bool("pause")
    else
        saved_pos = nil
    end

    mp.command("playlist-" .. direction)
end

mp.add_key_binding(nil, "sync-next", function() navigate("next") end)
mp.add_key_binding(nil, "sync-prev", function() navigate("prev") end)

-- Ustawienie pozycji startowej PRZED wczytaniem silnika wideo
mp.register_event("start-file", function()
    if opts.mode == "video" and saved_pos then
        mp.set_property("file-local-options/start", tostring(saved_pos))
        mp.set_property("file-local-options/hr-seek", "yes")
        mp.set_property_bool("pause", true)
    end
end)

-- Wznowienie pracy dopiero po pełnym zainicjowaniu bufora i klatki
mp.register_event("playback-restart", function()
    if opts.mode == "video" and saved_pos then
        local should_pause = saved_pause
        saved_pos = nil

        -- Bufor czasowy zapobiegający mruganiu przy powolnym dekodowaniu
        mp.add_timeout(0.12, function()
            mp.set_property_bool("pause", should_pause)
            busy = false
        end)
    else
        saved_pos = nil
        busy = false
    end
end)
