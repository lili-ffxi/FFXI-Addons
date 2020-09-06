# Position Manager

Set per-character screen position.  

Commands:  
  //pm set <pos_x> <pos_y> \[Charactername|:all\]  
  //pm set delay <seconds> \[Charactername|:all\]  

The delay value is 0 by default. On some systems with very fast or very slow storage, you might need to increase it a bit to make sure that the `wincontrol` plugin gets loaded before position_manager.

Warning: the `all` name will delete every other character-specific settings that are already saved! It's best to use it only once after you install the addon, to set default position for non-specified characters.

### Examples:  
`//pm set 0 60 all`  
Will set the default positioning for all characters to X: 0 and Y: 60 (the height of the Windows 10 taskbar with 150% UI scaling.)  

`//pm set 1920 0 Yourname`  
Will set the default position for the character called "Yourname" to X: 1920 and Y: 0.  
This will make the character appear on the secondary screen that is to the right of the main screen - useful for multi-screen setups.

`//pm set delay 2 :all`
`//pm set 0 40 Yourmain`  
`//pm set 800 40 Youralt`  
Will set delay to 2 seconds for all characters, then position for your main to X: 0, Y: 40, and your alt to the X: 800, Y: 40.
If your laptop screen is 1600px wide, and your instances are both set at 800x600, this will put them side by side.

Note: Characters are only moved after they're logged in. The <all> position will be used for the character login screen as well.

Enjoy.
