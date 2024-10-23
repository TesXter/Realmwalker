local gui = require("gui")

-- Get the local player
local local_player = get_local_player()
if local_player == nil then
    return
end

local enabled = false

-- Function to check if the Hatetide quest is active
local function is_hatetide_quest_active()
    local quests = get_quests()
    for _, quest in pairs(quests) do
        if quest:get_name():find("SME_Hatetide_ActivityPlayerQuest") then
            return true
        end
    end
    return false
end

-- Main update function
on_update(function()
    enabled = gui.elements.main_toggle:get()

    if enabled and is_hatetide_quest_active() then
        local actors = actors_manager.get_all_actors()
        for _, actor in pairs(actors) do
            local name = actor:get_skin_name()
            local distance = get_player_position():dist_to_ignore_z(actor:get_position())
            
            if name == "RealmWalker_portal" then
                -- Follow Realmwalker
                if distance > 7 then  
                    pathfinder.request_move(actor:get_position())
                end
            elseif name:find("S06_Realmwalker_Portal_Generic") then
                -- Interact with portal after Realmwalker dies
                if distance > 3 then
                    pathfinder.request_move(actor:get_position())
                end
                interact_object(actor)
            elseif name:find("ACD_") then
                -- Interact with portal before beginning
                if distance > 3 then
                    pathfinder.request_move(actor:get_position())
                end
                interact_object(actor)
            end
        end
    end
end)

-- Render menu
on_render_menu(gui.render)
