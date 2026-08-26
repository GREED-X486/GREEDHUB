-- ============================================================
--   GREED HUB | Blox Fruits Script Hub
--   Features: Auto Farm, Sea Events, PVP, Player Kill & More
--   Author: GREED_X
--   Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/GREED-X486/GREEDHUB/refs/heads/main/GREEDHUB.lua"))()
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = Workspace.CurrentCamera

-- ============================================================
--  STATE TABLE (all toggles stored here)
-- ============================================================
local State = {
    -- Auto Farm
    AutoFarm         = false,
    AutoMastery      = false,
    AutoBoss         = false,
    AutoChest        = false,
    AutoQuest        = false,
    AutoStats        = false,

    -- Sea Events
    SeaEventFarm     = false,
    AutoRaid         = false,
    AutoTreasure     = false,

    -- PVP
    AutoPVP          = false,
    AutoBlock        = false,
    AutoCombo        = false,
    NoClip           = false,
    SpeedBoost       = false,

    -- Kill Aura
    KillAura         = false,
    KillTarget       = "",     -- specific player name to kill
    KillAuraRange    = 15,

    -- Misc
    AntiAFK          = false,
    InfiniteJump     = false,
    FlyEnabled       = false,
    ESPEnabled       = false,
    FruitESP         = false,
}

-- ============================================================
--  UTILITY FUNCTIONS
-- ============================================================
local function GetChar()
    return LP.Character
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function TeleportTo(pos)
    local root = GetRoot()
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

local function TeleportToPart(part)
    local root = GetRoot()
    if root and part then
        root.CFrame = part.CFrame * CFrame.new(0, 3, -4)
    end
end

local function IsAlive(player)
    local char = player and player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title   = "GREED HUB",
        Text    = msg,
        Duration = 4,
    })
end

-- ============================================================
--  AUTO FARM LOOP
-- ============================================================
local farmConnection
local function StartAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    farmConnection = RunService.Heartbeat:Connect(function()
        if not State.AutoFarm then return end
        local char = GetChar()
        local root = GetRoot()
        local hum  = GetHum()
        if not char or not root or not hum then return end
        if hum.Health <= 0 then
            task.wait(3)
            return
        end

        -- Find nearest enemy mob
        local nearest, nearestDist = nil, math.huge
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 and h.MaxHealth <= 500000 then
                    -- filter out players
                    local isPlayer = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character == obj then isPlayer = true break end
                    end
                    if not isPlayer then
                        local dist = (root.Position - r.Position).Magnitude
                        if dist < nearestDist then
                            nearest = r
                            nearestDist = dist
                        end
                    end
                end
            end
        end

        if nearest then
            -- Teleport close to mob
            if nearestDist > 10 then
                root.CFrame = nearest.CFrame * CFrame.new(0, 2, -5)
                task.wait(0.1)
            end
            -- Simulate attack via tool or click
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local activate = tool:FindFirstChild("Activate")
                if activate then activate:FireServer() end
            end
        end
        task.wait(0.05)
    end)
end

-- ============================================================
--  AUTO BOSS FARM
-- ============================================================
local bossNames = {
    "Gorilla King", "Bobby", "Yeti", "Mob Leader",
    "Cursed Captain", "Ice Admiral", "Saber Expert",
    "Wystern", "Order", "Magma Admiral", "Warden",
    "Chief Warden", "Swan", "Mihawk", "Cyborg",
    "Darkbeard", "Rip_Indra", "Golden Boss",
}

local bossConnection
local function StartBossFarm()
    if bossConnection then bossConnection:Disconnect() end
    bossConnection = RunService.Heartbeat:Connect(function()
        if not State.AutoBoss then return end
        local root = GetRoot()
        if not root then return end

        for _, name in ipairs(bossNames) do
            local boss = Workspace:FindFirstChild(name, true)
            if boss then
                local bossRoot = boss:FindFirstChild("HumanoidRootPart")
                local bossHum  = boss:FindFirstChildOfClass("Humanoid")
                if bossRoot and bossHum and bossHum.Health > 0 then
                    root.CFrame = bossRoot.CFrame * CFrame.new(0, 3, -5)
                    task.wait(0.1)
                    -- Attack
                    local char = GetChar()
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        local remote = tool:FindFirstChild("Activate")
                        if remote then remote:FireServer() end
                    end
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.1)
    end)
