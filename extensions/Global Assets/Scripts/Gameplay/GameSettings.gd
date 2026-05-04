extends "res://Global Assets/Scripts/Gameplay/GameSettings.gd"



# Master variable that notes whether this is an Archipelago enabled save file
var archipelagoEnabled: bool

#Slot data received from the server
var slotData: Dictionary

# Array to store access to the level select categories (all of Doorway to Nowhere, for example)
# This is not access to individual levels, as that's controlled through story flags
var archipelagoStageAccess: Array = [false, true, false, false, false, false, false, false,
										   false, false, false, false, false, false, false, false, 
										   false, false, false, false, false, false, false, false, 
										   false, false, false, false, false, false, false, false, 
										   false, false]

# Array to store access to each world
# The worlds in this array are in a counterclockwise circle starting with Time, so:
# Time, Nature, Civ, Chaos, Space, Darkness
# Index 6, which is unused in base game, is the alt timeline.
var archipelagoWorldAccess: Array = [true, false, false, false, false, false, false]

#list of checked locations, sent to the server when connecting to make sure nothing was missed
var checkedLocations: Array

#Count of gears, since they're being handled differently here
var archipelagoGearCount: int

#Same as with gear, they need to be tracked differently
var archipelagoShackleCount: int

#Tracks what levels have been completed, used for level unlock locations
var archipelagoCompletedLevels: Array

#Marks whether Steel on Steel and Zero Seconds to Midnight have been received, as they might not be unlocked immediately
var archipelagoStSReceived: bool = false
var archipelagoZStMReceived: bool = false

#Whether or not the Chrono Gear has been received
var archipelagoChronoGear: bool = false

#Tracks the number of threads received overall
var archipelagoThreadCounts: Dictionary = {
	"time": [0, 0, 0], 
	"space": [0, 0], 
	"nature": [0], 
	"civilization": [0], 
	"chaos": [0], 
}

#Tracks the number of purchases made on each shop page.
var archipelagoShopPurchases: Dictionary = {
	"time": [0, 0, 0], 
	"space": [0, 0], 
	"nature": [0], 
	"civilization": [0], 
	"chaos": [0], 
}

#Tracks which specific items have been purchased
#Added separately because I'm doing this part of the shop much later
var archipelagoItemsPurchased: Dictionary = {
	"time": [
				[false, false, false, false, false],
				[false, false, false, false, false], 
				[false, false, false, false, false, false, false, false, false, false, false, false, false],
			],
	"space": [
			[false, false, false, false], 
			[false, false, false, false]
			],
	"nature":
			[[false, false, false, false]],
	"civilization":
			[[false, false, false, false, false, false, false]],
	"chaos": 
			[[false, false, false, false, false, false, false, false, false]]
}

#Stores the items that are in the shop locations so the text in the shops can be updated
var archipelagoShopItems: Dictionary

#Flag for the three starting CDs
var startingCDsSent: bool = false

#Marks which collectibles have been picked up so they don't keep spawning
#Normally it checks by which have actually been unlocked
var collectedCDs: Array
var collectedThreads: Array

#Holding spot for the ConnectionInfo's received_items array, as the ConnectionInfo won't exist when
#the file is loaded
var receivedItems: Array

#The GoldenGears() function actually tracks the number of stages completed, not physical gears collected

func GetStageAccess(a: String):
	if(!archipelagoEnabled):
		return super(a)
	else:
		match a:
			"level_sanctum": return archipelagoStageAccess[0]
			"hub_sanctum": return archipelagoStageAccess[1]
			"level_belltown": return archipelagoStageAccess[2]
			"level_carnival": return archipelagoStageAccess[3]
			"level_sands": return archipelagoStageAccess[4]
			"level_storm": return archipelagoStageAccess[5]
			"level_tree": return archipelagoStageAccess[6]
			"hub_garden": return archipelagoStageAccess[7]
			"level_skytops": return archipelagoStageAccess[8]
			"level_beach": return archipelagoStageAccess[9]
			"level_atlantis": return archipelagoStageAccess[10]
			"level_solar": return archipelagoStageAccess[11]
			"hub_starship": return archipelagoStageAccess[12]
			"level_pirate": return archipelagoStageAccess[13]
			"level_farside": return false #unused level
			"level_moon": return archipelagoStageAccess[14]
			"level_intermission": return archipelagoStageAccess[15]
			"level_castleroad": return archipelagoStageAccess[16]
			"hub_civ": return archipelagoStageAccess[17]
			"level_ruins": return archipelagoStageAccess[18]
			"level_cursed": return archipelagoStageAccess[19]
			"level_factory": return archipelagoStageAccess[20]
			"hub_city": return archipelagoStageAccess[21]
			"level_highway": return archipelagoStageAccess[22]
			"level_arcade": return archipelagoStageAccess[23]
			"level_concert": return archipelagoStageAccess[24]
			"level_stadium": return archipelagoStageAccess[25]
			"level_belltown_alt": return archipelagoStageAccess[26]
			"hub_camp": return archipelagoStageAccess[27]
			"level_moon_alt": return archipelagoStageAccess[28]
			"level_tree_alt": return archipelagoStageAccess[29]
			"level_castleroad_alt": return archipelagoStageAccess[30]
			"level_stadium_alt": return archipelagoStageAccess[31]
			"level_tower1": return archipelagoStageAccess[32]
			"level_tower2": return archipelagoStageAccess[33]
			
		
		
