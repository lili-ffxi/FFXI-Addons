# Tellapart v1.1.4.

This addon adds letters at the end of enemy mob names, for the purpose of telling them apart. It will add letters from the range of A to ZZ, which I assume is going to be enough forever because to get past ZZ it would mean 700 identical mobs of the same name in zone, and I can't see that happen ever.  

Get support for the addon on FFXIAH:  
https://www.ffxiah.com/forum/topic/57093/tellapart-add-progressive-letters-to-mob-names/  

Names are changed in a way that they are identical across different clients, even if those clients run on different computers. In other words, everybody will see the same Mandragora B in any given zone, regardless of when you zone in, where, how, etc.  

Couple known quirks:  
- if there's only one mob with that name in the zone, it will not be renamed. A known offender is that one lone Locus Lugcrawler in Crawler's Next [S]. There's only one in the entire zone, so no letter for him. There might be more somewhere else.  
- some NMs have multiple copies of themselves that are spawnable - Unity NMs, Geas Fete, but also Abyssea etc. This is normal and there's no way to know that they are NMs instead of regular mobs, so enjoy your Ayapec A-B-C-D  
- there's a global 23 characters limit to mob names. So, mobs whose names is longer than 20 characters get their name truncated to make space for the letters. I don't see this causing issues in general, but if it does do let me know.  
- it's inactive inside of those areas that do not have killable mobs (mostly cities).
- due to the way renaming works, it's doing some work per every frame. If you run at 30fps on a regular pc it should not matter, but if you are playing on a potato or have 8 instances loaded all running at 120fps and have been roaming a lot in any given zone, you might see your fps drop or your instance stutter. Lower your fps a bit to prevent that, or don't run it on *all* of your boxes.  
- this is written for retail. Private servers are unsupported, tho it should work on them with no issues. Names can be inconsistent on private server if two people use different versions of the client, which it can sometimes happen and it's never an issue on retail which doesn't let you connect with an outdated client.  

Lastly, one last buywer's beware: this breaks bots. Do not come asking me support for bots. Write a better one that is compatible with this instead. What do you mean you can't write a bot!?  

Apart from the above, it should work anywhere, even instanced zones. It's pretty sturdy.  

Load it and it's on, unload it and it's off.  
One command available:
_//ta mask_: removes the appended letters from the current target's name when using the <t> pronoun in chat. Enabled by default.
