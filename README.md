# Loadout Anytime

This Sourcemod plugin for TF2 allows players to change their loadout at any time.

This is a "what if" scenario plugin. It's not meant to be taken seriously, but it's fun to play with.

## Features

- Change your loadout at any time.
- Clip sizes are saved between weapons.
- Regeneration times are saved between weapons. (for use with the Flying Guillotine, Jarate, etc.)
- Overheal applies when switching from a weapon that lowers your health. (such as when switching to the Sandman)
- Uses existing bind setup (`+attack3` or `MOUSE3` by default) to quickly open the loadout menu.
- Chat and console command (`!loadout [item] [slot]` or `sm_loadout [item] [slot]`) to change specific items.

## Known Issues

- Ammo is not saved between weapons. Instead, every weapon uses the same reserve ammo pool. This may be changed in the future.
- Rechargable weapons (e.g. Pomson, Cow Mangler) may not save their recharge amount when switching to a different weapon.
- Holding down attack buttons for throwable weapons (e.g. Jarate) will allow you to immediately regenerate the weapon by switching to a different weapon and back.

## Progress

- [x] Scout
  - [x] Primary
  - [x] Secondary
  - [x] Melee
- [ ] Sniper
  - [x] Primary
  - [x] Secondary
  - [ ] Melee
- [ ] Soldier
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
- [ ] Demoman
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
- [ ] Medic
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
- [ ] Heavy
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
- [ ] Pyro
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
- [ ] Spy
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
  - [ ] PDA
  - [ ] PDA2
  - [ ] Building
- [ ] Engineer
  - [ ] Primary
  - [ ] Secondary
  - [ ] Melee
  - [ ] PDA
  - [ ] PDA2
  - [ ] Building

## Dependencies

- [Gimme](https://forums.alliedmods.net/showthread.php?t=335644)
  - It is recommended to modify and recompile this plugin to remove all instances of `PrintToChat` and blank out the `TF2_SwitchtoSlot` function.
  - These changes will prevent the plugin from spamming chat and automatically switching weapons which causes issues.
  - Alternatively, use my [forked variant of Gimme](https://github.com/KiwifruitDev/gimme) which has these changes already made.
- [TF2Attributes](https://forums.alliedmods.net/showthread.php?t=210221)
- [Econ Data](https://forums.alliedmods.net/showthread.php?t=315011)
- [Alternative Hud Text](https://forums.alliedmods.net/showthread.php?t=155911) (compile-time dependency only)

## Installation

1. Download the latest release from the [releases page](https://github.com/KiwifruitDev/loadout-anytime/releases).
1. Extract the contents of the zip file into your `tf` folder. This will add the `loadout_anytime.smx` file to your `tf/addons/sourcemod/plugins` folder.
1. Restart your server or type `sm plugins load loadout_anytime` in the server console.
1. Players can use the `!loadout [item] [slot]` command to change their loadout at any time. Using the command without any arguments will display a menu with slots and items to choose from.
1. Pressing the `+attack3` key (default: `MOUSE3`) will open the loadout menu.

## Development

1. Clone the repository to a mod folder inside of your TF2 server directory. (not the `tf` folder!)
1. Install the dependencies listed above.
1. Run `compile.bat` to compile the plugin. You may optionally copy and modify this batch file to accommodate your own build environment.
1. The plugin should be copied over to your `tf/addons/sourcemod/plugins` folder automatically. If it is not, you can copy it manually.
1. Type `sm plugins reload loadout_anytime` in the server console to reload the plugin.

## Pull Requests & Issues

Pull requests and issues are welcome. Please make sure to follow the [contributing guidelines](CONTRIBUTING.md) for pull requests.

## Configuration

All weapon indices, class, and slot configurations are compiled into the plugin.

In order to modify the configuration, you will need to recompile the plugin yourself.

There may be a configuration file in the future, but for now, the plugin must be recompiled.

## Quick Switch CFG

Write this CFG to your client's `autoexec.cfg` file to bind quick switch keys to your numpad.

```cfg
bind kp_end "sm_loadout 1"
bind kp_downarrow "sm_loadout 2
bind kp_pgdn "sm_loadout 3"
bind kp_leftarrow "sm_loadout 4"
bind kp_5 "sm_loadout 5"
bind kp_rightarrow "sm_loadout 6"
bind kp_home "sm_loadout 7"
bind kp_uparrow "sm_loadout 8"
bind kp_pgup "sm_loadout 9"
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
