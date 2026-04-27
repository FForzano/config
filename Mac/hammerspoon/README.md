
# Hammerspoon Modular Config

This Hammerspoon configuration is designed to be modular, scalable, and easily extensible. Each feature is organized in a separate Lua module, and keyboard shortcuts are configured via a JSON file.

## Directory Structure

```
.hammerspoon/
│
├── init.lua                # Entry point, imports modules and shortcuts
├── config/
│   └── hotkeys.json        # Shortcut configuration
├── modules/
│   ├── display_focus.lua   # Example functional module
│   └── ...                 # Other modules
└── utils/                  # (optional) Shared utilities
```

## How to Add a New Feature

1. **Create a new module**
   - Create a Lua file in `modules/`, e.g. `my_feature.lua`.
   - Export functions via a table, for example:
     ```lua
     local M = {}
     function M.doSomething()
         -- your code
     end
     return M
     ```

2. **Add the shortcut in `hotkeys.json`**
   - Open `config/hotkeys.json` and add a new entry:
     ```json
     {
       "myFeatureShortcut": {
         "module": "my_feature",
         "function": "doSomething",
         "modifiers": ["ctrl", "alt", "cmd"],
         "key": "M"
       }
     }
     ```
   - You can add multiple shortcuts, each with its own module and function.

3. **(Optional) Shared utilities**
   - If you have reusable functions, put them in `utils/` and import them in the modules that need them.

## How the Loading Works
- `init.lua` automatically loads all valid Lua modules in `modules/` (ignoring temporary or invalid files).
- For each shortcut defined in `hotkeys.json`, it looks up the corresponding function in the specified module and binds it.
- If a module or function is not found, an alert is shown but the rest of the configuration continues to work.

## Quick Example
1. Create `modules/hello.lua`:
   ```lua
   local M = {}
   function M.sayHello()
     hs.alert.show("Hello from my new module!")
   end
   return M
   ```
2. Add to `config/hotkeys.json`:
   ```json
   {
     "sayHello": {
       "module": "hello",
       "function": "sayHello",
       "modifiers": ["ctrl", "alt", "cmd"],
       "key": "H"
     }
   }
   ```
3. Reload Hammerspoon: now pressing `ctrl+alt+cmd+H` will show the alert!

---

**Tips:**
- Each module must return a table with exported functions (`return M`).
- Do not leave temporary or incomplete files in `modules/`.
- You can add, modify, or remove shortcuts just by editing `hotkeys.json`.

Happy hacking with Hammerspoon!
