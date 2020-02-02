local Mod = RegisterMod("Leveling System", 1) -- Register mod (duh)

-- Round function (so can round to num. decimal places) --
function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-------------
-- Imports --
-------------
local LevelingSystem = require("scripts/LevelingSystem.lua") -- Import level system script (experience table and level bonuses table)
local TblToString = require("scripts/TblToString.lua") -- Import TblToString script (with table to string functions)
local BitmapConverter = require("scripts/bitmap_1_converter.lua") -- Import bitmap converter (convert bitmap into number of 1s)

-------------------
-- Import Tables --
-------------------
local Exp = LevelingSystem.Exp -- Gets experience table from level system script
local LevelBonus = LevelingSystem.LevelBonus -- Gets level bonuses table from level system script

---------------
-- Variables --
---------------
local game = Game() -- Creates game variable (to avoid using Game() whenever using a function from Game)
local sfxManager = SFXManager() -- Creates sfx manager (for sounds)
local Variables = {} -- Creates blank variables table (to be filled in on load data)
local Stats = {} -- Creates blank stats table
local Points = {} -- Creates blank points table
local CritChance = {} -- Creates blank crit chance table
local CritDamage = {} -- Creates blank crit damage table
local TrashHPMult = 0 -- Creates HP multiplier variable for trash mobs
local level = game:GetLevel()

---------------------
--   Script for    --
-- Leveling System --
---------------------
local LevelScript = {}
	function LevelScript:Rebirth(player) -- Rebirth the character
		Stats.Level = 1 -- Resets level to level 1
		Stats.Experience = 0 -- Resets experience to 0
		Stats.MaxExperience = 100 -- Resets max experience to 100
		Stats.Strength = 15 -- Resets strength to 15
		Stats.Dexterity = 15 -- Resets dexterity to 15
		Stats.Vitality = 15 -- Resets vitality to 15
		Stats.Luck = 0 -- Resets luck to 0
		Points.Points_Stat = 0 -- Resets stat points to 0
		Stats.RebirthLevel = Stats.RebirthLevel + 1 -- Increases rebirth level by 1
	end
	
	function LevelScript:onPefUpdate(player)
		if game:GetFrameCount() > 1 then
			if Stats.Experience > Stats.MaxExperience then -- If the experience exceeds the maximum experience
				Stats.Experience = Stats.MaxExperience -- Sets the experience to the maximum experience (used for when max level)
			end
			if Stats.Experience >= Stats.MaxExperience and Stats.Level < 100 then -- Checks to see in the player has leveled up
				Stats.Experience = Stats.Experience - Stats.MaxExperience -- Sets the experience to the experience it should be
				Stats.MaxExperience = Stats.MaxExperience + math.floor((math.sqrt(Stats.Level)+Stats.Level) * 5) -- Sets the maximum experience to the next level's maximum experience
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector(0,0), player) -- Spawn level up effect
				sfxManager:Play(SoundEffect.SOUND_HOLY, 1.0, 0, false, 1.0)
				Stats.Level = Stats.Level + 1 -- Level up the player
				Points.Points_Stat = Points.Points_Stat + LevelBonus.LEVEL_STAT + Stats.RebirthLevel -- Increases stat points by stat point per level (plus rebirth level if >= 1)
			end
		end
	end
	
	function LevelScript:onKill(target)
	-- Adding Experience --
		local entity = target:ToNPC()
		if entity:IsBoss() then
			if entity.Type == EntityType.ENTITY_MOM then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Mom*2)
				else
					Stats.Experience = Stats.Experience + Exp.Mom
				end
			elseif entity.Type == EntityType.ENTITY_MOMS_HEART then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Heart*2)
				else
					Stats.Experience = Stats.Experience + Exp.Heart
				end
			elseif entity.Type == EntityType.ENTITY_SATAN then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Satan*2)
				else
					Stats.Experience = Stats.Experience + Exp.Satan
				end
			elseif entity.Type == EntityType.ENTITY_ISAAC then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Isaac*2)
				else
					Stats.Experience = Stats.Experience + Exp.Isaac
				end
			elseif entity.Type == EntityType.ENTITY_THE_LAMB then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Lamb*2)
				else
					Stats.Experience = Stats.Experience + Exp.Lamb
				end
			elseif entity.Type == EntityType.ENTITY_MEGA_SATAN then
				Stats.Experience = Stats.Experience
			elseif entity.Type == EntityType.ENTITY_MEGA_SATAN_2 then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.MegaSatan*2)
				else
					Stats.Experience = Stats.Experience + Exp.MegaSatan
				end
			elseif entity.Type == EntityType.ENTITY_ULTRA_GREED then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.UltraGreed*2)
				else
					Stats.Experience = Stats.Experience + Exp.UltraGreed
				end
			elseif entity.Type == EntityType.ENTITY_HUSH then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Hush*2)
				else
					Stats.Experience = Stats.Experience + Exp.Hush
				end
			elseif entity.Type == EntityType.ENTITY_DELIRIUM then
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Delirium*2)
				else
					Stats.Experience = Stats.Experience + Exp.Delirium
				end
			else
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Boss*2)
				else
					Stats.Experience = Stats.Experience + Exp.Boss
				end
			end
		else
			if entity.Type == EntityType.ENTITY_FLY then
				Stats.Experience = Stats.Experience
			else
				if entity:IsChampion() then
					Stats.Experience = Stats.Experience + (Exp.Enemy*2)
				else
					Stats.Experience = Stats.Experience + Exp.Enemy
				end
			end
		end
	end
Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LevelScript.onPefUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LevelScript.onKill)

