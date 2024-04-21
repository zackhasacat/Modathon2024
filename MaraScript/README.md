# Marascript Mod Summary

**Marascript** will be a set of scripts written for MWSE, designed to parse OpenMW scripts to run in MWSE.

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
