--[[ LOTRIX VX — سراب | ORANGE EDITION v4.0 | محلي (Client) لـ Delta ]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local HS=game:GetService("HttpService")
local CG=game:GetService("CoreGui")
local LT=game:GetService("Lighting")
local LP=Players.LocalPlayer
if not LP then return end
local ENV=(getgenv and getgenv()) or _G
local function ext(n) local ok,v=pcall(function() return ENV[n] end) if ok and type(v)=="function" then return v end end
if type(ENV._SARAB_CLEANUP)=="function" then pcall(ENV._SARAB_CLEANUP) end

---------------- الإعدادات ----------------
local CFG={
 Name="LOTRIX_VX",Ver="v4.0",
 Monsters={
  {k="majnoun",n="مجنون حارة",a={"مجنون حارة"}},
  {k="umsaaf",n="أم السعف والليف",a={"أم السعف","ام السعف"}},
  {k="gharzam",n="غرزام",a={"غرزام"}},
  {k="abumutlaq",n="أبو مطلق",a={"أبو مطلق","ابو مطلق"}},
 },
 Locs={
  {k="abdullah",part=1,n="بيت أبو عبدالله",p=Vector3.new(434.06,424.75,-35.63)},
  {k="garden",part=1,n="حديقة مجنون حارة",p=Vector3.new(298.68,422.78,-187.09)},
  {k="safa",part=1,n="بقالة صفا",p=Vector3.new(-152.93,423.81,-304.07)},
  {k="school",part=2,n="المدرسة"},
  {k="desert",part=3,n="الصحراء والبحث عن السحر المدفون"},
 },
 Items1={
  {k="milk",n="لبن",p=Vector3.new(335.76,434.49,-2352.34)},
  {k="water",n="كرتونة مياه",p=Vector3.new(261.30,424.59,-2350.44)},
  {k="rice",n="خيشة أرز",p=Vector3.new(258.31,423.96,-2202.29)},
  {k="ledger",n="دفتر الديون",p=Vector3.new(419.68,425.04,-2259.93)},
 },
 CatAliases={"قطة","قطه","قط","cat","kitten"},
 -- أسماء من أدلة الويب (إنجليزية) — غير مؤكدة داخل اللعبة. عدّلها بعد «اكتشاف الأغراض»
 P2={"scissors","voicerecorder","battery","rustykey","key","chemical","uvflashlight","flashlight"},
 P3={"smolderingrock","rock","shovel","hay","food","bottle"},
}

---------------- الحالة ----------------
local S={speed={on=false,mult=2,base=16},fly={on=false,speed=60,hover=false,up=false,down=false},
 noclip={on=false,saved=setmetatable({},{__mode="k"})},god={on=false},
 esp={en={},any=false,map={}},aim={on=false},night={on=false,fx={}},busy=false}
local alive,conns,UI,F=true,{},{},{}
local statusLabel
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

-- حفظ المواقع (اختياري)
local SAVE="SarabScript_Locations.json"
local saved={}
do
 local rf,isf=ext("readfile"),ext("isfile")
 if rf and isf then
  local ok,d=pcall(function() if isf(SAVE) then return HS:JSONDecode(rf(SAVE)) end end)
  if ok and type(d)=="table" then saved=d end
 end
end
local function locPos(l)
 local s=saved[l.k]
 if type(s)=="table" and type(s.x)=="number" and type(s.y)=="number" and type(s.z)=="number" then return Vector3.new(s.x,s.y,s.z) end
 return l.p
end

---------------- الحركة ----------------
function F.applySpeed() local h=getHum() if h then h.WalkSpeed=S.speed.on and S.speed.base*S.speed.mult or S.speed.base end end
function F.speed(on)
 if on and not getHum() then return false,"لا توجد شخصية حالياً" end
 S.speed.on=on F.applySpeed()
 if on then return true,"السرعة x"..fmt(S.speed.mult).." مفعّلة (محلياً)","ok" end
 return true,"تم إيقاف السرعة","info"
end

local controls,ctlFail=nil,-100
local function getMove(h,cam)
 if not controls and os.clock()-ctlFail>5 then
  pcall(function() controls=require(LP.PlayerScripts:FindFirstChild("PlayerModule")):GetControls() end)
  if not controls then ctlFail=os.clock() end
 end
 if controls then
  local ok,v=pcall(function() return controls:GetMoveVector() end)
  if ok and typeof(v)=="Vector3" then return v end
 end
 local md,l,r=h.MoveDirection,cam.CFrame.LookVector,cam.CFrame.RightVector
 l=Vector3.new(l.X,0,l.Z) r=Vector3.new(r.X,0,r.Z)
 if l.Magnitude>0.01 then l=l.Unit end
 if r.Magnitude>0.01 then r=r.Unit end
 return Vector3.new(md:Dot(r),0,-md:Dot(l))
end
local function killFly() local f=S.fly for _,k in ipairs({"lv","ao","att"}) do if f[k] then pcall(function() f[k]:Destroy() end) f[k]=nil end end end
local function buildFly()
 local root,h=getRoot(),getHum()
 if not root or not h then return false,"لا توجد شخصية صالحة للطيران" end
 killFly()
 local ok,err=pcall(function()
  local at=Instance.new("Attachment") at.Name="SARAB_Att" at.Parent=root
  local lv=Instance.new("LinearVelocity") lv.Name="SARAB_LV" lv.Attachment0=at lv.RelativeTo=Enum.ActuatorRelativeTo.World lv.MaxForce=1e9 lv.VectorVelocity=Vector3.zero lv.Parent=root
  local ao=Instance.new("AlignOrientation") ao.Name="SARAB_AO" ao.Mode=Enum.OrientationAlignmentMode.OneAttachment ao.Attachment0=at ao.MaxTorque=1e9 ao.Responsiveness=30 ao.CFrame=root.CFrame.Rotation ao.Parent=root
  S.fly.att,S.fly.lv,S.fly.ao=at,lv,ao
 end)
 if not ok then killFly() return false,"تعذر إنشاء عناصر الطيران: "..tostring(err) end
 S.fly.prev=h.PlatformStand h.PlatformStand=true
 return true
end
local function flyStep()
 local f=S.fly local root,h,cam=getRoot(),getHum(),WS.CurrentCamera
 if not f.on or not root or not h or not cam or not f.lv or not f.lv.Parent then return end
 local v=Vector3.zero
 if not f.hover then
  local m=getMove(h,cam)
  v=(cam.CFrame.LookVector*(-m.Z)+cam.CFrame.RightVector*m.X)*f.speed
  if f.up then v=v+Vector3.new(0,f.speed,0) end
  if f.down then v=v-Vector3.new(0,f.speed,0) end
 end
 f.lv.VectorVelocity=v
 local lk=cam.CFrame.LookVector lk=Vector3.new(lk.X,0,lk.Z)
 if f.ao and lk.Magnitude>0.01 then f.ao.CFrame=CFrame.lookAt(Vector3.zero,lk) end
end
function F.fly(on)
 local f=S.fly
 if on then
  local ok,e=buildFly() if not ok then return false,e end
  f.on=true disc(f.conn) f.conn=RS.Heartbeat:Connect(flyStep)
  return true,"الطيران يعمل — العصا والكاميرا تحددان الاتجاه","ok"
 end
 f.on,f.up,f.down,f.hover=false,false,false,false
 if UI.hover then UI.hover.set(false) end
 disc(f.conn) f.conn=nil killFly()
 local h,r=getHum(),getRoot()
 if h then h.PlatformStand=f.prev or false end
 if r then r.AssemblyLinearVelocity=Vector3.zero end
 return true,"تم إيقاف الطيران","info"
end

local function ncStep()
 local c=getChar() if not c then return end
 for _,p in ipairs(c:GetDescendants()) do
  if p:IsA("BasePart") then
   if S.noclip.saved[p]==nil then S.noclip.saved[p]=p.CanCollide end
   if p.CanCollide then p.CanCollide=false end
  end
 end
end
local function restoreCol()
 for p,v in pairs(S.noclip.saved) do if p and p.Parent then pcall(function() p.CanCollide=v end) end end
 S.noclip.saved=setmetatable({},{__mode="k"})
end
function F.noclip(on)
 if on then
  if not getChar() then return false,"لا توجد شخصية حالياً" end
  S.noclip.on=true disc(S.noclip.conn) S.noclip.conn=RS.Stepped:Connect(ncStep)
  return true,"اختراق التصادم مفعّل — قد تسقط خارج الخريطة","ok"
 end
 S.noclip.on=false disc(S.noclip.conn) S.noclip.conn=nil restoreCol()
 return true,"تمت استعادة التصادم الأصلي","info"
end

---------------- الحماية ----------------
local godC={}
local function bindGod(h)
 for _,c in ipairs(godC) do disc(c) end godC={}
 if not h then return end
 godC[1]=h.HealthChanged:Connect(function(v) if S.god.on and v>0 and v<h.MaxHealth then pcall(function() h.Health=h.MaxHealth end) end end)
 godC[2]=h.Died:Connect(function() if S.god.on then notify("ماتت الشخصية رغم التفعيل — الخادم هو من يتحكم بالصحة","err") end end)
end
function F.god(on)
 S.god.on=on
 if on then bindGod(getHum()) return true,"حماية محلية فقط: تعيد الصحة عندك ولا تمنع قتل الخادم لك","warn" end
 return true,"تم إيقاف عدم الموت","info"
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
  if p then pcall(function()
   for _,n in ipairs({CFG.Name,"SARAB_ESP"}) do local o=p:FindFirstChild(n) if o then o:Destroy() end end
  end) end
 end
end
local espF=Instance.new("Folder") espF.Name="SARAB_ESP" espF.Parent=host

---------------- كشف الوحوش ----------------
local function isNPC(m) return m:IsA("Model") and m:FindFirstChildOfClass("Humanoid")~=nil and Players:GetPlayerFromCharacter(m)==nil end
local function monKey(m) for _,x in ipairs(CFG.Monsters) do for _,a in ipairs(x.a) do if string.find(m.Name,a,1,true) then return x.k end end end end
local function rmHL(m) local e=S.esp.map[m] if e then disc(e.c) pcall(function() e.h:Destroy() end) S.esp.map[m]=nil end end
local function addHL(m,key,col)
 if S.esp.map[m] then return end
 local ok,h=pcall(function()
  local x=Instance.new("Highlight") x.Adornee=m x.FillColor=col x.OutlineColor=C.white x.FillTransparency=.55
  x.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop x.Parent=espF return x
 end)
 if not ok then return end
 S.esp.map[m]={h=h,k=key,c=m.AncestryChanged:Connect(function() if not m:IsDescendantOf(game) then rmHL(m) end end)}
end
local function consider(i)
 if not i:IsA("Model") or Players:GetPlayerFromCharacter(i) then return end
 local k=monKey(i)
 if k and S.esp.en[k] then addHL(i,k,C.g2) elseif S.esp.any and isNPC(i) then addHL(i,"npc",C.sub) end
end
local function cntESP(k) local n=0 for _,e in pairs(S.esp.map) do if k==nil or e.k==k then n=n+1 end end return n end
local function refreshESP()
 for m in pairs(S.esp.map) do rmHL(m) end
 disc(S.esp.conn) S.esp.conn=nil
 local on=S.esp.any for _,v in pairs(S.esp.en) do if v then on=true end end
 if not on then return end
 for _,d in ipairs(WS:GetDescendants()) do if d:IsA("Model") then consider(d) end end
 S.esp.conn=WS.DescendantAdded:Connect(function(d) if d:IsA("Model") then task.delay(.3,function() if alive and d.Parent then consider(d) end end) end end)
end
function F.esp(key,on,name)
 S.esp.en[key]=on or nil refreshESP()
 if not on then return true,"تم إيقاف كشف "..name,"info" end
 local n=cntESP(key)
 if n==0 then return true,"لا يوجد «"..name.."» ظاهر للعميل الآن — قد يكون الاسم مختلفاً","warn" end
 return true,"تم كشف "..n.." من «"..name.."»","ok"
end
function F.espAny(on)
 S.esp.any=on refreshESP()
 if not on then return true,"تم إيقاف كشف الـ NPC","info" end
 return true,"تم كشف "..cntESP(nil).." كائن (NPC)","ok"
end
function F.npcNames()
 local c={} for _,d in ipairs(WS:GetDescendants()) do if isNPC(d) then c[d.Name]=(c[d.Name] or 0)+1 end end
 local l={} for n,k in pairs(c) do l[#l+1]=n.." x"..k end table.sort(l)
 if #l==0 then return false,"لا توجد NPC ظاهرة للعميل الآن","warn" end
 local t=table.concat(l,"\n") print("[SARAB] NPC:\n"..t)
 return true,"وجدت "..#l.." اسماً"..(copyText(t) and " ونُسخت للحافظة" or " (الكونسول F9)"),"ok"
end

---------------- التنقل ----------------
function F.tp(l)
 local pos=locPos(l)
 if not pos then return false,"«"..l.n.."» غير محدد — قف فيه واضغط «حفظ هنا»" end
 local ch,r=getChar(),getRoot()
 if not ch or not r then return false,"لا توجد شخصية حالياً" end
 local ok,e=pcall(function() ch:PivotTo(CFrame.new(pos+Vector3.new(0,3,0))) r.AssemblyLinearVelocity=Vector3.zero end)
 if not ok then return false,"فشل الانتقال: "..tostring(e) end
 task.delay(.7,function() local r2=getRoot() if alive and r2 and (r2.Position-pos).Magnitude>30 then notify("الخادم أعادك — الانتقال غير مقبول هنا","err") end end)
 return true,"تم الانتقال إلى "..l.n,"ok"
end
function F.saveHere(l)
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 local p=r.Position saved[l.k]={x=p.X,y=p.Y,z=p.Z}
 local wf=ext("writefile") local pk=wf and pcall(wf,SAVE,HS:JSONEncode(saved))
 return true,"حُفظ موقع «"..l.n.."»"..(pk and " (في ملف)" or " (للجلسة)"),"ok"
end

---------------- الأغراض ----------------
local function ipos(i)
 if i:IsA("BasePart") then return i.Position end
 if i:IsA("Model") then local ok,cf=pcall(function() return i:GetPivot() end) if ok then return cf.Position end end
 if i:IsA("Tool") then local h=i:FindFirstChild("Handle") if h then return h.Position end end
end
local function fire(d,root)
 if d:IsA("ProximityPrompt") then local f=ext("fireproximityprompt") if f then pcall(f,d) return true end
 elseif d:IsA("ClickDetector") then local f=ext("fireclickdetector") if f then pcall(f,d) return true end
 else
  local f=ext("firetouchinterest") local part=d:IsA("BasePart") and d or d:FindFirstChild("Handle") or d:FindFirstChildWhichIsA("BasePart",true)
  if f and part and root then pcall(function() f(root,part,0) task.wait() f(root,part,1) end) return true end
 end
 return false
end
local function bpCount() local b=LP:FindFirstChildOfClass("Backpack") return b and #b:GetChildren() or 0 end
-- جمع غرض بإحداثيات: ينتقل، يبحث عن أقرب تفاعل، يفعّله، ثم يعود
function F.collectAt(it)
 if S.busy then return false,"عملية جمع قيد التنفيذ" end
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 S.busy=true
 local origin,before=r.CFrame,bpCount()
 r.CFrame=CFrame.new(it.p+Vector3.new(0,3,0)) r.AssemblyLinearVelocity=Vector3.zero
 task.wait(.5)
 local best,bd
 local ok,parts=pcall(function() return WS:GetPartBoundsInRadius(it.p,28) end)
 for _,p in ipairs(ok and parts or {}) do
  for _,o in ipairs({p,p.Parent}) do
   if o and o~=WS then
    local d=o:IsA("ProximityPrompt") and o or o:FindFirstChildWhichIsA("ProximityPrompt",true) or o:FindFirstChildWhichIsA("ClickDetector",true) or (o:IsA("Tool") and o)
    if d then local dd=(p.Position-it.p).Magnitude if not bd or dd<bd then best,bd=d,dd end end
   end
  end
 end
 local fired=best and fire(best,getRoot()) or false
 task.wait(.6)
 local r2=getRoot() if r2 then r2.CFrame=origin end
 S.busy=false
 if not best then return false,"«"..it.n.."»: لا يوجد عنصر تفاعلي قرب الإحداثيات (قد يكون الغرض أُخذ أو تغيّر مكانه)","warn" end
 if not fired then return false,"«"..it.n.."»: وُجد عنصر لكن المنفّذ لا يدعم تفعيله","warn" end
 if bpCount()>before then return true,"«"..it.n.."»: تمت إضافة غرض للحقيبة","ok" end
 return true,"«"..it.n.."»: فُعّل التفاعل — لم تتغير الحقيبة (الخادم لم يؤكد)","warn"
end
function F.collectAll1()
 local ok1=0
 for _,it in ipairs(CFG.Items1) do
  if it.k~="ledger" then local ok,m,k=F.collectAt(it) notify(m,k) if ok then ok1=ok1+1 end task.wait(.4) end
 end
 return true,"انتهت محاولة جمع اللبن والمياه والأرز ("..ok1.." من 3) — الدفتر عند القطة بشكل منفصل","info"
end
-- جمع بالأسماء (الجزء 2 و3)
function F.collectNames(list,label)
 if S.busy then return false,"عملية جمع قيد التنفيذ" end
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 local T={}
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
   local o=d.Parent local nm=string.lower((o and o.Name or "")..((o and o.Parent) and o.Parent.Name or "")):gsub("%s","")
   for _,w in ipairs(list) do if string.find(nm,w,1,true) then T[#T+1]={d=d,o=o} break end end
  end
 end
 if #T==0 then return false,label..": لا توجد أغراض بهذه الأسماء — استخدم «اكتشاف الأغراض القريبة» ثم عدّل CFG","warn" end
 S.busy=true local origin,before,n=r.CFrame,bpCount(),0
 for _,t in ipairs(T) do
  local rr=getRoot() if not rr or not alive then break end
  local p=t.o and ipos(t.o) if p then rr.CFrame=CFrame.new(p+Vector3.new(0,3,0)) task.wait(.15) end
  if fire(t.d,rr) then n=n+1 task.wait(.2) end
 end
 local r2=getRoot() if r2 then r2.CFrame=origin end
 task.wait(.4) S.busy=false
 local g=math.max(0,bpCount()-before)
 return true,label..": فُعّل "..n.." من "..#T.." — الجديد في الحقيبة: "..g,(g>0) and "ok" or "warn"
end
function F.discoverItems()
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 local names={}
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") or d:IsA("Tool") then
   local o=d:IsA("Tool") and d or d.Parent
   local p=o and ipos(o)
   if p and (p-r.Position).Magnitude<=80 then names[o.Name]=d.ClassName end
  end
 end
 local l={} for n,c in pairs(names) do l[#l+1]=n.." ["..c.."]" end table.sort(l)
 if #l==0 then return false,"لا أغراض تفاعلية ضمن 80 وحدة حولك","warn" end
 local t=table.concat(l,"\n") print("[SARAB] أغراض:\n"..t)
 return true,"وجدت "..#l.." عنصراً"..(copyText(t) and " ونُسخت للحافظة" or " (الكونسول F9)"),"ok"
end

---------------- تثبيت الكاميرا على القطة ----------------
local function findCat()
 local best,bd
 for _,d in ipairs(WS:GetDescendants()) do
  if isNPC(d) then
   local nm=string.lower(d.Name)
   for _,a in ipairs(CFG.CatAliases) do
    if string.find(nm,string.lower(a),1,true) then
     local p=ipos(d) local dd=p and (p-CFG.Items1[4].p).Magnitude or 1e9
     if not bd or dd<bd then best,bd=d,dd end break
    end
   end
  end
 end
 if best then return best,"name" end
 for _,d in ipairs(WS:GetDescendants()) do
  if isNPC(d) then
   local p=ipos(d) if p then local dd=(p-CFG.Items1[4].p).Magnitude if dd<120 and (not bd or dd<bd) then best,bd=d,dd end end
  end
 end
 return best,"near"
end
local function aimPoint(m)
 local h=m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
 return h and h.Position
end
function F.aim(on)
 if not on then S.aim.on=false pcall(function() RS:UnbindFromRenderStep("SARAB_AIM") end) return true,"تم إيقاف تثبيت الكاميرا","info" end
 local m,how=findCat()
 if not m then return false,"لم أجد القطة — قف قرب مكانها (419.68, 425.04, -2259.93) أو أضف اسمها في CFG.CatAliases" end
 S.aim.on=true S.aim.m=m
 pcall(function() RS:UnbindFromRenderStep("SARAB_AIM") end)
 RS:BindToRenderStep("SARAB_AIM",Enum.RenderPriority.Camera.Value+1,function()
  local cam=WS.CurrentCamera local mm=S.aim.m
  if not S.aim.on or not cam then return end
  if not mm or not mm.Parent then
   local n=findCat() if n then S.aim.m=n end return
  end
  local p=aimPoint(mm)
  if p then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,p) end
 end)
 return true,(how=="name" and "تثبيت الكاميرا على: " or "لم أجد اسم قطة؛ ثبّتّ على أقرب كائن: ")..m.Name,(how=="name") and "ok" or "warn"
end

---------------- الرؤية الليلية ----------------
local NV=S.night
local function nvSet(o,prop,val)
 local t=NV.fx[o] if not t then t={} NV.fx[o]=t end
 if t[prop]==nil then t[prop]=o[prop] end
 pcall(function() o[prop]=val end)
end
local NV_FLOOR=78 -- حد أدنى لإضاءة المحيط فقط (يرفع الأماكن المظلمة جداً ولا يلمس أي مصباح)
local function nvApply()
 local o=NV.fx[LT] and NV.fx[LT].Ambient or LT.Ambient
 local oo=NV.fx[LT] and NV.fx[LT].OutdoorAmbient or LT.OutdoorAmbient
 local f=NV_FLOOR/255
 nvSet(LT,"Ambient",Color3.new(math.max(o.R,f),math.max(o.G,f),math.max(o.B,f)))
 nvSet(LT,"OutdoorAmbient",Color3.new(math.max(oo.R,f),math.max(oo.G,f),math.max(oo.B,f)))
 nvSet(LT,"FogStart",1e6) nvSet(LT,"FogEnd",1e6)
 for _,o2 in ipairs(LT:GetChildren()) do
  if o2:IsA("Atmosphere") then nvSet(o2,"Density",0) nvSet(o2,"Haze",0) nvSet(o2,"Glare",0)
  elseif o2:IsA("BlurEffect") or o2:IsA("DepthOfFieldEffect") then nvSet(o2,"Enabled",false) end
 end
end
function F.night(on)
 if on then
  NV.on=true nvApply() disc(NV.conn) NV.acc=0
  NV.conn=RS.Heartbeat:Connect(function(dt) NV.acc=NV.acc+dt if NV.acc>=.3 then NV.acc=0 nvApply() end end)
  return true,"أُزيل الضباب ورُفع الظلام الشديد فقط — لم تُزَد إضاءة المصابيح (عندك فقط)","ok"
 end
 NV.on=false disc(NV.conn) NV.conn=nil
 for o,t in pairs(NV.fx) do for p,v in pairs(t) do pcall(function() o[p]=v end) end end
 NV.fx={}
 return true,"تمت استعادة إضاءة وضباب اللعبة الأصلية","info"
end

---------------- مهمة المدرسة: إيقاف السنابير (4 صمامات) ----------------
-- حسب أدلة الويب: 4 صمامات يدوية في حمامات الطابق الثاني (ممر مغمور بالمياه)، إغلاقها يُصرّف الماء.
local FW_EN={"faucet","valve","tap"}
local FW_AR={"صنبور","سنبور","سنابير","حنفية","حنفيه","محبس","صمام"}
local FAUCET_COUNT=4
local function isFaucet(d)
 local o=d.Parent
 local o2=o and o.Parent
 local s=string.lower((o and o.Name or "").." "..(o2 and o2.Name or "").." "..((o2 and o2.Parent) and o2.Parent.Name or "").." "..(d:IsA("ProximityPrompt") and (d.ObjectText.." "..d.ActionText) or ""))
 for _,w in ipairs(FW_EN) do if string.find(s,"%f[%a]"..w.."%f[%A]") then return true end end
 for _,w in ipairs(FW_AR) do if string.find(s,w,1,true) then return true end end
 return false
end
local function schoolCenter()
 for _,l in ipairs(CFG.Locs) do if l.k=="school" then return locPos(l) end end
end
function F.faucets()
 if S.busy then return false,"عملية قيد التنفيذ" end
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 local T={}
 for _,d in ipairs(WS:GetDescendants()) do
  if (d:IsA("ProximityPrompt") or d:IsA("ClickDetector")) and isFaucet(d) then
   local p=d.Parent and ipos(d.Parent)
   if p then
    local dup=false
    for _,t in ipairs(T) do if (t.p-p).Magnitude<4 then dup=true break end end
    if not dup then T[#T+1]={d=d,o=d.Parent,p=p} end
   end
  end
 end
 if #T==0 then return false,"لم أجد صمامات تفاعلية — اقترب من حمامات الطابق الثاني واضغط «اكتشاف الأغراض القريبة» وأرسل لي الأسماء","warn" end
 local c=schoolCenter() or r.Position
 table.sort(T,function(a,b) return (a.p-c).Magnitude<(b.p-c).Magnitude end)
 local found=#T
 while #T>FAUCET_COUNT do table.remove(T) end
 S.busy=true
 local origin,n=r.CFrame,0
 pcall(function()
  for i,t in ipairs(T) do
   if not alive then break end
   local rr=getRoot() if not rr then break end
   rr.CFrame=CFrame.new(t.p+Vector3.new(0,3,0)) rr.AssemblyLinearVelocity=Vector3.zero task.wait(.3)
   if fire(t.d,rr) then n=n+1 end
   notify("إيقاف السنابير: "..i.."/"..#T,"info")
   task.wait(.4)
  end
 end)
 local r2=getRoot() if r2 then r2.CFrame=origin end
 S.busy=false
 if n==0 then return false,"وجدت "..found.." عنصراً لكن المنفّذ لا يدعم تفعيلها","warn" end
 local extra=found>FAUCET_COUNT and (" (اخترت أقرب "..FAUCET_COUNT.." من "..found..")") or ""
 if #T<FAUCET_COUNT then extra=extra.." — وجدت "..#T.." فقط من 4، اقترب من الباقي" end
 return true,"فُعّل "..n.." من "..#T.." صمامات"..extra.." — تأكد داخل اللعبة أن الماء بدأ ينزل","warn"
end

---------------- إعادة ظهور الشخصية ----------------
local refreshActive
local function onChar(ch)
 task.spawn(function()
  local h=ch:WaitForChild("Humanoid",10) local r=ch:WaitForChild("HumanoidRootPart",10)
  if not h or not r or not alive then return end
  S.noclip.saved=setmetatable({},{__mode="k"})
  S.fly.lv,S.fly.ao,S.fly.att=nil,nil,nil S.fly.up,S.fly.down=false,false
  task.wait(.3)
  if ch~=LP.Character or not alive then return end
  S.speed.base=h.WalkSpeed>0 and h.WalkSpeed or 16
  disc(S.speed.guard)
  S.speed.guard=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if S.speed.on and h.WalkSpeed~=S.speed.base*S.speed.mult then h.WalkSpeed=S.speed.base*S.speed.mult end end)
  if S.speed.on then F.applySpeed() end
  bindGod(h)
  if S.fly.on then
   local ok,e=buildFly()
   if not ok then S.fly.on=false disc(S.fly.conn) if UI.fly then UI.fly.set(false) end notify("تعذر استئناف الطيران: "..tostring(e),"err") end
  end
  if refreshActive then refreshActive() end
 end)
end

---------------- بناء الواجهة ----------------
local FONT,RIGHT,CENTER=Enum.Font.SourceSansBold,Enum.TextXAlignment.Right,Enum.TextXAlignment.Center
local DW,DH=600,340
local function new(cl,pr)
 local o=Instance.new(cl) local par
 for k,v in pairs(pr) do if k=="Parent" then par=v else o[k]=v end end
 if par then o.Parent=par end return o
end
local function corner(o,r) return new("UICorner",{CornerRadius=UDim.new(0,r),Parent=o}) end
local function stroke(o,c,t,tr) return new("UIStroke",{Color=c,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=o}) end
local function label(par,t,pr)
 local l=new("TextLabel",{BackgroundTransparency=1,Text=t,Font=FONT,TextColor3=C.text,TextSize=15,TextXAlignment=RIGHT,Parent=par})
 for k,v in pairs(pr or {}) do l[k]=v end return l
end

local gui=new("ScreenGui",{Name=CFG.Name,ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999})
gui.Parent=host
local main=new("Frame",{Name="Main",Size=UDim2.fromOffset(DW,DH),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false,Parent=gui})
corner(main,12) stroke(main,C.g,2,.05)
new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(44,19,4),Color3.fromRGB(8,7,6)),Rotation=90,Parent=main})
local uiScale=new("UIScale",{Parent=main})
corner(new("Frame",{Size=UDim2.fromOffset(150,150),Position=UDim2.new(.5,-40,0,-50),BackgroundColor3=C.g,BackgroundTransparency=.9,BorderSizePixel=0,Parent=main}),75)

local sidebar=new("Frame",{Size=UDim2.fromOffset(120,324),Position=UDim2.fromOffset(8,8),BackgroundColor3=C.panel,BackgroundTransparency=.1,BorderSizePixel=0,Parent=main})
corner(sidebar,10) stroke(sidebar,C.gd,1,.3)
new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,Parent=sidebar})
new("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),Parent=sidebar})

local header=new("Frame",{Size=UDim2.fromOffset(326,32),Position=UDim2.fromOffset(134,8),BackgroundColor3=C.panel,BackgroundTransparency=.1,BorderSizePixel=0,Parent=main})
corner(header,8) stroke(header,C.gd,1,.3)
label(header,"♛",{Size=UDim2.fromOffset(24,32),Position=UDim2.new(1,-30,0,0),TextColor3=C.g,TextSize=20,TextXAlignment=CENTER})
local titleLabel=label(header,"الرئيسية",{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(1,-36,0,0),AnchorPoint=Vector2.new(1,0),TextColor3=C.g,TextSize=17})
label(header,"⠿ اسحب",{Size=UDim2.fromOffset(60,32),Position=UDim2.fromOffset(6,0),TextSize=11,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left})
local content=new("Frame",{Size=UDim2.fromOffset(326,254),Position=UDim2.fromOffset(134,46),BackgroundTransparency=1,ClipsDescendants=true,Parent=main})
local sbar=new("Frame",{Size=UDim2.fromOffset(326,28),Position=UDim2.fromOffset(134,304),BackgroundColor3=C.panel,BackgroundTransparency=.1,BorderSizePixel=0,Parent=main})
corner(sbar,8) stroke(sbar,C.gd,1,.3)
statusLabel=label(sbar,"جاهز — اختر قسماً من القائمة",{Size=UDim2.new(1,-16,1,-4),Position=UDim2.fromOffset(8,2),TextScaled=true,TextColor3=C.sub})
new("UITextSizeConstraint",{MaxTextSize=14,MinTextSize=8,Parent=statusLabel})

local info=new("Frame",{Size=UDim2.fromOffset(126,324),Position=UDim2.fromOffset(466,8),BackgroundColor3=C.panel,BackgroundTransparency=.1,BorderSizePixel=0,Parent=main})
corner(info,10) stroke(info,C.gd,1,.3)
local ring=new("Frame",{Size=UDim2.fromOffset(62,62),AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,10),BackgroundColor3=Color3.fromRGB(32,15,4),BorderSizePixel=0,Parent=info})
corner(ring,31) stroke(ring,C.g,2,0)
label(ring,"L",{Size=UDim2.fromScale(1,1),Font=Enum.Font.GothamBlack,TextSize=38,TextColor3=C.g,TextXAlignment=CENTER})
label(info,"LOTRIX",{Size=UDim2.new(1,0,0,20),Position=UDim2.fromOffset(0,76),Font=Enum.Font.GothamBlack,TextSize=18,TextColor3=C.white,TextXAlignment=CENTER})
label(info,"V   X",{Size=UDim2.new(1,0,0,12),Position=UDim2.fromOffset(0,96),Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.g,TextXAlignment=CENTER})
label(info,"ORANGE EDITION",{Size=UDim2.new(1,0,0,12),Position=UDim2.fromOffset(0,109),Font=Enum.Font.GothamBold,TextSize=8,TextColor3=C.sub,TextXAlignment=CENTER})
local function infoRow(y,k,v,vc)
 local r=new("Frame",{Size=UDim2.new(1,-12,0,28),Position=UDim2.fromOffset(6,y),BackgroundColor3=C.card,BorderSizePixel=0,Parent=info})
 corner(r,7) stroke(r,C.gd,1,.5)
 label(r,k,{Size=UDim2.new(.5,-4,1,0),Position=UDim2.new(1,-6,0,0),AnchorPoint=Vector2.new(1,0),TextSize=13})
 return label(r,v,{Size=UDim2.new(.5,-4,1,0),Position=UDim2.fromOffset(6,0),TextSize=12,TextColor3=vc or C.text,TextXAlignment=Enum.TextXAlignment.Left})
