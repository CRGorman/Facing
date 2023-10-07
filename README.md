# Facing
An FFXI Windower Addon for determining what direction the player is facing in relation to their target.

## Features
* The direction you must turn to face your target.
* Commands to face a direction, your target, or away from your target
* How many degrees you must turn.
* If you have enough TP to use a weapon skill.
* Customizable settings for position, size and color.

## Commands

* USAGE: facing \[options\]
  
| Command | Description |
| --- | --- |
| target, ft, f, face | face target |
| away, a | face away from target |
| turn, t | turn about face |
| left | turn left |
| right | turn right |
| cardinals | face a cardinal direction, n, ne, e, se, s, sw, w, nw, or intercardinal directions |
| hide | hide the display |
| show | show the display |
| visible, v | toggle the display |
| save | save settings |
| help | display in game help |


## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon's settings file: **Windower4\addons\facing\data\settings.xml**
3. Save the file
4. Type ```//lua r facing``` in the chat box to reload the addon configuration

## Bugs
* Overuse may cause your character to desync from the camera. This can sometimes be fixed by zoning or logging out. Your character will still be able to act, but the camera will not move and your player will be invisible.

## Thanks
Built with help from Rubenator.
