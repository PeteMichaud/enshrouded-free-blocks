-- Free Blocks: recipes whose only outputs are building blocks or road
-- materials cost nothing. Unlock requirements are left alone, so only unlocked
-- recipes can be crafted.

-- Building blocks (walls and roofs) are the items equipped in these slots.
-- Their names are not reliable: most are Block_..., a few are _Block_... .
local BLOCK_SLOTS = { BlueprintMaterial_Default = true, BlueprintMaterial_Roof = true }

-- Roads share their slot with every other terrain material (soil, grass,
-- rubble...), so they are picked out by name, e.g.
-- Build_TerrainMaterial_T1_Road_Stone_1. Use "^Build_TerrainMaterial_" instead
-- to make every craftable terrain material free.
local ROAD_ITEM_PATTERNS = { "^Build_TerrainMaterial_T%d+_Road_" }

local TAG = "[free-blocks]"

-- An error raised by EML aborts the game even inside pcall, so every field is
-- checked for existence before it is read or written.
local function hasField(obj, field)
    local t = game.types.of(obj)
    while t do
        local fields = t.struct_fields
        if fields and fields[field] ~= nil then
            return true
        end
        t = t.inner_type
    end
    return false
end

local function get(obj, field)
    if obj ~= nil and hasField(obj, field) then
        return obj[field]
    end
    return nil
end

local function resources(typeName)
    if game.types.get(typeName) == nil then
        return {}
    end
    return game.assets.get_resources_by_type(typeName)
end

-- Item ids are either a plain number or a struct wrapping one in `value`.
local function idValue(id)
    if id == nil or type(id) == "number" then
        return id
    end
    return get(id, "value")
end

local function isBlock(item)
    local slot = get(get(item, "equipment"), "slot")
    return slot ~= nil and BLOCK_SLOTS[tostring(slot)] == true
end

local function isRoad(item)
    local name = get(item, "debugName")
    if type(name) ~= "string" then
        return false
    end
    for _, pattern in ipairs(ROAD_ITEM_PATTERNS) do
        if string.find(name, pattern) then
            return true
        end
    end
    return false
end

local function collectFreeItemIds()
    local ids, blocks, roads = {}, 0, 0
    for _, resource in ipairs(resources("keen::ItemInfo")) do
        local item = resource.data
        local block = isBlock(item)
        if block or isRoad(item) then
            local id = idValue(get(item, "itemId"))
            if id ~= nil and not ids[id] then
                ids[id] = true
                if block then
                    blocks = blocks + 1
                else
                    roads = roads + 1
                end
            end
        end
    end
    return ids, blocks, roads
end

local function outputsOnlyFreeItems(recipe, freeIds)
    local outputs = get(recipe, "output") or {}
    local seen = 0
    for _, stack in ipairs(outputs) do
        local id = idValue(get(stack, "item"))
        if id == nil or not freeIds[id] then
            return false
        end
        seen = seen + 1
    end
    return seen > 0
end

local function zeroInputs(recipe)
    for _, input in ipairs(get(recipe, "input") or {}) do
        for _, field in ipairs({ "itemStack", "inputItemCategory" }) do
            local stack = get(input, field)
            if stack ~= nil and hasField(stack, "count") then
                stack.count = 0
            end
        end
    end
end

local freeIds, blockCount, roadCount = collectFreeItemIds()
local patched = 0

for _, typeName in ipairs({ "keen::RecipeRegistryResource", "keen::DevRecipeRegistryResource" }) do
    for _, registry in ipairs(resources(typeName)) do
        for _, recipe in ipairs(get(registry.data, "recipes") or {}) do
            if outputsOnlyFreeItems(recipe, freeIds) then
                zeroInputs(recipe)
                patched = patched + 1
                print(string.format("%s free: %s", TAG, tostring(get(recipe, "debugName"))))
            end
        end
    end
end

print(string.format("%s %d blocks and %d roads found, %d recipes made free", TAG, blockCount, roadCount, patched))
if patched == 0 then
    warn(TAG .. " nothing was changed; the game data layout may have changed in this game version")
end
