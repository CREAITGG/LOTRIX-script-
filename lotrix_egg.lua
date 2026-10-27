--[[ LOTRIX VX - STEAL AN EGG | Client only | v2.3 ]]
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local CG=game:GetService("CoreGui")
local SG=game:GetService("StarterGui")
local LP=Players.LocalPlayer
if not LP then return end
local ENV=(getgenv and getgenv()) or _G
local function ext(n)
 local ok,v=pcall(function() return ENV[n] or _G[n] end)
 if ok and type(v)=="function" then return v end
end
if type(ENV._LOTRIX_EGG_CLEANUP)=="function" then pcall(ENV._LOTRIX_EGG_CLEANUP) end

-- settings
local CFG={
 Name="LOTRIX_VX_EGG",
 TrapWords={"trap","snare"},
}

-- state
local S={alert={on=false,conns={},chase={},hooked={},token=0},trapAuto={on=false},speed={on=false,val=100,base=16}}
local alive,conns,F=true,{},{}
local statusLabel
local function track(c) conns[#conns+1]=c return c end
local function disc(c) if c then pcall(function() c:Disconnect() end) end end

local C={bg=Color3.fromRGB(9,8,7),panel=Color3.fromRGB(18,14,11),card=Color3.fromRGB(28,21,15),
 g=Color3.fromRGB(255,122,24),g2=Color3.fromRGB(255,170,84),gd=Color3.fromRGB(124,58,10),
 text=Color3.fromRGB(246,239,231),sub=Color3.fromRGB(172,152,136),off=Color3.fromRGB(62,50,41),
 amber=Color3.fromRGB(255,214,90),red=Color3.fromRGB(255,84,84),white=Color3.new(1,1,1)}
local KC={ok=C.g2,warn=C.amber,err=C.red,info=C.sub}
local function notify(t,k)
 print("[LOTRIX] "..tostring(t))
 if statusLabel and statusLabel.Parent then
  statusLabel.Text=tostring(t)
  statusLabel.TextColor3=KC[k or "info"] or C.sub
 end
end
local function popup(t)
 pcall(function() SG:SetCore("SendNotification",{Title="LOTRIX VX",Text=tostring(t),Duration=4}) end)
end

local function hasWord(name,words)
 local n=string.lower(name)
 for _,w in ipairs(words) do if string.find(n,w,1,true) then return true end end
 return false
end
local function inChar(i)
 local o=i local d=0
 while o and o~=WS and d<12 do
  if o:IsA("Model") and Players:GetPlayerFromCharacter(o) then return true end
  o=o.Parent d=d+1
 end
 return false
end
local function isTrap(inst)
 if not (inst:IsA("Model") or inst:IsA("BasePart")) then return false end
 if not hasWord(inst.Name,CFG.TrapWords) then return false end
 if inst:IsA("BasePart") and inst.Parent and inst.Parent:IsA("Model") and hasWord(inst.Parent.Name,CFG.TrapWords) then return false end
 return not inChar(inst)
end

-- host for the gui
local host
do
 local gh=ext("gethui")
 if gh then local ok,h=pcall(gh) if ok and h then host=h end end
 if not host then
  local ok=pcall(function() local t=Instance.new("Folder") t.Parent=CG t:Destroy() end)
  host=ok and CG or LP:WaitForChild("PlayerGui")
 end
 local pg=LP:FindFirstChild("PlayerGui")
 for _,p in ipairs({host,pg or host}) do
  pcall(function() local o=p:FindFirstChild(CFG.Name) if o then o:Destroy() end end)
 end
end

-- guard alert: read only. The server decides the chase, so this only warns you.
local function isMe(v)
 if v==nil or v=="" then return false end
 return tostring(v)==tostring(LP.UserId)
end
local function isGuard(d)
 return d:IsA("Model") and d:GetAttribute("GuardState")~=nil
end
local function hookGuard(g)
 local a=S.alert
 if a.hooked[g] then return end
 a.hooked[g]=true
 a.conns[#a.conns+1]=g.AttributeChanged:Connect(function(k)
  if not a.on then return end
  if k=="WakeTargetPlayer" then
   if isMe(g:GetAttribute(k)) then
    notify("الحارس يصحى وهدفه أنت!","err")
    popup("الحارس يصحى وهدفه أنت!")
   end
  elseif k=="TargetPlayer" then
   if isMe(g:GetAttribute(k)) then
    if not a.chase[g] then
     a.chase[g]=os.clock()
     notify("حارس يلاحقك الآن!","err")
     popup("حارس يلاحقك الآن!")
    end
   elseif a.chase[g] then
    local d=math.floor(os.clock()-a.chase[g])
    a.chase[g]=nil
    notify("انتهت الملاحقة بعد "..d.." ثانية","info")
    popup("انتهت الملاحقة بعد "..d.." ثانية")
   end
  end
 end)
end
function F.alert(on)
 local a=S.alert
 a.on=on
 a.token=a.token+1
 for _,c in ipairs(a.conns) do disc(c) end
 a.conns={} a.chase={} a.hooked={}
 disc(a.add) a.add=nil
 if not on then return true,"تم إيقاف تنبيه الحارس","info" end
 local n=0
 for _,d in ipairs(WS:GetDescendants()) do
  if isGuard(d) then n=n+1 hookGuard(d) end
 end
 if n==0 then
  a.on=false
  return false,"لم أجد حراساً الآن - اقترب من منطقة حارس وجرّب","warn"
 end
 a.add=WS.DescendantAdded:Connect(function(d)
  task.delay(.5,function()
   if alive and a.on and d.Parent and isGuard(d) then hookGuard(d) end
  end)
 end)
 local my=a.token
 task.spawn(function()
  while alive and a.on and a.token==my do
   task.wait(1)
   local first
   for _,t0 in pairs(a.chase) do
    if not first or t0<first then first=t0 end
   end
   if first then notify("ملاحقة جارية: "..math.floor(os.clock()-first).." ث","warn") end
  end
 end)
 return true,"تنبيه الحارس مفعّل - "..n.." حارس تحت المراقبة (قراءة فقط)","ok"
end

-- traps: local removal
function F.removeTraps()
 local n=0
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsDescendantOf(WS) and isTrap(d) then n=n+1 pcall(function() d:Destroy() end) end
 end
 return n
end
function F.trapAuto(on)
 local t=S.trapAuto t.on=on disc(t.conn) t.conn=nil
 if not on then return true,"تم إيقاف الحذف التلقائي","info" end
 t.conn=WS.DescendantAdded:Connect(function(d)
  task.delay(.25,function()
   if alive and t.on and d.Parent and isTrap(d) then pcall(function() d:Destroy() end) end
  end)
 end)
 return true,"أي فخ جديد يُحذف من شاشتك تلقائياً (محلي فقط)","warn"
end

-- walk speed: moves your own character only (not the game's speed stat)
local function fmt(n) return string.format("%g",n) end
local function parseNum(t)
 t=tostring(t or "")
 for i=0,9 do t=t:gsub("\217"..string.char(160+i),tostring(i)) end
 return tonumber((t:gsub("%s","")))
end
local function getHum()
 local c=LP.Character
 return c and c:FindFirstChildOfClass("Humanoid")
end
local function hookSpeed(h)
 disc(S.speed.hc)
 S.speed.hc=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
  if S.speed.on and h.WalkSpeed~=S.speed.val then h.WalkSpeed=S.speed.val end
 end)
end
function F.speed(on)
 local sp=S.speed
 if on then
  local h=getHum()
  if not h then return false,"لا توجد شخصية حالياً","warn" end
  if h.WalkSpeed>0 and h.WalkSpeed~=sp.val then sp.base=h.WalkSpeed end
  sp.on=true
  hookSpeed(h)
  h.WalkSpeed=sp.val
  return true,"سرعة المشي "..fmt(sp.val).." مفعّلة - لحركة شخصيتك فقط وقد يعيدها السيرفر","warn"
 end
 sp.on=false
 disc(sp.hc) sp.hc=nil
 local h=getHum()
 if h then h.WalkSpeed=sp.base end
 return true,"تم إيقاف السرعة","info"
end
function F.setSpeed(v)
 local sp=S.speed
 sp.val=math.clamp(v,1,1000)
 local h=getHum()
 if sp.on and h then h.WalkSpeed=sp.val end
 return sp.val
end

-- ui helpers
local function new(cls,props,parent)
 local o=Instance.new(cls)
 for k,v in pairs(props or {}) do o[k]=v end
 if parent then o.Parent=parent end
 return o
end
local function corner(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function stroke(o,c,t) return new("UIStroke",{Color=c or C.gd,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
local function label(p,t,sz,col,bold,al)
 return new("TextLabel",{BackgroundTransparency=1,Text=t,TextSize=sz or 14,TextColor3=col or C.text,Font=bold and Enum.Font.GothamBold or Enum.Font.SourceSans,TextWrapped=true,TextXAlignment=al or Enum.TextXAlignment.Right},p)
end

local DW,DH=250,266
local gui=new("ScreenGui",{Name=CFG.Name,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},host)
local uiScale=new("UIScale",{},gui)
local function rescale()
 local cam=WS.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(1000,600)
 uiScale.Scale=math.clamp(math.min(v.X*.55/DW,v.Y*.55/DH),.5,3)
end
rescale()
if WS.CurrentCamera then track(WS.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)) end

local main=new("Frame",{Size=UDim2.fromOffset(DW,DH),Position=UDim2.new(.5,-DW/2,.5,-DH/2),BackgroundColor3=C.bg,Visible=false},gui)
corner(main,14) stroke(main,C.g,1.5)
new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(40,18,4),Color3.fromRGB(9,8,7)),Rotation=90},main)
local header=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1},main)
local title=label(header,"LOTRIX VX",16,C.g2,true,Enum.TextXAlignment.Center) title.Size=UDim2.fromScale(1,1)
local function hbtn(txt,x)
 local b=new("TextButton",{Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(x,5),BackgroundColor3=C.card,Text=txt,TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.g,AutoButtonColor=false},header)
 corner(b,6) return b
