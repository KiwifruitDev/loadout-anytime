#pragma semicolon 1

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <gimme> // MODIFIED: Removed chat printouts and slot switching
#include <tf2_hud>

ArrayList debounce = null;
ArrayList clientPool = null;
ArrayList forceCycle = null;
ArrayList forceCycleOverride = null;
ArrayList forceCycleOverrideSlot = null;

#define MAX_LOADOUT 8
#define MAX_AMMO_TYPES 35
// index, name, ammo type, clip size, max ammo
#define INVALID_METADATA {"-1","Invalid","0","0","0"}

public Plugin:myinfo = {
	name = "Loadout Anytime",
	author = "KiwifruitDev",
	description = "Use !loadout to change your loadout at any time.",
	version = "1.0.0",
	url = "http://github.com/KiwifruitDev/loadout-anytime",
};

// Timer callback
public Action:TimerCallback(Handle:timer, any:data) {
	// Loop through clients
	for (int i = 1; i <= MaxClients; i++) {
		// Check if client is connected
		if (IsClientInGame(i)) {
			// Get client's pool
			ArrayList meterPool = clientPool.Get(i);
			// Loop through pool
			for (int c = 0; c < MAX_LOADOUT; c++) {
				// Get value
				int meter = meterPool.Get(c);
				if (meter > 0) {
					// Subtract 1 from meter
					meterPool.Set(c, meter - 1);
				}
			}
		}
	}
}

public OnPluginStart() {
	// Create variables
	debounce = new ArrayList();
	clientPool = new ArrayList();
	forceCycle = new ArrayList();
	forceCycleOverride = new ArrayList();
	forceCycleOverrideSlot = new ArrayList();
	// Loop all clients, setup pools
	for (int i = 1; i <= MaxClients; i++) {
		SetupPools(i, true);
	}
	// Create !loadout
	RegConsoleCmd("sm_loadout", Cmd_Loadout, "Loadout command");
}

public OnPluginEnd() {
	// Destroy variables
	delete debounce;
	delete clientPool;
	delete forceCycle;
	delete forceCycleOverride;
	delete forceCycleOverrideSlot;
}

public SetupPools(int client, bool push)
{
	// Create pool for client
	ArrayList myPool = new ArrayList();
	ArrayList clipPool = new ArrayList();
	ArrayList regenPool = new ArrayList();
	ArrayList slotPool = new ArrayList();
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		clipPool.Push(-1);
	}
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		regenPool.Push(0.0);
	}
	for (int i = 0; i < MAX_LOADOUT; i++) {
		slotPool.Push(0);
	}
	myPool.Push(clipPool); // clip
	myPool.Push(regenPool); // regen
	myPool.Push(slotPool); // slot
	if (push) {
		clientPool.Push(myPool);
	} else {
		clientPool.Set(client, myPool);
	}
}

public Action TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	return Plugin_Continue;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Get client
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetupPools(client, false);
}

public Action:Event_PlayerDisconnect(Handle:event, String:name[], bool:dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	// Remove client from pool
	clientPool.Erase(client);
}

