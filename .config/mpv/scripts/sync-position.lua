local saved_pos = nil

mp.add_key_binding(nil, "sync-next", function()
    saved_pos = mp.get_property_number("time-pos")
    mp.command("playlist-next")
end)

mp.add_key_binding(nil, "sync-prev", function()
    saved_pos = mp.get_property_number("time-pos")
    mp.command("playlist-prev")
end)

mp.register_event("file-loaded", function()
    if saved_pos then
        mp.commandv("seek", saved_pos, "absolute", "exact")
        saved_pos = nil
    end
end)
