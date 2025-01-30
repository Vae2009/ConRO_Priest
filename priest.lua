ConRO.Priest = {};
ConRO.Priest.CheckTalents = function()
end
ConRO.Priest.CheckPvPTalents = function()
end
local ConRO_Priest, ids = ...;

function ConRO:EnableRotationModule(mode)
	mode = mode or 0;
	self.ModuleOnEnable = ConRO.Priest.CheckTalents;
	self.ModuleOnEnable = ConRO.Priest.CheckPvPTalents;
	ConRO_AtonementButton:Hide();
	ConRO_RaidAtonementButton:Hide();
	if mode == 0 then
		self.Description = "Priest [No Specialization Under 10]";
		self.NextSpell = ConRO.Priest.Under10;
		self.ToggleHealer();
	end;
	if mode == 1 then
		self.Description = "Priest [Discipline - Healer]";
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextSpell = ConRO.Priest.Discipline;
			self.ToggleDamage();
			ConROButtonFrame:SetAlpha(1);
			ConRO_ShowAtonement();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow2:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow3:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Priest.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConROWindow2:SetAlpha(0);
			ConROWindow3:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 2 then
		self.Description = "Priest [Holy - Healer]";
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextSpell = ConRO.Priest.Holy;
			self.ToggleHealer();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow2:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow3:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Priest.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConROWindow2:SetAlpha(0);
			ConROWindow3:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 3 then
		self.Description = "Priest [Shadow - Caster]";
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextSpell = ConRO.Priest.Shadow;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow2:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConROWindow3:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Priest.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConROWindow2:SetAlpha(0);
			ConROWindow3:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self.lastSpellId = 0;
end

function ConRO:EnableDefenseModule(mode)
	mode = mode or 0;
	if mode == 0 then
		self.NextDef = ConRO.Priest.Under10Def;
	end;
	if mode == 1 then
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextDef = ConRO.Priest.DisciplineDef;
		else
			self.NextDef = ConRO.Priest.Disabled;
		end
	end;
	if mode == 2 then
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextDef = ConRO.Priest.HolyDef;
		else
			self.NextDef = ConRO.Priest.Disabled;
		end
	end;
	if mode == 3 then
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextDef = ConRO.Priest.ShadowDef;
		else
			self.NextDef = ConRO.Priest.Disabled;
		end
	end;
end

function ConRO:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end
end

function ConRO.Priest.Disabled(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells)
	wipe(ConRO.SuggestedDefSpells)
	return nil;
end

--Info
local _Player_Level = UnitLevel("player");
local _Player_Percent_Health = ConRO:PercentHealth('player');
local _is_PvP = ConRO:IsPvP();
local _in_combat = UnitAffectingCombat('player');
local _party_size = GetNumGroupMembers();
local _is_PC = UnitPlayerControlled("target");
local _is_Enemy = ConRO:TarHostile();
local _Target_Health = UnitHealth('target');
local _Target_Percent_Health = ConRO:PercentHealth('target');

--Resources
local _Mana, _Mana_Max, _Mana_Percent = ConRO:PlayerPower('Mana');
local _Insanity = ConRO:PlayerPower('Insanity');

--Conditions
local _Queue = 0;
local _is_moving = ConRO:PlayerSpeed();
local _enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
local _enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
local _enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
local _enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
local _can_Execute = _Target_Percent_Health < 20;

--Racials
local _AncestralCall, _AncestralCall_RDY = _, _;
local _ArcanePulse, _ArcanePulse_RDY = _, _;
local _Berserking, _Berserking_RDY = _, _;
local _ArcaneTorrent, _ArcaneTorrent_RDY = _, _;

local HeroSpec, Racial = ids.HeroSpec, ids.Racial;

function ConRO:Stats()
	_Player_Level = UnitLevel("player");
	_Player_Percent_Health = ConRO:PercentHealth('player');
	_is_PvP = ConRO:IsPvP();
	_in_combat = UnitAffectingCombat('player');
	_party_size = GetNumGroupMembers();
	_is_PC = UnitPlayerControlled("target");
	_is_Enemy = ConRO:TarHostile();
	_Target_Health = UnitHealth('target');
	_Target_Percent_Health = ConRO:PercentHealth('target');

	_Mana, _Mana_Max, _Mana_Percent = ConRO:PlayerPower('Mana');
	_Insanity = ConRO:PlayerPower('Insanity');

	_Queue = 0;
	_is_moving = ConRO:PlayerSpeed();
	_enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
	_enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
	_enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
	_enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
	_can_Execute = _Target_Percent_Health < 20;

	_AncestralCall, _AncestralCall_RDY = ConRO:AbilityReady(Racial.AncestralCall, timeShift);
	_ArcanePulse, _ArcanePulse_RDY = ConRO:AbilityReady(Racial.ArcanePulse, timeShift);
	_Berserking, _Berserking_RDY = ConRO:AbilityReady(Racial.Berserking, timeShift);
	_ArcaneTorrent, _ArcaneTorrent_RDY = ConRO:AbilityReady(Racial.ArcaneTorrent, timeShift);
end

function ConRO.Priest.Under10(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells)
	ConRO:Stats()
--Abilities

--Warnings

--Rotations

return nil;
end

function ConRO.Priest.Under10Def(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells)
	ConRO:Stats()
--Abilities

--Warnings

--Rotations

return nil;
end

