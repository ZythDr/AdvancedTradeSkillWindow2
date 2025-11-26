-- ATSW2 features added by https://github.com/ZythDr using Github Copilot.

local _G = _G

local rawset = _G.rawset or function(tbl, key, value)
    if tbl then
        tbl[key] = value
    end
end

local type = _G.type or type
local pcall = _G.pcall or pcall

local function fetch_global(name)
    if _G and _G[name] ~= nil then
        return _G[name]
    end
end

local extras_table = fetch_global('ATSW_Extras')
if type(extras_table) ~= 'table' then
    extras_table = {}
    rawset(_G, 'ATSW_Extras', extras_table)
end

local function safe_getglobal(name)
    local getter = fetch_global('getglobal')
    if type(getter) == 'function' then
        return getter(name)
    end
    return fetch_global(name)
end

local unpack = fetch_global('unpack')
local string_lib = _G.string or {}
local string_lower = string_lib.lower or function(text)
    return text
end
local math_lib = _G.math or {}
local math_floor = math_lib.floor or function(value)
    return value or 0
end
local math_mod = math_lib.fmod
if not math_mod then
    math_mod = function(value, divisor)
        if not (value and divisor) or divisor == 0 then
            return 0
        end
        return value - math_floor(value / divisor) * divisor
    end
end

local function list_length(list)
    local size = 0
    if not list then
        return size
    end
    while list[size + 1] ~= nil do
        size = size + 1
    end
    return size
end

local function append(list, value)
    local index = list_length(list) + 1
    list[index] = value
end

local function join(list, delimiter)
    delimiter = delimiter or ''
    local total = list_length(list)
    if total == 0 then
        return ''
    end
    local text = ''
    for index = 1, total do
        local chunk = list[index]
        if index == 1 then
            text = chunk or ''
        else
            text = text .. delimiter .. (chunk or '')
        end
    end
    return text
end

local FONT_COLOR_CODE_CLOSE = fetch_global('FONT_COLOR_CODE_CLOSE') or '|r'
local IsAddOnLoaded = fetch_global('IsAddOnLoaded')
local GetItemInfo = fetch_global('GetItemInfo')
local GetTradeSkillNumReagents = fetch_global('GetTradeSkillNumReagents')
local GetCraftNumReagents = fetch_global('GetCraftNumReagents')
local GetTradeSkillReagentInfo = fetch_global('GetTradeSkillReagentInfo')
local GetTradeSkillReagentItemLink = fetch_global('GetTradeSkillReagentItemLink')
local GetCraftReagentInfo = fetch_global('GetCraftReagentInfo')
local GetCraftReagentItemLink = fetch_global('GetCraftReagentItemLink')
local GetSpellTabInfo = fetch_global('GetSpellTabInfo')
local GetSpellTexture = fetch_global('GetSpellTexture')
local GetSpellName = fetch_global('GetSpellName')
local ATSW_GetProfessionTexture = fetch_global('ATSW_GetProfessionTexture')
local ATSW_GetPositionFromGame = fetch_global('ATSW_GetPositionFromGame')
local ATSW_SelectTab = fetch_global('ATSW_SelectTab')
local BOOKTYPE_SPELL = fetch_global('BOOKTYPE_SPELL') or 'BOOKTYPE_SPELL'
local ATSW_MAX_TRADESKILL_TABS = fetch_global('ATSW_MAX_TRADESKILL_TABS') or 0

local BEAST_TRAINING_TEXTURE = 'Interface\\Icons\\Ability_Hunter_BeastCall02'
local DISGUISE_TEXTURE = 'Interface\\Icons\\Ability_Rogue_Disguise'
local DISGUISE_NAME = 'Disguise'
local COST_LABEL_COLOR = '|cffFFd200'
local WHITE_MONEY_COLOR = '|cffffffff'
local GOLD_SUFFIX_COLOR = '|cffffd100'
local SILVER_SUFFIX_COLOR = '|cffc7c7cf'
local COPPER_SUFFIX_COLOR = '|cffeda55f'
local COPPER_PER_GOLD = 10000
local COPPER_PER_SILVER = 100

