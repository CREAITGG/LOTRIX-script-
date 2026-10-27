--[[ LOTRIX VX — STEAL AN EGG | محلي (Client) لـ Delta ]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local CG=game:GetService("CoreGui")
local LP=Players.LocalPlayer
if not LP then return end
local ENV=(getgenv and getgenv()) or _G
local function ext(n) local ok,v=pcall(function() return ENV[n] end) if ok and type(v)=="function" then return v end end
if type(ENV._SARAB_EGG_CLEANUP)=="function" then pcall(ENV._SARAB_EGG_CLEANUP) end

---------------- الإعدادات ----------------
local CFG={
 Name="LOTRIX_VX_EGG",Ver="v2.0",
 EggWords={"egg","بيض"},
 GuardWords={"guardian","guard","boss","oni","gorilla","حارس","وحش","monster"},
 TrapWords={"trap","snare","فخ"},
 SpeedMin=1,SpeedMax=1000,SpeedDefault=100,
 -- أسماء عربية للحيوانات والوحوش (إنجليزي ← عربي). أضف ما تريد
 Animals={
  {"oni tiger","نمر الأوني"},{"gorilla king","ملك الغوريلا"},{"gorilla","غوريلا"},{"oni","أوني"},{"tiger","نمر"},
  {"dragon","تنين"},{"wolf","ذئب"},{"fox","ثعلب"},{"bear","دب"},{"lion","أسد"},{"panda","باندا"},
  {"cat","قطة"},{"dog","كلب"},{"bird","طائر"},{"duck","بطة"},{"chicken","دجاجة"},{"rabbit","أرنب"},
  {"shark","قرش"},{"whale","حوت"},{"snake","أفعى"},{"spider","عنكبوت"},{"dino","ديناصور"},{"rex","ديناصور"},
  {"monster","وحش"},{"cosmic","كوني"},{"phoenix","طائر العنقاء"},{"unicorn","وحيد القرن"},{"turtle","سلحفاة"},
  {"monkey","قرد"},{"frog","ضفدع"},{"penguin","بطريق"},{"octopus","أخطبوط"},{"crab","سلطعون"},{"bat","خفاش"},
 },
}

---------------- الحالة ----------------
local S={speed={on=false,val=CFG.SpeedDefault,base=16},
 esp={egg={on=false,map={}},guard={on=false,map={}},trap={on=false,map={}}},
 freeze={on=false,list={},saved={}},anti={on=false,removed=0,fixed=0},
 trapAuto={on=false},busy=false}
local alive,conns,UI,F=true,{},{},{}
local statusLabel,statVal
local function track(c) conns[#conns+1]=c return c end
local function disc(c) if c then pcall(function() c:Disconnect() end) end end

local C={bg=Color3.fromRGB(9,8,7),panel=Color3.fromRGB(18,14,11),card=Color3.fromRGB(28,21,15),
 g=Color3.fromRGB(255,122,24),g2=Color3.fromRGB(255,170,84),gd=Color3.fromRGB(124,58,10),
 text=Color3.fromRGB(246,239,231),sub=Color3.fromRGB(172,152,136),off=Color3.fromRGB(62,50,41),
 amber=Color3.fromRGB(255,214,90),red=Color3.fromRGB(255,84,84),white=Color3.new(1,1,1)}
local KC={ok=C.g2,warn=C.amber,err=C.red,info=C.sub}
local function notify(t,k)
 print("[SARAB] "..tostring(t))
 if statusLabel and statusLabel.Parent then statusLabel.Text=tostring(t) statusLabel.TextColor3=KC[k or "info"] or C.sub end
end
local function getChar() return LP.Character end
local function getHum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function fmt(n) return string.format("%g",n) end
local function parseNum(t)
 t=tostring(t or "")
 for k,v in pairs({["٠"]="0",["١"]="1",["٢"]="2",["٣"]="3",["٤"]="4",["٥"]="5",["٦"]="6",["٧"]="7",["٨"]="8",["٩"]="9",["٫"]=".",["،"]="."}) do t=t:gsub(k,v) end
 return tonumber((t:gsub("%s","")))
end
local function copyText(t) local f=ext("setclipboard") or ext("toclipboard") if f then return (pcall(f,t)) end return false end

-- BEGIN-PURE
local function hasWord(name,words)
 local n=string.lower(name)
 for _,w in ipairs(words) do if string.find(n,w,1,true) then return true end end
 return false
end
local function abbr(n)
 local u={"","K","M","B","T","Qa"} local i=1
 while math.abs(n)>=1000 and i<#u do n=n/1000 i=i+1 end
 return string.format("%.3g",n)..u[i]
end
local KEYMAP={
 {{"time","timer","remain","countdown"},"الوقت","time"},
 {{"money","cash","income","coin","earn","profit","produc","reward","worth","value","price","gold"},"المال","money"},
 {{"rarity","tier","grade"},"الندرة","text"},
 {{"pet","animal","creature","monster","inside","content","hatch"},"الحيوان","text"},
 {{"owner","player","user"},"المالك","text"},
 {{"name","type","kind"},"الاسم","text"},
}
local function arKey(k)
 local l=string.lower(k)
 for _,e in ipairs(KEYMAP) do for _,w in ipairs(e[1]) do if string.find(l,w,1,true) then return e[2],e[3] end end end
 return k,"text"
end
local function trAnimal(text)
 local l=string.lower(tostring(text))
 for _,p in ipairs(CFG.Animals) do if string.find(l,p[1],1,true) then return tostring(text).." ("..p[2]..")" end end
 return tostring(text)
end
local function fmtVal(kind,v)
 if type(v)=="number" then
  if kind=="money" then return abbr(v) end
  if kind=="time" then return string.format("%d ث",math.floor(v)) end
  return fmt(v)
 end
 return trAnimal(v)
end
-- END-PURE

local function inChar(i)
 local o=i local d=0
 while o and o~=WS and d<10 do
  if o:IsA("Model") and Players:GetPlayerFromCharacter(o) then return true end
  o=o.Parent d=d+1
 end
 return false
end
local function isTarget(inst,words,modelOnly)
 if not (inst:IsA("Model") or (not modelOnly and inst:IsA("BasePart"))) then return false end
 if not hasWord(inst.Name,words) then return false end
 if inst:IsA("BasePart") and inst.Parent and inst.Parent:IsA("Model") and hasWord(inst.Parent.Name,words) then return false end
 return not inChar(inst)
end
local function primary(i)
 if i:IsA("BasePart") then return i end
 if i:IsA("Model") then return i.PrimaryPart or i:FindFirstChildWhichIsA("BasePart",true) end
end
local function distTo(i)
 local r,p=getRoot(),primary(i)
 if r and p then return math.floor((r.Position-p.Position).Magnitude) end
 return 0
end

---------------- السرعة ----------------
function F.applySpeed() local h=getHum() if h then h.WalkSpeed=S.speed.on and S.speed.val or S.speed.base end end
function F.speed(on)
 if on and not getHum() then return false,"لا توجد شخصية حالياً" end
 S.speed.on=on F.applySpeed()
 if on then return true,"سرعة الحركة "..fmt(S.speed.val).." مفعّلة — هذه حركة الشخصية، لا رقم السرعة في اللعبة","warn" end
 return true,"تم إيقاف سرعة الحركة","info"
end
local function readStat()
 local best
 local function chk(k,v) if not best and type(v)=="number" and string.find(string.lower(k),"speed",1,true) then best={k=k,v=v} end end
 local ls=LP:FindFirstChild("leaderstats")
 if ls then for _,v in ipairs(ls:GetChildren()) do if v:IsA("ValueBase") then chk(v.Name,v.Value) end end end
 for _,v in ipairs(LP:GetChildren()) do if v:IsA("ValueBase") then chk(v.Name,v.Value) end end
 for k,v in pairs(LP:GetAttributes()) do chk(k,v) end
 return best
end

---------------- الواجهة المضيفة ----------------
local host
do
 local gh=ext("gethui")
 if gh then local ok,h=pcall(gh) if ok and h then host=h end end
 if not host then
  local ok=pcall(function() local t=Instance.new("Folder") t.Parent=CG t:Destroy() end)
  host=ok and CG or LP:WaitForChild("PlayerGui")
 end
 for _,p in ipairs({host,LP:FindFirstChild("PlayerGui")}) do
  if p then pcall(function() for _,n in ipairs({CFG.Name,"SARAB_EGG_ESP"}) do local o=p:FindFirstChild(n) if o then o:Destroy() end end end) end
 end
end
local espF=Instance.new("Folder") espF.Name="SARAB_EGG_ESP" espF.Parent=host

---------------- الكشف (بيض / حراس / فخاخ) ----------------
local KIND={
 egg={words=CFG.EggWords,color=Color3.fromRGB(255,214,64),modelOnly=false,ar="البيض"},
 guard={words=CFG.GuardWords,color=Color3.fromRGB(255,85,85),modelOnly=true,ar="الحراس"},
 trap={words=CFG.TrapWords,color=Color3.fromRGB(255,140,40),modelOnly=false,ar="الفخاخ"},
}
local function eggInfo(inst)
 local lines,seen={},{}
 local function put(k,v)
  if type(v)~="number" and type(v)~="string" then return end
  if v=="" then return end
  local ak,kd=arKey(tostring(k))
  local id=ak..tostring(v)
  if seen[id] then return end
  seen[id]=true
  lines[#lines+1]=ak..": "..fmtVal(kd,v)
 end
 for k,v in pairs(inst:GetAttributes()) do put(k,v) end
 local n=0
 for _,d in ipairs(inst:GetDescendants()) do
  n=n+1 if n>70 or #lines>=6 then break end
  if d:IsA("ValueBase") and (d:IsA("StringValue") or d:IsA("NumberValue") or d:IsA("IntValue")) then put(d.Name,d.Value)
  elseif (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text~="" and #d.Text<50 then lines[#lines+1]="• "..trAnimal(d.Text) end
  for k,v in pairs(d:GetAttributes()) do put(k,v) end
 end
 if #lines==0 then return "لا بيانات ظاهرة للعميل" end
 local out={} for i=1,math.min(6,#lines) do out[i]=lines[i] end
 return table.concat(out,"\n")
end
local function labelText(kind,inst)
 if kind=="egg" then return "🥚 بيضة\n"..eggInfo(inst) end
 if kind=="guard" then return "👹 "..trAnimal(inst.Name).."\n"..distTo(inst).." م" end
 return "⚠ فخ — "..distTo(inst).." م"
end
local function rmESP(kind,inst)
 local e=S.esp[kind].map[inst]
 if e then disc(e.c) pcall(function() e.h:Destroy() end) pcall(function() e.b:Destroy() end) S.esp[kind].map[inst]=nil end
end
local function addESP(kind,inst)
 local st=S.esp[kind] if st.map[inst] then return end
 local cnt=0 for _ in pairs(st.map) do cnt=cnt+1 end
 if cnt>=150 then return end
 local p=primary(inst) if not p then return end
 local ok,h,b,l=pcall(function()
  local hh=Instance.new("Highlight") hh.Adornee=inst hh.FillColor=KIND[kind].color hh.OutlineColor=C.white hh.FillTransparency=.6
  hh.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hh.Parent=espF
  local bb=Instance.new("BillboardGui") bb.Adornee=p bb.Size=UDim2.fromOffset(190,80) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.MaxDistance=400 bb.Parent=espF
  local ll=Instance.new("TextLabel") ll.BackgroundTransparency=1 ll.Size=UDim2.fromScale(1,1) ll.Font=Enum.Font.SourceSansBold ll.TextSize=15
  ll.TextColor3=KIND[kind].color ll.TextStrokeTransparency=.3 ll.TextWrapped=true ll.Text=labelText(kind,inst) ll.Parent=bb
  return hh,bb,ll
 end)
 if not ok then return end
 st.map[inst]={h=h,b=b,l=l,c=inst.AncestryChanged:Connect(function() if not inst:IsDescendantOf(game) then rmESP(kind,inst) end end)}
end
local function refreshKind(kind)
 local st=S.esp[kind]
 for i in pairs(st.map) do rmESP(kind,i) end
 disc(st.conn) st.conn=nil
 if not st.on then return end
 local K=KIND[kind]
 for _,d in ipairs(WS:GetDescendants()) do if isTarget(d,K.words,K.modelOnly) then addESP(kind,d) end end
 st.conn=WS.DescendantAdded:Connect(function(d)
  task.delay(.3,function() if alive and st.on and d.Parent and isTarget(d,K.words,K.modelOnly) then addESP(kind,d) end end)
 end)
end
function F.esp(kind,on)
 S.esp[kind].on=on refreshKind(kind)
 local ar=KIND[kind].ar
 if not on then return true,"تم إيقاف كشف "..ar,"info" end
 local n=0 for _ in pairs(S.esp[kind].map) do n=n+1 end
 if n==0 then return true,"لا يوجد «"..ar.."» ظاهر الآن — قد يكون الاسم مختلفاً (استخدم أزرار الاكتشاف)","warn" end
 return true,"تم كشف "..n.." من "..ar,"ok"
end
local function tick()
 for kind,st in pairs(S.esp) do
  if st.on then for inst,e in pairs(st.map) do if e.l and e.l.Parent then e.l.Text=labelText(kind,inst) end end end
 end
 if statVal and statVal.Parent then
  local s=readStat()
  statVal.Text=s and (s.k.." = "..abbr(s.v)) or "غير متاح للعميل"
 end
end

---------------- أدوات الاكتشاف ----------------
local function path(i) local t,o={},i while o and o~=game and #t<7 do table.insert(t,1,o.Name) o=o.Parent end return table.concat(t,".") end
function F.npcNames()
 local c={}
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(d) then c[d.Name]=(c[d.Name] or 0)+1 end
 end
 local l={} for n,k in pairs(c) do l[#l+1]=n.." x"..k end table.sort(l)
 if #l==0 then return false,"لا توجد NPC ظاهرة للعميل الآن","warn" end
 local t=table.concat(l,"\n") print("[SARAB] NPC:\n"..t)
 return true,"وجدت "..#l.." اسماً"..(copyText(t) and " ونُسخت للحافظة" or " (الكونسول F9)"),"ok"
end
function F.trapNames()
 local c={}
 for _,d in ipairs(WS:GetDescendants()) do
  if (d:IsA("Model") or d:IsA("BasePart")) and hasWord(d.Name,CFG.TrapWords) and not inChar(d) then local k=d.Name.." ["..d.ClassName.."]" c[k]=(c[k] or 0)+1 end
 end
 local l={} for n,k in pairs(c) do l[#l+1]=n.." x"..k end table.sort(l)
 if #l==0 then return false,"لا فخاخ ظاهرة بهذه الكلمات الآن (ضع فخاً أو اقترب من واحد)","warn" end
 local t=table.concat(l,"\n") print("[SARAB] فخاخ:\n"..t)
 return true,"وجدت "..#l.." نوعاً"..(copyText(t) and " ونُسخت للحافظة" or " (الكونسول F9)"),"ok"
end
function F.eggSchema()
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 local best,bd
 for _,d in ipairs(WS:GetDescendants()) do
  if isTarget(d,CFG.EggWords,false) then local p=primary(d) if p then local dd=(p.Position-r.Position).Magnitude if not bd or dd<bd then best,bd=d,dd end end end
 end
 if not best then return false,"لا يوجد بيض ظاهر — اقترب من بيضة","warn" end
 local out={"egg: "..path(best).." ["..best.ClassName.."]"}
 for k,v in pairs(best:GetAttributes()) do out[#out+1]=" attr "..k.."="..tostring(v) end
 local n=0
 for _,d in ipairs(best:GetDescendants()) do
  n=n+1 if n>80 then break end
  local s=" "..d.ClassName..": "..d.Name
  if d:IsA("ValueBase") then s=s.." = "..tostring(d.Value) end
  if d:IsA("TextLabel") or d:IsA("TextButton") then s=s.." = '"..d.Text.."'" end
  out[#out+1]=s
  for k,v in pairs(d:GetAttributes()) do out[#out+1]="   attr "..k.."="..tostring(v) end
 end
 local t=table.concat(out,"\n") print("[SARAB] "..t)
 return true,"بيانات أقرب بيضة"..(copyText(t) and " نُسخت للحافظة" or " (الكونسول F9)"),"ok"
end

---------------- الحراس: تجميد محلي (تجريبي) ----------------
local function guardModels()
 local l={}
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsA("Model") and hasWord(d.Name,CFG.GuardWords) and not inChar(d) and d:FindFirstChildOfClass("Humanoid") then l[#l+1]=d end
 end
 return l
end
local function unfreeze()
 for h,v in pairs(S.freeze.saved) do
  pcall(function()
   if h.Parent then
    h.WalkSpeed=v.ws h.JumpPower=v.jp
    local an=h:FindFirstChildOfClass("Animator")
    if an then for _,t in ipairs(an:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end
   end
  end)
 end
 S.freeze.saved={}
end
function F.freeze(on)
 local f=S.freeze
 if not on then f.on=false disc(f.conn) f.conn=nil unfreeze() return true,"تمت إعادة الحراس لحالتهم الأصلية عندك","info" end
 f.list=guardModels()
 if #f.list==0 then return false,"لا يوجد حراس ظاهرون بهذه الأسماء — استخدم «اكتشاف أسماء الحراس»","warn" end
 f.on=true f.acc=0 f.scan=0 disc(f.conn)
 f.conn=RS.Heartbeat:Connect(function(dt)
  f.scan=f.scan+dt f.acc=f.acc+dt
  if f.scan>=3 then f.scan=0 f.list=guardModels() end
  if f.acc<.2 then return end
  f.acc=0
  for _,m in ipairs(f.list) do
   local h=m.Parent and m:FindFirstChildOfClass("Humanoid")
   if h then
    if not f.saved[h] then f.saved[h]={ws=h.WalkSpeed,jp=h.JumpPower} end
    h.WalkSpeed=0 h.JumpPower=0
    local an=h:FindFirstChildOfClass("Animator")
    if an then for _,t in ipairs(an:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end end
    local r=h.RootPart if r then r.AssemblyLinearVelocity=Vector3.zero end
   end
  end
 end)
 return true,"جُمّد "..#f.list.." حارس عندك — قد لا يؤثر على السيرفر، راقب إن توقفوا فعلاً","warn"
end

---------------- الفخاخ: إزالة محلية ----------------
function F.removeTraps()
 local n=0
 for _,d in ipairs(WS:GetDescendants()) do
  if d.Parent and (d:IsA("Model") or d:IsA("BasePart")) and isTarget(d,CFG.TrapWords,false) then
   n=n+1 pcall(function() d:Destroy() end)
  end
 end
 if n==0 then return false,"لا فخاخ ظاهرة الآن","warn" end
 return true,"أُزيل "..n.." فخ من شاشتك فقط — السيرفر قد يظل يفعّلها عليك","warn"
end
function F.trapAuto(on)
 local t=S.trapAuto t.on=on disc(t.conn) t.conn=nil
 if not on then return true,"تم إيقاف الحذف التلقائي","info" end
 t.conn=WS.DescendantAdded:Connect(function(d)
  task.delay(.25,function() if alive and t.on and d.Parent and isTarget(d,CFG.TrapWords,false) then pcall(function() d:Destroy() end) end end)
 end)
 return true,"أي فخ جديد يُحذف من شاشتك تلقائياً (محلي فقط)","warn"
end

---------------- الحماية: منع الترنح والدفع ----------------
local MOVERS={BodyVelocity=1,BodyForce=1,BodyGyro=1,BodyPosition=1,BodyAngularVelocity=1,BodyThrust=1,LinearVelocity=1,VectorForce=1,AngularVelocity=1,AlignPosition=1,AlignOrientation=1,LineForce=1,Torque=1}
local function hookAnti(ch)
 disc(S.anti.hc)
 S.anti.hc=ch.DescendantAdded:Connect(function(d)
  if S.anti.on and MOVERS[d.ClassName] then
   task.defer(function() pcall(function() d:Destroy() end) S.anti.removed=S.anti.removed+1 end)
  end
 end)
end
function F.anti(on)
 local a=S.anti a.on=on disc(a.conn) a.conn=nil
 if not on then return true,"تم إيقاف منع الترنح","info" end
 if getChar() then hookAnti(getChar()) end
 a.conn=RS.Heartbeat:Connect(function()
  local h=getHum() if not h then return end
  local st=h:GetState()
  if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then h:ChangeState(Enum.HumanoidStateType.GettingUp) a.fixed=a.fixed+1 end
  if h.PlatformStand then h.PlatformStand=false end
 end)
 return true,"منع الترنح والدفع مفعّل — لا يمنع إسقاط البيضة إن كان السيرفر هو من يسقطها","warn"
end

---------------- إعادة ظهور الشخصية ----------------
local refreshActive
local function onChar(ch)
 task.spawn(function()
  local h=ch:WaitForChild("Humanoid",10) local r=ch:WaitForChild("HumanoidRootPart",10)
  if not h or not r or not alive then return end
  task.wait(.3)
  if ch~=LP.Character or not alive then return end
  S.speed.base=h.WalkSpeed>0 and h.WalkSpeed or 16
  disc(S.speed.guard)
  S.speed.guard=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if S.speed.on and h.WalkSpeed~=S.speed.val then h.WalkSpeed=S.speed.val end end)
  if S.speed.on then F.applySpeed() end
  if S.anti.on then hookAnti(ch) end
  if refreshActive then refreshActive() end
 end)
end

---------------- واجهة صغيرة: LOTRIX VX ----------------
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
local DW,DH=250,196
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
local closeB=hbtn("✕",6) local hideB=hbtn("—",34)
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

local bar=new("Frame",{Size=UDim2.new(1,-16,0,38),Position=UDim2.new(0,8,1,-44),BackgroundColor3=C.panel},main)
corner(bar,8) stroke(bar,C.gd)
statusLabel=label(bar,"جاهز — محلي على جهازك فقط",12,C.sub,false,Enum.TextXAlignment.Center)
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
local resets={}
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
 resets[#resets+1]=function() on=false paint() end
end

-- 1) منع ضرب الزعماء: تجميد الحراس عندك + منع الترنح والدفع
toggleCard(42,"منع ضرب الزعماء","عند سرقة بيضة الزعيم يواصل نومه دون ملاحقتك",function(on)
 local ok1,m1,k1=F.freeze(on)
 F.anti(on)
 if on and not ok1 then return false,m1,k1 end
 if on then return true,"مفعّل: جُمّد الحراس عندك + منع الترنح — قد لا يؤثر على السيرفر، جرّب بحذر","warn" end
 return true,"تم الإيقاف","info"
end)
-- 2) حذف الفخاخ
toggleCard(102,"حذف الفخاخ","حذف الفخاخ لجعل الإمساك بك مستحيلاً",function(on)
 if on then
  F.trapAuto(true)
  local ok,m,k=F.removeTraps()
  return true,(ok and m or "حذف تلقائي مفعّل — لا فخاخ ظاهرة الآن"),"warn"
 end
 return F.trapAuto(false)
end)

local floatB=new("TextButton",{Size=UDim2.fromOffset(44,44),Position=UDim2.new(0,12,.5,-22),BackgroundColor3=C.g,Text="L",TextSize=24,Font=Enum.Font.GothamBlack,TextColor3=C.bg,Visible=false,AutoButtonColor=false},gui)
corner(floatB,22) stroke(floatB,C.white,2)
hideB.MouseButton1Click:Connect(function() main.Visible=false floatB.Visible=true end)
floatB.MouseButton1Click:Connect(function() main.Visible=true floatB.Visible=false end)

local function cleanup()
 if not alive then return end
 alive=false
 pcall(F.freeze,false) pcall(F.trapAuto,false) pcall(F.anti,false)
 disc(S.anti.hc)
 for _,c in ipairs(conns) do disc(c) end
 pcall(function() espF:Destroy() end)
 pcall(function() gui:Destroy() end)
 ENV._SARAB_EGG_CLEANUP=nil
end
ENV._SARAB_EGG_CLEANUP=cleanup
closeB.MouseButton1Click:Connect(function() notify("تم الإغلاق","info") task.delay(.15,cleanup) end)

refreshActive=function() end
track(LP.CharacterAdded:Connect(onChar))
if LP.Character then onChar(LP.Character) end

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
notify("LOTRIX VX جاهز — محلي فقط","ok")
task.spawn(function() local ok,e=pcall(intro) if not ok then main.Visible=true warn("[LOTRIX] intro: "..tostring(e)) end end)