function ConRO.Priest.Discipline(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Disc_Ability, ids.Disc_Form, ids.Disc_Buff, ids.Disc_Debuff, ids.Disc_PetAbility, ids.Disc_PvPTalent;

--Abilities
	local _AngelicFeather, _AngelicFeather_RDY = ConRO:AbilityReady(Ability.AngelicFeather, timeShift);	
	local _DispelMagic, _DispelMagic_RDY = ConRO:AbilityReady(Ability.DispelMagic, timeShift);
	local _DivineStar, _DivineStar_RDY = ConRO:AbilityReady(Ability.DivineStar, timeShift);
	local _Evangelism, _Evangelism_RDY, _Evangelism_CD = ConRO:AbilityReady(Ability.Evangelism, timeShift);
	local _Halo, _Halo_RDY = ConRO:AbilityReady(Ability.Halo, timeShift);
	local _MindBlast, _MindBlast_RDY = ConRO:AbilityReady(Ability.MindBlast, timeShift);
		local _EntropicRift_ACTIVE = ConRO:Totem(Buff.EntropicRift);
	local _Penance, _Penance_RDY = ConRO:AbilityReady(Ability.Penance, timeShift);
	local _PowerInfusion, _PowerInfusion_RDY = ConRO:AbilityReady(Ability.PowerInfusion, timeShift);
	local _PowerWordBarrier, _PowerWordBarrier_RDY = ConRO:AbilityReady(Ability.PowerWordBarrier, timeShift);
	local _PowerWordFortitude, _PowerWordFortitude_RDY = ConRO:AbilityReady(Ability.PowerWordFortitude, timeShift);
	local _PowerWordShield, _PowerWordShield_RDY = ConRO:AbilityReady(Ability.PowerWordShield, timeShift);
	local _PowerWordRadiance, _PowerWordRadiance_RDY = ConRO:AbilityReady(Ability.PowerWordRadiance, timeShift);
		local _PowerWordRadiance_CHARGES = ConRO:SpellCharges(_PowerWordRadiance);
		local _Atonement_BUFF = ConRO:UnitAura(Buff.Atonement, timeShift, 'target', 'HELPFUL');
		local _Atonement_COUNT = ConRO:GroupBuffCount(Buff.Atonement);
		local _Atonement_THRESHOLD = ConRO_AtonementBox:GetNumber();
	local _PsychicScream, _PsychicScream_RDY = ConRO:AbilityReady(Ability.PsychicScream, timeShift);
	local _PurgetheWicked, _PurgetheWicked_RDY = ConRO:AbilityReady(Ability.PurgetheWicked, timeShift);
		local _PurgetheWicked_DEBUFF = ConRO:TargetAura(Debuff.PurgetheWicked, timeShift + 3);
	local _Rapture, _Rapture_RDY = ConRO:AbilityReady(Ability.Rapture, timeShift);
		local _Rapture_BUFF = ConRO:Aura(Buff.Rapture, timeShift);
	local _ShadowWordDeath, _ShadowWordDeath_RDY = ConRO:AbilityReady(Ability.ShadowWordDeath, timeShift);
	local _ShadowWordPain, _ShadowWordPain_RDY = ConRO:AbilityReady(Ability.ShadowWordPain, timeShift);
		local _ShadowWordPain_DEBUFF = ConRO:TargetAura(Debuff.ShadowWordPain, timeShift + 3);
		local _PoweroftheDarkSide_BUFF = ConRO:Aura(Buff.PoweroftheDarkSide, timeShift);
	local _Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Shadowfiend, timeShift);
		local _Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
		local _ShadowCovenant_BUFF = ConRO:Aura(Buff.ShadowCovenant, timeShift);
	local _Smite, _Smite_RDY = ConRO:AbilityReady(Ability.Smite, timeShift);

	if _ShadowCovenant_BUFF then
		_DivineStar, _DivineStar_RDY = ConRO:AbilityReady(Ability.DivineStarSC, timeShift);
		_Halo, _Halo_RDY = ConRO:AbilityReady(Ability.HaloSC, timeShift);
		_Penance, _Penance_RDY = ConRO:AbilityReady(Ability.DarkReprimand, timeShift);
	end

	if tChosen[Ability.Mindbender.talentID] then
		_Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Mindbender, timeShift);
		_Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
	end

	if ConRO:HeroSpec(HeroSpec.Voidweaver) and tChosen[Ability.Voidwraith.talentID] then
		_Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Voidwraith, timeShift);
		_Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
	end

	if ConRO:HeroSpec(HeroSpec.Voidweaver) and tChosen[Ability.VoidBlast.talentID] and _EntropicRift_ACTIVE then
		_Smite, _Smite_RDY = ConRO:AbilityReady(Ability.VoidBlast, timeShift);
	end

	ConRO:Atonements(_Atonement_COUNT);

