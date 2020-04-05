# Witness Protection ver. 0.0.10

This addon takes care of renaming all the characters you encounter to random names. The goal is to anonymize the screen to make it impossible, or at least very difficult, to recognize who you are or what server you are on by watching a video or a stream.

Potentially useful for, well, streamers or videomakers that want to mantain partial anonymity on the internet. Probably useful for other things but I'll leave that up to you to find. It was also quite fun to write.

**Download:**  
[url=https://github.com/lili-ffxi/FFXI-Addons/]https://github.com/lili-ffxi/FFXI-Addons/[/url]

**IMPORTANT:** witness protection is still very much incomplete. It should not break anything but there might be a few hiccups. Please report them by posting in this thread, thanks!

Changelog:
- 0.0.9 - correctly assigns name lengths
- 0.0.8 - switched from Index to ID
- 0.0.7 - first public release

**How does it work:**
It reassign names both to characters that show up on screen, and to names in chat (party, linkshell, /say, /yell, etc). Names are cached and are persistent during each session, but are reset if you close the game or reload the addon.  
The random names are made from the player Index, and for this reason permanent names are only assigned once somebody shows up on your screen. People that you haven't met yet will be "Anon123", where 123 changes randomly.  
For testing purposes, the command `//wit` will print the name cache to the chatlog.

Due to the name cache, if you receive a /tell from somebody, replying to their name *will* make the message arrive to the intended recipient!

Also due to the name cache, is possible to assign permanent renames to anybody you want. You can also de-anonymize yourself (or anybody) by simply assigning your own name to yourself.

All the code in this has been written by me, but the original idea belong to [i]towbes[/i] from the Ashita discord, who is writing the exact same thing for Ashita.

**Known issues:**  
- ~~the length of the new name is capped at 4, 8, 12 or 16 characters, depending on the length of the original name. This seems to be a limitation of Windower. Working on it.~~ Fixed.  
- LS messages become garbage. This is definitely a bug in Windower, and (I think) it has been reported.  
- currently (and momentarily) does not anonymize names inside of Synthesis messages.  

**To-do:**
- fix the above.  
- include and test Synthesis messages.  
- write a better readme.  
- randomize linkpearl colors  
- maybe randomize character race and/or face  
- not sure what else.  

Please test it (at your own risk!) and report any suggestion/bugs/improvements. Thanks, and enjoy!