end
local closeB=hbtn("X",6) local hideB=hbtn("-",34)
new("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.fromOffset(12,34),BackgroundColor3=C.g,BorderSizePixel=0},main)

do
 local drag,start,startPos
 track(header.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true start=i.Position startPos=main.Position end
 end))
 track(UIS.InputChanged:Connect(function(i)
  if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local d=(i.Position-start)/uiScale.Scale
   main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
  end
 end))
 track(UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
 end))
end

local bar=new("Frame",{Size=UDim2.new(1,-16,0,38),Position=UDim2.new(0,8,1,-46),BackgroundColor3=C.panel},main)
corner(bar,8) stroke(bar,C.gd)
statusLabel=label(bar,"جاهز - محلي على جهازك فقط",12,C.sub,false,Enum.TextXAlignment.Center)
statusLabel.Size=UDim2.new(1,-10,1,0) statusLabel.Position=UDim2.fromOffset(5,0)

local function fx(card)
 pcall(function()
  local sc=card:FindFirstChildOfClass("UIScale") or new("UIScale",{},card)
  sc.Scale=.94
  TS:Create(sc,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
  local fl=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.g,BackgroundTransparency=.6,ZIndex=5},card)
  corner(fl,10)
  local t=TS:Create(fl,TweenInfo.new(.35),{BackgroundTransparency=1}) t:Play()
  t.Completed:Connect(function() fl:Destroy() end)
 end)