func GetWorldAccess(a: int):
	if(!archipelagoEnabled):
		return super(a)
	else:
		return archipelagoWorldAccess[a]
	

#Holds a bunch of stuff about the stage, in order:
#The scene file, the name in game, the notes for 100 score, the time for 100 score, the damage for 100 score,
#The story flag needed to unlock it, the value that flag needs to be, and two numbers I don't know
#I have added on the first part of the location ID for anything in those levels at the end.
func GetStageInfo(a: int):
	if(!archipelagoEnabled):
		return super(a)
	else:
		match a:
			1: return ["level_sanctum", tr("Storming the Sanctum"), 80, MinutesToMilliseconds(3), 100, "archipelago_sanctum", 1, 1, 1, 110000]
			2: return ["level_belltown", tr("The Top of Bell Tower"), 120, MinutesToMilliseconds(6), 100, "archipelago_belltown", 1, 2, 2, 120000]
			3: return ["", tr("Bell Town Underworks"), 80, MinutesToMilliseconds(4), 100, "", 0, 3, 3, 120000]
			4: return ["level_belltown_boss", tr("The Battle of Bell Town"), 0, MinutesToMilliseconds(5), 120, "archipelago_belltown_boss", 1, 4, 10, 121000]
			5: return ["level_carnival", tr("The Polpol Express"), 150, MinutesToMilliseconds(8), 150, "archipelago_carnival", 1, 5, 4, 130000]
			6: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 6, 5, 999000]
			7: return ["level_sands", tr("The Gravity of Time"), 120, MinutesToMilliseconds(9), 100, "archipelago_sands", 1, 7, 6, 140000]
			8: return ["", tr("Beneath the Sand"), 100, MinutesToMilliseconds(5), 100, "", 0, 8, 7, 140000]
			9: return ["level_storm", tr("The Shattered Keep"), 100, MinutesToMilliseconds(6), 150, "archipelago_storm", 1, 9, 8, 150000]
			10: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 10, 9, 999000]
			11: return ["level_tree", tr("Call to Nature"), 100, MinutesToMilliseconds(6), 150, "archipelago_tree", 1, 11, 12, 210000]
			12: return ["level_tree2", tr("Autumn Harvest"), 120, MinutesToMilliseconds(9), 100, "archipelago_tree2", 1, 12, 13, 211000]
			13: return ["", tr("Winter Wonder"), 100, MinutesToMilliseconds(5), 100, "", 0, 13, 14, 211000]
			14: return ["level_tree_boss", tr("Wrath of Nature"), 0, MinutesToMilliseconds(5), 150, "archipelago_tree_boss", 1, 14, 21, 212000]
			15: return ["level_skytops", tr("The Floating Islands"), 150, MinutesToMilliseconds(7), 100, "archipelago_skytops", 1, 15, 15, 220000]
			16: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 16, 16, 999000]
			17: return ["level_beach", tr("Riding the Waves"), 120, MinutesToMilliseconds(6), 100, "archipelago_beach", 1, 17, 17, 230000]
			18: return ["level_beach", tr("Chloe\'s Beach Race"), 0, MinutesToMilliseconds(5), 100, "archipelago_beach_boss", 1, 18, 20, 231000]
			19: return ["level_atlantis", tr("Rebuilding the Lost City"), 120, MinutesToMilliseconds(10), 150, "archipelago_atlantis", 1, 19, 18, 240000]
			20: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 20, 19, 999000]
			21: return ["level_solar", tr("The Great Space Bake"), 150, MinutesToMilliseconds(6), 100, "archipelago_solar", 1, 21, 23, 310000]
			22: return ["", tr("Found Family"), 100, MinutesToMilliseconds(5), 100, "", 0, 22, 24, 310000] #Not actually sure what this is? I think it's unused
			23: return ["level_pirate", tr("The Houshou Pirates"), 100, MinutesToMilliseconds(6), 200, "archipelago_pirate", 1, 23, 25, 320000]
			24: return ["level_moon", tr("Luknight of Darkness"), 100, MinutesToMilliseconds(10), 200, "archipelago_moon", 1, 24, 26, 330000]
			25: return ["", tr("Lunar Reminiscence"), 100, MinutesToMilliseconds(5), 100, "", 0, 25, 27, 330000]
			26: return ["level_moon_boss", tr("Ganmo\'s Grand Finale"), 50, MinutesToMilliseconds(4), 150, "archipelago_moon_boss", 1, 26, 28, 331000]
			27: return ["level_castleroad", tr("The Road to Civilization"), 120, MinutesToMilliseconds(7), 100, "archipelago_castleroad", 1, 27, 31, 410000]
			28: return ["level_castleroad_boss", tr("Roboco Strikes Back"), 50, MinutesToMilliseconds(5), 150, "archipelago_castleroad_boss", 1, 28, 38, 411000]
			29: return ["level_ruins", tr("Path of Memories"), 150, MinutesToMilliseconds(15), 250, "archipelago_ruins", 1, 29, 32, 420000]
			30: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 30, 33, 999000]
			31: return ["level_cursed", tr("A Head Start"), 120, MinutesToMilliseconds(9), 150, "archipelago_cursed", 1, 31, 34, 430000]
			32: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 32, 35, 999000]
			33: return ["level_factory", tr("The War Mind"), 120, MinutesToMilliseconds(10), 200, "archipelago_factory", 1, 33, 36, 440000]
			34: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 34, 37, 999000]
			35: return ["level_highway", tr("Caravan of Darkness"), 100, MinutesToMilliseconds(6), 150, "archipelago_highway", 1, 35, 40, 510000]
			36: return ["level_arcade", tr("Overclocking the Arcade"), 100, MinutesToMilliseconds(8), 150, "archipelago_arcade", 1, 36, 41, 520000]
			37: return ["", tr("Unknown Gear"), 100, MinutesToMilliseconds(5), 100, "", 0, 37, 42, 999000]
			38: return ["level_concert", tr("Song of Light and Darkness"), 150, MinutesToMilliseconds(8.5), 200, "archipelago_concert", 1, 38, 43, 530000]
			39: return ["level_sanctum_boss", tr("Case Closed"), 0, MinutesToMilliseconds(3), 200, "archipelago_sanctum_boss", 1, 39, 47, 111000]
			40: return ["level_stadium", tr("The KFP Games"), 120, MinutesToMilliseconds(8), 200, "archipelago_stadium", 1, 40, 44, 540000]
			41: return ["level_stadium_boss", tr("Another Time Traveler?"), 0, MinutesToMilliseconds(2.5), 120, "archipelago_stadium_boss", 1, 41, 45, 541000]
			42: return ["level_intermission", tr("The Space Between Worlds"), 0, MinutesToMilliseconds(4.5), 150, "archipelago_intermission", 1, 42, 30, 610000]
			43: return ["level_belltown_alt", tr("Solitude"), 100, MinutesToMilliseconds(7), 150, "archipelago_belltown_alt", 1, 43, 49, 710000]
			44: return ["level_moon_alt", tr("Entropy"), 120, MinutesToMilliseconds(9), 200, "archipelago_moon_alt", 1, 44, 50, 720000]
			45: return ["level_tree_alt", tr("Gloom"), 100, MinutesToMilliseconds(7), 150, "archipelago_tree_alt", 1, 45, 52, 730000]
			46: return ["level_castleroad_alt", tr("Despair"), 100, MinutesToMilliseconds(10), 250, "archipelago_castleroad_alt", 1, 46, 53, 740000]
			47: return ["level_stadium_alt", tr("Hope"), 0, MinutesToMilliseconds(8), 150, "archipelago_stadium_alt", 1, 47, 54, 750000]
			48: return ["level_tower1", tr("Her Time is Now"), 100, MinutesToMilliseconds(8), 150, "archipelago_tower1", 1, 48, 56, 620000]
			49: return ["level_tower2", tr("The Final Ascent"), 150, MinutesToMilliseconds(40), 400, "archipelago_tower2", 1, 49, 57, 630000]
			50: return ["level_tower2_boss", tr("Steel on Steel"), 0, MinutesToMilliseconds(8), 200, "archipelago_tower2_boss", 1, 50, 58, 631000]
			51: return ["level_sanctum2", tr("Defending the Sanctum"), 100, MinutesToMilliseconds(6), 200, "archipelago_sanctum2", 1, 51, 48, 112000]
			52: return ["hub_sanctum", tr("The Council Meeting"), 0, MinutesToMilliseconds(5), 100, "", 0, 52, 11, 100000]
			53: return ["hub_starship", tr("Timeless Weapon"), 0, MinutesToMilliseconds(5), 100, "", 0, 53, 29, 300000]
			54: return ["hub_garden", tr("The Golden Scales"), 0, MinutesToMilliseconds(5), 100, "", 0, 54, 22, 200000]
			55: return ["hub_city", "", 0, MinutesToMilliseconds(5), 100, "", 0, 55, 46, 500000]
			56: return ["hub_civ", tr("A Clean Slate"), 0, MinutesToMilliseconds(5), 100, "", 0, 56, 39, 400000]
			57: return ["hub_camp", "", 0, MinutesToMilliseconds(5), 100, "", 0, 57, 59, 700000]
			58: return ["level_belltown_alt_boss", tr("The Ancient Ones"), 0, MinutesToMilliseconds(3), 100, "archipelago_belltown_alt_boss", 1, 58, 51, 711000]
			59: return ["level_stadium_alt_boss", tr("The Way Home"), 0, MinutesToMilliseconds(6), 150, "archipelago_stadium_alt_boss", 1, 59, 55, 751000]
			60: return ["hub_sanctum", tr("The Secret Sanctum"), 0, MinutesToMilliseconds(5), 100, "endingB", 2, 60, 60, 101000]
			61: return ["level_tower2_boss2", tr("Zero Seconds To Midnight"), 0, MinutesToMilliseconds(7), 150, "archipelago_final", 1, 61, 61, 632000]

	return ["", "Invalid Gear", 100, MinutesToMilliseconds(5), 100, "", 0, 0, 0, 999000]


