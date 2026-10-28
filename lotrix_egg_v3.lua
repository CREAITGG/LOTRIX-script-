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
 Name="LOTRIX_VX_EGG",Ver="v3.0",
 EggWords={"egg","بيض"},
 GuardWords={"guard","boss","حارس"},
 TrapWords={"trap","snare","فخ"},
 SpeedMin=1,SpeedMax=250,SpeedDefault=100,
 -- أسماء عربية للحيوانات والوحوش (إنجليزي ← عربي). أضف ما تريد
 Animals={
  {"forestguard","حارس الغابة"},{"eggholder","حامل البيض"},{"guard","حارس"},
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

local C={bg=Color3.fromRGB(13,13,15),panel=Color3.fromRGB(22,22,26),card=Color3.fromRGB(33,33,38),
 g=Color3.fromRGB(196,198,208),g2=Color3.fromRGB(236,237,242),gd=Color3.fromRGB(72,72,82),
 text=Color3.fromRGB(240,240,244),sub=Color3.fromRGB(150,150,160),off=Color3.fromRGB(58,58,66),
 amber=Color3.fromRGB(255,214,90),red=Color3.fromRGB(255,84,84),money=Color3.fromRGB(60,255,140),white=Color3.new(1,1,1)}
local KC={ok=C.money,warn=C.amber,err=C.red,info=C.sub}
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
 local u={"","K","M","B","T","Q"} local i=1
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
local function inTread(i)
 local o=i
 for _=1,10 do
  if not o or o==WS then return false end
  if string.find(string.lower(o.Name),"treadmill",1,true) then return true end
  o=o.Parent
 end
 return false
end
local function isTarget(inst,words,modelOnly)
 if inTread(inst) then return false end
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


---------------- قاعدة البيانات (من أدلة الويب، غير رسمية) ----------------
local RAR={Common="عادي",Uncommon="غير شائع",Rare="نادر",Epic="ملحمي",Legendary="أسطوري",Mythic="خرافي",Cosmic="كوني",Secret="سري",Eternal="أبدي",Divine="إلهي"}
-- {اسم إنجليزي, عربي, الندرة, الدخل في الثانية}
local PETS={
 {"Chicken","دجاجة","Common",1},{"Dog","كلب","Common",2},{"Bird","طائر","Uncommon",8},{"Owl","بومة","Rare",35},{"Raccoon","راكون","Rare",45},{"Fox","ثعلب","Epic",180},{"Brr Brr Patapim","بر بر باتابيم","Legendary",1800},
 {"Frog","ضفدع","Common",3},{"Duckling","فرخ بط"},{"Catfish","سمكة السلور","Uncommon",12},{"Turtle","سلحفاة","Rare",60},{"Trulimero Trulicina","ترولميرو ترولتشينا","Epic",260},{"Swan","بجعة"},{"Axolotl","أكسولوتل"},{"Leviathan","لوياثان"},
 {"Jerboa","جربوع","Common",6},{"Fennec","ثعلب الفنك"},{"Camel","جمل","Rare",75},{"Tob Tobi Tob Tob","توب توبي توب توب"},{"Snake","أفعى"},{"Scorpion","عقرب"},{"Sand Spider","عنكبوت الرمال","Mythic",16000},{"Royal Sphinx","أبو الهول الملكي"},
 {"Toucan","طوقان","Rare",110},{"Chimpanzee","شمبانزي","Rare",90},{"Crocodile","تمساح","Epic",420},{"Gorilla","غوريلا","Legendary",4800},{"Orangutini Ananassini","أورانغوتيني أناناسيني","Legendary",5500},{"Spider","عنكبوت","Mythic",22000},{"Tiger","نمر"},{"King Snake","ملك الأفاعي","Secret",3e6},
 {"Penguin","بطريق"},{"Walrus","فظ","Epic",600},{"Polar Bear","دب قطبي","Legendary",7000},{"Sabertooth Tiger","نمر سيف الأسنان","Mythic",35000},{"Mammoth","ماموث","Mythic",42000},{"King Mammoth","ملك الماموث","Cosmic",4e5},{"Yeti","يتي"},{"Ice Dragon","تنين الجليد","Eternal"},
 {"Lava Gecko","وزغة اللافا"},{"Lava Frog","ضفدع اللافا","Epic",850},{"Flaming Bull","ثور ناري","Legendary",9500},{"Lava Iguana","إغوانا اللافا","Legendary",11000},{"Chillin Chilli","تشيلين تشيلي","Mythic",55000},{"Cerberus","سيربيروس","Secret",8e6},{"Phoenix","طائر الفينيق"},{"Lava Dragon","تنين اللافا","Eternal",1e8},
 {"Parrotfish","سمكة الببغاء","Rare",220},{"Swordfish","سمكة السيف","Epic",1100},{"Shark","قرش","Legendary",15000},{"Orca","أوركا","Mythic",80000},{"Whale Shark","قرش الحوت","Cosmic",7e5},{"Beluga Whale","حوت بيلوغا","Cosmic",8.5e5},{"Kraken","كراكن","Secret"},{"El Maja","إل ماجا"},
 {"Dodo","دودو"},{"Pterodactyl","تيروداكتيل"},{"Ankylosaurus","أنكيلوصور","Mythic",120000},{"Triceratops","ترايسيراتوبس"},{"Bronto","برونتو","Cosmic",1.5e6},{"Tralaledon","ترالاليدون"},{"T.Rex","تي ريكس","Eternal"},{"Mosasaurus","موصور","Eternal"},
 {"Centapede","ألف رجل"},{"Cosmic Gecko","وزغة كونية"},{"Cosmic Gorilla","غوريلا كونية"},{"La Vacca Saturno Saturnita","لا فاكا ساتورنو ساتورنيتا"},{"Cosmic Dragon","تنين كوني"},{"Cosmic Skeleton Boss","زعيم الهيكل الكوني"},{"Eternal Lunar Dragon","تنين القمر الأبدي","Eternal"},{"Unicorn","وحيد القرن","Divine",3.2e10},
 {"Tung Tung Sahur","تونغ تونغ ساهور"},{"Bananita Dolphinita","بنانيتا دولفينيتا"},{"Belula Beluga","بيلولا بيلوغا"},{"Mangolini Parrochini","مانغوليني باروكيني"},{"Bomboclat Crocolat","بومبوكلات كروكولات"},{"Strawberry Elephant","فيل الفراولة"},
 {"Kitsune","كيتسوني","Divine",4.8e10},{"Night Flame","اللهب الليلي","Divine",8e10},{"Archangel","رئيس الملائكة","Divine",2.27e11},{"World Burner","محرق العالم","Divine",5e11},{"Aetherion","إيثيريون","Divine",7.1e11},{"Royal Sky Whale","حوت السماء الملكي","Divine",4.22e11},
}
local function normTxt(s) return " "..string.lower(tostring(s)):gsub("[^%w]+"," ").." " end
for _,p in ipairs(PETS) do p.k=normTxt(p[1]) end
local function findPet(text,exact)
 local t=normTxt(text)
 local best,bl
 for _,p in ipairs(PETS) do
  local hit
  if exact then hit=(t==p.k) else hit=(string.find(t,p.k,1,true)~=nil) end
  if hit and (not bl or #p.k>bl) then best,bl=p,#p.k end
 end
 return best
end
local function petLine(p)
 local out={"🐾 "..p[2]..(p[3] and (" — "..(RAR[p[3]] or p[3])) or "")}
 if p[4] then
  local pre=(p[3]=="Divine") and "حتى ~" or "~"
  out[#out+1]='<font color="#3CFF8C">💰 '..pre..abbr(p[4]).."/ث • "..abbr(p[4]*60).."/د</font>"
 else
  out[#out+1]="💰 الدخل غير معروف في الأدلة"
 end
 return table.concat(out,"\n")
end

-- الحراس: بيوم → الحارس والسرعة المطلوبة (من أدلة الويب)
local GB={
 {{"enchant"},"الغابة المسحورة","أرواح الغابة","50B"},
 {{"angel","demon"},"الملائكة والشياطين","حراس الملائكة والشياطين","20B"},
 {{"titan","temple"},"معبد العمالقة","الغوريلا العملاق","7B"},
 {{"cherry","blossom","kitsune"},"زهر الكرز","كيتسوني","2.5B"},
 {{"cosmic"},"الكون","الحارس الكوني","700M"},
 {{"prehistoric","trex","t-rex","rex"},"ما قبل التاريخ","تي ريكس","18M"},
 {{"abyss","ocean","deepsea"},"المحيط العميق","حارس الأعماق","2.5M"},
 {{"volcano","cerberus","lava"},"البركان","سيربيروس","700K"},
 {{"snow","yeti","ice"},"الثلج","اليتي","170K"},
 {{"jungle","tiger"},"الأدغال","النمر","40K"},
 {{"desert","scorpion","sand"},"الصحراء","العقرب","10K"},
 {{"lake","swan"},"البحيرة","البجعة","900"},
 {{"forest","chicken"},"الغابة","الدجاجة","0"},
}
local function guardText(inst)
 local hay,o={},inst
 for _=1,8 do
  if not o or o==WS or o==game then break end
  hay[#hay+1]=string.lower(o.Name) o=o.Parent
 end
 local n=0
 for _,d in ipairs(inst:GetDescendants()) do
  n=n+1 if n>80 then break end
  hay[#hay+1]=string.lower(d.Name)
 end
 local t=table.concat(hay," ")
 for _,e in ipairs(GB) do
  for _,k in ipairs(e[1]) do
   if string.find(t,k,1,true) then return "👹 حارس "..e[3].." — "..e[2].."\nالسرعة المطلوبة: "..e[4].." • "..distTo(inst).." م" end
  end
 end
 return "👹 حارس (البيوم غير محدد)\n"..(inst.Parent and inst.Parent.Name or "؟").." • "..distTo(inst).." م"
end

---------------- السرعة ----------------
function F.applySpeed() local h=getHum() if h then h.WalkSpeed=S.speed.on and S.speed.val or S.speed.base end end
function F.speed(on)
 if on and not getHum() then return false,"لا توجد شخصية حالياً" end
 S.speed.on=on F.applySpeed()
 if on then return true,"سرعة الحركة "..fmt(S.speed.val).." مفعّلة (مشي حقيقي لشخصيتك). إن أعادك السيرفر أو شعرت بتقطع فخفّض القيمة","warn" end
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
local function matchKind(kind,d)
 local K=KIND[kind]
 if kind=="guard" then
  return d:IsA("Model") and not inChar(d) and hasWord(d.Name,CFG.GuardWords)
 end
 if isTarget(d,K.words,K.modelOnly) then return true end
 if kind=="egg" and d:IsA("Model") and not inChar(d) and not inTread(d) and findPet(d.Name,true) then return true end
 return false
end
local function eggInfo(inst)
 local other,money,seen={},{},{}
 local pet=findPet(inst.Name,false)
 local function put(k,v)
  if type(v)~="number" and type(v)~="string" then return end
  if v=="" then return end
  local ak,kd=arKey(tostring(k))
  local id=ak..tostring(v)
  if seen[id] then return end
  seen[id]=true
  if kd=="money" and type(v)=="number" then
   local l=string.lower(tostring(k))
   if string.find(l,"min",1,true) then money[#money+1]="💰 "..abbr(v/60).."/ث • "..abbr(v).."/د"
   elseif string.find(l,"sec",1,true) or string.find(l,"/s",1,true) or string.find(l,"income",1,true) or string.find(l,"produc",1,true) or string.find(l,"earn",1,true) or string.find(l,"profit",1,true) then
    money[#money+1]="💰 "..abbr(v).."/ث • "..abbr(v*60).."/د"
   else money[#money+1]="💰 "..abbr(v) end
  else
   other[#other+1]=ak..": "..fmtVal(kd,v)
  end
 end
 for k,v in pairs(inst:GetAttributes()) do put(k,v) end
 local n=0
 for _,d in ipairs(inst:GetDescendants()) do
  n=n+1 if n>70 or (#other+#money)>=7 then break end
  if d:IsA("ValueBase") and (d:IsA("StringValue") or d:IsA("NumberValue") or d:IsA("IntValue")) then put(d.Name,d.Value)
  elseif (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text~="" and #d.Text<50 then other[#other+1]="• "..trAnimal(d.Text) end
  for k,v in pairs(d:GetAttributes()) do put(k,v) end
 end
 if not pet then
  local m=0
  for _,d in ipairs(inst:GetDescendants()) do
   m=m+1 if m>70 then break end
   pet=findPet(d.Name,false)
   if pet then break end
  end
 end
 if pet then return petLine(pet) end
 if #other==0 and #money==0 then return "لا بيانات ظاهرة للعميل — لم أتعرف على الحيوان" end
 local out={}
 for i=1,math.min(3,#other) do out[#out+1]=other[i] end
 for i=1,math.min(2,#money) do out[#out+1]='<font color="#3CFF8C">'..money[i]..'</font>' end
 return table.concat(out,"\n")
end
local function labelText(kind,inst)
 if kind=="egg" then return "🥚 بيضة\n"..eggInfo(inst) end
 if kind=="guard" then return guardText(inst) end
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
  local bb=Instance.new("BillboardGui") bb.Adornee=p bb.Size=UDim2.fromOffset(230,96) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.MaxDistance=400 bb.Parent=espF
  local ll=Instance.new("TextLabel") ll.BackgroundTransparency=1 ll.Size=UDim2.fromScale(1,1) ll.Font=Enum.Font.SourceSansBold ll.TextSize=15
  ll.TextColor3=KIND[kind].color ll.TextStrokeTransparency=.3 ll.TextWrapped=true ll.RichText=true ll.Text=labelText(kind,inst) ll.Parent=bb
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
 for _,d in ipairs(WS:GetDescendants()) do if matchKind(kind,d) then addESP(kind,d) end end
 st.conn=WS.DescendantAdded:Connect(function(d)
  task.delay(.3,function() if alive and st.on and d.Parent and matchKind(kind,d) then addESP(kind,d) end end)
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
  if d:IsA("Model") and hasWord(d.Name,CFG.GuardWords) and d.Name~="Map" and not inChar(d) and not inTread(d) and d:FindFirstChildOfClass("Humanoid") then l[#l+1]=d end
 end
 return l
end
local function sleepOne(m)
 local h=m:FindFirstChildOfClass("Humanoid")
 local root=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
 if not root then return end
 local sv=S.freeze.saved[m]
 if not sv then
  sv={root=root,h=h,a=root.Anchored,o=root.Orientation,ps=h and h.PlatformStand,ws=h and h.WalkSpeed}
  S.freeze.saved[m]=sv
  local head=m:FindFirstChild("Head") or root
  if not head:FindFirstChild("LotrixZzz") then
   pcall(function()
    local at=Instance.new("Attachment") at.Name="LotrixZzz" at.Parent=head
    local z=Instance.new("ParticleEmitter") z.Texture="rbxassetid://134015502" z.Lifetime=NumberRange.new(2,3) z.Speed=NumberRange.new(1,2) z.Rate=2 z.Size=NumberSequence.new(.6,1.2) z.Parent=at
    sv.z=at
   end)
  end
 end
 if h then h.PlatformStand=true h.WalkSpeed=0 end
 root.Orientation=Vector3.new(0,sv.o.Y,90)
 root.Anchored=true
end
local function unfreeze()
 for m,sv in pairs(S.freeze.saved) do
  pcall(function()
   sv.root.Anchored=sv.a sv.root.Orientation=sv.o
   if sv.h then sv.h.PlatformStand=sv.ps sv.h.WalkSpeed=sv.ws end
   if sv.z then sv.z:Destroy() end
  end)
 end
 S.freeze.saved={}
end
function F.freeze(on)
 local f=S.freeze
 if not on then f.on=false disc(f.conn) f.conn=nil unfreeze() return true,"أُيقظ الحراس عندك","info" end
 f.list=guardModels()
 if #f.list==0 then return false,"لا حراس ظاهرون باسم Guard — اقترب منهم","warn" end
 f.on=true f.acc=0 disc(f.conn)
 for _,m in ipairs(f.list) do pcall(sleepOne,m) end
 f.conn=RS.Heartbeat:Connect(function(dt)
  f.acc=f.acc+dt
  if f.acc<1.5 then return end
  f.acc=0
  f.list=guardModels()
  for _,m in ipairs(f.list) do pcall(sleepOne,m) end
 end)
 return true,"نُوّم "..#f.list.." حارس على شاشتك (تجميد + نوم). السيرفر قد يظل يحرّكهم لك، جرّب وراقب","warn"
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
S.anti.nc={}
local function restoreNC() for p in pairs(S.anti.nc) do pcall(function() p.CanCollide=true end) end S.anti.nc={} end
function F.anti(on)
 local a=S.anti a.on=on disc(a.conn) a.conn=nil
 if not on then restoreNC() return true,"تم إيقاف الحماية من الضرب","info" end
 if getChar() then hookAnti(getChar()) end
 a.acc=0
 a.conn=RS.Heartbeat:Connect(function(dt)
  local h=getHum() local r=getRoot()
  if h then
   local st=h:GetState()
   if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then h:ChangeState(Enum.HumanoidStateType.GettingUp) a.fixed=a.fixed+1 end
   if h.PlatformStand then h.PlatformStand=false end
  end
  if r and h then
   local v=r.AssemblyLinearVelocity
   local ws=(S.speed.on and S.speed.val or S.speed.base)
   local lim=math.max(70,ws*1.7)
   if Vector3.new(v.X,0,v.Z).Magnitude>lim or v.Y>95 then
    local md=h.MoveDirection
    r.AssemblyLinearVelocity=Vector3.new(md.X*ws,(v.Y>95) and 0 or v.Y,md.Z*ws)
    a.fixed=a.fixed+1
   end
   if r.AssemblyAngularVelocity.Magnitude>25 then r.AssemblyAngularVelocity=Vector3.zero end
  end
  a.acc=a.acc+dt
  if a.acc>=.5 then
   a.acc=0
   for _,pl in ipairs(Players:GetPlayers()) do
    if pl~=LP and pl.Character then
     for _,p in ipairs(pl.Character:GetChildren()) do
      if p:IsA("BasePart") and p.CanCollide then a.nc[p]=true p.CanCollide=false end
     end
    end
   end
  end
 end)
 return true,"حماية الضرب مفعّلة (تصفير القوة المفاجئة + منع التصادم مع اللاعبين) — محلي، وقد لا يمنع السيرفر إسقاط البيضة","warn"
end

---------------- سرقة كل البيض بزر واحد ----------------
local function firePrompt(d)
 local f=ext("fireproximityprompt")
 if not f then return false end
 pcall(function() d.HoldDuration=0 end)
 return (pcall(f,d))
end
function F.stealAll()
 if S.busy then return false,"عملية قيد التنفيذ" end
 local r=getRoot() if not r then return false,"لا توجد شخصية حالياً" end
 if not ext("fireproximityprompt") then return false,"منفّذك لا يدعم fireproximityprompt","err" end
 local T={}
 for _,d in ipairs(WS:GetDescendants()) do
  if d:IsA("ProximityPrompt") and d.Enabled then
   local own=d.Parent
   local txt=string.lower(d.ActionText.." "..d.ObjectText)
   local chain=(own and own.Name or "").." "..((own and own.Parent) and own.Parent.Name or "")
   local isSteal=string.find(txt,"steal",1,true) or string.find(txt,"سرق",1,true) or string.find(txt,"grab",1,true) or string.find(txt,"take",1,true)
   if (isSteal or hasWord(chain,CFG.EggWords)) and not inChar(d) and not inTread(d) then
    local p=own and primary(own)
    if p then T[#T+1]={d=d,p=p.Position} end
   end
  end
 end
 if #T==0 then return false,"لم أجد زر سرقة بيض ظاهراً — اقترب من البيوض وجرّب، أو شغّل أداة الفحص وأرسل النتيجة","warn" end
 local from=r.Position
 table.sort(T,function(x,y) return (x.p-from).Magnitude<(y.p-from).Magnitude end)
 while #T>30 do table.remove(T) end
 S.busy=true
 local origin,n=r.CFrame,0
 local hadF,hadA=S.freeze.on,S.anti.on
 if not hadF then F.freeze(true) end
 if not hadA then F.anti(true) end
 pcall(function()
  for i,t in ipairs(T) do
   if not alive then break end
   local rr=getRoot() if not rr then break end
   rr.CFrame=CFrame.new(t.p+Vector3.new(0,3,0)) rr.AssemblyLinearVelocity=Vector3.zero
   task.wait(.25)
   if firePrompt(t.d) then n=n+1 end
   notify("سرقة البيض: "..i.."/"..#T,"info")
   task.wait(.35)
  end
 end)
 local r2=getRoot() if r2 then r2.CFrame=origin end
 if not hadF then F.freeze(false) end
 if not hadA then F.anti(false) end
 S.busy=false
 if n==0 then return false,"وجدت "..#T.." زراً لكن المنفّذ لم يفعّلها","warn" end
 return true,"فُعّل "..n.." من "..#T.." — لا أستطيع التأكد أن السيرفر قبل السرقة، راجع بيوضك","warn"
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

---------------- الأيقونة (صورتك) ----------------
local ICON_B64=[==[
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
]==]
local iconAsset
do
 local wf,gca=ext("writefile"),(ext("getcustomasset") or ext("getsynasset"))
 if wf and gca then
  pcall(function()
   local A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   local map={} for i=1,64 do map[string.byte(A,i)]=i-1 end
   local s=ICON_B64:gsub("%s","")
   local out={}
   for i=1,#s,4 do
    local a,b,c,d=string.byte(s,i,i+3)
    local n=map[a]*262144+map[b]*4096+(map[c] or 0)*64+(map[d] or 0)
    local c1,c2,c3=math.floor(n/65536),math.floor(n/256)%256,n%256
    if d==61 then
     if c==61 then out[#out+1]=string.char(c1) else out[#out+1]=string.char(c1,c2) end
    else out[#out+1]=string.char(c1,c2,c3) end
   end
   wf("lotrix_icon.png",table.concat(out))
   iconAsset=gca("lotrix_icon.png")
  end)
 end
end

---------------- الواجهة ----------------
local function new(cls,props,parent)
 local o=Instance.new(cls)
 for k,v in pairs(props or {}) do o[k]=v end
 if parent then o.Parent=parent end
 return o
end
local function corner(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function stroke(o,c,t,tr) return new("UIStroke",{Color=c or C.gd,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
local RIGHT,CENTER=Enum.TextXAlignment.Right,Enum.TextXAlignment.Center
local function label(p,t,sz,col,bold,al)
 return new("TextLabel",{BackgroundTransparency=1,Text=t,TextSize=sz or 14,TextColor3=col or C.text,Font=bold and Enum.Font.GothamBold or Enum.Font.SourceSansBold,TextWrapped=true,TextXAlignment=al or RIGHT},p)
end
local function makeIcon(parent,size)
 local f=new("Frame",{Size=UDim2.fromOffset(size,size),BackgroundColor3=C.panel},parent)
 corner(f,size/2)
 if iconAsset then
  local im=new("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image=iconAsset,ScaleType=Enum.ScaleType.Crop},f)
  corner(im,size/2)
 else
  local l=label(f,"L",size*.55,C.g2,true,CENTER) l.Size=UDim2.fromScale(1,1) l.Font=Enum.Font.GothamBlack
 end
 return f
end

local DW,DH=300,392
local gui=new("ScreenGui",{Name=CFG.Name,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},host)
local uiScale=new("UIScale",{},gui)
local function rescale()
 local cam=WS.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(1000,600)
 uiScale.Scale=math.clamp(math.min(v.X*.55/DW,v.Y*.8/DH),.5,3)
end
rescale()
if WS.CurrentCamera then track(WS.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)) end

local main=new("Frame",{Size=UDim2.fromOffset(DW,DH),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.bg,Visible=false,ClipsDescendants=true},gui)
corner(main,16)
local mainStroke=stroke(main,C.g,1.5,.2)
new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(38,38,44),Color3.fromRGB(10,10,12)),Rotation=90},main)
local pop=new("UIScale",{Scale=1},main)
local function popIn()
 pop.Scale=.85
 TS:Create(pop,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
end

local header=new("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1},main)
local ttl=label(header,"LOTRIX VX",20,C.g2,true,CENTER) ttl.Font=Enum.Font.GothamBlack ttl.Size=UDim2.new(1,0,0,26) ttl.Position=UDim2.fromOffset(0,4)
local sub=label(header,"STEAL AN EGG",10,C.sub,true,CENTER) sub.Size=UDim2.new(1,0,0,14) sub.Position=UDim2.fromOffset(0,28)
local function hbtn(txt,x)
 local b=new("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.fromOffset(x,10),BackgroundColor3=C.card,Text=txt,TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.g2,AutoButtonColor=false},header)
 corner(b,8) stroke(b,C.gd,1,.3) return b
end
local closeB=hbtn("✕",8) local hideB=hbtn("—",40)
local lineF=new("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.fromOffset(12,48),BackgroundColor3=C.gd,BorderSizePixel=0,ClipsDescendants=true},main)
local sweep=new("Frame",{Size=UDim2.fromOffset(70,2),Position=UDim2.fromOffset(-70,0),BackgroundColor3=C.g2,BorderSizePixel=0},lineF)
new("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)})},sweep)
task.spawn(function()
 while alive do
  if main.Visible then
   sweep.Position=UDim2.fromOffset(-70,0)
   TS:Create(sweep,TweenInfo.new(1.6,Enum.EasingStyle.Sine),{Position=UDim2.fromOffset(DW,0)}):Play()
   TS:Create(mainStroke,TweenInfo.new(.8,Enum.EasingStyle.Sine),{Transparency=.55}):Play()
   task.wait(.8)
   TS:Create(mainStroke,TweenInfo.new(.8,Enum.EasingStyle.Sine),{Transparency=.1}):Play()
   task.wait(.9)
  else task.wait(.5) end
 end
end)

-- سحب مع كشف النقر
local function draggable(handle,target,onTap)
 local st
 track(handle.InputBegan:Connect(function(i)
  local t=i.UserInputType
  if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
   st={input=i,start=i.Position,pos=target.Position,moved=false}
   local c c=i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then
     c:Disconnect() local s=st st=nil
     if s and not s.moved and onTap then onTap() end
    end
   end)
  end
 end))
 track(UIS.InputChanged:Connect(function(i)
  if st and (i==st.input or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-st.start
   if d.Magnitude>8 then st.moved=true end
   if st.moved then
    local k=uiScale.Scale
    target.Position=UDim2.new(st.pos.X.Scale,st.pos.X.Offset+d.X/k,st.pos.Y.Scale,st.pos.Y.Offset+d.Y/k)
   end
  end
 end))
end
draggable(header,main)

-- شريط الحالة
local bar=new("Frame",{Size=UDim2.new(1,-16,0,38),Position=UDim2.new(0,8,1,-46),BackgroundColor3=C.panel},main)
corner(bar,10) stroke(bar,C.gd,1,.3)
statusLabel=label(bar,"جاهز — محلي على جهازك فقط",12,C.sub,false,CENTER)
statusLabel.Size=UDim2.new(1,-12,1,0) statusLabel.Position=UDim2.fromOffset(6,0)

local function fx(card)
 pcall(function()
  local sc=card:FindFirstChildOfClass("UIScale") or new("UIScale",{},card)
  sc.Scale=.95
  TS:Create(sc,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
  local fl=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.g2,BackgroundTransparency=.7,ZIndex=5},card)
  corner(fl,10)
  local t=TS:Create(fl,TweenInfo.new(.4),{BackgroundTransparency=1}) t:Play()
  t.Completed:Connect(function() fl:Destroy() end)
 end)
end

-- منطقة القائمة
local list=new("ScrollingFrame",{Size=UDim2.new(1,-12,1,-108),Position=UDim2.fromOffset(6,56),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.g,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},main)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
new("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,6)},list)
local ord=0
local function nxt() ord=ord+1 return ord end
local function section(t)
 local l=label(list,"▌ "..t,12,C.sub,true) l.Size=UDim2.new(1,0,0,18) l.LayoutOrder=nxt()
end
local function card(txt,desc)
 local c=new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.card,LayoutOrder=nxt()},list)
 corner(c,10) stroke(c,C.gd,1,.4)
 local t=label(c,txt,14,C.text,true) t.Size=UDim2.new(1,-84,0,20) t.Position=UDim2.fromOffset(6,6)
 local d=label(c,desc or "",10,C.sub) d.Size=UDim2.new(1,-84,0,24) d.Position=UDim2.fromOffset(6,26) d.TextYAlignment=Enum.TextYAlignment.Top
 return c
end
local resets={}
local function toggleCard(txt,desc,fn)
 local c=card(txt,desc)
 local sw=new("TextButton",{Size=UDim2.fromOffset(48,24),Position=UDim2.new(0,8,.5,-12),BackgroundColor3=C.off,Text="",AutoButtonColor=false},c)
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
  local okc,ok,msg,kind=pcall(fn,want)
  if not okc then ok,msg,kind=false,"خطأ برمجي: "..tostring(ok),"err" end
  if ok then on=want end
  paint()
  notify(msg or (ok and "تم" or "فشل"),kind or (ok and "ok" or "err"))
 end)
 resets[#resets+1]=function() on=false paint() end
end
local function buttonCard(txt,desc,fn)
 local c=card(txt,desc)
 local b=new("TextButton",{Size=UDim2.fromOffset(52,26),Position=UDim2.new(0,8,.5,-13),BackgroundColor3=C.gd,Text="تنفيذ",TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.g2,AutoButtonColor=false},c)
 corner(b,9)
 b.MouseButton1Click:Connect(function()
  fx(c)
  task.spawn(function()
   local okc,ok,msg,kind=pcall(fn)
   if not okc then ok,msg,kind=false,"خطأ برمجي: "..tostring(ok),"err" end
   notify(msg or (ok and "تم" or "فشل"),kind or (ok and "ok" or "err"))
  end)
 end)
end

section("الحماية")
toggleCard("حماية من ضرب اللاعبين","لا تطير ولا تترنح عند الضرب بالعصا (محلي)",function(on) return F.anti(on) end)
toggleCard("حذف الفخاخ","يحذف الفخاخ من الأرض الآن وأي فخ جديد",function(on)
 if on then
  F.trapAuto(true)
  local ok,m=F.removeTraps()
  return true,(ok and m or "حذف تلقائي مفعّل — لا فخاخ ظاهرة الآن"),"warn"
 end
 return F.trapAuto(false)
end)
toggleCard("تنويم الزعماء","يجمّد الحراس نائمين عندك فقط (لا يتأثر اللاعبون الآخرون)",function(on) return F.freeze(on) end)
section("الحركة")
local spc=card("قيمة السرعة","1 إلى "..CFG.SpeedMax.." — فوق 300 يعيدك السيرفر")
local box=new("TextBox",{Size=UDim2.fromOffset(64,28),Position=UDim2.new(0,8,.5,-14),BackgroundColor3=C.panel,Text=tostring(CFG.SpeedDefault),TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.g2,ClearTextOnFocus=false},spc)
corner(box,8) stroke(box,C.g,1,.3)
local function readSpeed()
 local n=parseNum(box.Text)
 if not n then return nil end
 n=math.clamp(n,CFG.SpeedMin,CFG.SpeedMax) box.Text=fmt(n) return n
end
box.FocusLost:Connect(function()
 local n=readSpeed()
 if not n then notify("رقم غير صالح","err") box.Text=tostring(S.speed.val) return end
 S.speed.val=n if S.speed.on then F.applySpeed() end
 notify("القيمة: "..fmt(n),"ok")
end)
toggleCard("تفعيل السرعة","مشي حقيقي لشخصيتك بالقيمة أعلاه",function(on)
 if on then local n=readSpeed() if not n then return false,"رقم السرعة غير صالح","err" end S.speed.val=n end
 return F.speed(on)
end)
section("السرقة")
buttonCard("سرقة كل البيض","ينقلك لكل بيضة ويسرقها، والحراس مجمّدون عندك",function() return F.stealAll() end)
section("الكشف")
toggleCard("كشف الزعماء (كل الماب)","اسم عربي + المسافة فوق كل زعيم وحارس",function(on) return F.esp("guard",on) end)
toggleCard("كشف البيض والمال","الحيوان والندرة والدخل بالأخضر (K M B T Q) ثانية ودقيقة",function(on) return F.esp("egg",on) end)
buttonCard("نسخ أسماء الزعماء","ينسخ كل أسماء الشخصيات للحافظة",function() return F.npcNames() end)
buttonCard("بيانات أقرب بيضة","ينسخ بنية البيضة لضبط الأسماء",function() return F.eggSchema() end)
do
 local n=label(list,"كل شيء هنا يعمل على جهازك فقط. السيرفر هو الذي يقرر في النهاية، فبعض الأزرار قد لا تؤثر على اللاعبين الآخرين أو الحراس.",10,C.sub)
 n.Size=UDim2.new(1,0,0,36) n.LayoutOrder=nxt()
end

-- الأيقونة العائمة (صورتك)
local floatB=new("ImageButton",{Size=UDim2.fromOffset(58,58),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,44,.5,0),BackgroundColor3=C.panel,Image=iconAsset or "",ScaleType=Enum.ScaleType.Crop,Visible=false,AutoButtonColor=false,ZIndex=10},gui)
corner(floatB,29) stroke(floatB,C.g2,2,.1)
if not iconAsset then
 local l=label(floatB,"L",30,C.g2,true,CENTER) l.Size=UDim2.fromScale(1,1) l.Font=Enum.Font.GothamBlack
end
local function showMenu(v)
 main.Visible=v floatB.Visible=not v
 if v then popIn() end
end
hideB.MouseButton1Click:Connect(function() showMenu(false) end)
draggable(floatB,floatB,function() showMenu(true) end)

local function cleanup()
 if not alive then return end
 alive=false
 for _,k in ipairs({"egg","guard","trap"}) do S.esp[k].on=false pcall(refreshKind,k) end
 pcall(F.freeze,false) pcall(F.trapAuto,false) pcall(F.anti,false)
 S.speed.on=false disc(S.speed.guard) pcall(F.applySpeed)
 disc(S.anti.hc)
 for _,c in ipairs(conns) do disc(c) end
 pcall(function() espF:Destroy() end)
 pcall(function() gui:Destroy() end)
 ENV._SARAB_EGG_CLEANUP=nil
end
ENV._SARAB_EGG_CLEANUP=cleanup
local closeAt=0
closeB.MouseButton1Click:Connect(function()
 if os.clock()<closeAt then cleanup() return end
 closeAt=os.clock()+3 notify("اضغط ✕ مرة أخرى خلال 3 ثوانٍ للإغلاق النهائي","warn")
end)

refreshActive=function() for k,st in pairs(S.esp) do if st.on then refreshKind(k) end end end
track(LP.CharacterAdded:Connect(onChar))
if LP.Character then onChar(LP.Character) end
task.spawn(function() while alive do pcall(tick) task.wait(.5) end end)

---------------- الانترو (5 ثوانٍ) ----------------
local function intro()
 local g=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,8,10),ZIndex=50},gui)
 new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(40,40,46),Color3.fromRGB(6,6,8)),Rotation=90},g)
 local ring=new("Frame",{Size=UDim2.fromOffset(150,150),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.34),BackgroundTransparency=1,ZIndex=51},g)
 corner(ring,75)
 stroke(ring,C.g2,3,0)
 local rg=new("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.5,1),NumberSequenceKeypoint.new(1,0)})},ring.UIStroke)
 local ic=makeIcon(g,120) ic.AnchorPoint=Vector2.new(.5,.5) ic.Position=UDim2.fromScale(.5,.34) ic.ZIndex=52
 local t1=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,50),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.6),Text="LOTRIX VX",TextSize=46,Font=Enum.Font.GothamBlack,TextColor3=C.g2,TextTransparency=1,ZIndex=52},g)
 local t2=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.68),Text="S T E A L   A N   E G G",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=C.g,TextTransparency=1,ZIndex=52},g)
 local bar2=new("Frame",{Size=UDim2.fromOffset(260,6),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.76),BackgroundColor3=C.off,BorderSizePixel=0,ZIndex=52},g)
 corner(bar2,3)
 local fill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.g2,BorderSizePixel=0,ZIndex=53},bar2) corner(fill,3)
 local msg=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.82),Text="",TextSize=14,Font=Enum.Font.SourceSansBold,TextColor3=C.sub,ZIndex=52},g)
 local isc=new("UIScale",{},g)
 local function fit() local v=gui.AbsoluteSize isc.Scale=math.clamp(math.min(v.X/700,v.Y/420),.5,3) end
 fit()
 ic.Size=UDim2.fromOffset(60,60)
 TS:Create(ic,TweenInfo.new(1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(120,120)}):Play()
 task.delay(.5,function() TS:Create(t1,TweenInfo.new(.8),{TextTransparency=0}):Play() end)
 task.delay(1.2,function() TS:Create(t2,TweenInfo.new(.8),{TextTransparency=0}):Play() end)
 local steps={{0,"تهيئة النظام..."},{1.2,"فحص الشخصية..."},{2.4,"تحميل الأدوات..."},{3.6,"تجهيز الواجهة..."},{4.5,"جاهز!"}}
 local t0,si=os.clock(),1
 while alive and os.clock()-t0<5 do
  local e=os.clock()-t0
  while steps[si+1] and e>=steps[si+1][1] do si=si+1 end
  msg.Text=steps[si][2]
  fill.Size=UDim2.fromScale(math.min(1,e/5),1)
  rg.Rotation=(e*180)%360
  task.wait(.05)
 end
 if not alive then return end
 main.Visible=true popIn()
 local o=TS:Create(g,TweenInfo.new(.6),{GroupTransparency=1}) o:Play() o.Completed:Wait()
 g:Destroy()
end
notify("LOTRIX VX جاهز — محلي فقط","ok")
task.spawn(function() local ok,e=pcall(intro) if not ok then main.Visible=true warn("[LOTRIX] intro: "..tostring(e)) end end)
