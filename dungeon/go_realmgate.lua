local Scos = require("dungeon.waypoints.scos")
local Step = require("dungeon.waypoints.step")

local GoRealmgate = {}

local total_step = 0
local current_step = 0
local use_point = false
local previous_zone_name = ""

-- Main function to handle player movement towards realm gate
function GoRealmgate.running(player_position, zone_name)
    -- Reset current_step if a new zone is entered
    if current_step == 0 or zone_name ~= previous_zone_name then
        current_step = 0
        previous_zone_name = zone_name
    end

    -- Determine which set of waypoints to use based on the zone
    if current_step == 0 then
        if zone_name == "S06_Scos_RealmWalkerDungeonOfHatred" then
            -- Choose the closest waypoint set in Scos
            if player_position:dist_to_ignore_z(Scos.point[1]) < 2 then
                use_point = Scos.point
            else
                use_point = Scos.point_2
            end
        elseif zone_name == "S06_Step_RealmWalkerDungeonOfHatred" then
            -- Choose the waypoint set in Step
            if player_position:dist_to_ignore_z(Step.point[1]) < 2 then
                use_point = Step.point
            end
        end
    end

    -- If a waypoint set is selected, proceed with movement
    if use_point ~= false then
        total_step = #use_point

        -- Move towards the next waypoint if not yet reached
        if current_step < total_step then
            pathfinder.request_move(use_point[current_step + 1])
            -- Check if the player has reached the current waypoint
            if player_position:dist_to_ignore_z(use_point[current_step + 1]) < 1 then
                current_step = current_step + 1
                console.print("Moving to " .. current_step)
            end
        else
            -- Reset for next use
            current_step = 0
            use_point = false
        end
    else
        -- console.print("use_point is false (wait for update)")
    end
end

return GoRealmgate
