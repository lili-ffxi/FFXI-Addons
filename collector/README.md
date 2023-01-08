# Collector

Finds owned and missing items from a collection of items.  
`//collector` or `//col` for a list of available collections.  
E.G: `//col reive capes` to find what reive capes you possess and where they are.  

I initially wrote this addon to find reive capes and empyrean feet more easily, for the purpose of the 3:1 exchange.
It then occurred to me that there are *many* sets of items that are useful to look for, including for example dynamis currency.

Last update to the database: 06/01/2023

### TO-DO:
- make it search key items (mementos, atmas...)
- make it check long name

## Create custom sets
You can add your custom sets to the addon. Just create a file called `custom.lua` inside the addon directory, and fill it like this, in standard lua format:
```
return T{
  ['never without'} = { "Echo drops", "Silent Oil", "Prism Powder", },
}
```

<sub>Can you find the easter egg? Can you tell me where is it from?</sub>
