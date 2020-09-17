# Chatfix  

**For private servers only.**

Fixes chatlog displaying empty lines on private servers after the 10 Sept 2020 update to the retail client.  
That update shortened the Sender Name field of chat packets from 16 bytes to 15.  
Most private servers have not updated, and are still sending old chat packets, which make the updated client display empty lines.  

**NOTE:** this is a band-aid solution. Please let your server admin know that the correct solution is for them to upgrade their server to send correctly formed packets.

**NOTE:** this addon is useless if you are playing on the retail game, and will in fact break your chatlog.
