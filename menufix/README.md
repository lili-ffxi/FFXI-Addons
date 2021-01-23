# Menu

**For private servers only.**

Fixes the client crashing when opening the Profile menu after the November update to the retail client.  
That update changed a packet by adding 4 bytes with the Mastery Rank information at the end.
Most private servers have not updated, and are still sending the old, smaller packet, which causes the client to try and display bad data, leading to the crash.

**NOTE:** this is a band-aid solution. Please let your server admin know that the correct solution is for them to upgrade their server to send correctly formed packets.

**NOTE:** this addon is useless if you are playing on the retail game, and will prevent you from seeing your actual Mastery Rank.

**NOTE:** you must zone at least once after manually loading this addon - or load it before the character selection screen.

## Installation

Install this addon like any other windower addon:  
- create a windowerfolder\addons\menufix folder, and put menufix.lua there
- edit your windowerfolder\scripts\init.txt and add a line with `lua load menufix`
OR
- edit your plugin_manager configuration to include this addon.
