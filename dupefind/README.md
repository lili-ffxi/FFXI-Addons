**Author:**  Lili<br>
**Version:**  0.8.1<br>
**Date:** October 4, 2020<br>

# dupefind #

* Finds duplicates on current char/across all characters.

---

### Settings ###   

* dupefind uses 'settings.xml' in its data folder for all settings related to searching and displaying results.
* some settings are currently only accessible from the settings file. e.g. toggling print to log and print to textbox.

`__must_match_player__` -- only applies to findall search results. If _true_ df will only display matches with the current character. If _false_ all duplicates found across all characters are displayed.

**Abbreviations:** `//dupe, //df`

### Commands ###

usage:   
`//dupefind flag1 flag2 ... flagN`


dupefind by default does not display:     
- items with the RARE or EXclusive tags
- items that cannot be stacked (with a stack size of 1)
- items that cannot be sent to another character on the same account
and will only disply items on the currently logged in character.

results:   
- dupefind prints results to a textbox by default.
- `//df c` close/clear the textbox
- `//df h` hide the textbox, but keep the results
- `//df s` show the textbox

flags:   
- rare: includes rare items
- ex: includes exclusive items as long as they can be sent via POL
- nostack: includes items with stack size of 1
- asc/desc/none: sorts the results.
- findall: searchs every available character instead of just current
to use the findall flag, you need to have the addon findAll installed, and have 
run it at least once on all characters

example:   
    `//dupe nostack findall` -- will find all duplicate items that are not rare/ex, across every character  
    `//dupe ex nostack`      -- will find all duplicate items, including Ex and items that do not stack, but excluding Rare.

__Note:__ The textbox can be cleared by right-clicking with the mouse on the textbox.

---

#### To do: ####
* BUG: some items aren't displaying (e.g. aurora bass, t. whiteshell)
* add character and character set filtering to findall searching.
* add item matching to findall.
* add scrolling the textbox.
* add buttons for moving items.
* add bag info displays.
* and other textboxes for each bag.

#### Changelog: ####

0.9.0 - Added some code for textbox scrolling, but no actual scrolling.
0.8.1 - sort flag is valid anywhere in the arguments.
0.8.0 - Added findall updating and sort options.  
0.7.0 - Added right-click to clear textbox.  
0.6.3 - Extracted readme into seperate file.  
0.6.2 - Textbox works with findall data now. More code changes.   
0.6.1 - Added colors to textbox and templating for log and textbox.  
0.6.0 - Added textbox display option. Major code changes.  
0.5.2 - Minor fix.  
0.5.1 - Cleanup and better help text.  
0.4 - Some more cleanup.  
0.3 - First release. Many thanks to Arcon for the feedback about the code.  
0.2 - Cleanup. Multiple character search, toggles for stackable, rare, ex, CanSendPol.  
0.1 - Initial version. Single character search and stackable toggle.  

Thanks to Zohno, this addon contains code taken from his addon findAll  
Thanks to Arcon, he took the time to read my original iterations and letting me know all the dumb crap I was doing