end
infoRow(130,"الحالة","يعمل",C.g2) infoRow(162,"الإصدار",CFG.Ver,C.text)
local activeValue=infoRow(194,"النشطة","0",C.amber)

-- تأثير الضغط: تصغير مرن + وميض أخضر
local function fx(b)
 local sc=new("UIScale",{Parent=b})
 local ov=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.g,BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=3,Parent=b})
 corner(ov,8)
 local function up() TS:Create(sc,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play() end
 track(b.MouseButton1Down:Connect(function() TS:Create(sc,TweenInfo.new(.07),{Scale=.93}):Play() end))
 track(b.MouseButton1Up:Connect(up)) track(b.MouseLeave:Connect(up))
 track(b.MouseButton1Click:Connect(function() ov.BackgroundTransparency=.55 TS:Create(ov,TweenInfo.new(.4),{BackgroundTransparency=1}):Play() end))
end

local hideBtn=new("TextButton",{Size=UDim2.new(1,-12,0,38),Position=UDim2.fromOffset(6,232),BackgroundColor3=C.gd,AutoButtonColor=false,Text="",BorderSizePixel=0,Parent=info})
corner(hideBtn,8) stroke(hideBtn,C.g,1,.2) fx(hideBtn)
label(hideBtn,"إخفاء القائمة",{Size=UDim2.fromScale(1,1),TextXAlignment=CENTER,TextSize=15})
label(info,"♛  LOTRIX VX",{Size=UDim2.new(1,0,0,30),Position=UDim2.fromOffset(0,282),TextSize=12,TextColor3=C.g,TextXAlignment=CENTER})
local closeBtn=new("TextButton",{Size=UDim2.fromOffset(34,34),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(1,-4,0,4),BackgroundColor3=Color3.fromRGB(30,14,4),AutoButtonColor=false,Text="✕",Font=Enum.Font.GothamBlack,TextSize=18,TextColor3=C.g,BorderSizePixel=0,ZIndex=5,Parent=main})
corner(closeBtn,8) stroke(closeBtn,C.g,2,0) fx(closeBtn)
local floatBtn=new("TextButton",{Size=UDim2.fromOffset(52,52),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,44,.5,0),BackgroundColor3=C.g,AutoButtonColor=false,Text="L",Font=Enum.Font.GothamBlack,TextSize=28,TextColor3=C.bg,BorderSizePixel=0,Visible=false,ZIndex=10,Parent=gui})
corner(floatBtn,26) stroke(floatBtn,C.white,2,.4) fx(floatBtn)

