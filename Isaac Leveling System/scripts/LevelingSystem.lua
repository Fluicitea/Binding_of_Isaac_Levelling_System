local LevelingSystem = {}

---------------
-- Exp Table --
---------------
LevelingSystem = {
	Exp = {
	-- BoI Enemies --
		EXP_GAPER = 2,
		EXP_GUSHER = 2,
		EXP_HORF = 2,
		EXP_POOTER = 2,
		EXP_CLOTTY = 2,
		EXP_MULLIGAN = 1,
		EXP_SHOPKEEPER = 2,
		EXP_ATTACKFLY = 1,
		EXP_MAGGOT = 2,
		EXP_HIVE = 2,
		EXP_CHARGER = 2,
		EXP_GLOBIN = 2,
		EXP_BOOMFLY = 2,
		EXP_MAW = 2,
		EXP_HOST = 2,
		EXP_HOPPER = 2,
		EXP_SPITY = 2,
		EXP_BRAIN = 2,
		EXP_LEAPER = 2,
		EXP_MRMAW = 2,
		EXP_BABY = 2,
		EXP_VIS = 2,
		EXP_GUTS = 2,
		EXP_KNIGHT = 2,
		EXP_DOPLE = 2,
		EXP_FLAMINGHOPPER = 2,
		EXP_LEECH = 2,
		EXP_LUMP = 2,
		EXP_MEMBRAIN = 2,
		EXP_PARA_BITE = 2,
		EXP_FRED = 2,
		EXP_EYE = 2,
		EXP_SUCKER = 2,
		EXP_FISTULA_BIG = 5,
		EXP_FISTULA_MEDIUM = 3,
		EXP_FISTULA_SMALL = 2,
		EXP_BLASTOCYST_BIG = 5,
		EXP_BLASTOCYST_MEDIUM = 3,
		EXP_BLASTOCYST_SMALL = 2,
		EXP_EMBRYO = 1,
		EXP_MOTER = 2,
		EXP_SPIDER = 2,
		EXP_KEEPER = 2,
		EXP_GURGLE = 2,
		EXP_WALKINGBOIL = 2,
		EXP_BUTTLICKER = 2,
		EXP_HANGER = 2,
		EXP_SWARMER = 2,
		EXP_HEART = 2,
		EXP_BIGSPIDER = 2,
	-- BoI Mini-Bosses --
		EXP_SLOTH = 10,
		EXP_LUST = 10,
		EXP_WRATH = 10,
		EXP_GLUTTONY = 10,
		EXP_GREED = 10,
		EXP_ENVY = 10,
		EXP_PRIDE = 10,
	-- BoI Bosses --
		EXP_LARRYJR = 10,
		EXP_MONSTRO = 20,
		EXP_CHUB = 20,
		EXP_MONSTRO2 = 20,
		EXP_GURDY = 20,
		EXP_PIN = 20,
		EXP_DUKE = 20,
		EXP_PEEP = 20,
		EXP_LOKI = 20,
		EXP_GEMINI = 20,
		EXP_FALLEN = 20,
		EXP_MASK_OF_INFAMY = 10,
		EXP_HEART_OF_INFAMY = 10,
		EXP_GURDY_JR = 20,
		EXP_WIDOW = 20,
		EXP_DADDYLONGLEGS = 20,
		-- Horsemen --
		EXP_FAMINE = 20,
		EXP_PESTILENCE = 20,
		EXP_WAR = 20,
		EXP_DEATH = 20,
		EXP_HEADLESS_HORSEMAN = 10,
		EXP_HORSEMAN_HEAD = 10,
	-- BoI End Bosses --
		EXP_MOM = 50,
		EXP_MOMS_HEART = 100,
		EXP_SATAN = 150,
		EXP_ISAAC = 150,
	-- Rebirth Enemies --
		EXP_MOBILE_HOST = 2,
		EXP_NEST = 2,
		EXP_BABY_LONG_LEGS = 2,
		EXP_CRAZY_LONG_LEGS = 2,
		EXP_FATTY = 2,
		EXP_FAT_SACK = 2,
		EXP_BLUBBER = 2,
		EXP_HALF_SACK = 2,
		EXP_MOMS_HAND = 2,
		EXP_FLY_L2 = 2,
		EXP_SPIDER_L2 = 2,
		EXP_SWINGER = 2,
		EXP_DIP = 1,
		EXP_WALL_HUGGER = 2,
		EXP_WIZOOB = 2,
		EXP_SQUIRT = 2,
		EXP_COD_wORM = 2,
		EXP_RING_OF_FLIES = 1,
		EXP_DINGA = 2,
		EXP_OOB = 2,
		EXP_BLACK_MAW = 2,
		EXP_SKINNY = 2,
		EXP_BONY = 4,
		EXP_HOMUNCULUS = 2,
		EXP_TUMOR = 2,
		EXP_CAMILLO_JR = 2,
		EXP_SKINBALL = 2,
		EXP_MOM_HEAD = 2,
		EXP_ONE_TOOTH = 2,
		EXP_GURGLING = 2,
		EXP_SPLASHER = 2,
		EXP_GRUB = 2,
		EXP_WALL_CREEP = 2,
		EXP_RAGE_CREEP = 2,
		EXP_BLIND_CREEP = 2,
		EXP_CONJOINED_SPITTY = 2,
		EXP_ROUND_WORM = 2,
		EXP_RAGLING = 2,
		EXP_FLESH_MOBILE_HOST = 2,
		EXP_PSY_HORF = 2,
		EXP_FULL_FLY = 2,
		EXP_TICKING_SPIDER = 2,
		EXP_BEGOTTEN = 2,
		EXP_NULLS = 2,
		EXP_PSY_TUMOR = 2,
		EXP_FLOATING_KNIGHT = 2,
		EXP_NIGHT_CRAWLER = 2,
	-- Rebirth Bosses --
		EXP_THE_HAUNT = 20,
		EXP_DINGLE = 20,
		EXP_MEGA_MAW = 20,
		EXP_GATE = 20,
		EXP_MEGA_FATTY = 20,
		EXP_CAGE = 20,
		EXP_MAMA_GURDY = 20,
		EXP_DARK_ONE = 20,
		EXP_ADVERSARY = 20,
		EXP_POLYCEPHALUS = 20,
		EXP_MR_FRED = 20,
		-- Angels --
		EXP_URIEL = 20,
		EXP_GABRIEL = 20,
	-- Rebirth End Bosses
		EXP_THE_LAMB = 200,
		EXP_MEGA_SATAN = 100,
		EXP_MEGA_SATAN_2 = 100,
	-- Afterbirth Enemies --
		EXP_DART_FLY = 1,
		EXP_CONJOINED_FATTY = 3,
		EXP_FAT_BAT = 2,
		EXP_IMP = 2,
		EXP_ROUNDY = 2,
		EXP_BLACK_BONY = 5,
		EXP_BLACK_GLOBIN = 4,
		EXP_BLACK_GLOBIN_HEAD = 2,
		EXP_BLACK_GLOBIN_BODY = 2,
		EXP_SWARM = 1,
		EXP_MEGA_CLOTTY = 2,
		EXP_BONE_KNIGHT = 2,
		EXP_CYCLOPIA = 2,
		EXP_RED_GHOST = 4,
		EXP_FLESH_DEATHS_HEAD = 2,
		EXP_MOMS_DEAD_HAND = 4,
		EXP_DUKIE = 2,
		EXP_ULCER = 2,
		EXP_MEATBALL = 2,
		EXP_HUSH_FLY = 1,
		EXP_HUSH_GAPER = 2,
		EXP_HUSH_BOIL = 2,
		EXP_GREED_GAPER = 2,
	-- Afterbith Bosses --
		EXP_STAIN = 20,
		EXP_BROWNIE = 20,
		EXP_FORSAKEN = 20,
		EXP_LITTLE_HORN = 20,
		EXP_RAG_MAN = 20,
	-- Afterbith End Bosses --
		EXP_ULTRA_GREED = 200,
		EXP_HUSH = 300,
	-- Afterbirth+ Enemies --
		EXP_MUSHROOM = 2,
		EXP_POISON_MIND = 2,
		EXP_BLISTER = 2,
		EXP_THE_THING = 2,
		EXP_MINISTRO = 2,
		EXP_PORTAL = 1,
	-- Afterbirth+ Bosses --
		EXP_RAG_MEGA = 20,
		EXP_SISTERS_VIS = 20,
		EXP_BIG_HORN = 20,
	-- Afterbirth+ End Bosses --
		EXP_DELIRIUM = 350
	},
	LevelBonus = {
		LEVEL_STAT = 5, -- Stat points per level
	}
}

return LevelingSystem