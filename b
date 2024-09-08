if not game:IsLoaded() then 
    game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetPlayerDataRemote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)

-- Import necessary libraries
local nexus = loadstring(game:HttpGet("https://github.com/raditself/d/releases/download/x/xPip.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/BetterSaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/BetterInterfaceManager1"))()

-- Set up the library
local Library = nexus
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

-- Define constants and variables
local keys = {
    ["A"] = 0x41,
    ["B"] = 0x42,
    ["C"] = 0x43,
    ["D"] = 0x44,
    ["E"] = 0x45,
    ["F"] = 0x46,
    ["G"] = 0x47,
    ["H"] = 0x48,
    ["I"] = 0x49,
    ["J"] = 0x4A,
    ["K"] = 0x4B,
    ["L"] = 0x4C,
    ["M"] = 0x4D,
    ["N"] = 0x4E,
    ["O"] = 0x4F,
    ["P"] = 0x50,
    ["Q"] = 0x51,
    ["R"] = 0x52,
    ["S"] = 0x53,
    ["T"] = 0x54,
    ["U"] = 0x55,
    ["V"] = 0x56,
    ["W"] = 0x57,
    ["X"] = 0x58,
    ["Y"] = 0x59,
    ["Z"] = 0x5A,
    ["-"] = 0xBD,
    ["'"] = 0xDE
}

local usedWords = {}
local wordLists = {
    Normal = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/normal.txt", true))(),
    LongWords = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/longwords.txt", true))()
}

-- Define functions
local function findLetters()
    -- implement your logic to find letters here
    for _, v in pairs(getgc()) do
        if type(v) == "function" and not is_synapse_function(v) and islclosure(v) and debug.getinfo(v).name == "updateInfoFrame" then
            for __, vv in pairs(debug.getupvalues(v)) do
                if type(vv) == "table" and vv.Prompt ~= nil then
                    return vv.Prompt
                end
            end
        end
    end
end

local function myTurn()
    -- implement your logic to check if it's your turn here
    for _, v in pairs(getgc()) do
        if type(v) == "function" and not is_synapse_function(v) and islclosure(v) and debug.getinfo(v).name == "updateInfoFrame" then
            for __, vv in pairs(debug.getupvalues(v)) do
                if type(vv) == "table" and vv.PlayerID ~= nil then
                    return vv.PlayerID
                end
            end
        end
    end
    return game:GetService("Players").LocalPlayer.UserId
end

local function findWord(letters)
    -- implement your logic to find a word from the letters here
    for i, v in pairs(wordLists[Library.pointers.WordListPointer.current]) do
        if string.find(v, string.lower(letters)) and not used(v) and v ~= nil then
            return string.upper(v)
        end
    end
end

local function used(word)
    for i, v in pairs(usedWords) do
        if v == word then return true end
    end
    return false
end

local function typeAnswer()
    local word = findWord(findLetters())
    if word and word ~= "nil" then
        for v in string.gmatch(word, ".") do
            keypress(keys[v])
            wait(Library.pointers.TypeDelayPointer.current)
        end
        table.insert(usedWords, word)
        wait(Library.pointers.TypeDelayPointer.current)
        keypress(0x0D)
    end
end

local function tableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

-- Create the window
local window = Library:CreateWindow({
    Title = "WordBomb Helper",
    TabWidth = 150,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = true,
    Theme = "Dark",
})

-- Create tabs
local mainTab = window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://10734884548"
})

local settingsTab = window:AddTab({
    Title = "Settings",
    Icon = "settings"
})

-- Create sections
local mainSection = mainTab:AddSection({
    Title = "WordBomb",
    Side = "left"
})

local settingsSection = settingsTab:AddSection({
    Title = "Settings",
    Side = "left"
})

-- Add buttons and toggles
mainSection:AddButton({
    Title = "Type Answer",
    Callback = function()
        if myTurn() == game:GetService("Players").LocalPlayer.UserId then
            typeAnswer()
        end
        for _, v in pairs(mainSection.visibleContent) do
            if v:IsA("TextLabel") and string.find(v.Text, "Used Words:") then
                v.Text = "Used Words: " .. tostring(tableLength(usedWords))
            end
        end
    end
})

mainSection:AddToggle({
    Title = "Auto Type",
    Default = false,
    Pointer = "AutoTypePointer",
    Callback = function(value)
        if value then
            while value do
                wait(Library.pointers.AutoTypeDelayPointer.current)
                if myTurn() == game:GetService("Players").LocalPlayer.UserId then
                    typeAnswer()
                end
            end
        end
    end
})

mainSection:AddDropdown({
    Title = "Word List",
    Options = {"Normal", "LongWords"},
    Default = "Normal",
    Pointer = "WordListPointer"
})

mainSection:AddSlider({
    Title = "Type Delay",
    Min = 0,
    Max = 1,
    Def = 0,
    Decimals = 0.01,
    Pointer = "TypeDelayPointer"
})

mainSection:AddSlider({
    Title = "Auto Type Delay",
    Min = 0,
    Max = 8,
    Def = 0,
    Decimals = 0.01,
    Pointer = "AutoTypeDelayPointer",
    Callback = function(value)
        Library.pointers.AutoTypeDelayPointer.current = value
    end
})

mainSection:AddButton({
    Title = "Clear Used Words",
    Callback = function()
        for _, v in pairs(mainSection.visibleContent) do
            if v:IsA("TextLabel") and string.find(v.Text, "Used Words:") then
                v.Text = "Used Words: 0"
            end
        end
        usedWords = {}
    end
})

mainSection:AddLabel({
    Text = "Used Words: 0"
})

-- Add settings
settingsSection:AddToggle({
    Title = "Save Settings",
    Default = false,
    Callback = function(value)
        if value then
            repeat task.wait(0.1) 
                if _G.FB35D == true then print("return") return end SaveManager:Save(game.PlaceId) 
            until not Options.Settings.Value
        end
    end
})

settingsSection:AddButton({
    Title = "Delete Setting Config",
    Callback = function()
        delfile("x/settings/".. game.PlaceId ..".json")
    end  
})

-- Set libraries and folders
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({})
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("x")
SaveManager:SetFolder("x")

-- Build interface section and load the game
InterfaceManager:BuildInterfaceSection(settingsSection)
SaveManager:Load(game.PlaceId)

-- Select the first tab in the window
window:SelectTab(1)