--Indicators
	ConRO:AbilityInterrupt(_PsychicScream, _PsychicScream_RDY and ((ConRO:Interrupt() and _target_in_melee) or (_target_in_melee and ConRO:TarYou())));
	ConRO:AbilityPurge(_DispelMagic, _DispelMagic_RDY and ConRO:Purgable());
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityMovement(_AngelicFeather, _AngelicFeather_RDY);

	ConRO:AbilityBurst(_Shadowfiend, _Shadowfiend_RDY and ConRO:BurstMode(_Shadowfiend));
	ConRO:AbilityBurst(_PowerInfusion, _PowerInfusion_RDY and ConRO:BurstMode(_PowerInfusion));
	ConRO:AbilityBurst(_Rapture, _Rapture_RDY and not _Shadowfiend_RDY and not _ShadowCovenant_BUFF);
	ConRO:AbilityBurst(_Evangelism, _Evangelism_RDY and ((ConRO:IsSolo() and _Atonement_COUNT == 1) or ((ConRO:InParty() or ConRO:InRaid()) and _Atonement_COUNT < _Atonement_THRESHOLD)));

	ConRO:AbilityRaidBuffs(_PowerWordFortitude, _PowerWordFortitude_RDY and not ConRO:RaidBuff(Buff.PowerWordFortitude));

	ConRO:AbilityRaidBuffs(_PowerWordShield, _PowerWordShield_RDY and ((ConRO:InParty() or ConRO:InRaid()) and _Atonement_COUNT < _Atonement_THRESHOLD));
	ConRO:AbilityRaidBuffs(_PowerWordRadiance, _PowerWordRadiance_RDY and not _Shadowfiend_RDY and not _MindBlast_RDY and((ConRO:InParty() or ConRO:InRaid()) and _Atonement_COUNT < _Atonement_THRESHOLD));

--Warnings
	ConRO:Warnings("Refresh Atonement!", _in_combat and _is_Enemy and ((ConRO:InParty() or ConRO:InRaid()) and _Atonement_COUNT < _Atonement_THRESHOLD));

--Rotations
	repeat
		while(true) do
			if _PurgetheWicked_RDY and not _PurgetheWicked_DEBUFF then
				tinsert(ConRO.SuggestedSpells, _PurgetheWicked);
				_PurgetheWicked_DEBUFF = true;
				_Queue = _Queue + 1;
				break;
			elseif not tChosen[Ability.PurgetheWicked.talentID] and _ShadowWordPain_RDY and not _ShadowWordPain_DEBUFF then
				tinsert(ConRO.SuggestedSpells, _ShadowWordPain);
				_ShadowWordPain_DEBUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			if _Shadowfiend_RDY and ConRO:FullMode(_Shadowfiend) then
				tinsert(ConRO.SuggestedSpells, _Shadowfiend);
				_Shadowfiend_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _MindBlast_RDY and currentSpell ~= _MindBlast then
				tinsert(ConRO.SuggestedSpells, _MindBlast);
				_MindBlast_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Penance_RDY then
				tinsert(ConRO.SuggestedSpells, _Penance);
				_Penance_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ShadowWordDeath_RDY and (_can_Execute or (tChosen[Ability.InescapableTorment.talentID] and _Shadowfiend_ACTIVE)) then
				tinsert(ConRO.SuggestedSpells, _ShadowWordDeath);
				_ShadowWordDeath_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _DivineStar_RDY then
				tinsert(ConRO.SuggestedSpells, _DivineStar);
				_DivineStar_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Halo_RDY and currentSpell ~= _Halo then
				tinsert(ConRO.SuggestedSpells, _Halo);
				_Halo_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Smite_RDY then
				tinsert(ConRO.SuggestedSpells, _Smite);
				_Queue = _Queue + 1;
				break;
			end

			tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.Priest.DisciplineDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Disc_Ability, ids.Disc_Form, ids.Disc_Buff, ids.Disc_Debuff, ids.Disc_PetAbility, ids.Disc_PvPTalent;

--Abilities
	local _DesperatePrayer, _DesperatePrayer_RDY = ConRO:AbilityReady(Ability.DesperatePrayer, timeShift);
	local _Fade, _Fade_RDY = ConRO:AbilityReady(Ability.Fade, timeShift);
	local _PainSuppression, _PainSuppression_RDY = ConRO:AbilityReady(Ability.PainSuppression, timeShift);
	local _PowerWordLife, _PowerWordLife_RDY = ConRO:AbilityReady(Ability.PowerWordLife, timeShift);
	local _PowerWordShield, _PowerWordShield_RDY = ConRO:AbilityReady(Ability.PowerWordShield, timeShift);
		local _Atonement_BUFF = ConRO:UnitAura(Buff.Atonement, timeShift, 'player', 'HELPFUL');

--Rotations
	if ConRO:IsSolo() and not _Atonement_BUFF then
		if _PowerWordShield_RDY and _Player_Percent_Health < 95 then
			tinsert(ConRO.SuggestedDefSpells, _PowerWordShield);
		end
	end

	if _PainSuppression_RDY and not _is_Enemy and _Target_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _PainSuppression);
	end

	if _DesperatePrayer_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _DesperatePrayer);
	end

	if _Fade_RDY and not ConRO:IsSolo() and (ConRO:TarYou() or _enemies_in_melee >= 1) then
		tinsert(ConRO.SuggestedDefSpells, _Fade);
	end

return nil;
end

