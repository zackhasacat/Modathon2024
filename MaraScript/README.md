# Marascript Mod Summary

**Marascript**  will be a set of scripts mean to allow other scripts to run in both MWSE and OpenMW lua
## Goals
The initial goal is not to achieve full compatibility. UI elements, for instance, will not be recreated at this stage.

### Features to Implement
- Package built-in scripts.
- Implement a coin flip functionality.

## Structure

### Markup Files
- **YAML**: Defines the required version of Marascript and the necessary `.esp` file.

### Marascript Lua Files
- These Lua files are crafted by modders and are the only files that actively execute operations within Marascript.

### Require Lua Files
- These are essential Lua files "required" by Marascript scripts. They contain documentation and operate on a more foundational level, handling interactions and data storage through backend collaboration.

### Backend Lua Files
- Located in `scripts/omw/`, these files are incorporated by `marascript.omwscripts`. This includes `main.lua` for MWSE and other Lua files in the directory.

Design:
Objects will be recreated to reflect the new system. getObjectById(id) would return a reference, but not with the fields of an OpenMW reference, or MWSE. It will be recreated entirely.

Dependancy:
Mods that use this will need users to have marascript installed. This could be a barrier to entry. Marascript could be packaged with other mods, but it has the possibility of making their marascript downgraded, if they had their packaged marascript in dedicated directories, this may work. Interfaces and events would all have to be custom as well on the omw side.
