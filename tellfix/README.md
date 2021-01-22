# Tellfix  

**For private servers only.**

Fixes being unable to send tells on private servers after the 10 Sept 2020 update to the retail client.  
That update moved the Sender Name field of chat packets from the 5th byte to the 6th.
Most private servers have not updated, and are still expecting the old tell packets, which make the tell fail to send.

**NOTE:** this is a band-aid solution. Please let your server admin know that the correct solution is for them to upgrade their server to accept the new packet format.

**NOTE:** this addon is useless if you are playing on the retail game, and will in fact break your chatlog.

## Installation

Install this addon like any other windower addon:  
- create a windowerfolder\addons\tellfix folder, and put tellfix.lua there
- edit your windowerfolder\scripts\init.txt and add a line with `lua load tellfix`
OR
- edit your plugin_manager configuration to include this addon.
