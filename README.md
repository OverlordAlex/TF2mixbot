A mix bot for South African TF2 (Written in SourcePawn using SourceMod)

The pickupBot.sp can be compiled at: https://www.sourcemod.net/compiler.php

This plugin should be written as a http client, which would make outside integration easier.

Commands:
* add - add youself to the mix (or to the sub queue if the mix is full)
* rem - remove yourself from the mix
* show - show how full the mix is
* start - show all the players in the mix, and reset the queues
* set_players - set the number of players required for the mix 

* rem_player - remove a player id from the mix (admin only)

TODO:
```
 /*
     1. IRC / DISCORD integration
     2. Periodic printing the mix/12 status
     3. Automatic start when full
     4. Remove players by name, instead of ID
*/
```
