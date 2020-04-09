* Smeagol: automatically uses XP or CP rings.

https://www.ffxiah.com/forum/topic/53244/smeagol-automatically-use-xpcp-rings/

Smeagol will use CP rings at level 99, or XP rings at any level below 99.
Rings need to be in Inventory, or Wardrobe 1-4. If you want to keep a ring from
being used, put it in any other bag.

**Commands:**
//smeagol on|start|off|stop - starts or stops Smeagol.  
//smeagol xp|cp|normal - forces the choice of xp/cp rings regardless of level, or disables override.  
//smeagol <number> - how often Smeagol should check if an exp buff is active, in seconds. Default is 4.  
//smeagol check - come out of sleep and check for usable rings.  
//smeagol reset - restores default settings.  
//smeagol r|reload|u|unload - reloads/unloads Smeagol.  

**Changelog:**
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

Thanks to Kale for his gearswap suite, Smeagol started with code from that.  
thanks to from20020516, the code that check for ring cooldown is from him.  