func UpdateStoryFlag(flagName: String, flagValue: int):
	if archipelagoEnabled:
		if not storyFlag.keys().has(flagName):
			storyFlag[flagName] = 0
	super(flagName, flagValue)

#You will be my nemesis in time.
#also this is where golden gear count is incremented
func UpdateStoryFlags():
	super()
	if (archipelagoEnabled):
		#I have to copy the entire thing because this is where the starting CDs are, pain
		CheckStoryFlag(1, "world_time", 1)
		CheckStoryFlag(4, "world_time", 6)
		CheckStoryFlag(11, "world_nature", 1)
		CheckStoryFlag(14, "world_nature", 6)
		CheckStoryFlag(24, "ending_moon", 1)
		CheckStoryFlag(26, "world_space", 5)
		CheckStoryFlag(29, "world_civ", 3)
		CheckStoryFlag(31, "world_civ", 5)
		CheckStoryFlag(45, "world_alter", 5)
		CheckStoryFlag(47, "world_alter", 9)
		CheckStoryFlag(54, "fishing", 3)
		CheckStoryFlag(60, "ending", 1)

		if storyFlag["world_time"] >= 7:
			goldenGears[52] = true
		if storyFlag["anya"] >= 3:
			goldenGears[53] = true
		if goldenGears[19] and storyFlag["world_nature"] < 3:
			storyFlag["world_nature"] = 3
		if (goldenGears[27] or goldenGears[35]) and not goldenGears[42]:
			goldenGears[42] = true
		if storyFlag.has("endingB"):
			if not goldenGears[50]:
				storyFlag["endingB"] = 0
			elif not goldenGears[60]:
				storyFlag["endingB"] = min(storyFlag["endingB"], 4)
		if storyFlag["world_time"] >= 20:
			goldenGears[59] = true

		var totalGoldenGears: int = GoldenGears()
		if goldenGearAcquired > 0 and goldenGears[goldenGearAcquired] == false:
			totalGoldenGears += 1

		if totalGoldenGears >= 2:
			UpdateStoryFlag("sanctum_irys", 1)
		if totalGoldenGears >= 3:
			UpdateStoryFlag("sanctum_dog", 1)
		if totalGoldenGears >= 5:
			UpdateStoryFlag("world_time", 4)


		for i in 9:
			GameSettings.UnlockCodec("codec_Tutorial" + str(i + 1), false)

		if [
			"AmeliaWatson", 
			"MoriCalliope", 
			"GawrGura", 
			"NinomaeInaNis", 
			"TakanashiKiara"
		].all(codecsUnlocked.has):
			GameSettings.UnlockCodec("codec_Myth")

		if storyFlag["fishing"] >= 2:
			GameSettings.UnlockCodec("codec_Tutorial_Fishing")

		if storyFlag["world_chaos"] >= 2:
			GameSettings.UnlockCodec("codec_LaplusDarknessPrimeTimeline")

		if goldenGears[59]:
			GameSettings.UnlockCodec("codec_Tutorial_ChronoGear")

		#Instead of granting the CDs, check their locations
		if not startingCDsSent:
			for i in [100201, 100202, 100203]:
				CheckLocation(i)
			startingCDsSent = true

		if not achievementsUnlocked.has("ach_holoxpert1") and (goldenGears[4] or goldenGearAcquired == 4):
			UnlockAchievement("ach_holoxpert1")
		if not achievementsUnlocked.has("ach_holoxpert2") and (goldenGears[18] or goldenGearAcquired == 18):
			UnlockAchievement("ach_holoxpert2")
		if not achievementsUnlocked.has("ach_holoxpert3") and (goldenGears[26] or goldenGearAcquired == 26):
			UnlockAchievement("ach_holoxpert3")
		if not achievementsUnlocked.has("ach_holoxpert4") and (goldenGears[31] or goldenGearAcquired == 31):
			UnlockAchievement("ach_holoxpert4")
		if not achievementsUnlocked.has("ach_holoxpert5") and (goldenGears[35]):
			UnlockAchievement("ach_holoxpert5")
		if not achievementsUnlocked.has("ach_time_rebuilt") and (goldenGears[59] or goldenGearAcquired == 59):
			UnlockAchievement("ach_time_rebuilt")

		if not achievementsUnlocked.has("ach_river_angler"):
			if fishRecord.size() > 0 and fishRecord.all(
				func(record: Dictionary): return record["count"] > 0
			):
				UnlockAchievement("ach_river_angler")

		var gears: int
		for i in goldenGears.size():
			if goldenGears[i] == true and IsGoldenGear(i):
				gears += 1
		if not achievementsUnlocked.has("ach_gear_hunter"):
			if gears >= 35:
				UnlockAchievement("ach_gear_hunter")
		if not achievementsUnlocked.has("ach_just_about_perfect") or not achievementsUnlocked.has("ach_the_clock_runs_fast"):
			var score: int
			var time: float
			for i in GameSettings.goldenGears.size():
				if GameSettings.goldenGears[i] == true:
					score += GameSettings.scoreRecord[i]
					time += GameSettings.timeRecord[i]

			if score >= 14000:
				UnlockAchievement("ach_just_about_perfect")
			if gears >= 35 and time < MinutesToMilliseconds(180):
				UnlockAchievement("ach_the_clock_runs_fast")

