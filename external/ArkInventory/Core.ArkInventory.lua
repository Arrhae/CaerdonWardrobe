local ADDON_NAME, namespace = ...
local L = namespace.L

local addonName = "ArkInventory"
local ArkInventoryMixin = {}

function ArkInventoryMixin:GetName()
    return addonName
end

function ArkInventoryMixin:Init()
	hooksecurefunc(ArkInventory.API, "ItemFrameUpdated", function(...) self:OnFrameItemUpdate(...) end)
end

function ArkInventoryMixin:SetTooltipItem(tooltip, item, locationInfo)
	if locationInfo.isOffline then
		if not item:IsItemEmpty() then
			tooltip:SetHyperlink(item:GetItemLink())
		end
	elseif not locationInfo.isBankOrBags then
		local speciesID, level, breedQuality, maxHealth, power, speed, name = tooltip:SetGuildBankItem(locationInfo.tab, locationInfo.index)
	elseif locationInfo.bag == BANK_CONTAINER then
		local hasItem, hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = tooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(locationInfo.slot))
	else
		local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = tooltip:SetBagItem(locationInfo.bag, locationInfo.slot)
	end
end

function ArkInventoryMixin:Refresh()
	ArkInventory.ItemCacheClear( )
	ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
end

function ArkInventoryMixin:OnFrameItemUpdate(frame, loc_id, bag_id, slot_id)
	local bag = ArkInventory.API.InternalIdToBlizzardBagId(loc_id, bag_id)
	local slot = slot_id
	
	if not ArkInventory.API.LocationIsOffline(loc_id) then
		local itemDB = ArkInventory.API.ItemFrameItemTableGet(frame)
		local itemLink = itemDB and itemDB.h

		-- ArkInventory creates invalid hyperlinks for caged battle pets - fix 'em up for now
		if ( itemLink and strfind(itemLink, "battlepet:") ) then
			local _, speciesID, level, quality, health, power, speed, battlePetID = strsplit(":", itemLink);
			local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);

			if battlePetID == name then
				battlePetID = "0"
			end

			itemLink = string.format("%s|Hbattlepet:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r", YELLOW_FONT_COLOR_CODE, speciesID, level, quality, health, power, speed, battlePetID, name)
		end

		if not itemLink then
			CaerdonWardrobe:ClearButton(frame)
		elseif loc_id == ArkInventory.Const.Location.Vault then
			local tab = ArkInventory.Global.Location[loc_id].view_tab
			CaerdonWardrobe:UpdateButtonLink(itemLink, self:GetName(), {tab = tab, index = slot, isBankorBags = false}, frame, options)
		else
			local options = {
				showMogIcon=true, 
				showBindStatus=true,
				showSellables=true
			}

			CaerdonWardrobe:UpdateButtonLink(itemLink, self:GetName(), { bag = bag, slot = slot, isBankOrBags = true }, frame, options)
		end
	else
		local itemLink
		local i = ArkInventory.API.ItemFrameItemTableGet( frame )
		if i and i.h then
			itemLink = i.h
		end

		if itemLink then
			CaerdonWardrobe:UpdateButtonLink(itemLink, self:GetName(), { isOffline=true, isBankOrBags = false }, frame, options)
		else
			CaerdonWardrobe:ClearButton(frame)
		end
	end
end


local Version = nil
if select(4, GetAddOnInfo(addonName)) then
	if IsAddOnLoaded(addonName) then
		Version = GetAddOnMetadata(addonName, 'Version')
		CaerdonWardrobe:RegisterFeature(ArkInventoryMixin)
	end
end