end

-- ============================================================
--  AUTO CHEST FARM
-- ============================================================
local chestConnection
local function StartChestFarm()
    if chestConnection then chestConnection:Disconnect() end
    chestConnection = RunService.Heartbeat:Connect(function()
        if not State.AutoChest then return end
        local root = GetRoot()
        if not root then return end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Chest" or obj.Name == "Chest1" or obj.Name == "Chest2" then
                local chestPos = obj:IsA("BasePart") and obj.Position
                    or (obj:FindFirstChild("Handle") and obj.Handle.Position)
                if chestPos then
                    local dist = (root.Position - chestPos).Magnitude
                    if dist < 200 then
                        TeleportTo(chestPos + Vector3.new(0, 3, 0))
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(1)
    end)
end

-- ============================================================
--  AUTO QUEST
-- ============================================================
local function DoAutoQuest()
    -- Finds and accepts nearest quest giver NPC
    task.spawn(function()
        while State.AutoQuest do
            local root = GetRoot()
            if root then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "QuestGiver" or obj.Name == "QuestNPC" then
                        local r = obj:FindFirstChild("HumanoidRootPart")
                        if r then
                            TeleportToPart(r)
                            task.wait(0.3)
                            -- Try to fire quest accept remote
                            local remote = ReplicatedStorage:FindFirstChild("Quests", true)
                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer("Accept")
                            end
                            task.wait(0.5)
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- ============================================================
--  SEA EVENT FARM
-- ============================================================
local seaEventNames = {
    "Rumble Ship", "Sea Beast", "Pirate Ship",
    "Snow Lurker", "Shark", "Terrorshark",
}

local seaConnection
local function StartSeaEventFarm()
    if seaConnection then seaConnection:Disconnect() end
    seaConnection = RunService.Heartbeat:Connect(function()
        if not State.SeaEventFarm then return end
        local root = GetRoot()
        if not root then return end

        for _, name in ipairs(seaEventNames) do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == name or obj.Name:find(name) then
                    local r = obj:FindFirstChild("HumanoidRootPart")
                        or (obj:IsA("BasePart") and obj)
                    if r then
                        local dist = (root.Position - r.Position).Magnitude
                        if dist < 2000 then
                            root.CFrame = r.CFrame * CFrame.new(0, 5, -6)
                            task.wait(0.1)
                            local char = GetChar()
                            local tool = char and char:FindFirstChildOfClass("Tool")
                            if tool then
                                local activate = tool:FindFirstChild("Activate")
                                if activate then activate:FireServer() end
                            end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end)
end

-- ============================================================
--  KILL AURA — attacks ALL nearby enemies + targets a player
-- ============================================================
local killAuraConnection
local function StartKillAura()
    if killAuraConnection then killAuraConnection:Disconnect() end
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not State.KillAura then return end
        local root = GetRoot()
        local char = GetChar()
        local hum  = GetHum()
        if not root or not char or not hum or hum.Health <= 0 then return end

        local tool = char:FindFirstChildOfClass("Tool")
        local targets = {}

        -- If a specific player is targeted, prioritize them
        if State.KillTarget ~= "" then
            local target = Players:FindFirstChild(State.KillTarget)
            if target and IsAlive(target) and target ~= LP then
                local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    table.insert(targets, tRoot)
                end
            end
        end

        -- Also grab all nearby players in range
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and IsAlive(player) then
                local tRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (root.Position - tRoot.Position).Magnitude
                    if dist <= State.KillAuraRange then
                        table.insert(targets, tRoot)
                    end
                end
            end
        end

        for _, tRoot in ipairs(targets) do
            -- Teleport directly behind the target
            root.CFrame = tRoot.CFrame * CFrame.new(0, 2, -2)
            task.wait(0.05)
            -- Use equipped tool to attack
            if tool then
                local activate = tool:FindFirstChild("Activate")
                if activate then activate:FireServer() end
                -- Also simulate click
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local clickDetector = handle:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireClickDetector(clickDetector)
                    end
                end
            end
            task.wait(0.05)
        end

        task.wait(0.03)
    end)
