
# superPush
Hi, this is my game. Not sure if it will be finished


![menu](https://github.com/pakeke-constructor/PUSH_GAME/blob/master/txt_and_images/screenshots/menu.jpg?raw=true)

![in game](https://github.com/pakeke-constructor/PUSH_GAME/blob/master/txt_and_images/screenshots/ingame.jpg?raw=true)


# Controls:

`WASD` to move.

`K`  to push

`L` to pull

`I` and `O` to zoom in and out, but this is just temporary for debug probs

# Some things to know:

Clojure is not actually used here! The language used is Fennel, a lisp dialect that transpiles to lua

Files starting with `NM` are not my own. (i.e. other people's code.)



An example of a generated Map:
(See src/systems/StaticSystems/generationSys.lua for what the chars mean)
```
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# . # # # % % % % % % % # . . . . . . # # . . . . . . . . . # # % #
# p . . # # # # # % % # # . . . . . . # # # . . . . . . . . . # % #
# ^ . . . ^ p ^ # % # # . . . . . . # # % # # # # . . . . . . # % #
# ^ . @ e p l p # # # . . . . . . # # % # # # . . . . ^ . l . # # #
# . . . . ^ p ^ . . . ^ p . . . # # % % # . . . # # # ^ l l . . . #
# r p . . . . # # # . r . U ^ . # % % % # . . . e c # ^ l . l . p #
# . ^ e . . . e c # . ^ ^ ^ l . # % % % # . . p # # # . . l ^ R ^ #
# p e . . . . # # # ^ . ^ p . # # % # # # . . . e ^ p e . ^ ^ ^ . #
# . ^ p . . . . . . . . . ^ p ^ # % # . . . e . # # # . # # # ^ ^ #
# e e ^ . # # . . # . . . p l p # # # . . . ^ ^ e c # ^ e c # . . #
# ^ p ^ . # # # # # # # . ^ p ^ # . . . ^ ^ p ^ # # # ^ # # # p . #
# e ^ . . . # % % % % # . . . . . . . . ^ p l p ^ e ^ . . ^ e . . #
# . . ^ . . # # # % % # # . . . ^ . . . . ^ p ^ . . ^ ^ ^ p ^ ^ . #
# ^ ^ . p . . . # # % % # # . # # # . . . # # . . . . . e u ^ . . #
# . . . . . l . . # # # # . ^ e c # . . . . . ^ p ^ . . . . . # # #
# . . . . l ^ p ^ # . . . . . # # # . . . . . p l p . . # # # # % #
# . . . . ^ p ^ p . . . . . ^ . e . . # # . . ^ p ^ . . # % % % % #
# . . . ^ p l p ^ . . . . ^ p ^ p . # # # # . # . . . . # % % % % #
# . . e . ^ p ^ # . . # # p l p . . # # . # # # # . # . # % % % % #
# . . p l ^ . . # # # # # ^ p ^ . . . # # # # # ^ p ^ . # # # % % #
# # . ^ R . . . # % % % # . ^ . . # # # % % # . p l p . . . # # % #
# # # . . . . # # % % # # . . . # # % % % % # . ^ p ^ ^ . . . # # #
# # # . . . . # % # # # . . . # # % % % % % # # . . ^ ^ ^ ^ . . # #
# # . . . . # # % # . . . . # # % % % % % % # . . p ^ . ^ ^ p . # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
```