#If the server sends a fresh item list, need to replace all current items with the sent list
func RefreshItems(items: Array[NetworkItem]):
	archipelagoStageAccess = [false, true, false, false, false, false, false, false,
							  false, false, false, false, false, false, false, false, 
							  false, false, false, false, false, false, false, false, 
							  false, false, false, false, false, false, false, false, 
							  false, false]
	archipelagoWorldAccess = [true, false, false, false, false, false, false]
	archipelagoGearCount = 0
	archipelagoShackleCount = 0
	archipelagoChronoGear = false
	archipelagoThreadCounts = {
		"time": [0, 0, 0], 
		"space": [0, 0], 
		"nature": [0], 
		"civilization": [0], 
		"chaos": [0], 
	}
	archipelagoItemsPurchased = {
		"time": [
				[false, false, false, false, false],
				[false, false, false, false, false], 
				[false, false, false, false, false, false, false, false, false, false, false, false, false],
			],
		"space": [
			[false, false, false, false], 
			[false, false, false, false]
			],
		"nature":
			[[false, false, false, false]],
		"civilization":
			[[false, false, false, false, false, false, false]],
		"chaos": 
			[[false, false, false, false, false, false, false, false, false]]
	}
	storyFlag["ending"] = 0
	for i in range(62):
		if GetStageInfo(i)[5] != "" and storyFlag.keys().has(GetStageInfo(i)[5]):
			storyFlag[GetStageInfo(i)[5]] = 0
	
	for item in items:
		#Regular receive item to not get a HUD message for it
		ReceiveItem(item.id)	

