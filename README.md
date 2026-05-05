# Riichi Mahjong Scoring Tool

In January 2025 I was working in the Godot Game engine, and I decided that I wanted to learn how it's UI features worked. Alongside this, I had been learning to play Riichi Mahjong for roughly 18 months. This is a game with notoriously complex rules, and a very long list of scoring hands known as "Yaku" that reward you with points upon their formation. These Yaku can be combined with one another, and contribute different amounts of score. Because of this, I figured that making a scoring calculator would be a great test of learning Godot's UI features, as well as learning the rules and scoring for Riichi Mahjong more thoroughly.

This calculator handles all of the most common Yaku, uses an algorithm I created to detect them accurately from a selected hand of 14 tiles, and can output roughly what the final score of the hand will be. All of the standard Yaku that dont rely on "Waits" are implemented properly, and can be combined with others. The two standard Yaku that isn't currently implemented as a result is "Pinfu", as it requires a Ryanmen wait. Aside from this, there is one other standard yaku and one high scoring "Yakuman" that arent handled correctly either, since the algorithm doesnt currently support more than 14 tiles, causing it to not be compatible with detecting "kan" (quad) calls. As a result, it can't detect Sankantsu (three quads) and Suukantsu (four quads).

Aside from these stipulations, the calculator handles everything else procedurally and outputs an itemized list of the Yaku it detects, their "han" value, and the final calculated score that the hand is valued at. I'd like to return to this project at some point, and maybe remake it in Javascript instead so that it can be hosted here, and support the missing features, and fix any remaining inconsistencies with it's scoring, since it's still got some weird edge cases.

## Installation Instructions <br>

1. Find the v1.0 Release in "Releases" on the right hand side of the page.
2. Download either the Windows or Linux release.
3. Extract the files anywhere you'd like.
4. Run the .exe on Windows Devices, or the .x86_64 file on Linux devices.

### Controls:

> - Only utilizes mouse controls. 
> - Click the tiles to add them to the hand above the selection, click the tiles in the hand to remove them.
> - Settings on the left and top can be combined to satisfy different criteria that aren't directly related to the tiles in-hand, but are related to game circumstances. 
> - Click "Calculate" to calculate the score.
