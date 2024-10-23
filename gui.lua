local gui = {}
local developer_id = "TesXter_Realmwalker"

local function create_checkbox(key)
    return checkbox:new(false, get_hash(developer_id .. "_" .. key))
end

gui.elements = {
    main_tree = tree_node:new(0),
    main_toggle = create_checkbox("main_toggle"),
}

function gui.render()
    if not gui.elements.main_tree:push("Realmwalker 0.1") then return end

    gui.elements.main_toggle:render("Enable", "")
    if not gui.elements.main_toggle:get() then
        gui.elements.main_tree:pop()
        return
    end

    gui.elements.main_tree:pop()
end

return gui