#Handles an item received from the server (which should be all of them, but modularity)
func ReceiveServerItem(item: NetworkItem):
	ReceiveItem(item.id)
	if item.is_local():
		var message = "You found your " + item.get_name()
		hud.SetMessage(message)
	else:
		var message = "Received " + item.get_name() + " from " + Archipelago.conn.get_player_name(item.src_player_id)
		hud.SetMessage(message)

func ReceiveItem(id: int):
	if (id / 1000) as int == 1:
		#Stage or world unlock, type is next digit
		if (id % 1000) / 100 as int == 1:
			#Stage unlock, stage ID is the last 2 digits
			var stageID = id % 100
			match stageID:
				50:
					archipelagoStSReceived = true
					CheckTower2Unlocks(50)
				61:
					archipelagoZStMReceived = true
					CheckTower2Unlocks(61)
				_:
					UpdateStoryFlag(GetStageInfo(stageID)[5], 1) #unlock the level
					UnlockStage(stageID)
					if slotData["world_unlock_mode"] == 0:
						UnlockWorld(stageID)
		else:
			#World unlock, last digit is the ID
			var worldID = id % 10 as int
			#The worlds are in a weird order (see the archipelagoWorldAccess array),
			#and I did not know that when making these IDs
			match worldID:
				0:
					archipelagoWorldAccess[0] = true
				1:
					archipelagoWorldAccess[1] = true
				2:
					archipelagoWorldAccess[4] = true
				3:
					archipelagoWorldAccess[2] = true
				4:
					archipelagoWorldAccess[3] = true
				5:
					archipelagoWorldAccess[5] = true
				6:
					archipelagoWorldAccess[6] = true
	else:
		#Item unlock, next digit is the item type
		match ((id % 1000) / 100) as int:
			0: 
				archipelagoGearCount += 1
				CheckGoalCondition()
			1: 
				archipelagoShackleCount += 1
				CheckTower2Unlocks(50) #Steel on Steel
				CheckTower2Unlocks(61) #Zero Seconds to Midnight
			2: 
				#thread unlock, last two digits are shop then page
				match (id / 10) % 10:
					0:
						archipelagoThreadCounts["time"][id % 10] += 1
					1:
						archipelagoThreadCounts["nature"][id % 10] += 1
					2:
						archipelagoThreadCounts["space"][id % 10] += 1
					3:
						archipelagoThreadCounts["civilization"][id % 10] += 1
					4:
						archipelagoThreadCounts["chaos"][id % 10] += 1
				UnlockThread(id) #I need to account for the different pages of threads now
			3: UnlockCD(cds[(id % 100) - 1].cd_id) #I assumed this was 1 indexed when I made the item IDs, it's not
			4: #Ability Unlocks
				match (id % 100):
					0: 
						archipelagoChronoGear = true
					_:
						return
						#For now, this is just the chrono gear. I'll be adding other abilities later
			5: #Border arts
				borderArtUnlocked.append(borderArt.keys()[id % 100])

