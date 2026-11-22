--[[
  Name: Recount heal and Guessed Absorbs Module
  Author: Extrêm
]]

if not Recount then return end --  Forget about this if no Recount is present

local Recount = Recount

local Rhga = LibStub("AceAddon-3.0"):NewAddon("RecountHealAndGuessedAbsorbs", "AceEvent-3.0", "AceTimer-3.0","AceConsole-3.0")
Rhga.Version = tonumber(string.sub("$Revision: 17 $", 12, -3))

local RL = LibStub("AceLocale-3.0"):GetLocale("Recount")
local L = LibStub("AceLocale-3.0"):GetLocale("RecountHealAndGuessedAbsorbs")
local Epsilon=0.000000000000000001
local DetailTitles={}
DetailTitles.GuessedAbsorbed={
	TopNames = RL["Ability Name"],
	TopCount = RL["Count"],
	TopAmount = RL["Absorbed"],
	BotNames = "",
	BotMin = RL["Min"],
	BotAvg = RL["Avg"],
	BotMax = RL["Max"],
	BotAmount = RL["Count"]
}

DetailTitles.ShieldedWho={
	TopNames = RL["Player/Mob Name"],
	TopCount = "",
	TopAmount = RL["Count"],
	BotNames = RL["Ability Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = RL["Count"]
}

local function GetHealAndAbsorb(data, fight)
	local healing, hps = Recount:MergedPetHealingDPS(data, Recount.db.profile.CurDataSet)
	if not Recount.db.profile.MergeAbsorbs then
		local absorbs = fight.Absorbs or 0
		healing = healing + absorbs
		hps = hps + absorbs / ((fight.ActiveTime or 0) + Epsilon)
	end
	return healing, hps
end

local function GetHealAndAbsorbTable(fight)
	if Recount.db.profile.MergeAbsorbs then
		return fight.Heals
	end
	local merged = Recount:GetTable()
	if fight.Absorbed then
		for k,v in pairs(fight.Absorbed) do
			merged[k] = v
		end
	end

	if fight.Heals then
		for k,v in pairs(fight.Heals) do
			merged[k] = v
		end
	end
	return merged
end

-- The data on the panel
function Rhga:DataModesHealAndGuessedAbsorbs(data, num)
	if not data or not data.Fights or not data.Fights[Recount.db.profile.CurDataSet] then return 0, 0 end
	local fight = data.Fights[Recount.db.profile.CurDataSet]
	local healing, hps = GetHealAndAbsorb(data, fight)
	if num==1 then
		return healing, hps
	else
		return healing, {{GetHealAndAbsorbTable(fight),L["Heal & absorb"],DetailTitles.GuessedAbsorbed},{fight.ShieldedWho," "..L["Shielded Who"],DetailTitles.ShieldedWho}}
	end
end


-- On over function
function Rhga:TooltipFuncsHealGuessedAbsorbs(name,data)
	if not data or not data.Fights or not data.Fights[Recount.db.profile.CurDataSet] then return end
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	Recount:AddSortedTooltipData(RL["Top 3"].." "..L["Heal & absorb"],GetHealAndAbsorbTable(data.Fights[Recount.db.profile.CurDataSet]),3)
end

-- Add the panel to recount
Recount:AddModeTooltip(L["Heal & absorb"],Rhga.DataModesHealAndGuessedAbsorbs,Rhga.TooltipFuncsHealGuessedAbsorbs,nil,nil,nil,nil)
