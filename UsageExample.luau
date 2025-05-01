-- Get the actual service
local ShortcutService = require(PATH.TO.SHORTCUTSERVICE)

-- This is the shortest example, there are multiple ways to bind a shortcut
ShortcutService:Bind(
  "Print Hi", -- Name
  function() -- Handler function
    print("Hi!")
  end,
  Enum.KeyCode.LeftControl,Enum.KeyCode.P -- Keys in the shortcut
)

-- Allow the module to get inputs and perform shortcut checks
ShortcutService:Activate()
