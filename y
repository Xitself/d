
if not game:IsLoaded() then 
    game.Loaded:Wait()
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetPlayerDataRemote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)


local Murderer, Sheriff = nil, nil
local infJumpConnection, Device = false, nil
local highlights = {}

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
	Device = "MOBILE"
end

local function FindMap()
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("CoinContainer") then
            return v.CoinContainer
        end
    end
    return nil
end

local function findGunDrop()
    if FindMap() then 
        return FindMap().Parent:FindFirstChild("GunDrop") or false
    end
end

local function IsAlive(Player, roles)
    local role = roles and roles[Player.Name]
    return role and not role.Killed and not role.Dead
end

local function updatePlayerData()
    if GetPlayerDataRemote then
        return GetPlayerDataRemote:InvokeServer()
    end
end

local function CreateHighlight()
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LocalPlayer then 
            pcall(function()
                if v.Character and not v.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", v.Character)  
                end
            end)
        end
    end
end

local function UpdateHighlights()
    for _, v in pairs(Players:GetChildren()) do
        pcall(function()
            local highlight = v.Character and v.Character:FindFirstChild("Highlight")
            if highlight then
                if IsAlive(v, roles) then
                    local role = roles[v.Name]
                    if role then
                        if role.Role == "Murderer" then
                            highlight.FillColor = Color3.fromRGB(225, 0, 0)
                        elseif role.Role == 'Sheriff' then
                            highlight.FillColor = Color3.fromRGB(0, 0, 225)
                        elseif role.Role == 'Hero' then
                            highlight.FillColor = Color3.fromRGB(0, 0, 225)
                        else
                            highlight.FillColor = Color3.fromRGB(76, 215, 134)
                        end 
                    else 
                        highlight.FillColor = Color3.fromRGB(76, 215, 134)
                    end
                else
                    highlight.FillColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
    end
end

local function DestroyHighlight()
    for _, player in next, Players:GetPlayers()  do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local highlight = character:FindFirstChild("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function InGame()
    local Cannon = workspace:FindFirstChild("ConfettiCannon")
    if Cannon then 
        LocalPlayer.PlayerGui.MainGUI.Game.EarnedXP.Visible = false 
        LocalPlayer.PlayerGui.MainGUI.Game.Timer.Visible = false
    elseif Murderer == nil or not Murderer or not Murderer and not Sheriff then 
        return false 
    elseif LocalPlayer.PlayerGui.MainGUI.Game.EarnedXP.XPText.Text == "900" and LocalPlayer.PlayerGui.MainGUI.Game.Timer.Visible == false and Murderer ~= LocalPlayer.Name then 
        return false 
    elseif LocalPlayer.PlayerGui.MainGUI.Game.EarnedXP.Visible == true or LocalPlayer.PlayerGui.MainGUI.Game.Timer.Visible == true then 
        return true
    else
        return false
    end
end

local function GetMurderer()
    for _, player in ipairs(game.Players:GetPlayers()) do 
        if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
            return player.Name
        end
    end   
    return nil 
end

local function GetSheriff()
    for _, player in ipairs(game.Players:GetPlayers()) do 
        if player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
            return player.Name
        end
    end   
    return nil 
end
 
local function tween_teleport(TargetFrame)
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
    if humanoidRootPart and IsAlive(LocalPlayer, roles) then
        local distance = (humanoidRootPart.Position - TargetFrame.p).Magnitude
        local tweenInfo = TweenInfo.new(distance / 70, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
             
        local move = Services.TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = TargetFrame})
        move:Play()
        move.Completed:Wait()

    end
end

local function playerHasItem(itemName)
    repeat task.wait() 
         MainGUI = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
    until MainGUI

    for _, child in pairs(MainGUI.Game.Inventory.Main.Perks.Items.Container.Current.Container:GetChildren()) do
        if child:IsA("Frame") and child.ItemName.Label.Text == itemName then
            return true
        end
    end

    return false
end


local nexus = loadstring(game:HttpGet("https://github.com/raditself/d/releases/download/x/xPip.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/BetterSaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/raditself/d/main/BetterInterfaceManager1"))()

local Options = nexus.Options
SaveManager:SetLibrary(nexus)

local Window = nexus:CreateWindow({
    Title = "skid", "",
    TabWidth = 150,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10734884548"
    }),
    Sheriff = Window:AddTab({
        Title = "Sheriff",
        Icon = "rbxassetid://10747372702"
    }),
    Murderer = Window:AddTab({
        Title = "Murderer",
        Icon = "rbxassetid://10747372992"
    }),
    Server = Window:AddTab({
        Title = "Server",
        Icon = "rbxassetid://10734949856"
    }),
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "settings"
    }),
}