function ConRO.Priest.Holy(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Holy_Ability, ids.Holy_Form, ids.Holy_Buff, ids.Holy_Debuff, ids.Holy_PetAbility, ids.Holy_PvPTalent;

--Abilities
	local _AngelicFeather, _AngelicFeather_RDY = ConRO:AbilityReady(Ability.AngelicFeather, timeShift);
	local _Apotheosis, _Apotheosis_RDY = ConRO:AbilityReady(Ability.Apotheosis, timeShift);
	local _DispelMagic, _DispelMagic_RDY = ConRO:AbilityReady(Ability.DispelMagic, timeShift);
	local _DivineHymn, _DivineHymn_RDY = ConRO:AbilityReady(Ability.DivineHymn, timeShift);
	local _HolyFire, _HolyFire_RDY = ConRO:AbilityReady(Ability.HolyFire, timeShift);
	local _HolyNova, _HolyNova_RDY = ConRO:AbilityReady(Ability.HolyNova, timeShift);
	local _HolyWordChastise, _HolyWordChastise_RDY = ConRO:AbilityReady(Ability.HolyWordChastise, timeShift);
	local _PowerWordFortitude, _PowerWordFortitude_RDY = ConRO:AbilityReady(Ability.PowerWordFortitude, timeShift);
	local _PsychicScream, _PsychicScream_RDY = ConRO:AbilityReady(Ability.PsychicScream, timeShift);
	local _ShadowWordDeath, _ShadowWordDeath_RDY = ConRO:AbilityReady(Ability.ShadowWordDeath, timeShift);
	local _ShadowWordPain, _ShadowWordPain_RDY = ConRO:AbilityReady(Ability.ShadowWordPain, timeShift);
		local _ShadowWordPain_DEBUFF = ConRO:TargetAura(Debuff.ShadowWordPain, timeShift + 3);
	local _Smite, _Smite_RDY = ConRO:AbilityReady(Ability.Smite, timeShift);


	local _DivineStar, _DivineStar_RDY = ConRO:AbilityReady(Ability.DivineStar, timeShift);
	local _Halo, _Halo_RDY = ConRO:AbilityReady(Ability.Halo, timeShift);
	local _HolyWordSalvation, _HolyWordSalvation_RDY = ConRO:AbilityReady(Ability.HolyWordSalvation, timeShift);
	local _Mindgames, _Mindgames_RDY = ConRO:AbilityReady(Ability.Mindgames, timeShift);

--Indicators
	ConRO:AbilityInterrupt(_PsychicScream, _PsychicScream_RDY and ((ConRO:Interrupt() and _target_in_melee) or (_target_in_melee and ConRO:TarYou())));
	ConRO:AbilityPurge(_DispelMagic, _DispelMagic_RDY and ConRO:Purgable())
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityMovement(_AngelicFeather, _AngelicFeather_RDY);

	ConRO:AbilityRaidBuffs(_PowerWordFortitude, _PowerWordFortitude_RDY and not ConRO:RaidBuff(Buff.PowerWordFortitude));

	ConRO:AbilityBurst(_DivineHymn, _DivineHymn_RDY and _in_combat);
	ConRO:AbilityBurst(_Apotheosis, _Apotheosis_RDY and _in_combat);
	ConRO:AbilityBurst(_HolyWordSalvation, _HolyWordSalvation_RDY and _in_combat);

	ConRO:AbilityBurst(_Mindgames, _Mindgames_RDY and _in_combat);

--Warnings

--Rotations
	if _is_Enemy then
		repeat
			while(true) do
				if _DivineStar_RDY then
					tinsert(ConRO.SuggestedSpells, _DivineStar);
					_DivineStar_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _Halo_RDY and currentSpell ~= _Halo then
					tinsert(ConRO.SuggestedSpells, _Halo);
					_Halo_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _HolyWordChastise_RDY then
					tinsert(ConRO.SuggestedSpells, _HolyWordChastise);
					_HolyWordChastise_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _HolyFire_RDY and currentSpell ~= _HolyFire then
					tinsert(ConRO.SuggestedSpells, _HolyFire);
					_HolyFire_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _ShadowWordPain_RDY and not _ShadowWordPain_DEBUFF then
					tinsert(ConRO.SuggestedSpells, _ShadowWordPain);
					_ShadowWordPain_DEBUFF = true;
					_Queue = _Queue + 1;
					break;
				end

				if _HolyNova_RDY and _enemies_in_melee >= 3 then
					tinsert(ConRO.SuggestedSpells, _HolyNova);
					_Queue = _Queue + 3;
					break;
				end

				if _Smite_RDY then
					tinsert(ConRO.SuggestedSpells, _Smite);
					_Queue = _Queue + 3;
					break;
				end

				tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
				_Queue = _Queue + 3;
				break;
			end
		until _Queue >= 3;
	end
return nil;
end

function ConRO.Priest.HolyDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Holy_Ability, ids.Holy_Form, ids.Holy_Buff, ids.Holy_Debuff, ids.Holy_PetAbility, ids.Holy_PvPTalent;

--Abilities
	local _GuardianSpirit, _GuardianSpirit_RDY = ConRO:AbilityReady(Ability.GuardianSpirit, timeShift);
	local _DesperatePrayer, _DesperatePrayer_RDY = ConRO:AbilityReady(Ability.DesperatePrayer, timeShift);
	local _PowerWordLife, _PowerWordLife_RDY = ConRO:AbilityReady(Ability.PowerWordLife, timeShift);
	local _PowerWordShield, _PowerWordShield_RDY = ConRO:AbilityReady(Ability.PowerWordShield, timeShift);
		local _WeakenedSoul_DEBUFF = ConRO:UnitAura(Debuff.WeakenedSoul, timeShift, 'player', 'HARMFUL');
		local _PowerWordShield_BUFF = ConRO:Aura(Buff.PowerWordShield, timeShift);
	local _Fade, _Fade_RDY = ConRO:AbilityReady(Ability.Fade, timeShift);

--Rotations
	if _PowerWordLife_RDY and _Player_Percent_Health <= 35 then
		tinsert(ConRO.SuggestedDefSpells, _PowerWordLife);
	end

	if _GuardianSpirit_RDY and _Target_Percent_Health <= 25 and not _is_Enemy then
		tinsert(ConRO.SuggestedDefSpells, _GuardianSpirit);
	end

	if _DesperatePrayer_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _DesperatePrayer);
	end

	if _Fade_RDY and not ConRO:IsSolo() and (ConRO:TarYou() or _enemies_in_melee >= 1) then
		tinsert(ConRO.SuggestedDefSpells, _Fade);
	end

	if _PowerWordShield_RDY and not _WeakenedSoul_DEBUFF and not _PowerWordShield_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _PowerWordShield);
	end