#Maps individual levels to the stages they are in	
func UnlockStage(id: int):
	match id:
		1: archipelagoStageAccess[0] = true
		2: archipelagoStageAccess[2] = true
		4: archipelagoStageAccess[2] = true
		5: archipelagoStageAccess[3] = true
		7: archipelagoStageAccess[4] = true
		9: archipelagoStageAccess[5] = true
		11: archipelagoStageAccess[6] = true
		12: archipelagoStageAccess[6] = true
		14: archipelagoStageAccess[6] = true
		15: archipelagoStageAccess[8] = true
		17: archipelagoStageAccess[9] = true
		18: archipelagoStageAccess[9] = true
		19: archipelagoStageAccess[10] = true
		21: archipelagoStageAccess[11] = true
		23: archipelagoStageAccess[13] = true
		24: archipelagoStageAccess[14] = true
		26: archipelagoStageAccess[14] = true
		27: archipelagoStageAccess[16] = true
		28: archipelagoStageAccess[16] = true
		29: archipelagoStageAccess[18] = true
		31: archipelagoStageAccess[19] = true
		33: archipelagoStageAccess[20] = true
		35: archipelagoStageAccess[22] = true
		36: archipelagoStageAccess[23] = true
		38: archipelagoStageAccess[24] = true
		39: archipelagoStageAccess[0] = true
		40: archipelagoStageAccess[25] = true
		41: archipelagoStageAccess[25] = true
		42: archipelagoStageAccess[15] = true
		43: archipelagoStageAccess[26] = true
		44: archipelagoStageAccess[28] = true
		45: archipelagoStageAccess[29] = true
		46: archipelagoStageAccess[30] = true
		47: archipelagoStageAccess[31] = true
		48: archipelagoStageAccess[32] = true
		49: archipelagoStageAccess[33] = true
		50: archipelagoStageAccess[33] = true
		51: archipelagoStageAccess[0] = true
		52: archipelagoStageAccess[1] = true
		53: archipelagoStageAccess[7] = true
		54: archipelagoStageAccess[12] = true
		55: archipelagoStageAccess[17] = true
		56: archipelagoStageAccess[21] = true
		57: archipelagoStageAccess[27] = true
		58: archipelagoStageAccess[26] = true
		59: archipelagoStageAccess[31] = true
		61:	archipelagoStageAccess[33] = true

#Maps levels to the world they're in, to be called in automatic world unlock mode
func UnlockWorld(id: int):
	match id:
		1, 2, 4, 5, 7, 9, 39, 51, 52:
			archipelagoWorldAccess[0] = true #Time
		11, 12, 14, 15, 17, 18, 19, 54:
			archipelagoWorldAccess[1] = true #Nature
		21, 23, 24, 26, 53:
			archipelagoWorldAccess[4] = true #Space
		27, 28, 29, 31, 33, 56:
			archipelagoWorldAccess[2] = true #Civ
		35, 36, 38, 40, 41, 55:
			archipelagoWorldAccess[3] = true #Chaos
		42, 48, 49, 50, 61:
			archipelagoWorldAccess[5] = true #Darkness
		43, 44, 45, 46, 47, 57, 58, 59:
			archipelagoWorldAccess[6] = true #Alter

#Extra logic handling for Steel on Steel and Zero Seconds to Midnight,
#which both require having all 5 shackles to unlock
func CheckTower2Unlocks(id: int):
	if id == 50:
		#Steel on Steel
		if (archipelagoShackleCount >= slotData["steel_on_steel_shackle_requirement"] and archipelagoStSReceived):
			UpdateStoryFlag(GetStageInfo(id)[5], 1) #unlock the level
			UnlockStage(id) 
	else:
		#Zero Seconds to Midnight
		if (archipelagoShackleCount >= slotData["zero_seconds_to_midnight_shackle_requirement"] and archipelagoZStMReceived):
			UpdateStoryFlag(GetStageInfo(id)[5], 1) #unlock the level
			UpdateStoryFlag("ending", 1) #Make sure the cutscene lets you through
			UnlockStage(id) 

#This will send the checked location over to Archipelago, once I have more of that figured out
func CheckLocation(locationId: int):
	if not checkedLocations.has(locationId): 
		checkedLocations.append(locationId)
	Archipelago.collect_location(locationId)

#Some extra handling for purchasing something from a shop.
#Could probably be done on the shop's end, but keeping this in one place
func CheckShopLocation(shop: String, page: int, unlock: int):
	match shop:
		"time":
			CheckLocation(1000 + (100 * page) + unlock)
		"nature":
			CheckLocation(2000 + (100 * page) + unlock)
		"space":
			CheckLocation(3000 + (100 * page) + unlock)
		"civilization":
			CheckLocation(4000 + (100 * page) + unlock)
		"chaos":
			CheckLocation(5000 + (100 * page) + unlock)
	archipelagoShopPurchases[shop][page] += 1
	archipelagoItemsPurchased[shop][page][unlock] = true

