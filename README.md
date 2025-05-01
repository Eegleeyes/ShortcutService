# ShortcutService
A ROBLOX module made to help create easy, contextual keyboard shortcuts

Get it here:

https://create.roblox.com/store/asset/79683943757034/ShortcutService?viewFromStudio=true&keyword=&searchId=e8c5bc6b-0f2c-4ec4-8945-13a129331b42


Usage Example:

```
local ShortcutService = require(PATH.TO.SHORTCUTSERVICE)

ShortcutService:Bind(
  "Print Hi",
  function()
    print("Hi!")
  end,
  Enum.KeyCode.LeftControl,Enum.KeyCode.M
)

ShortcutService:Activate()
```