return nil;
end

function ConRO.Priest.Shadow(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Shad_Ability, ids.Shad_Form, ids.Shad_Buff, ids.Shad_Debuff, ids.Shad_PetAbility, ids.Shad_PvPTalent;

--Abilities
	local _DarkAscension, _DarkAscension_RDY = ConRO:AbilityReady(Ability.DarkAscension, timeShift);
		local _DarkAscension_BUFF = ConRO:Aura(Buff.DarkAscension, timeShift);
	local _DevouringPlague, _DevouringPlague_RDY = ConRO:AbilityReady(Ability.DevouringPlague, timeShift);
		local _DevouringPlague_DEBUFF, _, _DevouringPlague_DUR = ConRO:TargetAura(Debuff.DevouringPlague, timeShift);
	local _DispelMagic, _DispelMagic_RDY = ConRO:AbilityReady(Ability.DispelMagic, timeShift);
	local _DivineStar, _DivineStar_RDY = ConRO:AbilityReady(Ability.DivineStar, timeShift);
	local _Halo, _Halo_RDY = ConRO:AbilityReady(Ability.Halo, timeShift);
	local _MindBlast, _MindBlast_RDY = ConRO:AbilityReady(Ability.MindBlast, timeShift);
		local _MindBlast_CHARGE, _MindBlast_MCHARGE, _MindBlast_CHARGECD = ConRO:SpellCharges(_MindBlast);
		local _MindDevourer_BUFF = ConRO:Aura(Buff.MindDevourer, timeShift);
	local _MindFlay, _MindFlay_RDY = ConRO:AbilityReady(Ability.MindFlay, timeShift);
	local _MindFlayInsanity, _MindFlayInsanity_RDY = ConRO:AbilityReady(Ability.MindFlayInsanity, timeShift);
		local _MindFlayInsanity_BUFF = ConRO:Aura(Buff.MindFlayInsanity, timeShift);
	local _MindSpike, _MindSpike_RDY = ConRO:AbilityReady(Ability.MindSpike, timeShift);
	local _MindSpikeInsanity, _MindSpikeInsanity_RDY = ConRO:AbilityReady(Ability.MindSpikeInsanity, timeShift);
		local _, _MindSpikeInsanity_COUNT = ConRO:Aura(Buff.MindSpikeInsanity, timeShift);
		local _, _MindMelt_COUNT = ConRO:Aura(Buff.MindMelt, timeShift);
	local _PowerInfusion, _PowerInfusion_RDY = ConRO:AbilityReady(Ability.PowerInfusion, timeShift);
	local _PowerWordFortitude, _PowerWordFortitude_RDY = ConRO:AbilityReady(Ability.PowerWordFortitude, timeShift);
	local _PowerWordShield, _PowerWordShield_RDY = ConRO:AbilityReady(Ability.PowerWordShield, timeShift);
	local _PsychicHorror, _PsychicHorror_RDY = ConRO:AbilityReady(Ability.PsychicHorror, timeShift);
	local _PsychicScream, _PsychicScream_RDY = ConRO:AbilityReady(Ability.PsychicScream, timeShift);
	local _Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Shadowfiend, timeShift);
		local _Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
	local _Silence, _Silence_RDY = ConRO:AbilityReady(Ability.Silence, timeShift);
	local _ShadowCrash, _ShadowCrash_RDY, _ShadowCrash_CD = ConRO:AbilityReady(Ability.ShadowCrash, timeShift);
	local _ShadowWordDeath, _ShadowWordDeath_RDY = ConRO:AbilityReady(Ability.ShadowWordDeath, timeShift);
		local _ShadowWordDeath_CHARGE, _ShadowWordDeath_MCHARGE = ConRO:SpellCharges(_ShadowWordDeath);
	local _ShadowWordPain, _ShadowWordPain_RDY = ConRO:AbilityReady(Ability.ShadowWordPain, timeShift);
		local _ShadowWordPain_DEBUFF, _, _ShadowWordPain_DUR = ConRO:TargetAura(Debuff.ShadowWordPain, timeShift);
		local _Deathspeaker_BUFF = ConRO:Aura(Buff.Deathspeaker, timeShift);
	local _Shadowform, _Shadowform_RDY = ConRO:AbilityReady(Ability.Shadowform, timeShift);
		local _Shadowform_FORM = ConRO:Form(Form.Shadowform);
	local _VoidEruption, _VoidEruption_RDY = ConRO:AbilityReady(Ability.VoidEruption, timeShift);
		local _Voidform_BUFF, _, _Voidform_DUR = ConRO:Aura(Buff.Voidform, timeShift);
		local _Voidform_FORM = ConRO:Form(Form.Voidform);
	local _VoidBolt, _VoidBolt_RDY = ConRO:AbilityReady(Ability.VoidBolt, timeShift);
	local _VampiricTouch, _VampiricTouch_RDY = ConRO:AbilityReady(Ability.VampiricTouch, timeShift);
		local _VampiricTouch_DEBUFF, _, _VampiricTouch_DUR = ConRO:TargetAura(Debuff.VampiricTouch, timeShift);
	local _VoidTorrent, _VoidTorrent_RDY = ConRO:AbilityReady(Ability.VoidTorrent, timeShift);
		local _EntropicRift_ACTIVE = ConRO:Totem(Buff.EntropicRift);