---------------------
--   Script for    --
--   Stat System   --
---------------------
local StatScript = {}	
	------------------------
	-- Save and Load data --
	------------------------
	function saveData(data)
		dataToString = TblToString.tostring(data) -- Uses TblToString script to convert the table given as data into a string
		Isaac.SaveModData(Mod, dataToString) -- Saves the data for the mod using the previously converted string
	end
	
	function StatScript:onGameExit()
		saveData(Variables) -- Saves the data in the Variables table
	end
	
	function StatScript:onRender()
		-- Renders stats to screen --
		Isaac.RenderText("STR: "..Stats.Strength, 400, 160, 1, 1, 1, 1)
		Isaac.RenderText("DEX: "..Stats.Dexterity, 400, 170, 1, 1, 1, 1)
		Isaac.RenderText("VIT: "..Stats.Vitality, 400, 180, 1, 1, 1, 1)
		Isaac.RenderText("LCK: "..Stats.Luck, 400, 190, 1, 1, 1, 1)
		Isaac.RenderText("Stat pt: "..Points.Points_Stat, 400, 200, 1, 1, 1, 1)
		Isaac.RenderText("Exp: "..Stats.Experience.." ("..round((Stats.Experience / Stats.MaxExperience)*100).."%)", 210, 240, 1, 1, 1, 1)
		Isaac.RenderText("Lvl: "..Stats.Level, 270, 250, 1, 1, 1, 1)
		Isaac.RenderText("Rebirth: "..Stats.RebirthLevel, 190, 250, 1, 1, 1, 1)
		if Stats.ExtraHealth > 0 then
			Isaac.RenderText("HP: "..Stats.Health.."/"..Stats.MaxHealth.." + "..Stats.ExtraHealth, 60, 5, 1, 1, 1, 1)
		else
			Isaac.RenderText("HP: "..Stats.Health.."/"..Stats.MaxHealth, 60, 5, 1, 1, 1, 1)
		end
		-- Stat Rendering end --
	end
	
	function StatScript:onCache(player, cacheFlag)
		if cacheFlag == CacheFlag.CACHE_DAMAGE then -- If cache is damage
			player.Damage = player.Damage + round(((Stats.Strength / 5) - 3), 1)
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then -- If cache is fire delay
			if player.MaxFireDelay >= 1 then
				player.MaxFireDelay = player.MaxFireDelay - math.floor(math.log(Stats.Dexterity^3/200) - 2)
			else
				player.MaxFireDelay = 1
			end
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then -- If cache is luck
			player.Luck = player.Luck + math.floor(Stats.Luck / 5)
		end
	end
	
	function StatScript:onPlayerInit(player)
		if Isaac.HasModData(Mod) then
			Variables = load("return "..Isaac.LoadModData(Mod))() -- Loads the data for the mod into the Variables table
		else
			-- Default values for the Variables table
			Variables = {
				Isaac = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						CRIT = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Magdalene = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Cain = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Judas = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Eve = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Samson = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Azazel = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Lazarus = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Eden = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Lilith = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Apollyon = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				BB = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				TheLost = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				TheKeeper = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						Crit = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				},
				Modded = {
					Stats = {
						Strength = 15, -- Strength stat
						Vitality = 15, -- Vitality stat
						Dexterity = 15, -- Dexterity stat
						Luck = 0, -- Luck stat
						Experience = 0, -- Current experience
						Health = 30, -- Current health
						ExtraHealth = 0, -- Current extra health (goes above cap)
						MaxHealth = 30, -- Maximum health
						HealthDif = 0, -- Health difference due to character, items, etc.
						EternalArmor = false, -- Has eternal heart armour?
						GoldenArmor = false, -- Has golden heart armour?
						Level = 1, -- Current level
						RebirthLevel = 0, -- Current rebirth level
						MaxExperience = 100 -- Experience to next level
					},
					Points = {
						Points_Stat = 0, -- Current stat points
					},
					CritChance = {
						CRIT = 0.1, -- Chance of basic crit
						OVERCRIT = 1, -- Chance of Overcrit
						DOUBLE_OVERCRIT = 1 -- Chance of double Overcrit
					},
					CritDamage = {
						CRIT = 2, -- Basic crit damage multiplier
						OVERCRIT = 3, -- Overcrit damage multiplier
						DOUBLE_OVERCRIT = 4 -- Double Overcrit damage multiplier
					}
				}
			}
		end
		if player:GetName() == "Isaac" then
			Stats = Variables.Isaac.Stats -- Initialises stats variable
			Points = Variables.Isaac.Points -- Initialises points variable
			CritChance = Variables.Isaac.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Isaac.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Magdalene" then
			Stats = Variables.Magdalene.Stats -- Initialises stats variable
			Points = Variables.Magdalene.Points -- Initialises points variable
			CritChance = Variables.Magdalene.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Magdalene.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Cain" then
			Stats = Variables.Cain.Stats -- Initialises stats variable
			Points = Variables.Cain.Points -- Initialises points variable
			CritChance = Variables.Cain.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Cain.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Judas" then
			Stats = Variables.Judas.Stats -- Initialises stats variable
			Points = Variables.Judas.Points -- Initialises points variable
			CritChance = Variables.Judas.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Judas.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Eve" then
			Stats = Variables.Eve.Stats -- Initialises stats variable
			Points = Variables.Eve.Points -- Initialises points variable
			CritChance = Variables.Eve.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Eve.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Samson" then
			Stats = Variables.Samson.Stats -- Initialises stats variable
			Points = Variables.Samson.Points -- Initialises points variable
			CritChance = Variables.Samson.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Samson.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Azazel" then
			Stats = Variables.Azazel.Stats -- Initialises stats variable
			Points = Variables.Azazel.Points -- Initialises points variable
			CritChance = Variables.Azazel.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Azazel.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Lazarus" then
			Stats = Variables.Lazarus.Stats -- Initialises stats variable
			Points = Variables.Lazarus.Points -- Initialises points variable
			CritChance = Variables.Lazarus.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Lazarus.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Eden" then
			Stats = Variables.Eden.Stats -- Initialises stats variable
			Points = Variables.Eden.Points -- Initialises points variable
			CritChance = Variables.Eden.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Eden.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Lilith" then
			Stats = Variables.Lilith.Stats -- Initialises stats variable
			Points = Variables.Lilith.Points -- Initialises points variable
			CritChance = Variables.Lilith.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Lilith.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "Apollyon" then
			Stats = Variables.Apollyon.Stats -- Initialises stats variable
			Points = Variables.Apollyon.Points -- Initialises points variable
			CritChance = Variables.Apollyon.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Apollyon.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "???" then
			Stats = Variables.BB.Stats -- Initialises stats variable
			Points = Variables.BB.Points -- Initialises points variable
			CritChance = Variables.BB.CritChance -- Initialises crit chance variable
			CritDamage = Variables.BB.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "The Lost" then
			Stats = Variables.TheLost.Stats -- Initialises stats variable
			Points = Variables.TheLost.Points -- Initialises points variable
			CritChance = Variables.TheLost.CritChance -- Initialises crit chance variable
			CritDamage = Variables.TheLost.CritDamage -- Initialises crit damage variable
		elseif player:GetName() == "The Keeper" then
			Stats = Variables.TheKeeper.Stats -- Initialises stats variable
			Points = Variables.TheKeeper.Points -- Initialises points variable
			CritChance = Variables.TheKeeper.CritChance -- Initialises crit chance variable
			CritDamage = Variables.TheKeeper.CritDamage -- Initialises crit damage variable
		else
			Stats = Variables.Modded.Stats -- Initialises stats variable
			Points = Variables.Modded.Points -- Initialises points variable
			CritChance = Variables.Modded.CritChance -- Initialises crit chance variable
			CritDamage = Variables.Modded.CritDamage -- Initialises crit damage variable
		end
		-- Set stats according to mod stats --
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- Add damage cache flag for evaluation
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) -- Add fire delay cache flag for evaluation
		player:AddCacheFlags(CacheFlag.CACHE_LUCK) -- Add luck cache flag for evaluation
		player:EvaluateItems() -- Evaluate cache
		-- Stat setting end --
	end
	
	function StatScript:onPefUpdate(player)
		local pData = player:GetData()
		local BlackHearts = BitmapConverter.BitmapConvert(player:GetBlackHearts())
		
		if game:GetFrameCount() == 0 then
			Stats.ExtraHealth = 0 -- Set extra health to 0
		end
		
		if game:GetFrameCount() == 1 then -- If game just started
			-- Ensures player cannot die from heart damage --
			if player:GetName() ~= "???" then
				Stats.ExtraHealth = Stats.ExtraHealth + (player:GetSoulHearts() * 5) -- Set extra health
			else
				Stats.ExtraHealth = (round(Stats.Vitality * 2) + Stats.ExtraHealth) -- Set ??? extra health
			end
			Stats.HealthDif = 0 -- Set health difference to 0
			-- Set stats according to mod stats --
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- Add damage cache flag for evaluation
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) -- Add fire delay flag for evaluation
			player:AddCacheFlags(CacheFlag.CACHE_LUCK) -- Add luck flag for evaluation
			player:EvaluateItems() -- Evaluate cache
			-- Stat setting end --
		end
		
		-- Set stats according to mod stats --
		if player:GetName() ~= "???" and player:GetName() ~= "The Lost" then -- ??? and The Lost never have red heart health
			Stats.MaxHealth = (round(Stats.Vitality * 2) + Stats.HealthDif)
		else
			Stats.MaxHealth = 0
		end
		CritChance.Crit = round((Stats.Dexterity / 150), 2)
		CritChance.OVERCRIT = round((CritChance.Crit / 10), 2)
		CritChance.DOUBLE_OVERCRIT = round((CritChance.Crit / 100), 2)
		-- Stat setting end --
		
		if game:GetFrameCount() > 2 then
				-- Health overhaul --
			if player:GetMaxHearts() ~= 14 then -- If max hearts not equal to 7
				if game:GetFrameCount() == 3 then
					player:AddMaxHearts(14 - player:GetMaxHearts()) -- Set max hearts to 7 hearts
				else
					if Stats.MaxHealth <= 0 and player:GetMaxHearts() ~= 0 then
						Stats.HealthDif = Stats.HealthDif + (player:GetMaxHearts() * 5) -- Change health by heart difference (via health difference stat)
						Stats.MaxHealth = (round(Stats.Vitality * 2) + Stats.HealthDif) -- Ensures max health is set before health is healed (so health failsafe is not triggered)
						player:AddMaxHearts(14 - player:GetMaxHearts()) -- Set max hearts to 7 hearts
					elseif Stats.MaxHealth > 0 then
						Stats.HealthDif = Stats.HealthDif - ((14 - player:GetMaxHearts()) * 5) -- Change health by heart difference (via health difference stat)
						Stats.MaxHealth = (round(Stats.Vitality * 2) + Stats.HealthDif) -- Ensures max health is set before health is healed (so health failsafe is not triggered)
						player:AddMaxHearts(14 - player:GetMaxHearts()) -- Set max hearts to 7 hearts
					end
				end
			end
			if Stats.MaxHealth <= 0 then
				player:AddMaxHearts(-player:GetMaxHearts()) -- Set max hearts to 0 hearts
				Stats.MaxHealth = 0 -- Set max health to 0
			end
			if player:GetSoulHearts() ~= 0 and Stats.ExtraHealth == 0 then -- If player has soul hearts or black hearts and player has no extra health
				Stats.ExtraHealth = Stats.ExtraHealth + (player:GetSoulHearts()*5) -- Add the number of gained soul hearts to extra health
				player:AddBlackHearts(-BlackHearts) -- Remove black hearts
				player:AddSoulHearts(6 - player:GetSoulHearts()) -- Remove soul hearts
			elseif player:GetSoulHearts() ~= 6 and Stats.ExtraHealth ~= 0 then -- If player soul hearts not 3 soul heart and player has extra health
				Stats.ExtraHealth = Stats.ExtraHealth - ((6 - player:GetSoulHearts())*5) -- Add the number of gained soul hearts to extra health
				if Stats.ExtraHealth == 0 then
					player:AddBlackHearts(-BlackHearts) -- Remove black hearts
					player:AddSoulHearts(-player:GetSoulHearts()) -- Set soul hearts to 0
				else
					player:AddBlackHearts(-BlackHearts) -- Remove black hearts
					player:AddSoulHearts(6 - player:GetSoulHearts()) -- Set soul hearts to 3
				end
			end
			if player:GetHearts() ~= 3 and Stats.Health ~= Stats.MaxHealth and Stats.Health > 10 then
				if pData.FromFull ~= false then -- If dropping to 1.5 hearts because health dropping from full or because of game restart (don't want health change from that)
					pData.FromFull = false -- Set FromFull data to false
				elseif pData.FromFull == false and player:GetHearts() > 3 then -- If regaining health (not dropping from full health)
					if player:GetHearts() == player:GetMaxHearts() then
						Stats.Health = Stats.MaxHealth
					else
						Stats.Health = Stats.Health - ((3 - player:GetHearts()) * 5) -- Heal the player
					end
				end
				player:AddHearts(3 - player:GetHearts()) -- Set player hearts to 1.5
			elseif player:GetHearts() ~= 2 and Stats.Health ~= Stats.MaxHealth and Stats.Health <= 10 and Stats.Health > 5 then
				if pData.FromFull ~= false then -- If dropping to 1 hearts because health dropping from full or because of game restart (don't want health change from that)
					pData.FromFull = false -- Set FromFull data to false
				elseif pData.FromFull == false and player:GetHearts() > 2 then -- If regaining health (not dropping from full health)
					if player:GetHearts() == player:GetMaxHearts() then
						Stats.Health = Stats.MaxHealth
					else
						Stats.Health = Stats.Health - ((2 - player:GetHearts()) * 5) -- Heal the player
					end
				end
				player:AddHearts(2 - player:GetHearts()) -- Set player hearts to 1
			elseif player:GetHearts() ~= 1 and Stats.Health ~= Stats.MaxHealth and Stats.Health <= 5 then
				if pData.FromFull ~= false then -- If dropping to 0.5 hearts because health dropping from full or because of game restart (don't want health change from that)
					pData.FromFull = false -- Set FromFull data to false
				elseif pData.FromFull == false and player:GetHearts() > 1 then -- If regaining health (not dropping from full health)
					if player:GetHearts() == player:GetMaxHearts() then
						Stats.Health = Stats.MaxHealth
					else
						Stats.Health = Stats.Health - ((1 - player:GetHearts()) * 5) -- Heal the player
					end
				end
				player:AddHearts(1 - player:GetHearts()) -- Set player hearts to 0.5
			elseif player:GetHearts() ~= player:GetMaxHearts() and Stats.Health == Stats.MaxHealth then -- If player health is max health
				if pData.FromFull ~= true then -- If health regained to full
					pData.FromFull = true -- Set FromFull data to true
				end
				player:SetFullHearts() -- Sets player hearts to full hearts
			end
			
			if player:GetName() ~= "The Lost" then -- The Lost always has 0 health, so death handled by on damage
				if Stats.Health <= 0 and Stats.ExtraHealth <= 0 then -- If health is <= 0
					Stats.Health = 0 -- Set health to 0
					player:AddHearts(-24) -- Remove all player hearts
					if player:GetExtraLives() > 0 then -- If player has extra lives
						player:Revive() -- Revive player
						Stats.Health = Stats.MaxHealth -- Set health to maximum health
					else
						player:Die() -- PLayer dies
					end
				end
			end
			if Stats.Health > Stats.MaxHealth then -- If health stat is greater than maximum health (should never happen, but just in case)
				Stats.Health = Stats.MaxHealth -- Set health to maximum health
			end
		
			for _, entity in pairs(Isaac.GetRoomEntities()) do -- Loop over all room entities
				if player:GetName() ~= "The Lost" then -- No picking up hearts for The Lost
					if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_HEART and entity:GetData().Picked == nil and entity:GetSprite():IsPlaying("Collect") then -- If not collected heart pickup and is playing collect animation
						entity:GetData().Picked = true -- Sets entity has been picked up
						if entity.SubType == HeartSubType.HEART_ETERNAL then -- If entity is eternal heart
							if Stats.EternalArmor == false and Stats.GoldenArmor == false then -- If player doesn't have health armour
								Stats.EternalArmor = true -- Give player eternal heart health armour
							end
						elseif entity.SubType == HeartSubType.HEART_GOLDEN then -- If entity is golden heart
							if Stats.EternalArmor == false and Stats.GoldenArmor == false then -- If player doesn't have health armour
								Stats.GoldenArmor = true -- Give player golden heart health armour
							end
						end
					end
				end
			end
		end
		
		if game:GetFrameCount() == 2 then -- If game has been running for 2 frames (so stats can be initialised first)
			if player:GetMaxHearts() ~= 6 then -- If max hearts not equal to 3
				Stats.HealthDif = Stats.HealthDif - ((6 - player:GetMaxHearts()) * 5) -- Change health by heart difference (via health difference stat)
				Stats.MaxHealth = (round(Stats.Vitality * 2) + Stats.HealthDif) -- Ensures max health is set before health is healed (so health failsafe is not triggered)
				if player:GetMaxHearts() > 6 then -- Only heal health if it went up
					Stats.Health = Stats.Health - ((6 - player:GetMaxHearts()) * 5) -- Heals health by health gained
				end
			end
			if player:GetSoulHearts() ~= 0 and Stats.ExtraHealth == 0 then -- If player has soul hearts or black hearts and player has no extra health
				player:AddBlackHearts(-BlackHearts) -- Remove black hearts
				player:AddSoulHearts(-(player:GetSoulHearts())) -- Remove soul hearts
			elseif player:GetSoulHearts() ~= 6 and Stats.ExtraHealth ~= 0 then -- If player soul hearts not 3 soul heart and player has extra health
				player:AddBlackHearts(-BlackHearts) -- Remove black hearts
				player:AddSoulHearts(6 - player:GetSoulHearts()) -- Set soul hearts to 3
			end
			if player:GetHearts() ~= player:GetMaxHearts() and Stats.Health == Stats.MaxHealth then -- If player health is max health
				if pData.FromFull ~= true then -- If health regained to full
					pData.FromFull = true -- Set FromFull data to true
				end
				player:SetFullHearts() -- Sets player hearts to full hearts
			end
			Stats.Health = Stats.MaxHealth
			-- Health overhaul end --
		end
	end
	
	function StatScript:onPlayerDamage(_, damage, _, source)
		-- Player health damage --
		local player = Isaac.GetPlayer(0) -- Gets player
		if player:GetName() == "The Lost" then
			if player:GetExtraLives() > 0 then -- If player has extra lives
				player:Revive() -- Revive player
				Stats.Health = Stats.MaxHealth -- Set health to maximum health
			else
				player:Die() -- Player dies
			end
		end
		if source.Entity:IsBoss() then -- If damage source was a boss
			if Stats.GoldenArmor ~= true and Stats.EternalArmor ~= true then -- If player does not have health armour
				if Stats.ExtraHealth > 0 then -- If player has extra health (soul heart equivalent)
					if Stats.ExtraHealth - ((damage + (damage * ((Stats.Level - 1) * 0.2))) * 5) >= 0 then -- If player can take the damage from extra health without losing it all
						Stats.ExtraHealth = Stats.ExtraHealth - ((damage + (damage * ((Stats.Level - 1) * 0.2))) * 5) -- Take the damage from extra health (boss damage increases by 1 per level)
					else
						Stats.ExtraHealth = 0 -- Set extra health to 0
					end
				else
					Stats.Health = Stats.Health - ((damage + (damage * ((Stats.Level - 1) * 0.2))) * 5) -- Take the damage from health (boss damage increases by 1 per level)
				end
			else
				Stats.GoldenArmor = false -- Set golden heart health armour to false
				Stats.EternalArmor = false -- Set eternal heart health armour to false
			end
		else
			if Stats.GoldenArmor ~= true and Stats.EternalArmor ~= true then -- If player does not have health armour
				if Stats.ExtraHealth > 0 then -- If player has extra health (soul heart equivalent)
					if Stats.ExtraHealth - (damage * 5) >= 0 then -- If player can take the damage from extra health without losing it all
						Stats.ExtraHealth = Stats.ExtraHealth - (damage * 5) -- Take the damage from extra health
					else
						Stats.ExtraHealth = 0 -- Set extra health to 0
					end
				else
					Stats.Health = Stats.Health - (damage * 5) -- Take the damage from health
				end
			else
				Stats.GoldenArmor = false -- Set golden heart health armour to false
				Stats.EternalArmor = false -- Set eternal heart health armour to false
			end
		end
	end
	
	function StatScript:onEnemySpawn(entity)
		--Increase boss health based on player level --
		if entity:IsBoss() then
			entity.MaxHitPoints = entity.MaxHitPoints + (entity.MaxHitPoints * ((Stats.Level-1) * 0.05)) -- Increases maximum hit points of spawned entity
			entity.HitPoints = entity.MaxHitPoints -- Heals entity to maximum hit points (so that entity starts on max health)
		else
			TrashHPMult = ((Stats.Level-1) * 0.2)*((level:GetAbsoluteStage()*0.5)+0.5) -- Sets trash mob HP multiplier
			entity.MaxHitPoints = entity.MaxHitPoints + (entity.MaxHitPoints * (TrashHPMult * 0.1)) -- Increases maximum hit points of spawned entity
			entity.HitPoints = entity.MaxHitPoints -- Heals entity to maximum hit points (so that entity starts on max health)
		end
	end
	
	function StatScript:onEval(CurseFlags)
		return CurseFlags | 1 << 3 -- Gives curse of the unknown on top of other curses (don't need to see num. hearts, numerical health system)
	end
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, StatScript.onRender)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, StatScript.onCache)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, StatScript.onPlayerInit)
Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, StatScript.onPefUpdate)
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, StatScript.onPlayerDamage, EntityType.ENTITY_PLAYER)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, StatScript.onEnemySpawn)
Mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, StatScript.onEval)
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, StatScript.onGameExit)

