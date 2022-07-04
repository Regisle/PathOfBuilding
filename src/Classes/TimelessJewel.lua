-- Path of Building
--
-- Class: TimelessJewel
-- TimelessJewel
--
local ipairs = ipairs
local t_insert = table.insert
local m_max = math.max
local m_min = math.min

-- Constants

--[[
TimelessJewel needs to have 
	AlternateTreeVersion
	AlternateTreeVersion.NotableReplacementSpawnWeight
	AlternateTreeVersion.AreSmallAttributePassiveSkillsReplaced
	AlternateTreeVersion.AreSmallNormalPassiveSkillsReplaced
	AlternateTreeVersion.MinimumAdditions
	AlternateTreeVersion.MaximumAdditions
	Seed
	Keystone
DataManager needs to have
	GetAlternatePassiveSkillKeyStone(self.TimelessJewel)
	GetApplicableAlternatePassiveSkills(PassiveSkill, self.TimelessJewel)
	GetApplicableAlternatePassiveAdditions(PassiveSkill, self.TimelessJewel)
	
	-> if implementing last two functions here also needs
		GetPassiveSkillType  (used for <ANY> function to match)
		AlternatePassiveSkills (list of all)
		AlternatePassiveAdditions  (list of all)
--]]
local TimelessJewelClass = newClass("TimelessJewel", function(self, TimelessJewel, DataManager)
	self.TimelessJewel = TimelessJewel
	self.DataManager = DataManager
	
	-- not sure if keep these here or move it
	self.DataManager.GetApplicableAlternatePassiveSkills = function(passiveSkill, TimelessJewel)
		local alternatePassiveSkills = {}
		for _, alternatePassiveSkill in ipairs(DataManager.AlternatePassiveSkills)
			local passiveSkillType = DataManager.GetPassiveSkillType(passiveSkill)
			-- FIX THIS (<ANY>)
			if (alternatePassiveSkill.AlternateTreeVersionIndex == timelessJewel.AlternateTreeVersion.Index) and (alternatePassiveSkill.ApplicablePassiveTypes.Any<uint>((Func<uint, bool>) (q => (PassiveSkillType) q == passiveSkillType)))
				t_insert(alternatePassiveSkills, alternatePassiveSkill)
			end
			return alternatePassiveSkills
		end
	end
	self.DataManager.GetApplicableAlternatePassiveAdditions = function(passiveSkill, TimelessJewel)
		local passiveAdditions = {}
		for _, alternatePassiveAddition in ipairs(DataManager.AlternatePassiveAdditions)
			local passiveSkillType = DataManager.GetPassiveSkillType(passiveSkill)
			-- FIX THIS (<ANY>)
			if (alternatePassiveAddition.AlternateTreeVersionIndex == timelessJewel.AlternateTreeVersion.Index) and (alternatePassiveAddition.ApplicablePassiveTypes.Any<uint>((Func<uint, bool>) (q => (PassiveSkillType) q == passiveSkillType)))
				t_insert(passiveAdditions, alternatePassiveAddition)
			end
			return passiveAdditions
		end
	end
end


function TimelessJewelClass:IsPassiveSkillReplaced(PassiveSkill)
	if PassiveSkill.IsKeyStone then
		return true
	elseif PassiveSkill.IsNotable then
		local NotableReplacementSpawnWeight = self.TimelessJewel.AlternateTreeVersion.NotableReplacementSpawnWeight
		local randWeight = new RandomNumberGenerator({PassiveSkill.GraphIdentifier, self.TimelessJewel.Seed}).Generate(0, 100)
		return (NotableReplacementSpawnWeight >= 100) or (randWeight < NotableReplacementSpawnWeight)
	elseif PassiveSkill.StatIndices.Count == 1 then
		-- FIX THIS (Type Cast)
		local uint num = (uint) ((int) PassiveSkill.StatIndices[0] + 1 - 574)
		if (num <= 6U && (73 & 1 << (int) num) != 0) then
			return self.TimelessJewel.AlternateTreeVersion.AreSmallAttributePassiveSkillsReplaced
		end
	end
	return self.TimelessJewel.AlternateTreeVersion.AreSmallNormalPassiveSkillsReplaced
end


function TimelessJewelClass:ReplacePassiveSkill(PassiveSkill)
	--[[ --keystones implemented elsewhere
	if PassiveSkill.IsKeyStone then
		local altNode = {}
		altNode.alternatePassiveSkill = self.DataManager.GetAlternatePassiveSkillKeyStone(self.TimelessJewel)
		altNode.statRolls = {}
		altNode.alternatePassiveAdditionInformations = {}
		return altNode 
	end
	--]]
	local alternatePassiveSkill = nil
	local randomNumberGenerator = new RandomNumberGenerator({PassiveSkill.GraphIdentifier, self.TimelessJewel.Seed})
	local exclusiveMaximumValue = 0
	if PassiveSkill.IsNotable then--(DataManager.GetPassiveSkillType(this.PassiveSkill) == PassiveSkillType.Notable)
		randomNumberGenerator.Generate(0, 100)  --throw away return, just using it to advance prng state,  local num1 = randomNumberGenerator.Generate(0, 100)
	end
	for _, alternatePassiveSkill2 in ipairs(self.DataManager.GetApplicableAlternatePassiveSkills(PassiveSkill, self.TimelessJewel)) do
		exclusiveMaximumValue += alternatePassiveSkill2.SpawnWeight
		if (randomNumberGenerator.Generate(exclusiveMaximumValue) < alternatePassiveSkill2.SpawnWeight)
			alternatePassiveSkill = alternatePassiveSkill2
		end
	end
	local dictionary1 = {}
	dictionary1[0] = {alternatePassiveSkill.StatAMinimumValue, alternatePassiveSkill.StatAMaximumValue}
	dictionary1[1] = {alternatePassiveSkill.StatBMinimumValue, alternatePassiveSkill.StatBMaximumValue}
	dictionary1[2] = {alternatePassiveSkill.StatCMinimumValue, alternatePassiveSkill.StatCMaximumValue}
	dictionary1[3] = {alternatePassiveSkill.StatDMinimumValue, alternatePassiveSkill.StatDMaximumValue}
	local statRolls = {}
	for key=0,math.Min(alternatePassiveSkill.StatIndices.Count, 4),1 do --for (uint key = 0; (long) key < (long) Math.Min(alternatePassiveSkill1.StatIndices.Count, 4); ++key)
		local num2 = dictionary1[key][0]
		if (dictionary1[key][1] > dictionary1[key][0])
			num2 = randomNumberGenerator.Generate(dictionary1[key][0], dictionary1[key][1])
		end
		t_insert(statRolls, {key, num2})
	end
	if (alternatePassiveSkill.MinimumAdditions == 0) and (alternatePassiveSkill.MaximumAdditions == 0) then
		local altNode = {}
		altNode.alternatePassiveSkill = alternatePassiveSkill
		altNode.statRolls = statRolls
		altNode.alternatePassiveAdditionInformations = {}
		return altNode 
	end
	local minimumValue = self.TimelessJewel.AlternateTreeVersion.MinimumAdditions + alternatePassiveSkill.MinimumAdditions
	local maximumValue = self.TimelessJewel.AlternateTreeVersion.MaximumAdditions + alternatePassiveSkill.MaximumAdditions
	local num3 = minimumValue
	if (maximumValue > minimumValue)
		num3 = randomNumberGenerator.Generate(minimumValue, maximumValue)
	end
	local altNode = {}
	altNode.alternatePassiveSkill = alternatePassiveSkill
	altNode.statRolls = statRolls
	altNode.alternatePassiveAdditionInformations = self.RollAlternatePassiveAdditions(PassiveSkill, randomNumberGenerator, num3)
	return altNode 
end


function TimelessJewelClass:AugmentPassiveSkill(PassiveSkill)
	local randomNumberGenerator = new RandomNumberGenerator({PassiveSkill.GraphIdentifier, self.TimelessJewel.Seed})
	if PassiveSkill.isNotable then --(DataManager.GetPassiveSkillType(PassiveSkill) == PassiveSkillType.Notable)
		randomNumberGenerator.Generate(0, 100) --throw away return, just using it to advance prng state, local num1 = randomNumberGenerator.Generate(0, 100)
	end
	local minimumAdditions = self.TimelessJewel.AlternateTreeVersion.MinimumAdditions
	local maximumAdditions = self.TimelessJewel.AlternateTreeVersion.MaximumAdditions
	local additionCountRoll  = minimumAdditions
	if (maximumAdditions > minimumAdditions)
		additionCountRoll  = randomNumberGenerator.Generate(minimumAdditions, maximumAdditions)
	end
	return self.RollAlternatePassiveAdditions(PassiveSkill, randomNumberGenerator, additionCountRoll)
end


function TimelessJewelClass:RollAlternatePassiveAdditions(PassiveSkill, randomNumberGenerator, additionCountRoll)
	local source = {}
	for index=0,additionCountRoll,1 do --for (int index = 0; (long) index < (long) num; ++index)
		local rolledAlternatePassiveAddition = nil
		while (rolledAlternatePassiveAddition == nil) do -- or additionInformationList.Any<AlternatePassiveAdditionInformation>((Func<AlternatePassiveAdditionInformation, bool>) (q => q.AlternatePassiveAddition == rolledAlternatePassiveAddition)))
			rolledAlternatePassiveAddition = self.RollAlternatePassiveAddition(PassiveSkill, randomNumberGenerator)
		end
		local alternatePassiveAdditionStatRollRanges  = {}
		alternatePassiveAdditionStatRollRanges [0] = {rolledAlternatePassiveAddition.StatAMinimumValue, rolledAlternatePassiveAddition.StatAMaximumValue}
		alternatePassiveAdditionStatRollRanges [1] = {rolledAlternatePassiveAddition.StatBMinimumValue, rolledAlternatePassiveAddition.StatBMaximumValue}
		local statRolls = {}
		for j=0,m_min(rolledAlternatePassiveAddition.StatIndices.Count, 2),1 do --for (uint key = 0; (long) key < (long) Math.Min(rolledAlternatePassiveAddition.StatIndices.Count, 2); ++key)
			local alternatePassiveAdditionStatRoll  = alternatePassiveAdditionStatRollRanges [j][0]
			if (alternatePassiveAdditionStatRollRanges [j][1] > alternatePassiveAdditionStatRollRanges [j][0])
				alternatePassiveAdditionStatRoll  = randomNumberGenerator.Generate(alternatePassiveAdditionStatRollRanges [j][0], alternatePassiveAdditionStatRollRanges [j][1])
			end
			t_insert(statRolls, {j, alternatePassiveAdditionStatRoll })
		end
		local AlternatePassiveAddition = {}
		AlternatePassiveAddition.AlternatePassiveAddition = rolledAlternatePassiveAddition
		AlternatePassiveAddition.StatRolls = statRolls
		t_insert(source, AlternatePassiveAddition)
	end
	return source
end


function TimelessJewelClass:RollAlternatePassiveAddition(PassiveSkill, randomNumberGenerator)
	local passiveAdditions = self.DataManager.GetApplicableAlternatePassiveAdditions(PassiveSkill, self.TimelessJewel)
	local maxWeight = 0
	for _, alternatePassiveAddition in ipairs(passiveAdditions) do --(uint) passiveAdditions.Sum<AlternatePassiveAddition>((Func<AlternatePassiveAddition, long>) (q => (long) q.SpawnWeight))
		maxWeight += alternatePassiveAddition.SpawnWeight
	end
	local additionRoll = randomNumberGenerator.Generate(maxWeight)
	for _, alternatePassiveAddition in ipairs(passiveAdditions)) do
		if (alternatePassiveAddition.SpawnWeight > additionRoll) then
			return alternatePassiveAddition
		additionRoll -= alternatePassiveAddition.SpawnWeight
	}
	return nil
end