local userScale=1
local function updScale()
 local v=gui.AbsoluteSize if v.X<=0 or v.Y<=0 then return end
 uiScale.Scale=math.clamp(math.min(v.X*.75/DW,v.Y*.75/DH)*userScale,.35,4)
end
track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updScale)) updScale()

local function draggable(handle,target,onTap)
 local st
 track(handle.InputBegan:Connect(function(i)
  local t=i.UserInputType
  if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
   st={input=i,start=i.Position,center=target.AbsolutePosition+target.AbsoluteSize*target.AnchorPoint,moved=false}
   local c c=i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then c:Disconnect() local s=st st=nil if s and not s.moved and onTap then onTap() end end
   end)
  end
 end))
 track(UIS.InputChanged:Connect(function(i)
  if st and (i==st.input or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-st.start
   if d.Magnitude>8 then st.moved=true end
   if st.moved then local v=gui.AbsoluteSize target.Position=UDim2.fromOffset(math.clamp(st.center.X+d.X,0,v.X),math.clamp(st.center.Y+d.Y,0,v.Y)) end
  end
 end))
end

---------------- مكوّنات الصفحات ----------------
local pages,orders={},{}
local function nxt(p) orders[p]=(orders[p] or 0)+1 return orders[p] end
local function newPage(id)
 local sf=new("ScrollingFrame",{Name=id,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.g,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=content})
 new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=sf})
 new("UIPadding",{PaddingRight=UDim.new(0,6),PaddingLeft=UDim.new(0,2),PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,8),Parent=sf})
 pages[id]=sf return sf