---------------------
--   Script for    --
--    Stat Menu    --
---------------------
local MenuScript = {}
	-- Variables --
	local sfont = nil
	local invUI = nil
	local pageUI = 1
	local buttonpressed = false
	local buttontimer = 15
	local actionbutton = 0
	local phase = 10
	local selectedline = 1
	
	local invPosition = Vector(170,64)
	
	-- Colours --
	local c_gray = Color(0.5,0.5,0.5,1,0,0,0)
	local c_white = Color(1,1,1,1,0,0,0)
	local c_yellow = Color(1,1,0,1,0,0,0)
	local c_paper = Color(0.6,0.52,0.46,1,0,0,0)
	
	function MenuScript:WriteText(text, px, py, align, col)
		local fontw = 6
		local ch

		if sfont == nil then -- If sfont not defined
			sfont = Sprite() -- sfont set to be Sprite()
			sfont:Load("/gfx/ui/Fonts.anm2",true) -- sfont loads fonts animation
			sfont:Play("Idle") -- sfont plays idle animation
		end

		if align == 1 then -- Align 1 = align centre
			px = px - ((string.len(text) * fontw) / 2) + (fontw/2) -- Aligns text central
		elseif align == 2 then -- Align 2 = alight right
			px = px - (string.len(text) * fontw) -- Aligns text right
		end

		sfont.Color = col -- Sets colour of the font

		for i=1, string.len(text) do -- Loop over letters in the text
			ch = string.byte(text,i) - 32 -- Converts each letter in message into a character
			sfont:SetLayerFrame(0,ch) -- Sets the frame of the sfont to that in the position of the character number
			sfont:Render(Vector(px + ((i-1)*fontw), py), Vector(0,0), Vector(0,0)) -- Renders the letter
		end
	end
	
	function MenuScript:DrawMenu(player)
		local drawline = 0 -- Line position
		local rowA = 0 -- First row position
		local rowB = 135 -- Second row position

		if invUI == nil then -- If invUI not defined
			invUI = Sprite() -- invUI set to be Sprite()
			invUI:Load("/gfx/ui/MenuUI.anm2",true) -- invUI loads menu animation
		end
		
		if pageUI == 1 then
			invUI:Play("Swap1") -- invUI plays swap paper animation (static)
			invUI:Render(invPosition, Vector(0,0), Vector(0,0)) -- invUI renders at invPosition
			
			MenuScript:WriteText("STAT MENU", invPosition.X-15, invPosition.Y-15, 0, c_paper) -- Write text "STAT MENU" at top left corner of menu
			MenuScript:WriteText(player:GetName(), invPosition.X+150, invPosition.Y-15, 2, c_paper) -- Write player name at top right corner of menu
			MenuScript:WriteText("STAT POINTS: "..Points.Points_Stat, invPosition.X+130, invPosition.Y+75, 2, c_paper)

			rowA = invPosition.X-5 -- Sets first row position
			rowB = rowA + rowB -- Sets second row position
			drawline = invPosition.Y -- Sets draw position of first line
			
			MenuScript:WriteText("Health", rowA, drawline, 0, c_paper) -- Writes text "Health" in row A
			MenuScript:WriteText(string.format("%.2f",Stats.MaxHealth), rowB, drawline, 2, c_white) -- Writes maximum health in row B
			drawline = drawline + 12 -- Sets draw position of next line
			MenuScript:WriteText("Damage", rowA, drawline, 0, c_paper) -- Writes text "Damage" in row A
			MenuScript:WriteText(string.format("%.2f",player.Damage), rowB, drawline, 2, c_white) -- Writes player damage in row B
			drawline = drawline + 12 -- Sets draw position of next line
			MenuScript:WriteText("Fire rate", rowA, drawline, 0, c_paper) -- Writes text "Fire Rate" in row A
			MenuScript:WriteText(string.format("%.2f",30/player.MaxFireDelay).." /s", rowB, drawline, 2, c_white) -- Writes player tears per second in row B
			drawline = drawline + 12 -- Sets draw position of next line
			MenuScript:WriteText("Crit. Chance", rowA, drawline, 0, c_paper) -- Writes text "Crit. Chance" in row A
			MenuScript:WriteText(string.format("%.2f",(CritChance.Crit*100)).."%", rowB, drawline, 2, c_white) -- Writes player crit chance (in %) in row B
			drawline = drawline + 12 -- Sets draw position of next line
			MenuScript:WriteText("Crit. Damage", rowA, drawline, 0, c_paper) -- Writes text "Crit. Damage" in row A
			MenuScript:WriteText(string.format("%.2f",CritDamage.CRIT).."x", rowB, drawline, 2, c_white) -- Writes player crit damage in row B
			drawline = drawline + 12 -- Sets draw position of next line
			MenuScript:WriteText("Luck", rowA, drawline, 0, c_paper) -- Writes text "Luck" in row A
			MenuScript:WriteText(string.format("%.0f",player.Luck), rowB, drawline, 2, c_white) -- Writes player luck in row B
			
			local cline -- Creates line colour variable (to change in certain circumstances) for row A
			local cline2 -- Creates line colour variable (to change in certain circumstances) for row B
			
			drawline = drawline + 24 -- Sets draw position of next line
			if (selectedline == 1) then cline = c_white cline2 = c_yellow else cline = c_paper cline2 = c_gray end -- Changes colour of line 1 depending on if it is selected
			MenuScript:WriteText("STR", rowA, drawline, 0, cline) -- Write text "STR" in row A
			drawline = drawline + 10 -- Sets draw position of next line
			if Points.Points_Stat > 0 then -- If stat points available to spend
				if Stats.Strength > 15 then -- If Strength stat higher than the default
					MenuScript:WriteText("< "..Stats.Strength.." >", rowB, drawline, 2, cline2) -- Writes strength stat with "< >" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Strength.." >", rowB, drawline, 2, cline2) -- Writes strength stat with "> >" around it in row B
				end
			else
				if Stats.Strength > 15 then -- If Strength stat higher than the default
					MenuScript:WriteText("< "..Stats.Strength.." <", rowB, drawline, 2, cline2) -- Writes strength stat with "< <" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Strength.." <", rowB, drawline, 2, cline2) -- Writes strength stat with "> <" around it in row B
				end
			end
			drawline = drawline + 12 -- Sets draw position of next line
			if (selectedline == 2) then cline = c_white cline2 = c_yellow else cline = c_paper cline2 = c_gray end -- Changes colour of line 2 depending on if it is selected
			MenuScript:WriteText("DEX", rowA, drawline, 0, cline) -- Writes text "DEX" in row A
			drawline = drawline + 10 -- Sets draw position of next line
			if Points.Points_Stat > 0 then -- If stat points available to spend
				if Stats.Dexterity > 15 then -- If Dexterity stat higher than the default
					MenuScript:WriteText("< "..Stats.Dexterity.." >", rowB, drawline, 2, cline2) -- Writes dexterity stat with "< >" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Dexterity.." >", rowB, drawline, 2, cline2) -- Writes dexterity stat with "> >" around it in row B
				end
			else
				if Stats.Dexterity > 15 then -- If Dexterity stat higher than the default
					MenuScript:WriteText("< "..Stats.Dexterity.." <", rowB, drawline, 2, cline2) -- Writes dexterity stat with "< <" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Dexterity.." <", rowB, drawline, 2, cline2) -- Writes dexterity stat with "> <" around it in row B
				end
			end
			drawline = drawline + 12 -- Sets draw position of next line
			if (selectedline == 3) then cline = c_white cline2 = c_yellow else cline = c_paper cline2 = c_gray end -- Changes colour of line 3 depending on if it is selected
			MenuScript:WriteText("VIT", rowA, drawline, 0, cline) -- Write text "VIT" in row A
			drawline = drawline + 10 -- Sets draw position of next line
			if Points.Points_Stat > 0 then -- If stat points available to spend
				if Stats.Vitality > 15 then -- If Vitality stat higher than the default
					MenuScript:WriteText("< "..Stats.Vitality.." >", rowB, drawline, 2, cline2) -- Writes vitality stat with "< >" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Vitality.." >", rowB, drawline, 2, cline2) -- Writes vitality stat with "< >" around it in row B
				end
			else
				if Stats.Vitality > 15 then -- If Vitality stat higher than the default
					MenuScript:WriteText("< "..Stats.Vitality.." <", rowB, drawline, 2, cline2) -- Writes vitality stat with "< <" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Vitality.." <", rowB, drawline, 2, cline2) -- Writes vitality stat with "> <" around it in row B
				end
			end
			drawline = drawline + 12 -- Sets draw position of next line
			if (selectedline == 4) then cline = c_white cline2 = c_yellow else cline = c_paper cline2 = c_gray end -- Changes colour of line 4 depending on if it is selected
			MenuScript:WriteText("LCK", rowA, drawline, 0, cline) -- Write text "LCK" in row A
			drawline = drawline + 10 -- Sets draw position of next line
			if Points.Points_Stat > 0 then -- If stat points available to spend
				if Stats.Luck > 0 then -- If Luck stat higher than the default
					MenuScript:WriteText("< "..Stats.Luck.." >", rowB, drawline, 2, cline2) -- Writes luck stat with "< >" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Luck.." >", rowB, drawline, 2, cline2) -- Writes luck stat with "> >" around it in row B
				end
			else
				if Stats.Luck > 0 then -- If Luck stat higher than the default
					MenuScript:WriteText("< "..Stats.Luck.." <", rowB, drawline, 2, cline2) -- Writes luck stat with "< <" around it in row B
				else
					MenuScript:WriteText("> "..Stats.Luck.." <", rowB, drawline, 2, cline2) -- Writes luck stat with "> <" around it in row B
				end
			end
			drawline = drawline + 12 -- Sets draw position of next line
			if (selectedline == 5) then cline = c_white cline2 = c_yellow else cline = c_paper cline2 = c_gray end -- Changes colour of line 5 depending on if it is selected
			MenuScript:WriteText("REBIRTH?", rowA, drawline, 0, cline) -- Writes text "REBIRTH?" in row A
			drawline = drawline + 10 -- Sets draw position of next line
			if Stats.Level == 100 and Stats.Experience == Stats.MaxExperience then -- If max level and max exp
				MenuScript:WriteText("DO IT", rowB, drawline, 2, cline2) -- Writes text "DO IT" in row B
			else
				MenuScript:WriteText("NEED MORE EXP", rowB, drawline, 2, c_gray) -- Writes text "NEED MORE EXP" in row B (gray colour)
			end
		end
	end
	
	function MenuScript:UIRender()
		local player = Isaac.GetPlayer(0) -- Get player

		if phase == 0 then -- If current phase is 0
			MenuScript:DrawMenu(player) -- Draw the menu
		end
	end
	
	function MenuScript:UPDATEui()
		local player = Isaac.GetPlayer(0) -- Get player

		if player.FrameCount == 3 then -- If player frame count is 3
			pageUI = 1 -- Set current page to 1
			selectedline = 1 -- Set selected line to 1
		elseif Input.IsButtonPressed(Keyboard.KEY_T, 0) then -- If pressed key T
			if buttonpressed == false then -- If button pressed is false
				if phase == 10 then -- If phase is 10
					phase = 0 -- Set phase to 0
					player.ControlsEnabled = false -- Disable player controls
				else
					phase = 10 -- Set phase to 10
					player.ControlsEnabled = true -- Enable player controls
				end
				buttonpressed = true -- Set button pressed to true
			end
		elseif Input.IsActionPressed(ButtonAction.ACTION_DOWN,player.ControllerIndex) and phase ~= 10 then -- If in menu and move down (S key) is pressed
			if buttonpressed == false then -- If button pressed is false
				if pageUI == 1 then -- If current page is 2
					selectedline = math.min(selectedline + 1, 5) -- Set selected line to next line (up to 5)
				end
				buttonpressed = true -- Set button pressed to true
			end
		elseif Input.IsActionPressed(ButtonAction.ACTION_UP,player.ControllerIndex) and (phase ~= 10) then -- If in menu and move up (W key) is pressed
			if buttonpressed == false then -- If button pressed is false
				if pageUI == 1 then -- If current page is 2
					selectedline = math.max(selectedline - 1, 1) -- Set selected line to previous line (up to 0)
				end
				buttonpressed = true -- Set button pressed to true
			end
		elseif Input.IsActionPressed(ButtonAction.ACTION_RIGHT,player.ControllerIndex) and (phase ~= 10) and (phase ~= 6) then -- If in menu and move right (D key) is pressed
			if (buttonpressed == false) then -- If button pressed is false
				if pageUI == 1 then -- If current page is 2
					if selectedline == 1 then -- If selected line is 1
						if Points.Points_Stat > 0 then -- If stat points available to spend
							Stats.Strength = Stats.Strength + 1 -- Increase strength by 1
							Points.Points_Stat = Points.Points_Stat - 1 -- Decrease stat points by 1
							player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- Add damage cache flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					elseif selectedline == 2 then -- If selected line is 2
						if Points.Points_Stat > 0 then -- If stat points available to spend
							Stats.Dexterity = Stats.Dexterity + 1 -- Increase dexterity by 1
							Points.Points_Stat = Points.Points_Stat - 1 -- Decrease stat points by 1
							player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) -- Add fire delay flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					elseif selectedline == 3 then -- If selected line is 3
						if Points.Points_Stat > 0 then -- If stat points available to spend
							Stats.Vitality = Stats.Vitality + 1 -- Increase vitality by 1
							Points.Points_Stat = Points.Points_Stat - 1 -- Decrease stat points by 1
							Stats.Health = Stats.Health + 2 -- Increase Health by amount of health gained
						end
					elseif selectedline == 4 then -- If selected line is 4
						if Points.Points_Stat > 0 then -- If stat points available to spend
							Stats.Luck = Stats.Luck + 1 -- Increase luck by 1
							Points.Points_Stat = Points.Points_Stat - 1 -- Decrease stat points by 1
							player:AddCacheFlags(CacheFlag.CACHE_LUCK) -- Add luck flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					end
				end
				buttonpressed = true -- Set button pressed to true
			end
		elseif Input.IsActionPressed(ButtonAction.ACTION_LEFT,player.ControllerIndex) and (phase ~= 10) and (phase ~= 6) then -- If in menu and move left (A key) is pressed
			if buttonpressed == false then -- If button pressed is false
				if pageUI == 1 then -- If current page is 2
					if selectedline == 1 then -- If selected line is 1
						if Stats.Strength > 15 then -- If strength stat is more than base strength
							Stats.Strength = Stats.Strength - 1 -- Decrease strength by 1
							Points.Points_Stat = Points.Points_Stat + 1 -- Set stat points to stat points + 1
							player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- Add damage cache flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					elseif selectedline == 2 then -- If selected line is 2
						if Stats.Dexterity > 15 then -- If dexterity stat is more than base dexterity
							Stats.Dexterity = Stats.Dexterity - 1 -- Decrease dexterity by 1
							Points.Points_Stat = Points.Points_Stat + 1 -- Set stat points to stat points + 1
							player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) -- Add fire delay flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					elseif selectedline == 3 then -- If selected line is 3
						if Stats.Vitality > 15 then -- If vitality stat is more than base vitality
							Stats.Vitality = Stats.Vitality - 1 -- Decrease vitality by 1
							Points.Points_Stat = Points.Points_Stat + 1 -- Set stat points to stat points + 1
							Stats.Health = Stats.Health - 2 -- Decrease Health by amount of health lost
						end
					elseif selectedline == 4 then -- If selected line is 4
						if Stats.Luck > 0 then -- If luck stat is more than base luck
							Stats.Luck = Stats.Luck - 1 -- Decrease luck by 1
							Points.Points_Stat = Points.Points_Stat + 1 -- Set stat points to stat points + 1
							player:AddCacheFlags(CacheFlag.CACHE_LUCK) -- Add luck flag for evaluation
							player:EvaluateItems() -- Evaluate cache
						end
					end
				end
				buttonpressed = true -- Set button pressed to true
			end
		elseif Input.IsActionPressed(ButtonAction.ACTION_BOMB, player.ControllerIndex) and (phase ~= 10) and (phase ~= 6) then -- If in menu and bomb (E key) is pressed
			if pageUI == 1 then -- If current page is 2
				if selectedline == 5 then -- If selected line is 5
					if Stats.Level == 100 and Stats.Experience == Stats.MaxExperience then -- If max level and max exp
						LevelScript:Rebirth(player) -- Run Rebirth function
					end
				end
			end
		else
			buttonpressed = false -- Set button pressed to false
			buttontimer = 15 -- Set button timer to 15
			actionbutton = 0 -- Set action button to 0
		end
	end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, MenuScript.UPDATEui)
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, MenuScript.UIRender)