end
local function toggleCard(y,txt,desc,fn)
 local c=new("Frame",{Size=UDim2.new(1,-16,0,54),Position=UDim2.fromOffset(8,y),BackgroundColor3=C.card},main)
 corner(c,10) stroke(c,C.gd)
 local t=label(c,txt,13,C.text,true) t.Size=UDim2.new(1,-66,0,18) t.Position=UDim2.fromOffset(6,5)
 local d=label(c,desc,10,C.sub) d.Size=UDim2.new(1,-66,0,26) d.Position=UDim2.fromOffset(6,23) d.TextYAlignment=Enum.TextYAlignment.Top
 local sw=new("TextButton",{Size=UDim2.fromOffset(46,24),Position=UDim2.new(0,8,.5,-12),BackgroundColor3=C.off,Text="",AutoButtonColor=false},c)
 corner(sw,12)
 local kn=new("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.new(0,3,.5,-9),BackgroundColor3=C.white},sw) corner(kn,9)
 local on=false
 local function paint()
  TS:Create(sw,TweenInfo.new(.15),{BackgroundColor3=on and C.g or C.off}):Play()
  TS:Create(kn,TweenInfo.new(.15),{Position=on and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)}):Play()
 end
 sw.MouseButton1Click:Connect(function()
  fx(c)
  local want=not on
  local ok,msg,kind=fn(want)
  if ok then on=want end
  paint()
  notify(msg or (ok and "تم" or "فشل"),kind or (ok and "ok" or "err"))
 end)
 return c,d
end

