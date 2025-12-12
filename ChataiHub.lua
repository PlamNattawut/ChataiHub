
getgenv().AutoMine = false
getgenv().SelectRocks = ""
getgenv().AutoMon = false
getgenv().SelectMon = ""
getgenv().TweenSpeed = 30


local RocksTable = {}

int = function()
    for _,v in pairs(require(game:GetService("ReplicatedStorage").Shared.Data.Rock)) do
        table.insert(RocksTable,_)
    end
end

local MonTable = {}

int1 = function()
    for _,v in pairs(require(game:GetService("ReplicatedStorage").Shared.Data.Enemies)) do
        table.insert(MonTable,_)
    end
end


--// ส่วนสคริป

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Char = player.Character
local RootPart = Char.HumanoidRootPart
local livingFolder = workspace:WaitForChild("Living")

Tween = function(Target,Speed)
    local Dis = (Target.Position - RootPart.Position).Magnitude
    TweenService:Create(RootPart,TweenInfo.new(Dis/Speed,Enum.EasingStyle.Linear),
    {CFrame = Target}
    ):Play()
end

-- // remote
Pickaxe = function()
    game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Pickaxe")
end

Weapon = function()
    game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Weapon")
end

noclip = function()
    for _,v in pairs(Char:GetDescendants()) do
        if v:IsA("BasePart") then
        v.CanCollide = false
        end
    end
end

-- // part ตีน
local Taiteen = workspace:FindFirstChild("TaiTeen")
if not Taiteen then
    taitenn = Instance.new("Part")
    taitenn.Name = "Taiteen"
    taitenn.Parent = workspace
    taitenn.Anchored = true
    taitenn.Transparency = 1
    taitenn.Size = Vector3.new(5,0.7,5)
end

UpdateTaiTeen = function()
    if taitenn and RootPart then
        taitenn.CFrame = RootPart.CFrame * CFrame.new(0,-3,0)
    end
end


--// Loop Auto Mine

task.spawn(function()
    while task.wait() do
        if getgenv().AutoMine then
            
            local target = getgenv().SelectRocks
            local SelectedModel = nil

            -- หาแร่ที่เลือก
            for _, Rocks in ipairs(workspace.Rocks:GetChildren()) do
                for _, part in ipairs(Rocks:GetChildren()) do
                    if part:IsA("Part") and part.Name == "SpawnLocation" then
                        local Model = part:FindFirstChildOfClass("Model")
                        if Model and Model.Name == target then
                            SelectedModel = Model
                            break
                        end
                    end
                end
                if SelectedModel then break end
            end

            -- ไม่พบแร่
            if not SelectedModel then
                workspace.Camera.CameraSubject = RootPart
                continue
            end

            -- เริ่มขุด
            repeat task.wait()

                if not getgenv().AutoMine then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                local HP = SelectedModel:GetAttribute("Health")

                -- **จุดที่ทำให้กล้องค้าง — แก้โดยสั่ง reset ทุกกรณี**
                if not HP or HP <= 0 or not SelectedModel.Parent then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                local Hitbox = SelectedModel:FindFirstChild("Hitbox")
                if not Hitbox then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                -- ทำงานหลัก
                Tween(Hitbox.CFrame * CFrame.new(0,-4,0), getgenv().TweenSpeed)
                Pickaxe()
                noclip()
                UpdateTaiTeen()

                -- จับกล้องถ้าอยู่ใกล้
                if (Hitbox.Position - RootPart.Position).Magnitude <= 6 then
                    workspace.Camera.CameraSubject = Hitbox
                else
                    workspace.Camera.CameraSubject = RootPart
                end

            until HP <= 0 or not SelectedModel.Parent or not getgenv().AutoMine

            -- **ปิดท้ายทุกครั้ง เผื่อ safety**
            workspace.Camera.CameraSubject = RootPart
        end
    end
end)


