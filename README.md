![banner](http://swampservers.net/infection/fatkidbanner.png)

*Fat Kid* is a Garry's Mod remake of the classic Halo 3 custom game with the same name.

The game consists of rounds in which one player spawns as the "Fat Kid", a slow moving character with a massive amount of health, and his goal is to eliminate the other players before the round ends. The other players ("skinny kids") must flee through a narrow map and break down barricades to avoid being cornered and eaten by the Fat Kid. If the Fat Kid eats a player, that player turns into a "skeleton", which is a minion of the Fat Kid. Skeletons are fast-moving but have very low health, and their goal is to help the Fat Kid eliminate the skinny kids. The round has a time limit, and if any skinny kid survives until the end, the Fat Kid loses.

I originally created this gamemode in 2015 and it was [popular on YouTube](https://www.youtube.com/results?search_query=gmod+fat+kid) for some time. It was kept proprietary for several years, but I've decided to open source it now to see what the community can do with it. The official server is available at: fatkid.swampservers.net (type `connect fatkid.swampservers.net` in console) and it is available on Steam Workshop [here](https://steamcommunity.com/sharedfiles/filedetails/?id=2467219933).

If you want to create a community server, please be aware that **this code is distributed with a [restrictive license](https://github.com/swampservers/fatkid/blob/master/LICENSE) which disallows you from selling any form of in-game items or privileges to players**. I don't want my gamemode to be ruined by pay-to-win nonsense; in fact, this is the main reason I kept the gamemode private for so long.

I hope for community contribution to the gamemode. If you make a new map or other extension for it, please be aware that the [license](https://github.com/swampservers/fatkid/blob/master/LICENSE) gives us permission to include your work in this repository so everyone can use it. Extensions are required to be open source as spelled out in the license. We would also appreciate it if VMFs of maps are made available.

# Code

This repo actually contains 3 gamemodes - *Fat Kid*, *Duck Hunt*, and *Infection*. The idea was to remake various infection custom games from Halo 3, and the *Infection* gamemode would manage most of the common game logic. The *Fat Kid* gamemode is a subclass of *Infection*. *Duck Hunt* was another popular Halo 3 custom game which I remade, but I don't host a server for it.

# Mapping

VMFs are included, please use them for examples. There is also an .fgd. All in [maps/](https://github.com/swampservers/fatkid/tree/master/maps).

IF YOU WANT TO SUBMIT A NEW MAP, YOU MUST ALSO WRITE A BACKSTORY! See the [gymnasium](https://github.com/swampservers/fatkid/blob/master/gamemodes/fatkid/gamemode/maps/gymnasium/sh_init.lua) backstory for an example. The backstory should be HTML and will be shown to players when they initially join the server. It should be placed in `gamemodes/fatkid/gamemode/maps/(name of map not including fatkid_ or any number)/sh_init.lua` similarly to the current maps.

- To create barricades: Use frozen prop_physics or func_breakable. Name them "barricade_X" where X is a number. All entities with the same barricade name will share a health bar (which is tracked by the gamemode).
- To make skeleton-only tunnels: Make a trigger brush and tie it to "func_skeletonpass". Only skeletons can walk through it. Make a different entity for each brush.
- Spawnpoints: info_player_start for humans, info_zombie_start for skeletons (if none they use human spawns), info_az_start for fat kid (if none he uses skeleton spawns or human spawns)
- Respawning weapons: Just place frozen weapon entities; the respawning is handled by code in the gamemode.
- Map-specific Lua (such as dodgeball spawning and traffic cars): Add your code to a folder with the map name as shown [here](https://github.com/swampservers/fatkid/tree/master/gamemodes/fatkid/gamemode/maps)
- Props: When the fat kid uses his stun attack, all nearby prop_physics will be unfrozen and have some force added. Using frozen prop_physics can make your map more exciting.
- General practices: Don't make areas too big and open; it makes it too easy for skinny kids to shoot the skeletons. Try to make sure there are at least two ways for skeletons to get to any area to prevent them from getting bored of running through a single doorway and dying over and over.

# Credits

Programmer and official server manager: [swamponions](https://steamcommunity.com/id/swamponions/)

**NEW** fatkid_swimmingpool: [PYROTEKNIK](https://steamcommunity.com/id/pyroteknik/)

fatkid_gymnasium: [swamponions](https://steamcommunity.com/id/swamponions/)

fatkid_elementary: [swamponions](https://steamcommunity.com/id/swamponions/) (a heavily modified [ph_elementary_school](https://steamcommunity.com/sharedfiles/filedetails/?id=2461335501) )

fatkid_underground: [AltShadow](https://steamcommunity.com/id/altshadow/)

duckhunt_pond: [swamponions](https://steamcommunity.com/id/swamponions/)

Playermodel: [Rottweiler](https://steamcommunity.com/sharedfiles/filedetails/?id=416939663)

![wallpaper](https://swampservers.net/loading/fatkidwallpaper.jpg)