#Marks a level as having been completed, and checks to see if that should send any level unlock checks
func MarkLevelCompletion(levelId: int):
	archipelagoCompletedLevels.append(levelId)
	
	match levelId:
		1: 
			CheckLocation(GameSettings.GetStageInfo(2)[9]) #Top of Bell Tower
			CheckLocation(10) #Time Hub
		2: 
			CheckLocation(GameSettings.GetStageInfo(5)[9]) #PolPol Express
			CheckLocation(GameSettings.GetStageInfo(7)[9]) #Gravity of Time
			CheckLocation(GameSettings.GetStageInfo(9)[9]) #Shattered Keep
		4: 
			CheckLocation(2) #World of Nature
			CheckLocation(3) #World of Space
			CheckLocation(GameSettings.GetStageInfo(11)[9]) #Call to Nature
			CheckLocation(GameSettings.GetStageInfo(21)[9]) #Great Space Bake
		5: 
			if(archipelagoCompletedLevels.has(5) and archipelagoCompletedLevels.has(7) and archipelagoCompletedLevels.has(9)):
				CheckLocation(GameSettings.GetStageInfo(4)[9]) #Battle of Bell Town
		7: 
			if(archipelagoCompletedLevels.has(5) and archipelagoCompletedLevels.has(7) and archipelagoCompletedLevels.has(9)):
				CheckLocation(GameSettings.GetStageInfo(4)[9]) #Battle of Bell Town
		9: 
			if(archipelagoCompletedLevels.has(5) and archipelagoCompletedLevels.has(7) and archipelagoCompletedLevels.has(9)):
				CheckLocation(GameSettings.GetStageInfo(4)[9]) #Battle of Bell Town
		11: 
			CheckLocation(GameSettings.GetStageInfo(12)[9]) #Autumn Harvest
			CheckLocation(GameSettings.GetStageInfo(15)[9]) #Sky Tops
			CheckLocation(GameSettings.GetStageInfo(17)[9]) #Riding the Waves
			CheckLocation(20) #Nature Hub
		#12: If I'm correct, Autumn Harvest is actually not required 
		14: 
			if(archipelagoCompletedLevels.has(14) and archipelagoCompletedLevels.has(26)):
				if slotData["intermission_world_unlocks"] == false:
					CheckLocation(4) #World of Civilization
					CheckLocation(5) #World of Chaos
					CheckLocation(GameSettings.GetStageInfo(27)[9]) #Road to Civilization
					CheckLocation(GameSettings.GetStageInfo(35)[9]) #Caravan of Darkness
				CheckLocation(GameSettings.GetStageInfo(42)[9]) #Intermission
		15: 
			if(archipelagoCompletedLevels.has(15) and archipelagoCompletedLevels.has(17)):
				CheckLocation(GameSettings.GetStageInfo(19)[9]) #Rebuilding the Lost City
		17: 
			if(archipelagoCompletedLevels.has(15) and archipelagoCompletedLevels.has(17)):
				CheckLocation(GameSettings.GetStageInfo(19)[9]) #Rebuilding the Lost City
		18: 
			CheckLocation(GameSettings.GetStageInfo(14)[9]) #Wrath of Nature
		19: 
			CheckLocation(GameSettings.GetStageInfo(18)[9]) #Chloe's Beach Race
		21: 
			CheckLocation(GameSettings.GetStageInfo(23)[9]) #Houshou Pirates
			CheckLocation(30) #Space Hub
		23: 
			CheckLocation(GameSettings.GetStageInfo(24)[9]) #Luknight of Darkness
		24: 
			CheckLocation(GameSettings.GetStageInfo(26)[9]) #Ganmo's Grand Finale
		26: 
			if(archipelagoCompletedLevels.has(14) and archipelagoCompletedLevels.has(26)):
				if slotData["intermission_world_unlocks"] == false:
					CheckLocation(4) #World of Civilization
					CheckLocation(5) #World of Chaos
					CheckLocation(GameSettings.GetStageInfo(27)[9]) #Road to Civilization
					CheckLocation(GameSettings.GetStageInfo(35)[9]) #Caravan of Darkness
				CheckLocation(GameSettings.GetStageInfo(42)[9]) #Intermission
		27: 
			CheckLocation(GameSettings.GetStageInfo(29)[9]) #Path of Memories
			CheckLocation(40) #Civilization Hub
		28: 
			if archipelagoCompletedLevels.has(28) and archipelagoCompletedLevels.has(41):
				CheckLocation(GameSettings.GetStageInfo(42)[9])
		29: 
			CheckLocation(GameSettings.GetStageInfo(31)[9]) #A Head Start
		31: 
			CheckLocation(GameSettings.GetStageInfo(33)[9]) #The War Mind
		33: 
			CheckLocation(GameSettings.GetStageInfo(28)[9]) #Roboco Strikes Back
		35: 
			CheckLocation(GameSettings.GetStageInfo(36)[9]) #Overclocking the Arcade
			CheckLocation(50) #Chaos Hub
		36: 
			CheckLocation(GameSettings.GetStageInfo(38)[9]) #Song of Light and Darkness
		38: 
			CheckLocation(GameSettings.GetStageInfo(40)[9]) #The KFP Games
		39: 
			CheckLocation(GameSettings.GetStageInfo(51)[9]) #Defending the Sanctum
		40: 
			CheckLocation(GameSettings.GetStageInfo(41)[9]) #Another Time Traveler?
		41: 
			if archipelagoCompletedLevels.has(28) and archipelagoCompletedLevels.has(41):
				CheckLocation(GameSettings.GetStageInfo(39)[9]) #Case Closed
		42: 
			if slotData["intermission_world_unlocks"] == true:
				CheckLocation(4) #World of Civilization
				CheckLocation(5) #World of Chaos
				CheckLocation(GameSettings.GetStageInfo(27)[9]) #Road to Civilization
				CheckLocation(GameSettings.GetStageInfo(35)[9]) #Caravan of Darkness
		43: 
			CheckLocation(GameSettings.GetStageInfo(44)[9]) #Entropy
			CheckLocation(70) #Alter Hub
		44: 
			CheckLocation(GameSettings.GetStageInfo(58)[9]) #The Ancient Ones
		45: 
			CheckLocation(GameSettings.GetStageInfo(46)[9]) #Despair
		46: 
			CheckLocation(GameSettings.GetStageInfo(47)[9]) #Hope
		47: 
			CheckLocation(GameSettings.GetStageInfo(59)[9]) #The Way Home
		48: 
			CheckLocation(GameSettings.GetStageInfo(49)[9]) #The Final Ascent
		49: 
			CheckLocation(GameSettings.GetStageInfo(50)[9]) #Steel on Steel
		50: 
			CheckGoalCondition()
			CheckLocation(GameSettings.GetStageInfo(61)[9]) #Zero Seconds to Midnight
		51: 
			CheckLocation(GameSettings.GetStageInfo(43)[9]) #Solitude
			CheckLocation(7) #Alter timeline unlock
		58: 
			CheckLocation(GameSettings.GetStageInfo(45)[9]) #Gloom
		59: 
			CheckLocation(GameSettings.GetStageInfo(48)[9]) #Her Time is Now
			CheckLocation(60) #World of Darkness unlock
		61: 
			CheckGoalCondition()