local vendor_defaults = {
    [2320] = true,
    [2321] = true,
    [4291] = true,
    [8343] = true,
    [14341] = true,
    [3371] = true,
    [3372] = true,
    [8925] = true,
    [18256] = true,
    [2324] = true,
    [2604] = true,
    [2605] = true,
    [4340] = true,
    [4341] = true,
    [4342] = true,
    [6260] = true,
    [6261] = true,
    [2880] = true,
    [3466] = true,
}

local vendor_only_reagents = fetch_global('ATSW_VENDOR_ONLY_REAGENTS')
if type(vendor_only_reagents) ~= 'table' then
    vendor_only_reagents = {}
end
for itemID in pairs(vendor_defaults) do
    vendor_only_reagents[itemID] = true
end
rawset(_G, 'ATSW_VENDOR_ONLY_REAGENTS', vendor_only_reagents)

local function current_profession()
    local realmTable = fetch_global('ATSW_Profession')
    local realm = fetch_global('ATSW_realm')
    local player = fetch_global('ATSW_player')
    if not (realmTable and realm and player) then
        return
    end
    local realmData = realmTable[realm]
    return realmData and realmData[player]
end

local function ensure_disguise_background()
    local backgrounds = fetch_global('ATSW_Background')
    if type(backgrounds) == 'table' and not backgrounds[DISGUISE_TEXTURE] then
        backgrounds[DISGUISE_TEXTURE] = DISGUISE_NAME
    end
end

ensure_disguise_background()

local function normalized_string(value)
    if type(value) == 'string' then
        return string_lower(value)
    end
end

local disguise_texture_key = normalized_string(DISGUISE_TEXTURE)

local function get_disguise_spell_name()
    if not (GetSpellTabInfo and GetSpellTexture and GetSpellName) then
        return
    end
    local tabIndex = 1
    while true do
        local _, _, offset, numSpells = GetSpellTabInfo(tabIndex)
        if not numSpells then
            break
        end
        for slot = offset + 1, offset + numSpells do
            local texture = GetSpellTexture(slot, BOOKTYPE_SPELL)
            if texture and normalized_string(texture) == disguise_texture_key then
                return GetSpellName(slot, BOOKTYPE_SPELL)
            end
        end
        tabIndex = tabIndex + 1
    end
end

local function player_knows_disguise()
    return get_disguise_spell_name() ~= nil
end

local function names_match(a, b)
    local left = normalized_string(a)
    local right = normalized_string(b)
    if not left or not right then
        return left == right
    end
    return left == right
end

local function matches_disguise_profession(name)
    if not name then
        return
    end
    local disguiseSpellName = get_disguise_spell_name()
    if disguiseSpellName then
        if names_match(name, disguiseSpellName) then
            return true
        end
    end
    return names_match(name, DISGUISE_NAME)
end

local function get_tab(index)
    return safe_getglobal('ATSWFrameTab' .. index)
end

local function get_tab_normal_texture(tab)
    if tab and tab.GetNormalTexture then
        return tab:GetNormalTexture()
    end
end

local function get_tab_texture(tab)
    local normal = get_tab_normal_texture(tab)
    if normal and normal.GetTexture then
        return normal:GetTexture()
    end
end

local function find_tab_by_texture(texture)
    local normalizedTexture = normalized_string(texture)
    if not normalizedTexture then
        return
    end
    for index = 1, ATSW_MAX_TRADESKILL_TABS do
        local tab = get_tab(index)
        if tab then
            local tabTexture = get_tab_texture(tab)
            if tabTexture and normalized_string(tabTexture) == normalizedTexture then
                return tab
            end
        end
    end
end

local function find_unused_tab()
    for index = 1, ATSW_MAX_TRADESKILL_TABS do
        local tab = get_tab(index)
        if tab and not tab.Name and not get_tab_texture(tab) then
            return tab
        end
    end
end

local function clear_tab(tab)
    if not tab then
        return
    end
    tab.Name = nil
    local normal = get_tab_normal_texture(tab)
    if normal and normal.SetTexture then
        normal:SetTexture(nil)
    else
        tab:SetNormalTexture(nil)
    end
    if tab.Hide then
        tab:Hide()
    end