--Conditions
	if tChosen[Ability.MindMelt.talentID] and currentSpell == _MindSpike then
		_MindMelt_COUNT = _MindMelt_COUNT + 1;
	end

	if currentSpell == _MindSpikeInsanity then
		_MindSpikeInsanity_COUNT = _MindSpikeInsanity_COUNT - 1;
	end

	local _DevouringPlague_COST = 50;
	if _MindDevourer_BUFF then
		_DevouringPlague_COST = 0;
	elseif tChosen[Ability.MindsEye.talentID] then
		_DevouringPlague_COST = 45;
	elseif tChosen[Ability.DistortedReality.talentID] then
		_DevouringPlague_COST = 55;
	end

	if tChosen[Ability.ShadowCrashDest.talentID] then
		_ShadowCrash, _ShadowCrash_RDY, _ShadowCrash_CD = ConRO:AbilityReady(Ability.ShadowCrashDest, timeShift);
	end

	if tChosen[Ability.Mindbender.talentID] then
		_Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Mindbender, timeShift);
		_Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
	end

	if ConRO:HeroSpec(HeroSpec.Voidweaver) and tChosen[Ability.Voidwraith.talentID] then
		_Shadowfiend, _Shadowfiend_RDY = ConRO:AbilityReady(Ability.Voidwraith, timeShift);
		_Shadowfiend_ACTIVE = ConRO:Totem(_Shadowfiend);
	end

	if ConRO:HeroSpec(HeroSpec.Voidweaver) and tChosen[Ability.VoidBlast.talentID] and _EntropicRift_ACTIVE then
		_MindBlast, _MindBlast_RDY = ConRO:AbilityReady(Ability.VoidBlast, timeShift);
	end

	if currentSpell == _MindBlast then
		_MindBlast_CHARGE = _MindBlast_CHARGE - 1;
	end

--Indicators
	ConRO:AbilityInterrupt(_Silence, _Silence_RDY and ConRO:Interrupt());
	ConRO:AbilityInterrupt(_PsychicHorror, _PsychicHorror_RDY and (ConRO:Interrupt() and not _Silence_RDY and _is_PC and _is_Enemy));
	ConRO:AbilityInterrupt(_PsychicScream, _PsychicScream_RDY and ((ConRO:Interrupt() and not _Silence_RDY and _target_in_melee) or (_target_in_melee and ConRO:TarYou())) and _is_PC and _is_Enemy);
	ConRO:AbilityPurge(_DispelMagic, _DispelMagic_RDY and ConRO:Purgable());
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_melee and ConRO:Purgable());
	ConRO:AbilityMovement(_PowerWordShield, _PowerWordShield_RDY and tChosen[Ability.BodyandSoul.talentID]);

	ConRO:AbilityRaidBuffs(_PowerWordFortitude, _PowerWordFortitude_RDY and not ConRO:RaidBuff(Buff.PowerWordFortitude));

	ConRO:AbilityBurst(_VoidEruption, _VoidEruption_RDY and not _Voidform_BUFF and ConRO:BurstMode(_VoidEruption));
	ConRO:AbilityBurst(_PowerInfusion, _PowerInfusion_RDY and not _Voidform_BUFF and _Insanity >= 40 and ConRO:BurstMode(_PowerInfusion));
	ConRO:AbilityBurst(_VoidTorrent, _VoidTorrent_RDY and not _Voidform_BUFF and _VampiricTouch_DEBUFF and _ShadowWordPain_DEBUFF and ConRO:BurstMode(_VoidTorrent));
	ConRO:AbilityBurst(_ShadowCrash, _ShadowCrash_RDY and (not _VampiricTouch_DEBUFF or _VampiricTouch_DUR <= 3));
	ConRO:AbilityBurst(_Shadowfiend, _Shadowfiend_RDY and ConRO:BurstMode(_Shadowfiend));

--Warnings