-- 1) guard alert (read only)
toggleCard(42,"تنبيه الحارس","ينبّهك لما يستهدفك حارس ويعرض مدة الملاحقة (قراءة فقط)",function(on)
 return F.alert(on)
end)
-- 2) trap removal
toggleCard(102,"حذف الفخاخ","حذف الفخاخ من شاشتك وأي فخ جديد تلقائياً",function(on)
 if on then
  F.trapAuto(true)
  local n=F.removeTraps()
  if n>0 then return true,"أُزيل "..n.." فخ من شاشتك فقط - السيرفر قد يظل يفعّلها","warn" end
  return true,"حذف تلقائي مفعّل - لا فخاخ ظاهرة الآن","warn"
 end
 return F.trapAuto(false)
end)

-- 3) walk speed with a value box
do
 local c,d=toggleCard(162,"سرعة المشي","سرعة حركة شخصيتك فقط (ليست رقم السرعة في اللعبة)",function(on)
  return F.speed(on)
 end)
 d.Size=UDim2.new(1,-124,0,26)
 local tb=new("TextBox",{Size=UDim2.fromOffset(54,22),Position=UDim2.new(0,58,.5,-11),BackgroundColor3=C.panel,Text=fmt(S.speed.val),PlaceholderText="1-1000",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.g2,ClearTextOnFocus=false},c)
 corner(tb,6) stroke(tb,C.gd)
 tb.FocusLost:Connect(function()
  local v=parseNum(tb.Text)
  if not v then
   tb.Text=fmt(S.speed.val)
   notify("اكتب رقماً بين 1 و 1000","err")
   return
  end
  v=F.setSpeed(v)
  tb.Text=fmt(v)
  notify("تم ضبط السرعة على "..fmt(v),"ok")
 end)
end

local floatB=new("TextButton",{Size=UDim2.fromOffset(44,44),Position=UDim2.new(0,12,.5,-22),BackgroundColor3=C.g,Text="L",TextSize=24,Font=Enum.Font.GothamBlack,TextColor3=C.bg,Visible=false,AutoButtonColor=false},gui)
corner(floatB,22) stroke(floatB,C.white,2)
hideB.MouseButton1Click:Connect(function() main.Visible=false floatB.Visible=true end)
floatB.MouseButton1Click:Connect(function() main.Visible=true floatB.Visible=false end)

local function cleanup()
 if not alive then return end
 alive=false
 pcall(F.alert,false) pcall(F.trapAuto,false) pcall(F.speed,false)
 for _,c in ipairs(conns) do disc(c) end
 pcall(function() gui:Destroy() end)
 ENV._LOTRIX_EGG_CLEANUP=nil
end
ENV._LOTRIX_EGG_CLEANUP=cleanup
closeB.MouseButton1Click:Connect(function() notify("تم الإغلاق","info") task.delay(.15,cleanup) end)

track(LP.CharacterAdded:Connect(function(ch)
 task.spawn(function()
  local h=ch:WaitForChild("Humanoid",10)
  if not h or not alive then return end
  task.wait(.3)
  if ch~=LP.Character then return end
  if S.speed.on then hookSpeed(h) h.WalkSpeed=S.speed.val end
 end)
end))

local function intro()
 local g=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,6,4),ZIndex=50},gui)
 local t1=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,60),Position=UDim2.new(0,0,.38,0),Text="LOTRIX VX",TextSize=52,Font=Enum.Font.GothamBlack,TextColor3=C.g,TextTransparency=1,ZIndex=51},g)
 local t2=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,.38,64),Text="STEAL AN EGG",TextSize=20,Font=Enum.Font.GothamBold,TextColor3=C.g2,TextTransparency=1,ZIndex=51},g)
 local ln=new("Frame",{Size=UDim2.fromOffset(0,3),Position=UDim2.new(.5,0,.38,106),BackgroundColor3=C.g,BorderSizePixel=0,ZIndex=51},g)
 TS:Create(t1,TweenInfo.new(1),{TextTransparency=0}):Play()
 task.wait(.6)
 TS:Create(t2,TweenInfo.new(1),{TextTransparency=0}):Play()
 TS:Create(ln,TweenInfo.new(2.5),{Size=UDim2.fromOffset(240,3),Position=UDim2.new(.5,-120,.38,106)}):Play()
 task.wait(3.4)
 main.Visible=true
 TS:Create(g,TweenInfo.new(1),{GroupTransparency=1}):Play()
 task.wait(1)
 g:Destroy()
end
notify("LOTRIX VX جاهز - محلي فقط","ok")
task.spawn(function()
 local ok,e=pcall(intro)
 if not ok then
  if alive and main.Parent then main.Visible=true end
  warn("[LOTRIX] intro: "..tostring(e))
 end
end)