local function isValidPart(part, checkMaterial)
    if IsAlive(LocalPlayer, roles) then
        return part and part:IsA("BasePart") and part.Parent and part.Parent.Name == "Coin_Server" and part.Parent:FindFirstChild("TouchInterest") and (not checkMaterial or part.Material == Enum.Material.Glass)
    end
    return false
end


local Toggle = Tabs.Main:AddToggle("CoinChams", {
    Title = "Coin Chams",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()
                if FindMap() then
                    for _, v in pairs(FindMap():GetChildren()) do
                        if v.Name == 'Coin_Server' and not highlights[v] then
                            local esp = Instance.new("Highlight")
                            esp.Name = "CoinESP"
                            esp.FillTransparency = 0.5
                            esp.FillColor = Color3.new(94/255, 1, 255/255)
                            esp.OutlineColor = Color3.new(94/255, 1, 255/255)
                            esp.OutlineTransparency = 0
                            esp.Parent = v.Parent
                            highlights[v] = esp  
                        end
                    end
                end 
            until not Options.CoinChams.Value
            for _, highlight in pairs(highlights) do
                highlight:Destroy()
            end         
        end
    end
})

local Toggle = Tabs.Main:AddToggle("PlayerESP", {
    Title = "Player Chams",
    Default = false,
    Callback = function(value)
        if value then 
        repeat task.wait()
            CreateHighlight() 
            UpdateHighlights()
        until not Options.PlayerESP.Value
        DestroyHighlight()
        end 
    end
})  

local ToggleGunCham = Tabs.Main:AddToggle("GunCham", {
    Title = "Gun Dropped ESP",
    Default = false,
    Callback = function(value)
        if value then
            local success, result = pcall(function()
                repeat
                    task.wait()

                    if findGunDrop() then
                        local esp = findGunDrop():FindFirstChild("GunESP")

                        if not esp then
                            esp = Instance.new("Highlight")
                            esp.Name = "GunESP"
                            esp.FillTransparency = 0.5
                            esp.FillColor = Color3.new(94, 1, 255)
                            esp.OutlineColor = Color3.new(94, 1, 255)
                            esp.OutlineTransparency = 0
                            esp.Parent = findGunDrop()
                        end
                    end
                until not Options.GunCham.Value

                if findGunDrop() then
                    local esp = findGunDrop():FindFirstChild("GunESP")
                    if esp then
                        esp:Destroy()
                    end
                end
            end)

            if not success then
                warn("Error in ToggleGunCham callback:", result)
            end
        end
    end
})

