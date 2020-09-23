local addonName = "Bagnon"
local BagnonMixin = {}

function BagnonMixin:GetName()
    return addonName
end

function BagnonMixin:Init()
	hooksecurefunc(Bagnon.Item, "Update", function(...) self:OnUpdateSlot(...) end)
end

function BagnonMixin:SetTooltipItem(tooltip, item, locationInfo)
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

function BagnonMixin:Refresh()
	if Bagnon.sets then
		Bagnon:UpdateFrames()
	end
end

function BagnonMixin:OnUpdateSlot(bagnonItem)
	local bag, slot = bagnonItem:GetBag(), bagnonItem:GetID()
	if bagnonItem.info.cached then
		CaerdonWardrobe:UpdateButtonLink(bagnonItem.info.link, self:GetName(), { isOffline = true }, bagnonItem, { showMogIcon = true, showBindStatus = true, showSellables = true } )
	else
		if bag ~= "vault" then
			local tab = GetCurrentGuildBankTab()
			if Bagnon:InGuild() and tab == bag then
				local itemLink = GetGuildBankItemLink(tab, slot)
				CaerdonWardrobe:UpdateButtonLink(itemLink, self:GetName(), { tab = tab, index = slot }, bagnonItem, { showMogIcon = true, showBindStatus = true, showSellables = true } )
			else
				local itemLink = GetContainerItemLink(bag, slot)
				CaerdonWardrobe:UpdateButtonLink(itemLink, self:GetName(), { bag = bag, slot = slot, isBankOrBags = true }, bagnonItem, { showMogIcon = true, showBindStatus = true, showSellables = true } )
			end
		end
	end
end

local Version = nil
if select(4, GetAddOnInfo(addonName)) then
	if IsAddOnLoaded(addonName) then
		Version = GetAddOnMetadata(addonName, "Version")
		CaerdonWardrobe:RegisterFeature(BagnonMixin)
	end
end
