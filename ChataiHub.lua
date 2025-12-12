getgenv().AutoMine=false;getgenv().SelectRocks="";getgenv().AutoMon=false;getgenv().SelectMon="";getgenv().TweenSpeed=30
local RocksTable={},MonTable={}
for _,v in pairs(require(game:GetService("ReplicatedStorage").Shared.Data.Rock)) do table.insert(RocksTable,_) end
for _,v in pairs(require(game:GetService("ReplicatedStorage").Shared.Data.Enemies)) do table.insert(MonTable,_) end
local TweenService,RunService,Workspace,Players=game:GetService("TweenService"),game:GetService("RunService"),game:GetService("Workspace"),game:GetService("Players")
local player=Players.LocalPlayer;local Char=player.Character;local RootPart=Char.HumanoidRootPart;local livingFolder=workspace:WaitForChild("Living")
local function Tween(Target,Speed)local Dis=(Target.Position-RootPart.Position).Magnitude;TweenService:Create(RootPart,TweenInfo.new(Dis/Speed,Enum.EasingStyle.Linear),{CFrame=Target}):Play() end
local function Pickaxe() game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Pickaxe") end
local function Weapon() game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Weapon") end
local function noclip() for _,v in pairs(Char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end
local taitenn=workspace:FindFirstChild("TaiTeen") or Instance.new("Part",workspace);taitenn.Name="Taiteen";taitenn.Anchored=true;taitenn.Transparency=1;taitenn.Size=Vector3.new(5,0.7,5)
local function UpdateTaiTeen() if taitenn and RootPart then taitenn.CFrame=RootPart.CFrame*CFrame.new(0,-3,0) end end

-- AutoMine loop
task.spawn(function() while task.wait() do if getgenv().AutoMine then
local target=getgenv().SelectRocks;local SelectedModel=nil
for _,Rocks in ipairs(workspace.Rocks:GetChildren()) do for _,part in ipairs(Rocks:GetChildren()) do if part:IsA("Part") and part.Name=="SpawnLocation" then local Model=part:FindFirstChildOfClass("Model");if Model and Model.Name==target then SelectedModel=Model;break end end end;if SelectedModel then break end end
if not SelectedModel then workspace.Camera.CameraSubject=RootPart;continue end
repeat task.wait()
if not getgenv().AutoMine then workspace.Camera.CameraSubject=RootPart;break end
local HP=SelectedModel:GetAttribute("Health")
if not HP or HP<=0 or not SelectedModel.Parent then workspace.Camera.CameraSubject=RootPart;break end
local Hitbox=SelectedModel:FindFirstChild("Hitbox")
if not Hitbox then workspace.Camera.CameraSubject=RootPart;break end
Tween(Hitbox.CFrame*CFrame.new(0,-4,0),getgenv().TweenSpeed);Pickaxe();noclip();UpdateTaiTeen()
if (Hitbox.Position-RootPart.Position).Magnitude<=6 then workspace.Camera.CameraSubject=Hitbox else workspace.Camera.CameraSubject=RootPart end
until HP<=0 or not SelectedModel.Parent or not getgenv().AutoMine
workspace.Camera.CameraSubject=RootPart
end end)

-- AutoMon loop
task.spawn(function() while task.wait() do if getgenv().AutoMon then
local target=getgenv().SelectMon;local SelectedMob=nil
for _,mob in ipairs(livingFolder:GetChildren()) do if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then local BaseName=mob.Name:match("^%a+");if BaseName==target then SelectedMob=mob;break end end end
if not SelectedMob then workspace.Camera.CameraSubject=RootPart;continue end
repeat task.wait()
if not getgenv().AutoMon then workspace.Camera.CameraSubject=RootPart;break end
local Hum=SelectedMob:FindFirstChild("Humanoid");local HRP=SelectedMob:FindFirstChild("HumanoidRootPart")
if not Hum or not HRP or not SelectedMob.Parent then workspace.Camera.CameraSubject=RootPart;break end
if Hum.Health<=0 then workspace.Camera.CameraSubject=RootPart;break end
Tween(HRP.CFrame*CFrame.new(0,-3,0),getgenv().TweenSpeed);Weapon();noclip();UpdateTaiTeen()
if (HRP.Position-RootPart.Position).Magnitude<=6 then workspace.Camera.CameraSubject=HRP else workspace.Camera.CameraSubject=RootPart end
until Hum.Health<=0 or not getgenv().AutoMon or not SelectedMob.Parent
workspace.Camera.CameraSubject=RootPart
end end)

-- Redeem code
getgenv().RedeemCodeAll=false
local CodeList={"FREESPINS","PEAK","SORRYFORSHUTDOWN","400K!","300K!","100KLIKES","200K!","100K!","40KLIKES","20KLIKES","15KLIKES","10KLIKES","5KLIKES","BETARELEASE!","POSTRELEASEQNA","RELEASE"}
local Rep=game:GetService("ReplicatedStorage")
local FoundRemote
for _,v in pairs(Rep:GetDescendants()) do if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then local n=v.Name:lower();if n:find("code") or n:find("redeem") or n:find("reward") then FoundRemote=v;break end end end
if not FoundRemote then return end
local function Redeem(code) if FoundRemote:IsA("RemoteFunction") then return FoundRemote:InvokeServer(code) else FoundRemote:FireServer(code) end end
task.spawn(function() while task.wait() do if getgenv().RedeemCodeAll then for _,code in ipairs(CodeList) do Redeem(code);task.wait(0.3) end end;task.wait(1) end end)

-- UI
local WindUI=loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window=WindUI:CreateWindow({Title="Chatai Hub",Icon="leafy-green",Author="by Chatai",OpenButton={Title="OpenUI",Icon="monitor",CornerRadius=UDim.new(0,16),StrokeThickness=2,Color=ColorSequence.new(Color3.fromHex("FF0F7B"),Color3.fromHex("F89B29")),OnlyMobile=false,Enabled=true,Draggable=true}})
Window:Tag({Title="v 0.0.1",Icon="github",Color=Color3.fromHex("#30ff6a"),Radius=10})
local Tab=Window:Tab({Title="AutoMine",Icon="loader-pinwheel",Locked=false})
Tab:Select()
Tab:Dropdown({Title="SelectRocks",Desc="",Values=RocksTable,Value="",Callback=function(v)getgenv().SelectRocks=v end})
Tab:Toggle({Title="Auto Mine",Desc="",Icon="check",Type="Checkbox",Value=false,Callback=function(v)getgenv().AutoMine=v end})
Tab:Dropdown({Title="SelectMonster",Desc="",Values=MonTable,Value="",Callback=function(v)getgenv().SelectMon=v end})
Tab:Toggle({Title="Auto Monster",Desc="",Icon="check",Type="Checkbox",Value=false,Callback=function(v)getgenv().AutoMon=v end})
Tab:Slider({Title="Tween Speed",Desc="",Step=1,Value={Min=0,Max=50,Default=getgenv().TweenSpeed},Callback=function(v)getgenv().TweenSpeed=v end})
Tab:Toggle({Title="RedeemCodeAll",Desc="",Icon="check",Type="Checkbox",Value=false,Callback=function(v)getgenv().RedeemCodeAll=v end})
