-- Free Blocks: recipes whose only outputs are building blocks cost nothing.
-- Unlock requirements are left alone, so only unlocked blocks can be crafted.

-- Building block items are named Block_<tier>_<material>_CRAFTING (e.g.
-- Block_T1_Wood_Rough_CRAFTING). Add "^Build_TerrainMaterial_" here to also
-- make terrain materials (dirt, stone, sand...) free.
local BLOCK_ITEM_PATTERNS = { "^Block_" }

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

local function isBlockName(name)
    if type(name) ~= "string" then
        return false
    end
    for _, pattern in ipairs(BLOCK_ITEM_PATTERNS) do
        if string.find(name, pattern) then
            return true
        end
    end
    return false
end

local function collectBlockItemIds()
    local ids, count = {}, 0
    for _, resource in ipairs(resources("keen::ItemInfo")) do
        local item = resource.data
        if isBlockName(get(item, "debugName")) then
            local id = idValue(get(item, "itemId"))
            if id ~= nil and not ids[id] then
                ids[id] = true
                count = count + 1
            end
        end
    end
    return ids, count
end

local function outputsOnlyBlocks(recipe, blockIds)
    local outputs = get(recipe, "output") or {}
    local seen = 0
    for _, stack in ipairs(outputs) do
        local id = idValue(get(stack, "item"))
        if id == nil or not blockIds[id] then
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

local blockIds, blockCount = collectBlockItemIds()
local patched = 0

for _, typeName in ipairs({ "keen::RecipeRegistryResource", "keen::DevRecipeRegistryResource" }) do
    for _, registry in ipairs(resources(typeName)) do
        for _, recipe in ipairs(get(registry.data, "recipes") or {}) do
            if outputsOnlyBlocks(recipe, blockIds) then
                zeroInputs(recipe)
                patched = patched + 1
                print(string.format("%s free: %s", TAG, tostring(get(recipe, "debugName"))))
            end
        end
    end
end

print(string.format("%s %d block items found, %d recipes made free", TAG, blockCount, patched))
if patched == 0 then
    warn(TAG .. " nothing was changed; the game data layout may have changed in this game version")
end