end

-- ============================================================
--  KILL SPECIFIC PLAYER — wherever they are
-- ============================================================
local function KillPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then
        Notify("Player not found: " .. targetName)
        return
    end

    task.spawn(function()
        local attempts = 0
        while IsAlive(target) and attempts < 100 do
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local root  = GetRoot()
            local char  = GetChar()
            if not root or not tRoot then task.wait(0.1) continue end

            -- Chase and attack
            root.CFrame = tRoot.CFrame * CFrame.new(0, 2, -2)
            task.wait(0.05)

            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                local activate = tool:FindFirstChild("Activate")
                if activate then activate:FireServer() end
            end

            attempts = attempts + 1
            task.wait(0.05)
        end

        if not IsAlive(target) then
            Notify(targetName .. " has been eliminated!")
        else
            Notify("Could not eliminate " .. targetName)
        end
    end)
end

-- ============================================================
--  AUTO PVP — auto fight whoever attacks you
-- ============================================================
local pvpConnection
local function StartAutoPVP()
    if pvpConnection then pvpConnection:Disconnect() end
    pvpConnection = RunService.Heartbeat:Connect(function()
        if not State.AutoPVP then return end
        local root = GetRoot()
        local hum  = GetHum()
        if not root or not hum then return end

        -- Find closest player who is a threat (low distance)
        local nearest, nearestDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and IsAlive(player) then
                local tRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (root.Position - tRoot.Position).Magnitude
                    if dist < 60 and dist < nearestDist then
                        nearest = tRoot
                        nearestDist = dist
                    end
                end
            end
        end

        if nearest then
            root.CFrame = nearest.CFrame * CFrame.new(0, 2, -3)
            task.wait(0.05)
            local char = GetChar()
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                local activate = tool:FindFirstChild("Activate")
                if activate then activate:FireServer() end
            end
        end
        task.wait(0.05)
    end)
end

-- ============================================================
--  NO CLIP
-- ============================================================
local noclipConnection
local function SetNoClip(state)
    if noclipConnection then noclipConnection:Disconnect() end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = GetChar()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ============================================================
--  SPEED BOOST
-- ============================================================
local function SetSpeed(state)
    local hum = GetHum()
    if hum then
        hum.WalkSpeed = state and 75 or 16
    end
end

-- ============================================================
--  FLY
-- ============================================================
local flyConnection, flyBP, flyBG
local function SetFly(state)
    local char = GetChar()
    local root = GetRoot()
    if not char or not root then return end

    if state then
        flyBP = Instance.new("BodyPosition")
        flyBP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBP.Position = root.Position
        flyBP.Parent = root

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.CFrame = root.CFrame
        flyBG.Parent = root

        flyConnection = RunService.RenderStepped:Connect(function()
            if not State.FlyEnabled then return end
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            flyBP.Position = flyBP.Position + moveDir * 1.5
            flyBG.CFrame = Cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if flyBP then flyBP:Destroy() end
        if flyBG then flyBG:Destroy() end
    end
end

-- ============================================================
--  INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
--  ANTI AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

-- ============================================================
--  ESP (Player + Fruit)
-- ============================================================
local espObjects = {}

local function ClearESP()
    for _, v in pairs(espObjects) do
        if v and v.Parent then v:Destroy() end
    end
    espObjects = {}
end

local function DrawESP()
    ClearESP()
    if not State.ESPEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local box = Instance.new("SelectionBox")
                box.Adornee = char
                box.Color3 = Color3.fromRGB(255, 0, 80)
                box.LineThickness = 0.05
                box.SurfaceTransparency = 0.8
                box.SurfaceColor3 = Color3.fromRGB(255, 0, 80)
                box.Parent = Workspace
                table.insert(espObjects, box)

                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = root
                billboard.Size = UDim2.new(0, 100, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = root

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 80, 160)
                label.TextStrokeTransparency = 0
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 13
                label.Text = player.Name
                label.Parent = billboard
                table.insert(espObjects, billboard)
            end
        end
    end
end

-- ============================================================
--  FRUIT ESP
-- ============================================================
local fruitEspObjects = {}

local function ClearFruitESP()
    for _, v in pairs(fruitEspObjects) do
        if v and v.Parent then v:Destroy() end
    end
    fruitEspObjects = {}
end

local function DrawFruitESP()
    ClearFruitESP()
    if not State.FruitESP then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Fruit" or obj.Name:lower():find("fruit") then
            local part = obj:IsA("BasePart") and obj
                or obj:FindFirstChild("Handle")
            if part then
                local bill = Instance.new("BillboardGui")
                bill.Adornee = part
                bill.Size = UDim2.new(0, 120, 0, 30)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.AlwaysOnTop = true
                bill.Parent = part

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(255, 200, 0)
                lbl.TextStrokeTransparency = 0
                lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 12
                lbl.Text = "FRUIT: " .. obj.Name
                lbl.Parent = bill
                table.insert(fruitEspObjects, bill)
            end
        end
    end
end

-- Refresh ESP every 5 seconds
task.spawn(function()
    while true do
        DrawESP()
        DrawFruitESP()
        task.wait(5)
    end
end)

-- ============================================================
--  GUI BUILDER
-- ============================================================
local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 80)
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