end
local function newRow(p,h) return new("Frame",{Size=UDim2.new(1,0,0,h or 46),BackgroundTransparency=1,LayoutOrder=nxt(p),Parent=p}) end
local function baseCard(row,slot,count,asBtn)
 local sz,ps,an
 if count==1 then sz,ps,an=UDim2.new(1,0,1,0),UDim2.new(),Vector2.zero
 elseif slot==1 then sz,ps,an=UDim2.new(.5,-3,1,0),UDim2.new(1,0,0,0),Vector2.new(1,0)
 else sz,ps,an=UDim2.new(.5,-3,1,0),UDim2.new(),Vector2.zero end
 local b=new(asBtn==false and "Frame" or "TextButton",{Size=sz,Position=ps,AnchorPoint=an,BackgroundColor3=C.card,BorderSizePixel=0,Parent=row})
 if asBtn~=false then b.AutoButtonColor=false b.Text="" fx(b) end
 corner(b,8) stroke(b,C.gd,1,.3) return b
end
local function section(p,t) return label(p,"▌ "..t,{Size=UDim2.new(1,0,0,22),LayoutOrder=nxt(p),TextColor3=C.g,TextSize=16}) end
local function note(p,t,c) return label(p,t,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextSize=13,TextColor3=c or C.sub,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=nxt(p)}) end
local function statusRow(p,k,v,good)
 local b=baseCard(newRow(p,26),1,1,false)
 label(b,k,{Size=UDim2.new(.6,-8,1,0),Position=UDim2.new(1,-8,0,0),AnchorPoint=Vector2.new(1,0),TextSize=13})
 label(b,v,{Size=UDim2.new(.4,-8,1,0),Position=UDim2.fromOffset(8,0),TextSize=13,TextColor3=good and C.g2 or C.amber,TextXAlignment=Enum.TextXAlignment.Left})
