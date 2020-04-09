# Witness Protection ver. 0.1.0

This addon takes care of renaming all the characters you encounter to random names. The goal is to make it impossible, or at least very difficult, to recognize who you are or what server you are on by watching a video or a stream.

Potentially useful for, well, streamers or videomakers that want to mantain partial anonymity on the internet. Probably useful for other things but I'll leave that up to you to find. It was also quite fun to write.

**Changelog:**
-  0.1.0 - Added persistent random names and colors for Linkshells, improved caching of names, revamped code significantly.  
- 0.0.11 - testing ls colors  
- 0.0.10 - added incoming /check notifications and improved generation of names  
-  0.0.9 - correctly assigns name lengths  
-  0.0.8 - switched from Index to ID  
-  0.0.7 - first public release  

**How does it work:**  
It reassign names both to characters that show up on screen, and to names in chat (party, linkshell, /say, /yell, etc). Also assigns a random new color and name to any linkshell you come across, both on screen and in chat log. All reassignments are cached and are persistent during each session, but are reset if you close the game or reload the addon.  
The random names are made from the player Id, and for this reason permanent names are only assigned once somebody shows up on your screen. People that you haven't met yet will be "Anonabcd", where "abcd" is a random four letter string. I figure 9999 possibilities are enough with the current state of the game.

For testing purposes, the command `//wit` will dump the entire cache to the chatlog. Careful, it might get long.

Names are assigned uniquely and biunivocally , so if you can send a /tell to a reassigned name and the proper recipient will receive it - this also makes it possible to reply to tells.

Also due to the name cache, it is possible to assign permanent renames to anybody you want. You can also de-anonymize yourself (or anybody) by simply assigning your own name to yourself.

All the code in this has been written by me, but the original idea belong to *towbes* from the Ashita discord, who is writing the exact same thing for Ashita.

**Known issues:**  
- LS names can be garbage, this is due to a quirk of Windower which will be fixed soon. If it happens to you, just wait for the next Windower update.
- Synthesis messages are untested so use at your own risk.

**To-do:**  
- maybe randomize character race and/or face  
- not sure what else.  

Please test it (at your own risk!) and report any suggestion/bugs/improvements. Thanks, and enjoy!