local Toggle = Tabs.Murderer:AddToggle("KillAura", {
    Title = "Kill Aura",
    Default = false,
    Callback = function(value)
        if value then 
            repeat
                task.wait()
                local success, result = pcall(function() 
                    local Knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    
                    for i, v in ipairs(game.Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and Knife and IsAlive(v, roles) then
                            local EnemyRoot = v.Character:FindFirstChild("HumanoidRootPart")
                            if EnemyRoot then

                                local EnemyPosition = EnemyRoot.Position
                                local EnemyDistance = (EnemyPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                
                                if EnemyDistance <= tonumber(Options.Distance.Value) and Knife and Murderer == LocalPlayer.Name then
                                    humanoid:EquipTool(Knife) 
                                    wait(0.1)
                                    local teleportPosition = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 3 
                                    EnemyRoot.CFrame = CFrame.new(teleportPosition)
                                    
                                    if Device ~= "MOBILE" then 
                                        LocalPlayer.Character.Knife.Stab:FireServer('Down') 
                                        firetouchinterest(EnemyRoot, myKnife.Handle, 1)
                                        wait(0.1)
                                        firetouchinterest(EnemyRoot, myKnife.Handle, 0)
                                    end 
                                end
                            end
                        end  
                    end
                end)
            until not Options.KillAura.Value 
        end
    end
})

local Slider = Tabs.Murderer:AddSlider("Distance", {
	Title = "Aura Distance",
	Default = 5,
	Min = 5,
	Max = 50,
	Rounding = 0,
	Callback = function(Value)
	end
})

local Toggle = Tabs.Sheriff:AddToggle("SilentAim", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(value)
    end
})

local Slider = Tabs.Sheriff:AddSlider("Slider", {
    Title = "Accuracy",
    Default = 50,
    Min = 25,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
    end
})  

Tabs.Murderer:AddButton({
    Title = "Kill All",
    Callback = function()
        local Knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
        if Knife and Knife:IsA("Tool") then 

            local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
            humanoid:EquipTool(Knife)
            
            for i = 1, 3 do
                local success, result = pcall(function() 
                    for i, v in ipairs(Players:GetPlayers()) do task.wait()
                        if v ~= LocalPlayer and v.Character and IsAlive(v, roles) then
                            local enemyRoot = v.Character:WaitForChild("HumanoidRootPart")

                            if Device == "MOBILE" then 
                                v.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                            else
                                LocalPlayer.Character.Knife.Stab:FireServer('Down') 
                                firetouchinterest(enemyRoot, Knife.Handle, 1)
                                wait(0.1)
                                firetouchinterest(enemyRoot, Knife.Handle, 0)
                            end 
                        end         
                    end
                end)  
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = initialPosition
        end
    end
})


local Toggle = Tabs.Settings:AddToggle("Settings", {
    Title = "Save Settings",
	Default = false,
    Callback = function(value)
		if value then 
            repeat task.wait(.1) 
                if _G.FB35D == true then print("return") return end SaveManager:Save(game.PlaceId) 
            until not Options.Settings.Value
		end
	end
})

Tabs.Settings:AddButton({
	Title = "Delete Setting Config",
	Callback = function()
		delfile("x/settings/".. game.PlaceId ..".json")
	end  
})  

nexus:Notify({Title = 'Notification', Content = 'This script is currently in development and is currently in its beta phase.', Duration = 1})

coroutine.wrap(function()
    while true do
        task.wait(.1)
        if _G.FB35D == true then 
            return 
        end
        local success, err = pcall(function()
            Murderer = GetMurderer()
            Sheriff = GetSheriff()
            roles = updatePlayerData()
        end)
    end
end)()

local GunHook
GunHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }
    if not checkcaller() then
        if typeof(self) == "Instance" then
            if self.Name == "RemoteFunction" and method == "InvokeServer" then
                if Options.SilentAim.Value then 
                    if Murderer and Sheriff == LocalPlayer.Name then
                        local Root = workspace[tostring(Murderer)].HumanoidRootPart;
                        local Veloc = Root.AssemblyLinearVelocity;
                        local Pos = Root.Position 
                        local Accuracy = Options.Slider.Value / 100
                        if Veloc.Magnitude == 0 then
                            args[2] = Pos;
                        else
                            local Y = (Veloc.Unit * Root.Velocity.Magnitude) / 17 + Root.MoveDirection
                            local VirtualInputManager = Y.Y
                            if VirtualInputManager > 2.5 then
                                VirtualInputManager = 2.5
                            elseif VirtualInputManager < -2 then
                                VirtualInputManager = -2
                            end
                            args[2] = Pos + Vector3.new(Y.X, VirtualInputManager, Y.Z)
                        end
                    end;
                else
                    return GunHook(self, unpack(args));
                end;
            end;
        end;
    end;
    return GunHook(self, unpack(args));