end
local function run(fn,...)
 local okc,ok,msg,kind=pcall(fn,...)
 if not okc then return false,"خطأ برمجي: "..tostring(ok),"err" end
 return ok,msg,kind
end
local function iconTxt(b,icon,text,w)
 label(b,icon,{Size=UDim2.fromOffset(24,24),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),TextSize=18,TextXAlignment=CENTER})
 return label(b,text,{Size=UDim2.new(1,w or -84,1,0),Position=UDim2.new(1,-36,0,0),AnchorPoint=Vector2.new(1,0),TextSize=14,TextWrapped=true})
end
local function toggleCard(row,slot,count,icon,text,cb)
 local b=baseCard(row,slot,count) iconTxt(b,icon,text)
 local sw=new("Frame",{Size=UDim2.fromOffset(38,20),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,8,.5,0),BackgroundColor3=C.off,BorderSizePixel=0,Parent=b}) corner(sw,10)
 local kn=new("Frame",{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,2,.5,0),BackgroundColor3=C.white,BorderSizePixel=0,Parent=sw}) corner(kn,8)
 local o={on=false}
 function o.set(v)
  o.on=v and true or false
  TS:Create(sw,TweenInfo.new(.15),{BackgroundColor3=o.on and C.g or C.off}):Play()
  TS:Create(kn,TweenInfo.new(.15),{Position=o.on and UDim2.new(1,-18,.5,0) or UDim2.new(0,2,.5,0)}):Play()
  if refreshActive then refreshActive() end
 end
 track(b.MouseButton1Click:Connect(function()
  local want=not o.on local ok,m,k=run(cb,want)
  if ok then o.set(want) if m then notify(m,k or "ok") end else notify(m or "فشلت العملية",k or "err") end
 end))
 return o