-- ============================================================
--  SCREEN GUI
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "GREED_HUB"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = game:GetService("CoreGui")

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
MakeCorner(Main, 12)
MakeStroke(Main, Color3.fromRGB(130, 0, 200), 1.5)

-- Gradient accent on Main
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 20)),
})
grad.Rotation = 135
grad.Parent = Main

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
MakeCorner(TitleBar, 12)

-- Bottom of title bar fill to hide bottom corners
local TitleFill = Instance.new("Frame")
TitleFill.Size = UDim2.new(1, 0, 0, 12)
TitleFill.Position = UDim2.new(0, 0, 1, -12)
TitleFill.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
TitleFill.BorderSizePixel = 0
TitleFill.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⬡  GREED HUB  |  BLOX FRUITS  ⬡"
TitleText.TextColor3 = Color3.fromRGB(180, 80, 255)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
MakeCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.new(0, 0, 0)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
MakeCorner(MinBtn, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = minimized
            and UDim2.new(0, 520, 0, 44)
            or  UDim2.new(0, 520, 0, 420)
    }):Play()
end)

-- ============================================================
--  TAB BAR
-- ============================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 34)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
MakeCorner(TabBar, 8)
MakeStroke(TabBar, Color3.fromRGB(50, 20, 80), 1)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local tabList = {"Farm", "Events", "PVP", "Kill", "ESP", "Misc"}
local tabBtns = {}
local tabPages = {}

for _, name in ipairs(tabList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 74, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(120, 80, 160)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    MakeCorner(btn, 6)
    tabBtns[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -92)
    page.Position = UDim2.new(0, 10, 0, 88)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(130, 0, 200)
    page.Visible = false
    page.Parent = Main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    tabPages[name] = page
end

-- Tab switch logic
local function SwitchTab(name)
    for t, btn in pairs(tabBtns) do
        local active = t == name
        btn.BackgroundColor3 = active
            and Color3.fromRGB(100, 0, 180)
            or  Color3.fromRGB(25, 15, 45)
        btn.TextColor3 = active
            and Color3.fromRGB(255, 255, 255)
            or  Color3.fromRGB(120, 80, 160)
        tabPages[t].Visible = (t == name)
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- ============================================================
--  UI HELPERS
-- ============================================================
local function MakeSectionLabel(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "— " .. string.upper(text) .. " —"
    l.TextColor3 = Color3.fromRGB(100, 50, 150)
    l.TextSize = 9
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function MakeToggle(parent, label, stateKey, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
    row.BorderSizePixel = 0
    row.Parent = parent
    MakeCorner(row, 7)
    MakeStroke(row, Color3.fromRGB(40, 20, 65), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210, 180, 255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 36, 0, 19)
    togBg.Position = UDim2.new(1, -48, 0.5, -9.5)
    togBg.BackgroundColor3 = Color3.fromRGB(40, 20, 65)
    togBg.BorderSizePixel = 0
    togBg.Parent = row
    MakeCorner(togBg, 10)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 15, 0, 15)
    circle.Position = UDim2.new(0, 2, 0.5, -7.5)
    circle.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
    circle.BorderSizePixel = 0
    circle.Parent = togBg
    MakeCorner(circle, 10)

    local enabled = State[stateKey] or false

    local function UpdateVisual()
        TweenService:Create(togBg, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled
                and Color3.fromRGB(130, 0, 200)
                or  Color3.fromRGB(40, 20, 65)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = enabled
                and UDim2.new(0, 19, 0.5, -7.5)
                or  UDim2.new(0, 2, 0.5, -7.5)
        }):Play()
    end

    UpdateVisual()

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = row
    clickBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        State[stateKey] = enabled
        UpdateVisual()
        if callback then callback(enabled) end
    end)
    return row
