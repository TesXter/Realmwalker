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
        if quest:get_name():find("SME_Hatetide_ActivityPlayerQuest") or quest:get_name():find("ZE_Hatetide") then
            return true
        end
    end
    return false
end

-- Function to evade to a specific position
local function evade(position)
    cast_spell.position(337031, position, 3.0)
end

-- Function to move towards and interact with an actor
local function move_and_interact(actor, interaction_distance)
    local actor_position = actor:get_position()
    local distance = get_player_position():dist_to_ignore_z(actor_position)
    
    if distance > interaction_distance then
        evade(actor_position)
        pathfinder.request_move(actor_position)
    end
    
    if distance <= interaction_distance then
        interact_object(actor)
    end
end

-- Main update function
on_update(function()
    enabled = gui.elements.main_toggle:get()

    if enabled then
        if is_hatetide_quest_active() then
            local actors = actors_manager.get_all_actors()
        
            for _, actor in pairs(actors) do
                local name = actor:get_skin_name()
                
                if name == "RealmWalker_portal" then
                    -- Follow Realmwalker
                    move_and_interact(actor, 7)
                elseif name:find("S06_Realmwalker_Portal_Generic") then
                    -- Interact with portal after Realmwalker dies
                    move_and_interact(actor, 3)
                elseif name:find("ACD_Switch_S06") then
                    -- Interact with portal before beginning
                    move_and_interact(actor, 3)
                end
            end
        end
    end
end)

-- Render menu
on_render_menu(gui.render)