--Rotations
	repeat
		while(true) do
			if _Shadowform_RDY and not _Shadowform_FORM and not _Voidform_BUFF and not _Voidform_FORM then
				tinsert(ConRO.SuggestedSpells, _Shadowform);
				_Shadowform_FORM = true;
				_Queue = _Queue + 1;
				break;
			end

			if not _in_combat then
				if _ShadowCrash_RDY and tChosen[Ability.WhisperingShadows.talentID] and not _VampiricTouch_DEBUFF and currentSpell ~= _VampiricTouch and ConRO.lastSpellId ~= _ShadowCrash then
					tinsert(ConRO.SuggestedSpells, _ShadowCrash);
					_ShadowCrash_RDY = false;
					_VampiricTouch_DEBUFF = true;
					_Queue = _Queue + 1;
					break;
				end

				if _VampiricTouch_RDY and not _VampiricTouch_DEBUFF and currentSpell ~= _VampiricTouch and ConRO.lastSpellId ~= _ShadowCrash then
					tinsert(ConRO.SuggestedSpells, _VampiricTouch);
					_VampiricTouch_DEBUFF = true;
					_Queue = _Queue + 1;
					break;
				end

				if _ShadowWordPain_RDY and not _ShadowWordPain_DEBUFF and not tChosen[Ability.Misery.talentID] then
					tinsert(ConRO.SuggestedSpells, _ShadowWordPain);
					_ShadowWordPain_DEBUFF = true;
					_Queue = _Queue + 1;
					break;
				end

				if _Shadowfiend_RDY and ConRO:FullMode(_Shadowfiend) then
					tinsert(ConRO.SuggestedSpells, _Shadowfiend);
					_Shadowfiend_RDY = false;
					_Queue = _Queue + 1;
					break;
				end
			end

			if select(2, ConRO:EndChannel()) == _VoidTorrent and select(1, ConRO:EndChannel()) > 1 then
				tinsert(ConRO.SuggestedSpells, _VoidTorrent);
				_Queue = _Queue + 3;
				break;
			end

			if select(2, ConRO:EndChannel()) == _MindFlayInsanity and select(1, ConRO:EndChannel()) > 1 then
				tinsert(ConRO.SuggestedSpells, _MindFlayInsanity);
				_Queue = _Queue + 3;
				break;
			end

			if _VampiricTouch_RDY and not _VampiricTouch_DEBUFF and currentSpell ~= _VampiricTouch and ConRO.lastSpellId ~= _ShadowCrash then
				tinsert(ConRO.SuggestedSpells, _VampiricTouch);
				_VampiricTouch_DEBUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			if _ShadowWordPain_RDY and not _ShadowWordPain_DEBUFF and not tChosen[Ability.Misery.talentID] then
				tinsert(ConRO.SuggestedSpells, _ShadowWordPain);
				_ShadowWordPain_DEBUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			if _Shadowfiend_RDY and ConRO:FullMode(_Shadowfiend) then
				tinsert(ConRO.SuggestedSpells, _Shadowfiend);
				_Shadowfiend_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Halo_RDY and ConRO:HeroSpec(HeroSpec.Archon) and tChosen[Ability.PowerSurge.talentID] and currentSpell ~= _Halo then
				tinsert(ConRO.SuggestedSpells, _Halo);
				_Halo_RDY = false;
				_Insanity = _Insanity + 10;
				_Queue = _Queue + 1;
				break;
			end

			if _MindBlast_RDY and _MindBlast_CHARGE >= 1 and tChosen[Ability.VoidEruption.talentID] and _VoidEruption_RDY and not _Voidform_BUFF and ConRO:FullMode(_VoidEruption) then
				tinsert(ConRO.SuggestedSpells, _MindBlast);
				_MindBlast_CHARGE = _MindBlast_CHARGE - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _VoidEruption_RDY and currentSpell ~= _VoidEruption and not _Voidform_BUFF and ConRO:FullMode(_VoidEruption) then
				tinsert(ConRO.SuggestedSpells, _VoidEruption);
				_VoidEruption_RDY = false;
				_Voidform_BUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			if _DarkAscension_RDY and currentSpell ~= _DarkAscension and ConRO:FullMode(_DarkAscension) then
				tinsert(ConRO.SuggestedSpells, _DarkAscension);
				_DarkAscension_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _PowerInfusion_RDY and (_DarkAscension_BUFF or _Voidform_BUFF or currentSpell == _DarkAscension or currentSpell == _VoidEruption) and ConRO:FullMode(_PowerInfusion) then
				tinsert(ConRO.SuggestedSpells, _PowerInfusion);
				_PowerInfusion_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _VoidBolt_RDY and (_Voidform_BUFF or _Voidform_FORM) then
				tinsert(ConRO.SuggestedSpells, _VoidBolt);
				_VoidBolt_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _DevouringPlague_RDY and ((not _DevouringPlague_DEBUFF) or (_DevouringPlague_DUR <= 1) or (_Insanity > 90) or _MindDevourer_BUFF) then
				tinsert(ConRO.SuggestedSpells, _DevouringPlague);
				if not _MindDevourer_BUFF then
					_Insanity = _Insanity - _DevouringPlague_COST;
				end
				_MindDevourer_BUFF = false;
				_DevouringPlague_DEBUFF = true;
				_DevouringPlague_DUR = 7;
				_Queue = _Queue + 1;
				break;
			end

			if _MindBlast_RDY and ((_MindBlast_CHARGE >= _MindBlast_MCHARGE) or (_MindBlast_CHARGE ==  1 and _MindBlast_CHARGECD < 2)) and currentSpell ~= _MindBlast then
				tinsert(ConRO.SuggestedSpells, _MindBlast);
				_MindBlast_CHARGE = _MindBlast_CHARGE - 1;
				_Insanity = _Insanity + 6;
				_Queue = _Queue + 1;
				break;
			end

			if _VoidTorrent_RDY and (_DevouringPlague_DEBUFF and _DevouringPlague_DUR >= 3.5) and ConRO:FullMode(_VoidTorrent) then
				tinsert(ConRO.SuggestedSpells, _VoidTorrent);
				_VoidTorrent_RDY = false;
				_Insanity = _Insanity + 24;
				_Queue = _Queue + 1;
				break;
			end

			if _MindBlast_RDY and _MindBlast_CHARGE >= 1 and not _MindDevourer_BUFF then
				tinsert(ConRO.SuggestedSpells, _MindBlast);
				_MindBlast_CHARGE = _MindBlast_CHARGE - 1;
				_Insanity = _Insanity + 6;
				_Queue = _Queue + 1;
				break;
			end

			if _MindFlayInsanity_RDY and _MindFlayInsanity_BUFF then
				tinsert(ConRO.SuggestedSpells, _MindFlayInsanity);
				_MindFlayInsanity_RDY = false;
				_MindFlayInsanity_BUFF = false;
				_Insanity = _Insanity + 12;
				_Queue = _Queue + 1;
				break;
			end

			if _MindSpikeInsanity_RDY and (_MindSpikeInsanity_COUNT >= 1) and (_DevouringPlague_DUR >= 1.5) then
				tinsert(ConRO.SuggestedSpells, _MindSpikeInsanity);
				_MindSpikeInsanity_COUNT = _MindSpikeInsanity_COUNT - 1;
				_Insanity = _Insanity + 12;
				_Queue = _Queue + 1;
				break;
			end

			if _ShadowWordDeath_RDY and _ShadowWordDeath_CHARGE >= 1 and (_can_Execute or _Deathspeaker_BUFF or (_Shadowfiend_ACTIVE and tChosen[Ability.InescapableTorment.talentID])) then
				tinsert(ConRO.SuggestedSpells, _ShadowWordDeath);
				_ShadowWordDeath_RDY = false;
				_ShadowWordDeath_CHARGE = _ShadowWordDeath_CHARGE - 1;
				_Deathspeaker_BUFF = false;
				_Queue = _Queue + 1;
				break;
			end

			if _DevouringPlague_RDY and _Insanity >= _DevouringPlague_COST and _Voidform_BUFF and _Voidform_DUR <= 2.5 then
				tinsert(ConRO.SuggestedSpells, _DevouringPlague);
				_Insanity = _Insanity - _DevouringPlague_COST;
				_Queue = _Queue + 1;
				break;
			end

			if _Halo_RDY and currentSpell ~= _Halo then
				tinsert(ConRO.SuggestedSpells, _Halo);
				_Halo_RDY = false;
				_Insanity = _Insanity + 10;
				_Queue = _Queue + 1;
				break;
			end

			if _MindSpike_RDY and not _is_moving then
				tinsert(ConRO.SuggestedSpells, _MindSpike);
				_Insanity = _Insanity + 4;
				_Queue = _Queue + 1;
				break;
			end

			if _MindFlay_RDY and not _is_moving then
				tinsert(ConRO.SuggestedSpells, _MindFlay);
				_Insanity = _Insanity + 12;
				_Queue = _Queue + 3;
				break;
			end

			if _DivineStar_RDY then
				tinsert(ConRO.SuggestedSpells, _DivineStar);
				_DivineStar_RDY = false;
				_Insanity = _Insanity + 6;
				_Queue = _Queue + 1;
				break;
			end

			if _ShadowWordDeath_RDY and _ShadowWordDeath_CHARGE >= 1 then
				tinsert(ConRO.SuggestedSpells, _ShadowWordDeath);
				_ShadowWordDeath_RDY = false;
				_ShadowWordDeath_CHARGE = _ShadowWordDeath_CHARGE - 1;
				_Deathspeaker_BUFF = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ShadowWordPain_RDY then
				tinsert(ConRO.SuggestedSpells, _ShadowWordPain);
				_ShadowWordPain_DEBUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.Priest.ShadowDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Shad_Ability, ids.Shad_Form, ids.Shad_Buff, ids.Shad_Debuff, ids.Shad_PetAbility, ids.Shad_PvPTalent;

