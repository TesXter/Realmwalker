local gui = require("gui")
local GoRealmgate = require("dungeon.go_realmgate")

-- Get the local player
local local_player = get_local_player()
if not local_player then return end

local last_tick_time = get_time_since_inject()
local time_to_work = 5
local work_time = time_to_work

local enabled = false

-- Function to check if the Hatetide quest is active
local function is_hatetide_quest_active()
    for _, quest in pairs(get_quests()) do
        local quest_name = quest:get_name() 
        if quest_name:find("SME_Hatetide_ActivityPlayerQuest") or quest_name:find("ZE_Hatetide") or quest_name:find("RealmWalkerDungeonOfHatred") then
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
    elseif distance <= interaction_distance then
        interact_object(actor)
    end
end

-- Function to check if the player has a specific buff
local function is_player_has_buff(buff_name)
    local buffs = local_player:get_buffs()
    for _, buff in pairs(buffs) do
        if buff:name() == buff_name then
            return true
        end
    end
    return false
end

local function run_in_dungeon(player_position)
    local zone_name = world.get_current_world():get_current_zone_name()
    if zone_name == "S06_Scos_RealmWalkerDungeonOfHatred" or zone_name == "S06_Step_RealmWalkerDungeonOfHatred" or zone_name == "S06_Frac_RealmWalkerDungeonOfHatred" then
        GoRealmgate.running(player_position, zone_name)
    end
end

-- Main update function
on_update(function()
    enabled = gui.elements.main_toggle:get()

    if enabled then

        -- Get the current time
        local current_time = get_time_since_inject()

        -- Check if one second has passed
        if current_time - last_tick_time >= 1 then
            -- Update the last tick time
            last_tick_time = current_time

            -- Code to execute every second
            work_time = work_time - 1
            if work_time <= 0 then
                work_time = time_to_work
            end

        end

        if is_hatetide_quest_active() then

            local player_position = get_player_position()
            run_in_dungeon(player_position)

            local actors = actors_manager.get_all_actors()
        
            for _, actor in pairs(actors) do
                local name = actor:get_skin_name()
                
                if name == "RealmWalker_portal" then
                    -- Follow Realmwalker
                    if work_time >= 2 and work_time <= 5 then  
                        move_and_interact(actor, 7)
                    end
                elseif name:find("S06_Realmwalker_Portal_Generic") then
                    -- Interact with portal after Realmwalker dies
                    move_and_interact(actor, 3)
                elseif name:find("ACD_Switch_S06") then
                    -- Interact with portal before beginning
                    if is_player_has_buff("S06_Realmwalker_GizmoSummonMonster") then
                        return
                    end

                    move_and_interact(actor, 3)
                end
            end
        end
    end
end)

-- Render menu
on_render_menu(gui.render)