end
local function buttonCard(row,slot,count,icon,text,cb,tag)
 local b=baseCard(row,slot,count) local tx=iconTxt(b,icon,text)
 local tg=label(b,tag or "",{Size=UDim2.fromOffset(46,20),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,6,.5,0),TextSize=11,TextColor3=C.amber,TextXAlignment=CENTER,TextWrapped=true})
 track(b.MouseButton1Click:Connect(function()
  task.spawn(function() local ok,m,k=run(cb) if m then notify(m,k or (ok and "ok" or "err")) end end)
 end))
 return {setTag=function(t) tg.Text=t or "" end,setActive=function(v) b.BackgroundColor3=v and C.gd or C.card end}
end
local function holdCard(row,slot,count,icon,text,down,up)
 local b=baseCard(row,slot,count)
 label(b,icon.."  "..text,{Size=UDim2.fromScale(1,1),TextXAlignment=CENTER,TextSize=15})
 track(b.InputBegan:Connect(function(i)
  local t=i.UserInputType
  if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
   b.BackgroundColor3=C.gd down()
   local c c=i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then c:Disconnect() b.BackgroundColor3=C.card up() end end)
  end
 end))
end
local function inputCard(p,icon,text,def,cb)
 local b=baseCard(newRow(p,46),1,1,false) iconTxt(b,icon,text,-150)
 local box=new("TextBox",{Size=UDim2.fromOffset(56,28),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,70,.5,0),BackgroundColor3=Color3.fromRGB(20,13,7),Text=tostring(def),ClearTextOnFocus=false,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.white,BorderSizePixel=0,Parent=b})
 corner(box,6) stroke(box,C.gd,1,.2)
 local ap=new("TextButton",{Size=UDim2.fromOffset(58,28),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,6,.5,0),BackgroundColor3=C.g,AutoButtonColor=false,Text="تطبيق",Font=FONT,TextSize=14,TextColor3=C.bg,BorderSizePixel=0,Parent=b})
 corner(ap,6) fx(ap)
 local function go() local ok,m,k=run(cb,box.Text) if m then notify(m,k or (ok and "ok" or "err")) end end
 track(ap.MouseButton1Click:Connect(go))
 track(box.FocusLost:Connect(function(e) if e then go() end end))
end

---------------- الصفحات ----------------
local stopAll
do -- الرئيسية
 local p=newPage("home")
 section(p,"اختصارات")
 UI.night=toggleCard(newRow(p),1,1,"🌙","إزالة الضباب والظلام",F.night)
 buttonCard(newRow(p),1,1,"🚰","إيقاف السنابير (4 صمامات)",F.faucets,"تجريبي")
 buttonCard(newRow(p),1,1,"⛔","إيقاف كل الوظائف",function() stopAll() return true,"تم إيقاف جميع الوظائف","info" end)
 local have=0
 for _,n in ipairs({"gethui","fireproximityprompt","fireclickdetector","firetouchinterest","setclipboard","writefile"}) do if ext(n) then have=have+1 end end
 statusRow(p,"قدرات المنفّذ",have.."/6 متوفرة",have>=4)
 note(p,"كل شيء هنا يعمل على جهازك فقط، والخادم قد يعيدك أو يرفض بعض الأفعال.")