---------------------
--   Script for    --
-- Critical System --
---------------------
local CriticalScript = {}
	local CritId = Isaac.GetItemIdByName("Crit")
	
	function CriticalScript:onDamage(entity, damage, _, source)
		local player = Isaac.GetPlayer(0) -- Gets the player
		if entity:IsVulnerableEnemy() and (source.Type == EntityType.ENTITY_TEAR or source.Type == EntityType.ENTITY_LASER or source.Type == EntityType.ENTITY_KNIFE or source.Type == EntityType.ENTITY_EFFECT) then -- Only crit with player projectiles or lasers
			local rng = player:GetCollectibleRNG(CritId) -- Creates RNG using the Crit item (never implemented, also does not need to be given to player in order to use
			if rng:RandomFloat() < CritChance.CRIT then -- If RNG value is lower than the crit chance (crit chance is maximum value to roll from 0)
				if rng:RandomFloat() < CritChance.OVERCRIT then -- If RNG value is lower than the overcrit change
					if rng:RandomFloat() < CritChance.DOUBLE_OVERCRIT then -- If RNG value is lower than double overcrit chance
						entity:TakeDamage(damage * (CritDamage.DOUBLE_OVERCRIT - 1), 0, EntityRef(player), 0) -- If get double overcrit, entity takes double overcrit damage
						sfxManager:Play(SoundEffect.SOUND_DIMEPICKUP, 1.0, 0, false, 1.0) -- If get double overcrit, dime pickup sound plays
					else
						entity:TakeDamage(damage * (CritDamage.OVERCRIT - 1), 0, EntityRef(player), 0) -- If get overcrit, entity takes overcrit damage
						sfxManager:Play(SoundEffect.SOUND_NICKELPICKUP, 1.0, 0, false, 1.0) -- If get overcrit, nickel pickup sound plays
					end
				else
					entity:TakeDamage(damage * (CritDamage.CRIT - 1), 0, EntityRef(player), 0) -- If get crit, entity takes crit damage
					sfxManager:Play(SoundEffect.SOUND_PENNYPICKUP, 1.0, 0, false, 1.0) -- If get crit, penny pickup sound plays
				end
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, source.Position, Vector(0,0), player) -- Spawn critical visual effect
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, source.Position, Vector(0,0), player) -- Spawn critical visual effect
			end
		end
	end
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CriticalScript.onDamage)
