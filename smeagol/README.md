# Smeagol: automatically uses XP or CP rings.

https://www.ffxiah.com/forum/topic/53244/smeagol-automatically-use-xpcp-rings/

Smeagol will use CP rings at level 99, or XP rings at any level below 99.
Rings need to be in Inventory, or Wardrobe 1-4. If you want to keep a ring from being used, put it in any other bag.

### Available commands:
| Command | Description |
|---|---|
|//smeagol on\|start\|off\|stop | Starts or stops Smeagol.|  
|//smeagol xp\|both\|normal | Changes how Smeagol chooses the ring to use at level 99:|
||`xp` will force use of XP rings _only_, even at level 99.|
||`both` will prioritize CP rings, but will also use XP rings if they're available.|
||`normal` will only use XP rings levels below 99, and only CP rings at level 99.|
||Default is Normal.|
||Note: CP rings will only ever be used at level 99.|
|//smeagol \<number\>| How often Smeagol should check if an exp buff is active, in seconds. Default is 4.|  
|//smeagol check| Come out of sleep and check for usable rings.|  
|//smeagol reset| Restores default settings.|  
|//smeagol town| Toggles use of rings while in town. Default is no.|
|//smeagol r|reload|u|unload| - Reloads/unloads Smeagol.|  

Settings are not yet saved. You can edit the preference table in the lua directly.

### Changelog:
- 1.2.4 - Some minor bugfixes.
- 1.2.3 - Added idle_ring option in the lua, for characters not running GearSwap.
- 1.2.2 - Improved midaction logic.
- 1.2.1 - Fixed bug in the capped merit detection.
- 1.2.0 - Added midaction check.
- 1.1.0 - Human readable times, added detection for capped JP/Merits, added movement check.
- 1.0.1 - Minor code tweak.
- 1.0.0 - Breaking changes to the override logic. Added town check and related command.
- 0.6.0 - Added a delay on load, so there's time to set override manually before it attempts to use the first ring.
- 0.5.0 - Rewrote ring check function to not overwrite CP buff when switching to a sub level 99 job.  
          Reduced reliance on resources as an attempt to reduce memory usage.
- 0.4.0 - Added Endorsement Ring and a check for logged in status.  
- 0.3.1 - Bugfix.  
- 0.3.0 - Reduced memory, removed race condition, added check command.  
- 0.2.2 - Minor edits.  
- 0.2.1 - Added license and this help text.  
- 0.2.0 - Added checks for Mog House and Idle/Engaged status.  
- 0.1.2 - Removed chatlog spam that occurred when all available rings were on recast, and other adjustments.  
- 0.1.0 - Initial release.  

### Features
- Does not use rings inside town. Can toggle with `//smeagol town` command.
- Waits until you're not moving or casting a spell/using a JA/WS to use a ring.
- Uses CP rings at level 99, and XP rings at level 98 or below.
- Uses XP rings even at level 99 if one of the two overrides is set.
- Detects when you are carrying capped JP or Merits, to not waste ring charges.  
Merits are never considered capped if Emporox's Gift buff is active.

### TO-DO
- Nothing!? Suggestions welcome.
Note: no, I won't make it automatically drop spent rings.

Thanks to Kale for his gearswap suite, Smeagol started with code from that.  
Thanks to from20020516, the code that check for ring cooldown is from him.  