end
do -- الحركة
 local p=newPage("move")
 section(p,"السرعة")
 UI.speed=toggleCard(newRow(p),1,1,"⚡","تفعيل السرعة",F.speed)
 inputCard(p,"🔢","قيمة السرعة (1 - 50)",S.speed.mult,function(t)
  local n=parseNum(t)
  if not n then return false,"قيمة غير صالحة — أدخل رقماً من 1 إلى 50","err" end
  if n<1 or n>50 then return false,"خارج النطاق — المسموح 1 إلى 50","err" end
  S.speed.mult=n if S.speed.on then F.applySpeed() end
  return true,"تم ضبط السرعة على x"..fmt(n)..(S.speed.on and " وتطبيقها" or " (فعّلها من الزر)"),"ok"
 end)
 section(p,"الطيران")
 UI.fly=toggleCard(newRow(p),1,1,"✈","تشغيل الطيران",F.fly)
 inputCard(p,"🚀","سرعة الطيران (5 - 300)",S.fly.speed,function(t)
  local n=parseNum(t)
  if not n or n<5 or n>300 then return false,"قيمة غير صالحة — المسموح 5 إلى 300","err" end
  S.fly.speed=n return true,"سرعة الطيران = "..fmt(n),"ok"
 end)
 local r3=newRow(p)
 holdCard(r3,1,2,"⬆","صعود",function() if not S.fly.on then notify("شغّل الطيران أولاً","warn") return end S.fly.up=true end,function() S.fly.up=false end)
 holdCard(r3,2,2,"⬇","نزول",function() if not S.fly.on then notify("شغّل الطيران أولاً","warn") return end S.fly.down=true end,function() S.fly.down=false end)
 local r4=newRow(p)
 UI.hover=toggleCard(r4,1,2,"⏸","ثبات",function(on)
  if not S.fly.on then return false,"شغّل الطيران أولاً" end
  S.fly.hover=on return true,on and "ثبات في الهواء" or "تم إلغاء الثبات","info"
 end)
 buttonCard(r4,2,2,"⏹","إيقاف الطيران",function() local ok,m,k=F.fly(false) UI.fly.set(false) return ok,m,k end)
 section(p,"التصادم")
 UI.noclip=toggleCard(newRow(p),1,1,"👻","اختراق التصادم",F.noclip)
 note(p,"تُستعاد القيم الأصلية عند الإيقاف. قد يعيدك الخادم.",C.amber)
end
do -- الوحوش
 local p=newPage("monsters")
 note(p,"الكشف بأسماء الكائنات. إن لم يظهر شيء استخدم «اكتشاف أسماء NPC».")
 for _,m in ipairs(CFG.Monsters) do
  UI["esp_"..m.k]=toggleCard(newRow(p),1,1,"👁","كشف: "..m.n,function(on) return F.esp(m.k,on,m.n) end)
 end
 local r=newRow(p)
 UI.espAny=toggleCard(r,1,2,"🔍","كشف أي NPC",F.espAny)
 buttonCard(r,2,2,"📋","اكتشاف أسماء NPC",F.npcNames)
end
do -- التنقل
 local p=newPage("tp")
 note(p,"المدرسة والصحراء: قف فيها واضغط «حفظ هنا» (المدرسة تحسّن اختيار الصمامات).")
 for part=1,3 do
  section(p,({"الجزء الأول","الجزء الثاني","الجزء الثالث"})[part])
  for _,l in ipairs(CFG.Locs) do
   if l.part==part then
    local row=newRow(p,44)
    local b=new("TextButton",{Size=UDim2.new(.72,-3,1,0),Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),BackgroundColor3=C.card,AutoButtonColor=false,Text="",BorderSizePixel=0,Parent=row})
    corner(b,8) stroke(b,C.gd,1,.3) fx(b)
    label(b,"📍",{Size=UDim2.fromOffset(24,24),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),TextSize=18,TextXAlignment=CENTER})
    label(b,l.n,{Size=UDim2.new(1,-44,1,-4),Position=UDim2.new(1,-36,0,2),AnchorPoint=Vector2.new(1,0),TextSize=14,TextWrapped=true})
    local sl=label(b,locPos(l) and "" or "غير محدد",{Size=UDim2.fromOffset(44,18),Position=UDim2.fromOffset(4,2),TextSize=10,TextColor3=C.amber,TextXAlignment=Enum.TextXAlignment.Left})
    track(b.MouseButton1Click:Connect(function() local ok,m,k=run(F.tp,l) notify(m or "",k or (ok and "ok" or "err")) end))
    local s=new("TextButton",{Size=UDim2.new(.28,-3,1,0),BackgroundColor3=C.gd,AutoButtonColor=false,Text="حفظ هنا",Font=FONT,TextSize=13,TextColor3=C.white,BorderSizePixel=0,Parent=row})
    corner(s,8) fx(s)
    track(s.MouseButton1Click:Connect(function() local ok,m,k=run(F.saveHere,l) if ok then sl.Text="" end notify(m or "",k or (ok and "ok" or "err")) end))
   end
  end
 end
end
do -- الأغراض
 local p=newPage("items")
 section(p,"الجزء الأول (بإحداثياتك)")
 for i=1,4,2 do
  local row=newRow(p)
  for s=1,2 do
   local it=CFG.Items1[i+s-1]
   buttonCard(row,s,2,"🎒",it.n,function() return F.collectAt(it) end)
  end
 end
 buttonCard(newRow(p),1,1,"📦","جمع لبن + مياه + أرز",F.collectAll1)
 UI.aim=toggleCard(newRow(p),1,1,"🎯","تثبيت الكاميرا على القطة (دفتر الديون)",F.aim)
 note(p,"القطة تهرب كثيراً: فعّل التثبيت، ثم اضغط «دفتر الديون». التثبيت على الرأس لأن الفم غير قابل للتحديد.",C.amber)
 section(p,"الجزء الثاني والثالث")
 buttonCard(newRow(p),1,1,"🚰","المدرسة: إيقاف السنابير (4)",F.faucets,"تجريبي")
 buttonCard(newRow(p),1,1,"🏫","أغراض الجزء الثاني",function() return F.collectNames(CFG.P2,"الجزء الثاني") end,"أسماء مبدئية")
 buttonCard(newRow(p),1,1,"🏜","أغراض الجزء الثالث",function() return F.collectNames(CFG.P3,"الجزء الثالث") end,"أسماء مبدئية")
 buttonCard(newRow(p),1,1,"📋","اكتشاف الأغراض القريبة",F.discoverItems)
 note(p,"أسماء الجزءين غير مؤكدة — استخدم «اكتشاف الأغراض القريبة» وأرسل لي النتيجة.",C.amber)
end
do -- الحماية
 local p=newPage("protect")
 section(p,"الحماية")
 UI.god=toggleCard(newRow(p),1,1,"❤","عدم الموت",F.god)
 note(p,"تغيير الصحة محلياً يؤثر عندك فقط. الإخفاء عن الوحوش غير مدعوم من العميل.",C.amber)
end
stopAll=function()
 if S.fly.on then F.fly(false) end
 F.speed(false) F.noclip(false) F.god(false) F.night(false)
 if S.aim.on then F.aim(false) end
 S.esp.en,S.esp.any={},false refreshESP()
 for _,k in ipairs({"speed","fly","noclip","god","aim","night","espAny","hover"}) do if UI[k] then UI[k].set(false) end end
 for _,m in ipairs(CFG.Monsters) do local t=UI["esp_"..m.k] if t then t.set(false) end end
end
do -- الإعدادات
 local p=newPage("settings")
 section(p,"الواجهة")
 local r=newRow(p)
 buttonCard(r,1,2,"➖","تصغير",function() userScale=math.clamp(userScale-.1,.4,2) updScale() return true,"حجم الواجهة: "..math.floor(userScale*100).."%","info" end)
 buttonCard(r,2,2,"➕","تكبير",function() userScale=math.clamp(userScale+.1,.4,2) updScale() return true,"حجم الواجهة: "..math.floor(userScale*100).."%","info" end)
 section(p,"أدوات")
 buttonCard(newRow(p),1,1,"📌","نسخ إحداثياتي",function()
  local rt=getRoot() if not rt then return false,"لا توجد شخصية حالياً" end
  local v=rt.Position local t=string.format("Vector3.new(%.2f, %.2f, %.2f)",v.X,v.Y,v.Z)
  print("[SARAB] "..t)
  return true,copyText(t) and ("نُسخ: "..t) or (t.." (الكونسول F9)"),"ok"
 end)