func ArchipelagoThreadsAvailable(shop: String = "none", page: int = 0) -> int:
	if(!archipelagoEnabled or (shop == "none" and page == 0)):
		return ThreadsAvailable()
	else:
		#Making it return at least 0 in case something weird happens, but I don't expect it to
		return max(archipelagoThreadCounts[shop][page] - archipelagoShopPurchases[shop][page], 0)

func StoreShopItem(item: NetworkItem):
	if archipelagoShopItems == null:
		archipelagoShopItems = {}
	archipelagoShopItems[item.loc_id] = item

func CheckGoalCondition():
	match slotData["goal_condition"]:
		0:
			#Clear Steel on Steel
			if archipelagoCompletedLevels.has(50):
				Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)
		1:
			#Clear Zero Seconds to Midnight
			if archipelagoCompletedLevels.has(61):
				Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)
		2:
			#Gear Hunt
			if archipelagoGearCount >= slotData["gear_hunt_requirement"]:
				Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)

func ClearGameData():
	super()
	slotData = {}
	archipelagoStageAccess = [false, true, false, false, false, false, false, false,
							  false, false, false, false, false, false, false, false, 
							  false, false, false, false, false, false, false, false, 
							  false, false, false, false, false, false, false, false, 
							  false, false]
	archipelagoWorldAccess = [true, false, false, false, false, false, false]
	checkedLocations = []
	archipelagoGearCount = 0
	archipelagoShackleCount = 0
	archipelagoCompletedLevels = []
	archipelagoChronoGear = false
	archipelagoThreadCounts = {
		"time": [0, 0, 0], 
		"space": [0, 0], 
		"nature": [0], 
		"civilization": [0], 
		"chaos": [0], 
	}
	archipelagoShopPurchases = {
		"time": [0, 0, 0], 
		"space": [0, 0], 
		"nature": [0], 
		"civilization": [0], 
		"chaos": [0], 
	}
	archipelagoItemsPurchased = {
	"time": [
				[false, false, false, false, false],
				[false, false, false, false, false], 
				[false, false, false, false, false, false, false, false, false, false, false, false, false],
			],
	"space": [
			[false, false, false, false], 
			[false, false, false, false]
			],
	"nature":
			[[false, false, false, false]],
	"civilization":
			[[false, false, false, false, false, false, false]],
	"chaos": 
			[[false, false, false, false, false, false, false, false, false]]
	}
	startingCDsSent = false
	collectedCDs = []
	collectedThreads = []
	if (archipelagoEnabled):
		#Change this to starting hub
		currentMap = "res://Maps/hub_sanctum.tscn"
		previousMap = "res://Maps/hub_sanctum.tscn"
		

func PackArchipelagoData():
	var archipelagoData: Dictionary = {
		"stageAccess": archipelagoStageAccess,
		"worldAccess": archipelagoWorldAccess,
		"checkedLocations": checkedLocations,
		"gearCount": archipelagoGearCount,
		"shackleCount": archipelagoShackleCount,
		"completedLevels": archipelagoCompletedLevels,
		"stsReceived": archipelagoStSReceived,
		"zstmReceived": archipelagoZStMReceived,
		"chronoGear": archipelagoChronoGear,
		"threadCounts": archipelagoThreadCounts,
		"shopPurchases": archipelagoShopPurchases,
		"itemPurchases": archipelagoItemsPurchased,
		"shopItems": archipelagoShopItems,
		"startingCDsSent": startingCDsSent,
		"collectedCDs": collectedCDs,
		"collectedThreads": collectedThreads,
		"receivedItems": Archipelago.conn.received_items
	}
	
	return archipelagoData

func UnpackArchipelagoData(data: Dictionary):
	archipelagoStageAccess = data["stageAccess"]
	archipelagoWorldAccess = data["worldAccess"]
	checkedLocations = data["checkedLocations"]
	archipelagoGearCount = data["gearCount"]
	archipelagoShackleCount = data["shackleCount"]
	archipelagoCompletedLevels = data["completedLevels"]
	archipelagoStSReceived = data["stsReceived"]
	archipelagoZStMReceived = data["zstmReceived"]
	archipelagoChronoGear = data["chronoGear"]
	archipelagoThreadCounts = data["threadCounts"]
	archipelagoShopPurchases = data["shopPurchases"]
	archipelagoItemsPurchased = data["itemPurchases"]
	archipelagoShopItems = data["shopItems"]
	startingCDsSent = data["startingCDsSent"]
	collectedCDs = data["collectedCDs"]
	collectedThreads = data["collectedThreads"]
	receivedItems = data["receivedItems"]
