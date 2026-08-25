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
    -- Ignorowanie nowych zdarzeń, jeśli obecny plik jeszcze się nie wyrenderował
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

-- Włączenie obsługi przytrzymania klawisza ({repeatable = true})
mp.add_key_binding(nil, "sync-next", function() navigate("next") end, {repeatable = true})
mp.add_key_binding(nil, "sync-prev", function() navigate("prev") end, {repeatable = true})

-- Ustawienie pozycji startowej PRZED wczytaniem silnika wideo (dla wideo)
mp.register_event("start-file", function()
    if opts.mode == "video" and saved_pos then
        mp.set_property("file-local-options/start", tostring(saved_pos))
        mp.set_property("file-local-options/hr-seek", "yes")
        mp.set_property_bool("pause", true)
    end
end)

-- Zdarzenie wyrenderowania nowej klatki/obrazu
mp.register_event("playback-restart", function()
    if opts.mode == "video" and saved_pos then
        local should_pause = saved_pause
        saved_pos = nil

        -- Bufor czasowy zapobiegający mruganiu w wideo
        mp.add_timeout(0.12, function()
            mp.set_property_bool("pause", should_pause)
            busy = false
        end)
    else
        -- DLA OBRAZÓW: Natychmiastowe zdjęcie blokady w momencie wyświetlenia obrazu
        saved_pos = nil
        busy = false
    end
end)