// Metadata for weapons in displayed order
char weaponIndexMetaData[10][6][MAX_LOADOUT][5][256] = {
	{ // 0 Unknown
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 1 Scout
		{ // 0 Primary
			{ // 0
				"13",
				"Scattergun",
				"1",
				"6",
				"32",
			},
			{ // 1
				"45",
				"Force-A-Nature",
				"2",
				"2",
				"32",
			},
			{ // 2
				"220",
				"Shortstop",
				"3",
				"4",
				"32",
			},
			{ // 3
				"448",
				"Soda Popper",
				"4",
				"2",
				"32",
			},
			{ // 4
				"772",
				"Baby Face's Blaster",
				"5",
				"4",
				"32",
			},
			{ // 5
				"1103",
				"Back Scatter",
				"6",
				"4",
				"32",
			},
			INVALID_METADATA,INVALID_METADATA, // 6, 7
		},
		{ // 1 Secondary
			{ // 0
				"23",
				"Pistol",
				"7",
				"12",
				"36",
			},
			{ // 1
				"46",
				"Bonk! Atomic Punch",
				"8",
				"1",
				"0",
			},
			{ // 2
				"163",
				"Crit-a-Cola",
				"9",
				"1",
				"0",
			},
			{ // 3
				"222",
				"Mad Milk",
				"10",
				"1",
				"0",
			},
			{ // 4
				"449",
				"Winger",
				"11",
				"5",
				"36",
			},
			{ // 5
				"773",
				"Pretty Boy's Pocket Pistol",
				"12",
				"9",
				"36",
			},
			{ // 6
				"812",
				"Flying Guillotine",
				"13",
				"1",
				"0",
			},
			INVALID_METADATA, // 7
		},
		{ // 2 Melee
			{ // 0
				"0",
				"Bat",
				"14",
				"1",
				"0",
			},
			{ // 1
				"44",
				"Sandman",
				"15",
				"1",
				"0",
			},
			{ // 2
				"317",
				"Candy Cane",
				"16",
				"1",
				"0",
			},
			{ // 3
				"325",
				"Boston Basher",
				"17",
				"1",
				"0",
			},
			{ // 4
				"349",
				"Sun-on-a-Stick",
				"18",
				"1",
				"0",
			},
			{ // 5
				"355",
				"Fan O'War",
				"19",
				"1",
				"0",
			},
			{ // 6
				"450",
				"Atomizer",
				"20",
				"1",
				"0",
			},
			{ // 7
				"648",
				"Wrap Assassin",
				"21",
				"1",
				"0",
			},
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 2 Sniper
		{ // 0 Primary
			{ // 0
				"14",
				"Sniper Rifle",
				"22",
				"25",
				"0",
			},
			{ // 1
				"56",
				"Huntsman",
				"23",
				"1",
				"12",
			},
			{ // 2
				"230",
				"Sydney Sleeper",
				"24",
				"25",
				"0",
			},
			{ // 3
				"402",
				"Bazaar Bargain",
				"25",
				"25",
				"0",
			},
			{ // 4
				"526",
				"Machina",
				"26",
				"25",
				"0",
			},
			{ // 5
				"752",
				"Hitman's Heatmaker",
				"27",
				"25",
				"0",
			},
			{ // 6
				"1098",
				"Classic",
				"28",
				"25",
				"0",
			},
			INVALID_METADATA, // 7
		},
		{ // 1 Secondary
			{ // 0
				"16",
				"SMG",
				"29",
				"25",
				"75",
			},
			{ // 1
				"57",
				"Razorback",
				"30",
				"0",
				"0",
			},
			{ // 2
				"58",
				"Jarate",
				"31",
				"1",
				"0",
			},
			{ // 3
				"231",
				"Darwin's Danger Shield",
				"32",
				"0",
				"0",
			},
			{ // 4
				"642",
				"Cozy Camper",
				"33",
				"0",
				"0",
			},
			{ // 5
				"751",
				"Cleaner's Carbine",
				"34",
				"25",
				"75",
			},
			INVALID_METADATA,INVALID_METADATA, // 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 3 Soldier
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 4 Demoman
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 5 Medic
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 6 Heavy
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 7 Pyro
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 8 Spy
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
	{ // 9 Engineer
		{ // 0 Primary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 1 Secondary
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 2 Melee
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 3 PDA
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 4 PDA2
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
		{ // 5 Building
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 0, 1, 2, 3
			INVALID_METADATA,INVALID_METADATA,INVALID_METADATA,INVALID_METADATA, // 4, 5, 6, 7
		},
	},
};

// !loadout
public Action:Cmd_Loadout(int client, int args)
{
	// If no args, open menu to select slot
	if(args == 0)
	{
		Menu menu = new Menu(OnMenuSelectSlot);
		menu.SetTitle("Loadout: Choose Slot");
		menu.AddItem("", "Primary");
		menu.AddItem("", "Secondary");
		menu.AddItem("", "Melee");
		menu.AddItem("", "PDA");
		menu.AddItem("", "PDA2");
		menu.AddItem("", "Building");
		menu.Display(client, MENU_TIME_FOREVER);
	}
	// Else, use weapon by arg
	else
	{
		// Check for 2nd arg
		int item = GetCmdArgInt(1);
		item = item - 1;
		// If item is valid, use weapon
		if (item < MAX_LOADOUT)
		{
			forceCycle.Push(client);
			forceCycleOverride.Push(item);
			if(args >= 2)
			{
				int slot = GetCmdArgInt(2);
				slot = slot - 1;
				if (slot < 6)
				{
					forceCycleOverrideSlot.Push(slot);
				}
			}
			return Plugin_Handled;
		}
		// Show help
		PrintToChat(client, "Usage: !loadout [item] [slot]");
	}
	return Plugin_Handled;
}

// Menu
public int OnMenuSelect(Menu menu, MenuAction:action, int client, int item)
{
	switch(action)
	{
		case MenuAction_Select:
   		{
			forceCycle.Push(client);
			forceCycleOverride.Push(item);
			// Get menu title
			char title[32];
			menu.GetTitle(title, sizeof(title));
			// Get slot from title ("Loadout: Slot X")
			ReplaceString(title, 32, "Loadout: Slot ", "");
			int slot = StringToInt(title)-1;
			forceCycleOverrideSlot.Push(slot);
		}
	}
	return 0;
}

public int OnMenuSelectSlot(Menu menu2, MenuAction:action, int client, int slot)
{
	switch(action)
	{
		case MenuAction_Select:
   		{
			// Get class
			int class = GetEntProp(client, Prop_Send, "m_iClass");
			// Open menu
			Menu menu = new Menu(OnMenuSelect);
			menu.SetTitle("Loadout: Slot %d", slot+1);
			// Loop weaponIndexMetaData[class][slot][i]
			for (new i = 0; i < MAX_LOADOUT; i++) {
				// Is weapon valid?
				if (StringToInt(weaponIndexMetaData[class][slot][i][0]) == -1) {
					continue;
				}
				// Add weapon name to menu
				menu.AddItem("", weaponIndexMetaData[class][slot][i][1]);
			}
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
	}
	return 0;
}

public Action:OnPlayerRunCmd(iClient, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	int forceCycleIndex = forceCycle.FindValue(iClient);
	bool forceCycleClient = forceCycleIndex != -1;
	if(buttons & IN_ATTACK3)
	{
		// Make client execute sm_loadout
		ClientCommand(iClient, "sm_loadout");
	}
	if (forceCycleClient) {
		int oldWeapon = -1;
		int newWeapon = -1;
		int override = -1;
		int slot = -1;
		if (forceCycleClient) {
			int overrideIndex = forceCycleOverride.Length <= forceCycleIndex ? -1 : forceCycleOverride.Get(forceCycleIndex);
			if(overrideIndex != -1)
			{
				override = forceCycleOverride.Get(forceCycleIndex);
				forceCycleOverride.Erase(forceCycleIndex);
			}
			int forceCycleOverrideSlotIndex = forceCycleOverrideSlot.Length <= forceCycleIndex ? -1 : forceCycleOverrideSlot.Get(forceCycleIndex);
			if(forceCycleOverrideSlotIndex != -1)
			{
				slot = forceCycleOverrideSlot.Get(forceCycleIndex);
				forceCycleOverrideSlot.Erase(forceCycleIndex);
			}
			forceCycle.Erase(forceCycleIndex);
		}
		// Remove IN_ATTACK3
		buttons &= ~IN_ATTACK3;
		// Debounce client
		if (debounce.FindValue(iClient) != -1) {
			return Plugin_Continue;
		}
		int debIndex = debounce.Push(iClient);
		// Get weapon
		weapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		int weaponIndex;
		int curClip;
		float curRegen;
		ArrayList myPool = clientPool.Get(iClient);
		ArrayList clipPool = myPool.Get(0);
		ArrayList regenPool = myPool.Get(1);
		ArrayList slotPool = myPool.Get(2);
		bool found = false;
		// Get player class
		int class = GetEntProp(iClient, Prop_Send, "m_iClass");
		// Is weapon valid?
		if (weapon != -1) {
			weaponIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			// Get slot of weapon
			if (slot == -1) {
				for (new i = 0; i < 6; i++) {
					if(weapon == GetPlayerWeaponSlot(iClient, i)) {
						slot = i;
						break;
					}
				}
			}
			curClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
			curRegen = GetEntPropFloat(weapon, Prop_Send, "m_flEffectBarRegenTime");
			SetEntPropFloat(weapon, Prop_Send, "m_flEffectBarRegenTime", GetGameTime());
		}
		else
		{
			// Find slot which is invalid
			if (slot == -1) {
				for (new i = 0; i < 6; i++) {
					if(GetPlayerWeaponSlot(iClient, i) == -1) {
						slot = i;
						break;
					}
				}
			}
			// Set weapon based on slot
			oldWeapon = slotPool.Get(slot);
			newWeapon = oldWeapon + 1;
			if (newWeapon >= MAX_LOADOUT || StringToInt(weaponIndexMetaData[class][slot][newWeapon][0][0]) == -1) {
				newWeapon = 0;
			}
			found = true;
		}
		// Cycle through weapons
		for (new i = 0; i < MAX_LOADOUT; i++) {
			if (weaponIndex == StringToInt(weaponIndexMetaData[class][slot][i][0])) {
				oldWeapon = i;
				found = true;
				if(override > -1)
				{
					newWeapon = override;
					break;
				}
				// If we're at the end of the list or we hit -1, just use the first one in the list
				if (i == MAX_LOADOUT - 1 || StringToInt(weaponIndexMetaData[class][slot][i + 1][0]) == -1) {
					newWeapon = 0;
				} else {
					newWeapon = i + 1;
				}
				break;
			}
		}
		// If we didn't find the weapon, just use the first one in the list
		if (!found) {
			if(override > -1)
			{
				newWeapon = override;
			}
			else
			{
				newWeapon = 0;
			}
			oldWeapon = MAX_LOADOUT - 1;
		}
		slotPool.Set(slot, newWeapon);
		// Save client pool
		clipPool.Set(StringToInt(weaponIndexMetaData[class][slot][oldWeapon][2]), curClip);
		regenPool.Set(StringToInt(weaponIndexMetaData[class][slot][oldWeapon][2]), curRegen);
		myPool.Set(0, clipPool);
		myPool.Set(1, regenPool);
		clientPool.Set(iClient, myPool);
		// Timer: wait 0.01 seconds before giving the weapon
		ArrayList args = new ArrayList();
		args.Push(iClient);
		args.Push(class);
		args.Push(slot);
		args.Push(newWeapon);
		args.Push(debIndex);
		CreateTimer(0.1, GiveWeapon, args);
		// Return
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// Give weapon
public Action:GiveWeapon(Handle:timer, any:data)
{
	ArrayList args = data;
	int iClient = args.Get(0);
	int class = args.Get(1);
	int slot = args.Get(2);
	int newWeapon = args.Get(3);
	int debIndex = args.Get(4);
	ArrayList myPool = clientPool.Get(iClient);
	ArrayList clipPool = myPool.Get(0);
	ArrayList regenPool = myPool.Get(1);
	debounce.Erase(debIndex);
	// Check if index is valid
	int index = StringToInt(weaponIndexMetaData[class][slot][newWeapon][0]);
	if (index == -1) {
		// Return
		return Plugin_Continue;
	}
	giveitem(iClient, index);
	// Show text on HUD
	PrintToHud(iClient, weaponIndexMetaData[class][slot][newWeapon][1]);
	int weapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	// Is weapon valid?
	if (weapon == -1) {
		// Return
		return Plugin_Continue;
	}
	// Set regen time
	float regen = regenPool.Get(StringToInt(weaponIndexMetaData[class][slot][newWeapon][2]));
	if (regen > GetGameTime())
	{
		// Remove weapon, it's still regenerating
		forceCycle.Push(iClient);
	}
	else
	{
		// Set clip if not -1
		int clip = clipPool.Get(StringToInt(weaponIndexMetaData[class][slot][newWeapon][2]));
		if (clip != -1 && clip != 255)
		{
			int maxClip = StringToInt(weaponIndexMetaData[class][slot][newWeapon][3]);
			if (clip > maxClip) {
				clip = maxClip;
			}
			if (clip > 0) {
				SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
			}
		}
	}
}