end

---------------- التبويبات ----------------
local tabs={{"home","الرئيسية","🏠"},{"move","الحركة","🏃"},{"monsters","الوحوش","👹"},{"tp","التنقل","📍"},{"items","الأغراض","🎒"},{"protect","الحماية","🛡"},{"settings","الإعدادات","⚙"}}
local tabBtn={}
local function showPage(id)
 S.fly.up,S.fly.down=false,false
 for k,pg in pairs(pages) do pg.Visible=(k==id) end
 for _,t in ipairs(tabs) do
  local b=tabBtn[t[1]] if b then b.BackgroundColor3=(t[1]==id) and C.gd or C.card if t[1]==id then titleLabel.Text=t[2] end end
 end
end
local function makeTab(order,text,icon,cb,col)
 local b=new("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=col or C.card,AutoButtonColor=false,Text="",BorderSizePixel=0,LayoutOrder=order,Parent=sidebar})
 corner(b,8) stroke(b,C.gd,1,.4) fx(b)
 label(b,icon,{Size=UDim2.fromOffset(22,22),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),TextSize=16,TextXAlignment=CENTER})
 label(b,text,{Size=UDim2.new(1,-38,1,0),Position=UDim2.new(1,-32,0,0),AnchorPoint=Vector2.new(1,0),TextSize=15})
 track(b.MouseButton1Click:Connect(cb)) return b
end
for i,t in ipairs(tabs) do tabBtn[t[1]]=makeTab(i,t[2],t[3],function() showPage(t[1]) end) end

local cleanup
local closeUntil=0
local function reqClose()
 if os.clock()<closeUntil then cleanup() return end
 closeUntil=os.clock()+3 notify("اضغط الإغلاق مرة أخرى خلال 3 ثوانٍ للإغلاق النهائي","warn")
end
makeTab(20,"خروج","🚪",reqClose,Color3.fromRGB(96,38,6))
track(closeBtn.MouseButton1Click:Connect(reqClose))
local function setVisible(v) main.Visible=v floatBtn.Visible=not v if not v then S.fly.up,S.fly.down=false,false end end
track(hideBtn.MouseButton1Click:Connect(function() setVisible(false) end))
draggable(header,main) draggable(info,main) draggable(floatBtn,floatBtn,function() setVisible(true) end)

refreshActive=function()
 local n=0
 for _,v in ipairs({S.speed.on,S.fly.on,S.noclip.on,S.god.on,S.aim.on,S.night.on,S.esp.any}) do if v then n=n+1 end end
 for _,v in pairs(S.esp.en) do if v then n=n+1 end end
 activeValue.Text=tostring(n)
end

cleanup=function()
 if not alive then return end
 alive=false
 pcall(stopAll)
 for _,c in ipairs(godC) do disc(c) end
 disc(S.speed.guard) disc(S.fly.conn) disc(S.noclip.conn) disc(S.esp.conn) disc(S.night.conn)
 pcall(function() RS:UnbindFromRenderStep("SARAB_AIM") end)
 for m in pairs(S.esp.map) do rmHL(m) end
 restoreCol() killFly()
 for _,c in ipairs(conns) do disc(c) end
 pcall(function() gui:Destroy() end) pcall(function() espF:Destroy() end)
 if ENV._SARAB_CLEANUP==cleanup then ENV._SARAB_CLEANUP=nil end
 print("[SARAB] تم الإغلاق والتنظيف")
end
ENV._SARAB_CLEANUP=cleanup

---------------- الانترو (5 ثوانٍ) ----------------
local function intro()
 local cg=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,6,4),BorderSizePixel=0,ZIndex=50,Parent=gui})
 new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(54,24,4),Color3.fromRGB(5,4,3)),Rotation=90,Parent=cg})
 local glow=new("Frame",{Size=UDim2.fromOffset(380,380),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.45),BackgroundColor3=C.g,BackgroundTransparency=.88,BorderSizePixel=0,ZIndex=51,Parent=cg})
 corner(glow,190)
 local title=new("TextLabel",{Size=UDim2.fromOffset(700,90),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.38),BackgroundTransparency=1,Text="LOTRIX VX",Font=Enum.Font.GothamBlack,TextSize=40,TextColor3=C.g,TextTransparency=1,ZIndex=52,Parent=cg})
 local sub=new("TextLabel",{Size=UDim2.fromOffset(420,22),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundTransparency=1,Text="SARAB MAP   —   ORANGE EDITION",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.white,TextTransparency=1,ZIndex=52,Parent=cg})
 local tag=new("TextLabel",{Size=UDim2.fromOffset(420,26),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.58),BackgroundTransparency=1,Text="♛  تحكم أنيق وخفيف  ♛",Font=FONT,TextSize=20,TextColor3=C.g2,TextTransparency=1,ZIndex=52,Parent=cg})
 local msg=new("TextLabel",{Size=UDim2.fromOffset(420,20),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.7),BackgroundTransparency=1,Text="",Font=FONT,TextSize=15,TextColor3=C.sub,ZIndex=52,Parent=cg})
 local bar=new("Frame",{Size=UDim2.fromOffset(320,8),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.76),BackgroundColor3=C.off,BorderSizePixel=0,ZIndex=52,Parent=cg})
 corner(bar,4) stroke(bar,C.gd,1,.2)
 local fill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.g,BorderSizePixel=0,ZIndex=53,Parent=bar}) corner(fill,4)
 local cnt=new("TextLabel",{Size=UDim2.fromOffset(120,20),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.83),BackgroundTransparency=1,Text="5",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=C.g2,ZIndex=52,Parent=cg})
 local sc=new("UIScale",{Parent=cg}) -- يتكيّف مع حجم الشاشة
 local function fit() local v=gui.AbsoluteSize sc.Scale=math.clamp(math.min(v.X/760,v.Y/420),.5,3) end
 fit()
 TS:Create(title,TweenInfo.new(1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=72,TextTransparency=0}):Play()
 TS:Create(glow,TweenInfo.new(5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.fromOffset(560,560),BackgroundTransparency=.94}):Play()
 task.delay(.7,function() TS:Create(sub,TweenInfo.new(.8),{TextTransparency=0}):Play() end)
 task.delay(1.4,function() TS:Create(tag,TweenInfo.new(.8),{TextTransparency=0}):Play() end)
 TS:Create(fill,TweenInfo.new(5,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(1,1)}):Play()
 local steps={{0,"تهيئة النظام..."},{1.2,"فحص الشخصية..."},{2.4,"تحميل الأدوات..."},{3.6,"تجهيز الواجهة..."},{4.5,"جاهز!"}}
 local t0,si=os.clock(),1
 while alive and os.clock()-t0<5 do
  local e=os.clock()-t0
  while steps[si+1] and e>=steps[si+1][1] do si=si+1 end
  msg.Text=steps[si][2] cnt.Text=tostring(math.max(0,math.ceil(5-e)))
  task.wait(.1)
 end
 if not alive then return end
 cnt.Text="0"
 main.Visible=true
 local o=TS:Create(cg,TweenInfo.new(.6),{GroupTransparency=1}) o:Play() o.Completed:Wait()
 cg:Destroy()
end

---------------- التشغيل ----------------
track(LP.CharacterAdded:Connect(onChar))
if LP.Character then onChar(LP.Character) end
showPage("home")
notify("LOTRIX VX جاهز — الميزات محلية فقط","ok")
task.spawn(function() local ok,e=pcall(intro) if not ok then main.Visible=true warn("[SARAB] intro: "..tostring(e)) end end)
