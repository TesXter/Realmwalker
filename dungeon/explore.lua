local Explore = {}

local explored_areas = {}
local grid_size = 5  -- Size of each grid cell
local exploration_radius = 3  -- Radius around the player to mark as explored
local max_target_distance = 50  -- Maximum distance for a new target

-- Stuck detection variables
local last_position = nil
local last_move_time = 0
local stuck_threshold = 10  -- Seconds before considering the player stuck

local interact_altar = false

local function calculate_distance(point1, point2)
    return point1:dist_to_ignore_z(point2)
end

local function get_grid_key(point)
    return math.floor(point:x() / grid_size) .. "," ..
           math.floor(point:y() / grid_size) .. "," ..
           math.floor(point:z() / grid_size)
end

local function mark_area_as_explored(center)
    for x = -exploration_radius, exploration_radius, grid_size do
        for y = -exploration_radius, exploration_radius, grid_size do
            local point = vec3:new(
                center:x() + x,
                center:y() + y,
                center:z()
            )
            local grid_key = get_grid_key(point)
            explored_areas[grid_key] = true
        end
    end
end

local function is_point_explored(point)
    local grid_key = get_grid_key(point)
    return explored_areas[grid_key] ~= nil
end

local function find_unexplored_target(player_pos)
    local best_target = nil
    local best_distance = math.huge

    for x = -max_target_distance, max_target_distance, grid_size do
        for y = -max_target_distance, max_target_distance, grid_size do
            local point = vec3:new(
                player_pos:x() + x,
                player_pos:y() + y,
                player_pos:z()
            )
            
            if utility.is_point_walkeable(point) and not is_point_explored(point) then
                local distance = calculate_distance(player_pos, point)
                if distance < best_distance then
                    best_target = point
                    best_distance = distance
                end
            end
        end
    end

    return best_target
end

local function find_random_walkable_point(player_pos)
    local attempts = 0
    local max_attempts = 20

    while attempts < max_attempts do
        local angle = math.random() * 2 * math.pi
        local distance = math.random(5, max_target_distance)
        local point = vec3:new(
            player_pos:x() + math.cos(angle) * distance,
            player_pos:y() + math.sin(angle) * distance,
            player_pos:z()
        )

        if utility.is_point_walkeable(point) then
            return point
        end

        attempts = attempts + 1
    end

    return nil
end

local function check_if_stuck(player_position)
    local current_time = os.time()

    if last_position and calculate_distance(player_position, last_position) < 0.1 then
        if current_time - last_move_time > stuck_threshold then
            return true
        end
    else
        last_move_time = current_time
    end

    last_position = player_position
    return false
end

local function get_realmgate(player_position)
    local actors = actors_manager.get_all_actors()    
    for _, actor in ipairs(actors) do
        actor_name = actor:get_skin_name()

        if actor_name:find("Altar") then
            if player_position:dist_to_ignore_z(actor:get_position()) < 7 then
                return actor
            end
        end
    end
end

-- Main exploration function
function Explore.run(player_position)

    local altar = get_realmgate(player_position)
    if altar then
        if not interact_altar then
            altar_position = altar:get_position()
            pathfinder.request_move(altar_position)
            if altar_position:dist_to_ignore_z(player_position) < 2 then
                interact_object(altar)
                interact_altar = true
            end
            console.print("Realmgate found. Stop")
        end
        return
    end

    mark_area_as_explored(player_position)
    
    if check_if_stuck(player_position) then
        console.print("Player is stuck. Finding a random walkable point.")
    
        pathfinder.request_move(find_random_walkable_point(player_position))
        return 
    end
    
    local target = find_unexplored_target(player_position)
    
    if target then
        pathfinder.request_move(target)
        return target
    else
        -- No unexplored areas found within range
        console.print("No unexplored areas found within range")
        return nil
    end
end

return Explore