--Abilities
	local _DesperatePrayer, _DesperatePrayer_RDY = ConRO:AbilityReady(Ability.DesperatePrayer, timeShift);
	local _Dispersion, _Dispersion_RDY = ConRO:AbilityReady(Ability.Dispersion, timeShift);
	local _Fade, _Fade_RDY = ConRO:AbilityReady(Ability.Fade, timeShift);
	local _PowerWordLife, _PowerWordLife_RDY = ConRO:AbilityReady(Ability.PowerWordLife, timeShift);
	local _PowerWordShield, _PowerWordShield_RDY = ConRO:AbilityReady(Ability.PowerWordShield, timeShift);
			local _PowerWordShield_BUFF = ConRO:Aura(Buff.PowerWordShield, timeShift);
	local _VampiricEmbrace, _VampiricEmbrace_RDY = ConRO:AbilityReady(Ability.VampiricEmbrace, timeShift);

--Indicators

--Warnings

--Rotations
	if _PowerWordLife_RDY and _Player_Percent_Health <= 35 then
		tinsert(ConRO.SuggestedDefSpells, _PowerWordLife);
	end

	if _DesperatePrayer_RDY and _Player_Percent_Health <= 50 then
		tinsert(ConRO.SuggestedDefSpells, _DesperatePrayer);
	end

	if _VampiricEmbrace_RDY and _Player_Percent_Health <= 75 then
		tinsert(ConRO.SuggestedDefSpells, _VampiricEmbrace);
	end

	if _Dispersion_RDY and _Player_Percent_Health <= 40 then
		tinsert(ConRO.SuggestedDefSpells, _Dispersion);
	end

	if _Fade_RDY and not ConRO:IsSolo() and (ConRO:TarYou() or _enemies_in_melee >= 1) then
		tinsert(ConRO.SuggestedDefSpells, _Fade);
	end

	if _PowerWordShield_RDY and not _PowerWordShield_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _PowerWordShield);
	end
return nil;
end