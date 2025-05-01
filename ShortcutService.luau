local uis = game:GetService("UserInputService")

-- Create a type 'Shortcut'
export type Shortcut = {
	Name  : string,
	Keys  : {Enum.KeyCode},
	State : Enum.UserInputState,
	Handler : (Name:string,InputObject:InputObject,GameProcessed:boolean)->nil,
}

-- Define a table to list all Shortcuts
local allShortcuts = {}

-- Define a table to list all currently bound Shortcuts
local activeShortcuts = {}

-- Create the table to return
local ShortcutService = {}

-- Creates a <code>Shortcut</code> and overwrites any existing <code>Shortcut</code>s of the same name
function ShortcutService:CreateShortcut(Name:string,...:Enum.KeyCode):Shortcut
	-- Create the <code>Shortcut</code>
	local shortcut:Shortcut = {
		Name  = Name,
		Keys  = table.pack(...),
		State = Enum.UserInputState.Cancel,
	}
	
	-- Search through allShortcuts, replacing any matches
	allShortcuts[Name] = shortcut
	
	-- Return the Shortcut for optional further use
	return shortcut
end

-- Binds a handler function to a <code>Shortcut</code>, but doesn't activate the <code>Shortcut</code>
function ShortcutService:BindShortcutHandler(Name:string,Handler:(Name:string,InputObject:InputObject,GameProcessed:boolean)->nil):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end

	-- Bind the function
	allShortcuts[Name].Handler = Handler
end


-- Binds a given <code>Shortcut</code> to a <code>Handler function</code>
function ShortcutService:BindShortcut(Name:string,Handler:(Name:string,InputObject:InputObject,GameProcessed:boolean)->nil):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end
	
	-- Bind the function
	allShortcuts[Name].Handler = Handler
	
	-- Move the Shortcut into activeShortcuts
	activeShortcuts[Name] = allShortcuts[Name]
end

-- Compound of <code>ShortcutService:CreateShortcut()</code> and <code>ShortcutService:BindShortcut()</code>
-- Creates a <code>Shortcut</code>, binds a <code>Handler function</code> to it, and allows it to be activated
function ShortcutService:Bind(Name:string,Handler:(Name:string,InputObject:InputObject,GameProcessed:boolean)->nil,...:Enum.KeyCode):nil
	self:CreateShortcut(Name,...)
	self:BindShortcut(Name,Handler)
end

-- Allows a given <code>Shortcut</code> to be activated
function ShortcutService:ActivateShortcut(Name:string):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end
	
	-- Check for Handler's existance
	if not allShortcuts[Name].Handler then error("No Handler for shortcut With Name '"..Name.."' Found!") return end
	
	-- Move the shortcut into activeShortcuts
	activeShortcuts[Name] = allShortcuts[Name]
end

-- Unbinds a given <code>Shortcut</code>, just removing its <code>Handler function</code>
function ShortcutService:UnbindShortcutHandler(Name:string):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end

	-- Unbind the function
	allShortcuts[Name].Handler = nil
end

-- Unbinds a given <code>Shortcut</code>, removing its <code>Handler function</code> and disallowing it from being activated
function ShortcutService:UnbindShortcut(Name:string):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end
	
	-- Unbind the function
	allShortcuts[Name].Handler = nil
	
	-- Remove the shortcut from activeShortcuts
	activeShortcuts[Name] = nil
end

-- Unbinds a given <code>Shortcut</code>, disallowing it from being activated, but doesn't remove its <code>Handler function</code>
-- Does the same thing as <code>ShortcutService:DeactivateShortcut()</code>
function ShortcutService:Unbind(Name:string):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end
	
	-- Remove the shortcut from activeShortcuts
	activeShortcuts[Name] = nil
end

-- Unbinds a given <code>Shortcut</code>, but doesn't remove its <code>Handler function</code>
function ShortcutService:DeactivateShortcut(Name:string):nil
	-- Check for Shortcut's existance
	if not allShortcuts[Name] then error("No Shortcut With Name '"..Name.."' Found!") return end

	-- Remove the shortcut from activeShortcuts
	activeShortcuts[Name] = nil
end

-- Unbinds all Shortcuts, disallowing them from being activated, and removing their <code>Handler functions</code>
function ShortcutService:UnbindAllShortcuts():nil
	for name, shortcut in pairs(allShortcuts) do
		self:UnbindShortcut(name)
	end
end

-- Unbinds all <code>Shortcut</code>s, disallowing them from being activated, but doesn't remove their <code>Handler function</code>s
-- Does the same thing as <code>ShortcutService:DeactivateAllShortcuts()</code>
function ShortcutService:UnbindAll():nil
	activeShortcuts = {}
end

-- Deactivates all active Shortcuts
function ShortcutService:DeactivateAllShortcuts():nil
	activeShortcuts = {}
end

-- Local function for the handling of an input
local function onInput(i:InputObject,p:boolean)
	-- Loop through all the active shortcuts
	for name, shortcut in pairs(activeShortcuts) do
		local allPressedKeys = uis:GetKeysPressed()
		
		-- Loop through all pressed keys, testing if the current shortcut uses all of them
		local onlyRelevantKeysPressed = false
		for n, key in ipairs(allPressedKeys) do
			if not table.find(shortcut.Keys,key.KeyCode) then break end
			-- If it makes it to the end, we know that only keys in the shortcut are pressed
			onlyRelevantKeysPressed = n == #allPressedKeys
		end
		
		-- Loop through all keys required in the shortcut, testing if all of them are pressed
		local allRelevantKeysPressed = false
		for n, key in ipairs(shortcut.Keys) do
			if not uis:IsKeyDown(key) then break end
			-- Same as above, if it makes it to the end, we know that all the relevant keys are pressed
			allRelevantKeysPressed = n == #shortcut.Keys
		end
		
		if onlyRelevantKeysPressed and allRelevantKeysPressed then
			-- Call the handler function for the shortcut, passing the name, input object, and if the game processed the event
			shortcut.Handler(name,i,p)
		end
	end
end

-- Allows for the module to get User Inputs and perform <code>Shortcut</code> handling
function ShortcutService:Activate():RBXScriptConnection
	ShortcutService.UserInputConnection = uis.InputBegan:Connect(onInput)
	
	return ShortcutService.UserInputConnection
end

-- Disallows for the module to get User Inputs and perform <code>Shortcut</code> handling
function ShortcutService:Deactivate():nil
	ShortcutService.UserInputConnection:Disconnect()
end

return ShortcutService