end

local function reselect_current_profession()
    local profession = current_profession()
    if profession and type(ATSW_SelectTab) == 'function' then
        ATSW_SelectTab(profession)
    end
end

local function ensure_disguise_tab(exception)
    local disguiseName = get_disguise_spell_name()
    if disguiseName and exception and names_match(disguiseName, exception) then
        disguiseName = nil
    end
    local existingTab = find_tab_by_texture(DISGUISE_TEXTURE)
    local changed
    if disguiseName then
        local tab = existingTab or find_unused_tab()
        if tab then
            if tab.SetNormalTexture then
                tab:SetNormalTexture(DISGUISE_TEXTURE)
            end
            if tab.Show then
                tab:Show()
            end
            if tab.Name ~= disguiseName then
                tab.Name = disguiseName
            end
            changed = true
        end
    elseif existingTab then
        clear_tab(existingTab)
        changed = true
    end
    if changed then
        reselect_current_profession()
    end
end

local function is_beast_training()
    local profession = current_profession()
    if not (profession and ATSW_GetProfessionTexture) then
        return false
    end
    return ATSW_GetProfessionTexture(profession) == BEAST_TRAINING_TEXTURE
end

local function is_trade_skill()
    local func = fetch_global('ATSW_TradeSkill')
    return func and func()
end

local function get_reagent_count(index)
    if not index then
        return
    end
    if is_trade_skill() then
        return GetTradeSkillNumReagents and GetTradeSkillNumReagents(index)
    end
    return GetCraftNumReagents and GetCraftNumReagents(index)
end

local function get_reagent_info(index, reagentIndex)
    if not (index and reagentIndex) then
        return
    end
    if is_trade_skill() then
        local name, texture, amount, playerAmount = GetTradeSkillReagentInfo(index, reagentIndex)
        local link = GetTradeSkillReagentItemLink and GetTradeSkillReagentItemLink(index, reagentIndex)
        return name, texture, amount, playerAmount, link
    end
    local name, texture, amount, playerAmount = GetCraftReagentInfo(index, reagentIndex)
    local link = GetCraftReagentItemLink and GetCraftReagentItemLink(index, reagentIndex)
    return name, texture, amount, playerAmount, link
end

local function add_filter_name(source, filters, seen)
    if not source then
        return
    end
    local normalized = string_lower(source)
    if seen[normalized] then
        return
    end
    seen[normalized] = true
    append(filters, source .. '/exact')
end

local function ATSW_IsAuxLoaded()
    if IsAddOnLoaded and (IsAddOnLoaded('aux-addon') or IsAddOnLoaded('aux')) then
        return true
    end
    local auxFrame = fetch_global('aux_frame')
    if auxFrame and auxFrame:IsVisible() then
        return true
    end
    local buyTextBox = fetch_global('AuxBuySearchBox')
    if buyTextBox and buyTextBox:IsVisible() then
        return true
    end
    local nameTextBox = fetch_global('AuxBuyNameInputBox')
    if nameTextBox and nameTextBox:IsVisible() then
        return true
    end
    return false
end

local function build_aux_reagent_filter(button)
    if not (button and button.Name and ATSW_GetPositionFromGame) then
        return
    end
    local index = ATSW_GetPositionFromGame(button.Name)
    local reagentCount = get_reagent_count(index)
    if not (index and reagentCount and reagentCount > 0) then
        return
    end

    local filters = {}
    local seen = {}
    add_filter_name(button.Name, filters, seen)
    for reagentIndex = 1, reagentCount do
        local name = get_reagent_info(index, reagentIndex)
        add_filter_name(name, filters, seen)
    end
    if filters[1] then
        return join(filters, '; ')
    end
end