end);

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }
    if not checkcaller() then
        if tostring(method) == "InvokeServer" and tostring(self) == "GetChance" then
            wait(0.1)
        end
    end
    return __namecall(self, unpack(args))
end)

-- Set libraries and folders
SaveManager:SetLibrary(nexus)
InterfaceManager:SetLibrary(nexus)
SaveManager:SetIgnoreIndexes({})
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("x")
SaveManager:SetFolder("x")

-- Build interface section and load the game
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:Load(game.PlaceId)

-- Select the first tab in the window
Window:SelectTab(1)


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
local TeleportingToMurderer, GettingGun = false, false
local Murderer, Sheriff = nil, nil
local infJumpConnection, Device = false, nil
local highlights = {}

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
	Device = "MOBILE"
end

-- Create a function to check if a player is alive
local function IsAlive(player, playerData)
    local role = playerData[player.Name]
    return role and not role.Killed and not role.Dead
end

-- Create a function to update player data
local function updatePlayerData()
    if GetPlayerDataRemote then
        local roles = GetPlayerDataRemote:InvokeServer()
        local playerData = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if not playerData[player.Name] then
                playerData[player.Name] = { Role = "" }
            end
            if roles[player.Name] then
                playerData[player.Name].Role = roles[player.Name].Role
                playerData[player.Name].Killed = roles[player.Name].Killed
                playerData[player.Name].Dead = roles[player.Name].Dead
            end
        end
        return playerData
    end
end

-- Create a function to get the role of a player
local function GetPlayerRole(player)
    local playerData = updatePlayerData()
    local role = playerData[player.Name] and playerData[player.Name].Role
    return role
end

-- Create a function to highlight a player
local function HighlightPlayer(player, color)
    local character = player.Character
    if character then
        local highlight = character:FindFirstChild("Highlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = character
        end
        highlight.FillColor = color
        highlight.OutlineColor = color
    end
end

-- Create a function to highlight players with specific roles
local function HighlightRoles()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = GetPlayerRole(player)
            local playerData = updatePlayerData()
            if role == "Murderer" then
                if IsAlive(player, playerData) then
                    HighlightPlayer(player, Color3.new(225, 0, 0)) -- red color for alive Murderer
                else
                    HighlightPlayer(player, Color3.new(128, 0, 0)) -- darker red color for dead Murderer
                end
            elseif role == "Sheriff" then
                if IsAlive(player, playerData) then
                    HighlightPlayer(player, Color3.new(0, 0, 225)) -- blue color for alive Sheriff
                else
                    HighlightPlayer(player, Color3.new(0, 0, 128)) -- darker blue color for dead Sheriff
                end
            elseif role == "Hero" then
                if IsAlive(player, playerData) then
                    HighlightPlayer(player, Color3.new(255, 215, 0)) -- yellow color for alive Hero
                else
                    HighlightPlayer(player, Color3.new(255, 255, 255)) -- white color for dead Hero
                end
            end
        end
    end
end

-- Create a function to update highlights
local function UpdateHighlights()
    for _, v in pairs(Players:GetChildren()) do
        pcall(function()
            local highlight = v.Character and v.Character:FindFirstChild("Highlight")
            if highlight then
                if IsAlive(v, updatePlayerData()) then
                    local role = updatePlayerData()[v.Name]
                    if role then
                        if role.Role == "Murderer" then
                            highlight.FillColor = Color3.fromRGB(225, 0, 0)
                        elseif role.Role == 'Sheriff' then
                            highlight.FillColor = Color3.fromRGB(0, 0, 225)
                        elseif role.Role == 'Hero' then
                            highlight.FillColor = Color3.fromRGB(255, 215, 0) -- yellow color for Hero
                        else
                            highlight.FillColor = Color3.fromRGB(76, 215, 134)
                        end 
                    else
                    highlight.FillColor = Color3.fromRGB(76, 215, 134)
                        end 
                    else
                    highlight.FillColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
    end
end

-- Run the highlight function every second
while true do
    HighlightRoles()
    wait(1)
end