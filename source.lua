local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local mouse = Players.LocalPlayer:GetMouse()
local workspace = game:GetService("Workspace")

-- GUI setup
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua"))()
local window = ui.new({text="Survival Goonessy :flushed:", size=Vector2.new(400, 300)})

-- Create tabs
local mainTab = window.new({text="main"})
local settingsTab = window.new({text="settings"})
local miscTab = window.new({text="misc"})

-- Main tab controls
local pickupToggle = mainTab.new("Switch", {text="Auto Pickup"})
local closestPlayerToggle = mainTab.new("Switch", {text="Kill Aura"})
local autoHealToggle = mainTab.new("Switch", {text="Auto Heal"})
local autoPlantToggle = mainTab.new("Switch", {text="Auto Plant Fruit"})
local bowAimbotToggle = mainTab.new("Switch", {text="Bow Aimbot"})
local plantButton = mainTab.new("Button", {text="Plant 5 Boxes"})

-- Settings tab controls
local healThresholdSlider = settingsTab.new("Slider", {text="Heal Threshold", min=1, max=100, value=50})
local autoPickupRangeSlider = settingsTab.new("Slider", {text="Pickup Range", min=10, max=100, value=30})

-- Misc tab controls
local fullBrightButton = miscTab.new("Button", {text="Full Bright"})
local infiniteYieldButton = miscTab.new("Button", {text="Infinite Yield"})
local void = miscTab.new("Button", {text="Tp Void"})
local rejoinButton = miscTab.new("Button", {text="Rejoin"})  -- New switch for Bow Aimbot

-- Adjust button positions with offsets
local buttonOffsetX = 10  -- X offset to move buttons to the right
local buttonOffsetY = 20  -- Y offset for vertical spacing between buttons

-- Set initial position for buttons
local startPosition = Vector2.new(10, 30)  -- Starting position for the first button

fullBrightButton.Position = startPosition + Vector2.new(buttonOffsetX, 0)
infiniteYieldButton.Position = startPosition + Vector2.new(buttonOffsetX, buttonOffsetY)
rejoinButton.Position = startPosition + Vector2.new(buttonOffsetX, buttonOffsetY * 2)
bowAimbotToggle.Position = startPosition + Vector2.new(buttonOffsetX, buttonOffsetY * 3)  -- Position for Bow Aimbot toggle

-- Full Bright function
local function setLighting()
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

fullBrightButton.event:Connect(function()
    setLighting()
end)

-- Infinite Yield function
infiniteYieldButton.event:Connect(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

void.event:Connect(function()
game:GetService('TeleportService'):Teleport(18629058177)
end)

-- Rejoin function
rejoinButton.event:Connect(function()
    local ts = game:GetService("TeleportService")
    local p = Players.LocalPlayer
    ts:Teleport(game.PlaceId, p)
end)

-- Function to get all pickups within a certain range
local function getClosestPickups(folder)
    local Character = Players.LocalPlayer.Character
    local pickups = {}
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        for _, item in pairs(folder:GetChildren()) do
            if item:FindFirstChild("Pickup") and item:IsA("BasePart") then
                local distance = (Character.HumanoidRootPart.Position - item.Position).Magnitude
                if distance <= autoPickupRangeSlider.value then
                    table.insert(pickups, item)
                end
            end
        end
    end
    return pickups
end

-- Auto pickup function
local function autoPickup()
    while true do
        if pickupToggle.on then
            local pickups = getClosestPickups(workspace.Important.Items)
            for _, pickup in pairs(pickups) do
                ReplicatedStorage.Events.Pickup:FireServer(pickup)
            end
        end
        wait(0.2)  -- Adjust the wait time as needed
    end
end

-- Function to find the closest player (for general use)
local function getClosestPlayer()
    local localPlayer = Players.LocalPlayer
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

-- Function to find the closest player specifically for Bow Aimbot
local function getClosestPlayerForBow()
    local localPlayer = Players.LocalPlayer
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.Head.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

-- Auto target closest player function
local function autoTargetClosestPlayer()
    while true do
        if closestPlayerToggle.on then
            local closestPlayer = getClosestPlayer()

            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local args = {
                    [1] = {
                        [1] = closestPlayer.Character,
                        [2] = closestPlayer.Character,
                        [3] = closestPlayer.Character,
                        [4] = closestPlayer.Character,
                        [5] = closestPlayer.Character,
                        [6] = closestPlayer.Character,
                        [7] = closestPlayer.Character
                    }
                }
                
                ReplicatedStorage:WaitForChild("Events"):WaitForChild("SwingTool"):FireServer(unpack(args))
            else
                warn("No closest player found.")
            end
        end
        wait(0.01)  -- Adjust the wait time as needed
    end
end

-- Auto heal function
local function autoHeal()
    while true do
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health < healThresholdSlider.value then
                for i = 1, 10 do
                    -- Note: The healFoodDropdown is removed; no healing item is selected now
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("UseBagItem"):FireServer()
                    wait(0.1)  -- Small delay between uses
                end
            end
        end
        wait(1)  -- Check health every 1 second
    end
end

-- Auto plant function
local function autoPlant()
    while true do
        if autoPlantToggle.on then
            local Character = Players.LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Character.HumanoidRootPart.Position
                for _, deployable in pairs(workspace:FindFirstChild("Important"):FindFirstChild("Deployables"):GetChildren()) do
                    if deployable.Name == "Plant Box" then
                        local part = deployable:FindFirstChildOfClass("Part")
                        if part and (hrp - part.Position).Magnitude <= 10 then
                            ReplicatedStorage.Events.InteractStructure:FireServer(deployable, "Bloodfruit")
                        end
                    end
                end
            end
        end
        wait(0.2)  -- Adjust the wait time as needed
    end
end

-- Event handler for plant button
plantButton.event:Connect(function()
    local Character = Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        for i = 1, 5 do
            local position = Character.HumanoidRootPart.Position + Vector3.new(0, 0, i)
            local cframe = CFrame.new(position)
            ReplicatedStorage.Events.PlaceStructure:FireServer("Plant Box", cframe, 0)
        end
    end
end)

-- Bow Aimbot function
local function BowAimbot()
    while true do
        if bowAimbotToggle.on then
            local closestPlayer = getClosestPlayerForBow()

            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
                local targetPosition = closestPlayer.Character.Head.Position

                local args = {
                    [1] = {
                        ["drawStrength"] = 100,
                        ["Position"] = targetPosition,
                        ["toolName"] = "Iron Bow",
                        ["mousePosition"] = targetPosition,
                        ["rootPartPosition"] = Players.LocalPlayer.Character.HumanoidRootPart.Position
                    }
                }
                
                ReplicatedStorage:WaitForChild("Events"):WaitForChild("CreateProjectile"):FireServer(unpack(args))
            else
                warn("No closest player found.")
            end
        end
        wait(0.01)  -- Adjust the wait time as needed
    end
end

-- Start the auto pickup functionality
spawn(autoPickup)

-- Start the auto target closest player functionality
spawn(autoTargetClosestPlayer)

-- Start the auto heal functionality
spawn(autoHeal)

-- Start the auto plant functionality
spawn(autoPlant)

-- Start the Bow Aimbot functionality
spawn(BowAimbot)