local function run_aux_filter(filter)
    if not filter then
        return
    end
    local auxFrame = fetch_global('aux_frame')
    if auxFrame and auxFrame:IsVisible() then
        local loader = fetch_global('require')
        if type(loader) == 'function' then
            local okAux, auxAddon = pcall(loader, 'aux')
            local okSearch, searchTab = pcall(loader, 'aux.tabs.search')
            local hasControllers = auxAddon and searchTab and auxAddon.set_tab and searchTab.set_filter
                and searchTab.execute
            if okAux and okSearch and hasControllers then
                auxAddon.set_tab(1)
                searchTab.set_filter(filter)
                searchTab.execute()
                return true
            end
        end
    end
    local buyBox = fetch_global('AuxBuySearchBox')
    local searchClick = fetch_global('AuxBuySearchButton_OnClick')
    if buyBox and buyBox:IsVisible() and searchClick then
        buyBox:SetText(filter)
        searchClick()
        return true
    end
    local nameInput = fetch_global('AuxBuyNameInputBox')
    local Aux = fetch_global('Aux')
    if nameInput and nameInput:IsVisible() and Aux and Aux.buy and Aux.buy.SearchButton_onclick then
        nameInput:SetText(filter)
        Aux.buy.SearchButton_onclick()
        return true
    end
end

local function ATSW_SearchAuxReagents(button)
    if not ATSW_IsAuxLoaded() then
        return
    end
    local filter = build_aux_reagent_filter(button or safe_getglobal('this'))
    return run_aux_filter(filter)
end

local function hook_recipe_button_click()
    local original = fetch_global('ATSWRecipeButton_OnClick')
    if type(original) ~= 'function' then
        return
    end
    local function handler(button)
        if button == 'RightButton' and ATSW_SearchAuxReagents(safe_getglobal('this')) then
            return
        end
        return original(button)
    end
    rawset(_G, 'ATSWRecipeButton_OnClick', handler)
end

hook_recipe_button_click()

local function ATSW_ColorizedMoneyString(amount)
    if not amount or amount <= 0 then
        return
    end
    local gold = math_floor(amount / COPPER_PER_GOLD)
    local silver = math_floor(math_mod(amount, COPPER_PER_GOLD) / COPPER_PER_SILVER)
    local copper = math_floor(math_mod(amount, COPPER_PER_SILVER))
    local parts = {}
    local function add_part(value, color, suffix)
        append(parts, WHITE_MONEY_COLOR .. value .. FONT_COLOR_CODE_CLOSE .. color .. suffix .. FONT_COLOR_CODE_CLOSE)
    end
    if gold > 0 then
        add_part(gold, GOLD_SUFFIX_COLOR, 'g')
    end
    if gold > 0 or silver > 0 then
        add_part(silver, SILVER_SUFFIX_COLOR, 's')
    end
    if copper > 0 or list_length(parts) == 0 then
        add_part(copper, COPPER_SUFFIX_COLOR, 'c')
    end
    return join(parts, ' ')
end

local function ATSW_GetAuxCostDependencies()
    if not ATSW_IsAuxLoaded() then
        return
    end
    local loader = fetch_global('require')
    if type(loader) ~= 'function' then
        return
    end
    local okAux, auxAddon = pcall(loader, 'aux')
    if not (okAux and auxAddon and auxAddon.account_data and auxAddon.account_data.crafting_cost) then
        return
    end
    local okHistory, history = pcall(loader, 'aux.core.history')
    local okInfo, info = pcall(loader, 'aux.util.info')
    local okMoney, money = pcall(loader, 'aux.util.money')
    if okHistory and okInfo then
        return history, info, okMoney and money
    end
end

local function ATSW_GetVendorFallbackPrice(itemID, link)
    if not GetItemInfo then
        return
    end
    local identifier = link or ('item:' .. (itemID or 0))
    local _, _, _, _, _, _, _, _, _, _, vendorSellPrice = GetItemInfo(identifier)
    if vendorSellPrice and vendorSellPrice > 0 then
        return vendorSellPrice * 4
    end
end

local function ATSW_GetVendorUnitPrice(infoModule, itemID, link)
    if infoModule and infoModule.merchant_info then
        local vendorSell, vendorBuy = infoModule.merchant_info(itemID)
        if vendorBuy and vendorBuy > 0 then
            return vendorBuy
        end
        if vendorSell and vendorSell > 0 then
            return vendorSell * 4
        end
    end
    return ATSW_GetVendorFallbackPrice(itemID, link)
end

