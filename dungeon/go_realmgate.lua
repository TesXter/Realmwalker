local Scos = require("dungeon.waypoints.scos")
local Step = require("dungeon.waypoints.step")
local Frac = require("dungeon.waypoints.frac")

local GoRealmgate = {}

local total_step = 0
local current_step = 0
local use_point = false
local previous_zone_name = ""

-- Main function to handle player movement towards realm gate
function GoRealmgate.running(player_position, zone_name)

    -- Determine which set of waypoints to use based on the zone
    if current_step == 0 then
        if zone_name == "S06_Scos_RealmWalkerDungeonOfHatred" then
            -- Choose the closest waypoint set in Scos
            if player_position:dist_to_ignore_z(Scos.point[1]) < 2 then
                use_point = Scos.point
            elseif player_position:dist_to_ignore_z(Scos.point_2[1]) < 2 then
                use_point = Scos.point_2
            else
                use_point = Scos.point_3
            end
        elseif zone_name == "S06_Step_RealmWalkerDungeonOfHatred" then
            -- Choose the waypoint set in Step
            if player_position:dist_to_ignore_z(Step.point[1]) < 2 then
                use_point = Step.point
            elseif player_position:dist_to_ignore_z(Step.point_2[1]) < 2 then
                use_point = Step.point_2
            end
        elseif zone_name == "S06_Frac_RealmWalkerDungeonOfHatred" then
            -- Choose the waypoint set in Step
            if player_position:dist_to_ignore_z(Frac.point[1]) < 2 then
                use_point = Frac.point
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
        end
    else
        -- console.print("use_point is false (wait for update)")
    end
end

return GoRealmgate