-- // LOOP AutoMon 
task.spawn(function()
    while task.wait() do
        if getgenv().AutoMon then

            local target = getgenv().SelectMon
            local SelectedMob = nil

            -- ค้นหามอนที่ตรง BaseName
            for _, mob in ipairs(livingFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
                    
                    local BaseName = mob.Name:match("^%a+")

                    if BaseName == target then
                        SelectedMob = mob
                        break
                    end
                end
            end

            -- ถ้าไม่เจอข้าม
            if not SelectedMob then
                workspace.Camera.CameraSubject = RootPart
                continue
            end

            -- LOOP ตีมอน
            repeat task.wait()

                if not getgenv().AutoMon then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                local Hum = SelectedMob:FindFirstChild("Humanoid")
                local HRP = SelectedMob:FindFirstChild("HumanoidRootPart")

                -- ถ้ามอนหายหรือถูกลบ → กลับกล้องทันที
                if not Hum or not HRP or not SelectedMob.Parent then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                local HP = Hum.Health

                -- มอนตาย → กลับกล้อง + ออกจาก loop
                if HP <= 0 then
                    workspace.Camera.CameraSubject = RootPart
                    break
                end

                -- Tween ไปหา
                Tween(HRP.CFrame * CFrame.new(0, -3, 0), getgenv().TweenSpeed)
                Weapon()
                noclip()
                UpdateTaiTeen()

                -- กล้องตาม HRP ขณะมีชีวิต
                if (HRP.Position - RootPart.Position).Magnitude <= 6 then
                    workspace.Camera.CameraSubject = HRP
                else
                    workspace.Camera.CameraSubject = RootPart
                end

            until Hum.Health <= 0 or not getgenv().AutoMon or not SelectedMob.Parent

            -- ปิดท้ายทุกครั้งเผื่อ fail-safe
            workspace.Camera.CameraSubject = RootPart
        end
    end
end)



--// ใส่ Codes ทั้งหมดของคุณตรงนี้
local CodeList = {
    "FREESPINS",
    "PEAK",
    "SORRYFORSHUTDOWN",
    "400K!",
    "300K!",
    "100KLIKES",
    "200K!",
    "100K!",
    "40KLIKES",
    "20KLIKES",
    "15KLIKES",
    "10KLIKES",
    "5KLIKES",
    "BETARELEASE!",
    "POSTRELEASEQNA",
    "RELEASE",
}

--// หา Remote ที่ใช้ Redeem Code โดยอัตโนมัติ
local Rep = game:GetService("ReplicatedStorage")
local FoundRemote = nil

local function FindRedeemRemote()
    for _,v in pairs(Rep:GetDescendants()) do
        if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("reward") then
                return v
            end
        end
    end
    return nil
end

FoundRemote = FindRedeemRemote()

if not FoundRemote then
    --warn("❌ ไม่พบ Remote สำหรับ Redeem Code")
    return
end

--print("✔ พบ Remote สำหรับ Redeem: ", FoundRemote:GetFullName())
--print("⚡ กำลัง Redeem Codes ทั้งหมด...")

--// ฟังก์ชัน Redeem Code
local function Redeem(code)
    if FoundRemote:IsA("RemoteFunction") then
        return FoundRemote:InvokeServer(code)
    else
        FoundRemote:FireServer(code)
    end
end

--// Redeem ทุกโค้ด
task.spawn(function()
     while true do
        if getgenv().RedeemCodeAll then
            for _, code in ipairs(CodeList) do
                Redeem(code)
                task.wait()
            end
        end
        task.wait() -- เช็คทุก 1 วินาที
    end
end)

--//

int()
int1()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
        Title = "Chatai Hub",
        Icon = "leafy-green", -- lucide icon. optional
        Author = "by Chatai", -- optional

    OpenButton = {
        Title = "OpenUI",
        Icon = "monitor",
        CornerRadius = UDim.new(0,16),
        StrokeThickness = 2,
        Color = ColorSequence.new( 
            Color3.fromHex("FF0F7B"), 
            Color3.fromHex("F89B29")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
        }
    })
Window:Tag({
    Title = "v 0.0.1",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 10, -- from 0 to 13
})

local Tab = Window:Tab({
        Title = "AutoMine",
        Icon = "loader-pinwheel", -- optional
        Locked = false,
    })
Tab:Select() -- Select Tab


local Dropdown = Tab:Dropdown({
    Title = "SelectRocks",
    Desc = "",
    Values = RocksTable,
    Value = "",
    Callback = function(v) 
        getgenv().SelectRocks = v
    end
})

local Toggle = Tab:Toggle({
    Title = "Auto Mine",
    Desc = "",
    Icon = "check",
    Type = "Checkbox",
    Value = false, 
    Callback = function(v) 
        getgenv().AutoMine = v
    end
})

local Dropdown = Tab:Dropdown({
    Title = "SelectMonster",
    Desc = "",
    Values = MonTable,
    Value = "",
    Callback = function(v) 
        getgenv().SelectMon = v
    end
})

local Toggle = Tab:Toggle({
    Title = "Auto Monster",
    Desc = "",
    Icon = "check",
    Type = "Checkbox",
    Value = false, 
    Callback = function(v) 
        getgenv().AutoMon = v
    end
})

local Slider = Tab:Slider({
    Title = "Tween Speed",
    Desc = "",
    Step = 1,
    Value = {
        Min = 0,
        Max = 50,
        Default = getgenv().TweenSpeed,
    },
    Callback = function(v)
        getgenv().TweenSpeed = v
    end
})

--// Code

local Toggle = Tab:Toggle({
    Title = "RedeemCodeAll",
    Desc = "",
    Icon = "check",
    Type = "Checkbox",
    Value = false, 
    Callback = function(v) 
        getgenv().RedeemCodeAll = v
    end
})