local function ATSW_GetAuctionUnitPrice(historyModule, itemID, suffixID)
    if not historyModule then
        return
    end
    local key = itemID .. ':' .. (suffixID or 0)
    local price
    if historyModule.market_value then
        price = historyModule.market_value(key)
    end
    if (not price or price <= 0) and historyModule.value then
        price = historyModule.value(key)
    end
    if price and price > 0 then
        return price
    end
end

local function ATSW_FormatAuxCostLabel(totalCost)
    local labelStart = COST_LABEL_COLOR .. '(Total Cost: '
    local labelEnd = ')' .. FONT_COLOR_CODE_CLOSE
    local valueText
    if totalCost and totalCost > 0 then
        valueText = ATSW_ColorizedMoneyString(totalCost)
    else
        valueText = COST_LABEL_COLOR .. '?' .. FONT_COLOR_CODE_CLOSE
    end
    return labelStart .. (valueText or '') .. labelEnd
end

local function ATSW_GetAuxCostLabel(gameIndex, reagentCount)
    if not (gameIndex and reagentCount and reagentCount > 0) then
        return
    end
    local history, info = ATSW_GetAuxCostDependencies()
    if not (history and info and info.parse_link and info.merchant_info and history.value) then
        return
    end
    local totalCost = 0
    local missingCost
    for reagentIndex = 1, reagentCount do
        local _, _, amount, _, link = get_reagent_info(gameIndex, reagentIndex)
        if not (link and amount) then
            missingCost = true
            break
        end
        local itemID, suffixID = info.parse_link(link)
        local vendorOnly = vendor_only_reagents[itemID]
        local unitValue
        if vendorOnly then
            unitValue = ATSW_GetVendorUnitPrice(info, itemID, link)
        else
            unitValue = ATSW_GetAuctionUnitPrice(history, itemID, suffixID)
        end
        if not unitValue then
            missingCost = true
            break
        end
        totalCost = totalCost + unitValue * amount
    end
    if not missingCost then
        return ATSW_FormatAuxCostLabel(totalCost)
    end
end

local function update_aux_cost_label(recipeName)
    local costText = fetch_global('ATSWCostText')
    if not costText or is_beast_training() then
        return
    end
    if not recipeName then
        costText:Hide()
        return
    end
    local getPosition = ATSW_GetPositionFromGame
    local index = getPosition and getPosition(recipeName)
    local reagentCount = get_reagent_count(index)
    if not (index and reagentCount and reagentCount > 0) then
        costText:Hide()
        return
    end
    local label = ATSW_GetAuxCostLabel(index, reagentCount)
    if label then
        costText:SetText(label)
        costText:Show()
    else
        costText:Hide()
    end
end

local function hook_show_recipe()
    local original = fetch_global('ATSW_ShowRecipe')
    if type(original) ~= 'function' then
        return
    end
    local function handler(name)
        local results = { original(name) }
        update_aux_cost_label(name)
        if unpack then
            return unpack(results)
        end
        return results[1]
    end
    rawset(_G, 'ATSW_ShowRecipe', handler)
end

hook_show_recipe()

local function hook_atlas_skillups()
    local original = fetch_global('ATSW_SkillUps')
    if type(original) ~= 'function' then
        return
    end
    rawset(_G, 'ATSW_SkillUps', function(name)
        local ok, a, b, c, d = pcall(original, name)
        if ok then
            return a, b, c, d
        end
    end)
end

local function hook_configure_skill_buttons()
    local original = fetch_global('ATSW_ConfigureSkillButtons')
    if type(original) ~= 'function' then
        return
    end
    rawset(_G, 'ATSW_ConfigureSkillButtons', function(exception)
        original(exception)
        ensure_disguise_tab(exception)
    end)
end

local function hook_profession_exists()
    local original = fetch_global('ATSW_ProfessionExists')
    if type(original) ~= 'function' then
        return
    end
    rawset(_G, 'ATSW_ProfessionExists', function(profession)
        if matches_disguise_profession(profession) then
            return player_knows_disguise()
        end
        return original(profession)
    end)
end

hook_atlas_skillups()
hook_configure_skill_buttons()
hook_profession_exists()