end

local function MakeButton(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
    btn.Text = label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    MakeCorner(btn, 7)
    MakeStroke(btn, Color3.fromRGB(160, 50, 255), 1)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function MakeTextInput(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
    box.TextColor3 = Color3.fromRGB(210, 180, 255)
    box.PlaceholderColor3 = Color3.fromRGB(90, 60, 120)
    box.PlaceholderText = placeholder or "Type here..."
    box.Text = ""
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = parent
    MakeCorner(box, 7)
    MakeStroke(box, Color3.fromRGB(80, 30, 130), 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = box
    return box
end

-- ============================================================
--  BUILD FARM PAGE
-- ============================================================
local farmPage = tabPages["Farm"]
MakeSectionLabel(farmPage, "Auto Farm")
MakeToggle(farmPage, "Auto Farm Mobs", "AutoFarm", function(v)
    if v then StartAutoFarm() end
end)
MakeToggle(farmPage, "Auto Farm Bosses", "AutoBoss", function(v)
    if v then StartBossFarm() end
end)
MakeToggle(farmPage, "Auto Chest Farm", "AutoChest", function(v)
    if v then StartChestFarm() end
end)
MakeToggle(farmPage, "Auto Quest", "AutoQuest", function(v)
    if v then DoAutoQuest() end
end)
MakeSectionLabel(farmPage, "Teleport")
MakeButton(farmPage, "Teleport → First Sea", function()
    TeleportTo(Vector3.new(980, 60, 980))
end)
MakeButton(farmPage, "Teleport → Second Sea", function()
    TeleportTo(Vector3.new(-3000, 60, 3000))
end)
MakeButton(farmPage, "Teleport → Third Sea", function()
    TeleportTo(Vector3.new(6000, 60, -6000))
end)
MakeButton(farmPage, "Teleport → Raid Island", function()
    TeleportTo(Vector3.new(0, 50, -9900))
end)

-- ============================================================
--  BUILD EVENTS PAGE
-- ============================================================
local eventsPage = tabPages["Events"]
MakeSectionLabel(eventsPage, "Sea Events")
MakeToggle(eventsPage, "Auto Sea Event Farm", "SeaEventFarm", function(v)
    if v then StartSeaEventFarm() end
end)
MakeToggle(eventsPage, "Auto Raid", "AutoRaid", function(v)
    Notify(v and "Auto Raid ON" or "Auto Raid OFF")
end)
MakeToggle(eventsPage, "Auto Treasure", "AutoTreasure", function(v)
    Notify(v and "Auto Treasure ON" or "Auto Treasure OFF")
end)
MakeButton(eventsPage, "Join Nearest Raid", function()
    local remote = ReplicatedStorage:FindFirstChild("Raid", true)
    if remote then remote:FireServer("Join") end
    Notify("Attempting to join Raid...")
end)
MakeButton(eventsPage, "Collect Sea Event Reward", function()
    local root = GetRoot()
    if root then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Reward" or obj.Name == "EventReward" then
                local r = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle")
                if r then TeleportTo(r.Position) end
            end
        end
    end
end)

-- ============================================================
--  BUILD PVP PAGE
-- ============================================================
local pvpPage = tabPages["PVP"]
MakeSectionLabel(pvpPage, "Auto PVP")
MakeToggle(pvpPage, "Auto PVP (Attack Nearby)", "AutoPVP", function(v)
    if v then StartAutoPVP() end
end)
MakeToggle(pvpPage, "Auto Block / Parry", "AutoBlock", function(v)
    Notify(v and "Auto Block ON" or "Auto Block OFF")
end)
MakeToggle(pvpPage, "Auto Combo", "AutoCombo", function(v)
    Notify(v and "Auto Combo ON" or "Auto Combo OFF")
end)
MakeSectionLabel(pvpPage, "Movement")
MakeToggle(pvpPage, "Speed Boost (x4)", "SpeedBoost", function(v)
    SetSpeed(v)
end)
MakeToggle(pvpPage, "Fly Mode", "FlyEnabled", function(v)
    SetFly(v)
end)
MakeToggle(pvpPage, "No Clip", "NoClip", function(v)
    SetNoClip(v)
end)

-- ============================================================
--  BUILD KILL PAGE
-- ============================================================
local killPage = tabPages["Kill"]
MakeSectionLabel(killPage, "Kill Aura")
MakeToggle(killPage, "Kill Aura (All Nearby Players)", "KillAura", function(v)
    if v then StartKillAura() end
end)

MakeSectionLabel(killPage, "Kill Specific Player")
local playerInput = MakeTextInput(killPage, "Enter player name...")
playerInput:GetPropertyChangedSignal("Text"):Connect(function()
    State.KillTarget = playerInput.Text
end)

MakeButton(killPage, "Hunt & Kill Player", function()
    local name = playerInput.Text
    if name == "" then
        Notify("Enter a player name first!")
        return
    end
    KillPlayer(name)
end)

MakeSectionLabel(killPage, "Kill All Players")
MakeButton(killPage, "Kill Everyone in Server", function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            KillPlayer(player.Name)
        end
    end
end)

MakeSectionLabel(killPage, "Teleport to Target")
MakeButton(killPage, "Teleport to Target Player", function()
    local name = playerInput.Text
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then TeleportToPart(tRoot) end
    else
        Notify("Player not found: " .. name)
    end
end)

-- ============================================================
--  BUILD ESP PAGE
-- ============================================================
local espPage = tabPages["ESP"]
MakeSectionLabel(espPage, "Player ESP")
MakeToggle(espPage, "Player ESP (Box + Name)", "ESPEnabled", function(v)
    if not v then ClearESP() else DrawESP() end
end)
MakeToggle(espPage, "Fruit ESP", "FruitESP", function(v)
    if not v then ClearFruitESP() else DrawFruitESP() end
end)
MakeButton(espPage, "Refresh ESP", function()
    DrawESP()
    DrawFruitESP()
    Notify("ESP Refreshed!")
end)

-- ============================================================
--  BUILD MISC PAGE
-- ============================================================
local miscPage = tabPages["Misc"]
MakeSectionLabel(miscPage, "Player Mods")
MakeToggle(miscPage, "Anti AFK", "AntiAFK", function(v)
    Notify(v and "Anti AFK ON" or "Anti AFK OFF")
end)
MakeToggle(miscPage, "Infinite Jump", "InfiniteJump", function(v)
    Notify(v and "Infinite Jump ON" or "Infinite Jump OFF")
end)
MakeSectionLabel(miscPage, "Server")
MakeButton(miscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId)
end)
MakeButton(miscPage, "Copy Server ID", function()
    setclipboard(tostring(game.JobId))
    Notify("Server ID copied!")
end)
MakeSectionLabel(miscPage, "Credits")
local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 30)
credit.BackgroundTransparency = 1
credit.Text = "GREED HUB — Made by GREED_X"
credit.TextColor3 = Color3.fromRGB(100, 50, 150)
credit.TextSize = 11
credit.Font = Enum.Font.GothamBold
credit.Parent = miscPage

-- ============================================================
--  START ON FARM TAB
-- ============================================================
SwitchTab("Farm")
Notify("GREED HUB Loaded! Made by GREED_X")
print("✅ GREED HUB | Blox Fruits | by GREED_X")
