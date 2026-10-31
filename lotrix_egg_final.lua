--[[ LOTRIX VX — STEAL AN EGG v5.0 | محلي (Client) لـ Delta
     4 أدوات فقط: نوم عميق للزعيم • حذف الفخاخ • كشف تجميع المال • تفريم بيض ]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local CG=game:GetService("CoreGui")
local RepS=game:GetService("ReplicatedStorage")
local PPS=game:GetService("ProximityPromptService")
local HttpS=game:GetService("HttpService")
local LP=Players.LocalPlayer
if not LP then return end
local ENV=(getgenv and getgenv()) or _G
local function ext(n) local ok,v=pcall(function() return ENV[n] end) if ok and type(v)=="function" then return v end end
if type(ENV._SARAB_EGG_CLEANUP)=="function" then pcall(ENV._SARAB_EGG_CLEANUP) end
---------------- بوابة المفتاح (Platoboost) ----------------
-- تعمل قبل بقية السكربت: لا تتحمّل الأدوات إلا بعد تحقق المفتاح.
do
local gateOk=(function()
 --! configuration
 local service=36268 -- your service id, this is used to identify your service.
 local secret="1939b024-6be8-4920-a55b-e141456cbfd6" -- السر: لا تنشر الملف علناً
 local useNonce=true -- use a nonce to prevent replay attacks and request tampering.
 local KEY_FILE="LOTRIX_VX_EGG_KEY.txt" -- حفظ المفتاح على جهازك لتخطي إعادة اللصق (ضع nil لتعطيله)

 --! callbacks
 local onMessage=function(message) end

 --! wait for game to load
 if not game:IsLoaded() then game.Loaded:Wait() end

 --! sha256 (bit32)
 local band,bnot,bxor,rshift,rrotate=bit32.band,bit32.bnot,bit32.bxor,bit32.rshift,bit32.rrotate
 local M32=4294967296
 local K={
  0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
  0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
  0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
  0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
  0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
  0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
  0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
  0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}
 local function w32(n) return string.char(band(rshift(n,24),255),band(rshift(n,16),255),band(rshift(n,8),255),band(n,255)) end
 local function lDigest(msg)
  local len=#msg
  msg=msg.."\128"..string.rep("\0",(55-len)%64).."\0\0\0\0"..w32(len*8)
  local h0,h1,h2,h3,h4,h5,h6,h7=0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
  local w={}
  for i=1,#msg,64 do
   for j=1,16 do
    local b1,b2,b3,b4=string.byte(msg,i+(j-1)*4,i+(j-1)*4+3)
    w[j]=b1*16777216+b2*65536+b3*256+b4
   end
   for j=17,64 do
    local x,y=w[j-15],w[j-2]
    w[j]=(w[j-16]+bxor(rrotate(x,7),rrotate(x,18),rshift(x,3))+w[j-7]+bxor(rrotate(y,17),rrotate(y,19),rshift(y,10)))%M32
   end
   local a,b,c,d,e,f,g,h=h0,h1,h2,h3,h4,h5,h6,h7
   for j=1,64 do
    local t1=(h+bxor(rrotate(e,6),rrotate(e,11),rrotate(e,25))+bxor(band(e,f),band(bnot(e),g))+K[j]+w[j])%M32
    local t2=(bxor(rrotate(a,2),rrotate(a,13),rrotate(a,22))+bxor(band(a,b),band(a,c),band(b,c)))%M32
    h=g g=f f=e e=(d+t1)%M32 d=c c=b b=a a=(t1+t2)%M32
   end
   h0=(h0+a)%M32 h1=(h1+b)%M32 h2=(h2+c)%M32 h3=(h3+d)%M32 h4=(h4+e)%M32 h5=(h5+f)%M32 h6=(h6+g)%M32 h7=(h7+h)%M32
  end
  return string.format("%08x%08x%08x%08x%08x%08x%08x%08x",h0,h1,h2,h3,h4,h5,h6,h7)
 end

 --! json (HttpService)
 local function lEncode(t) return HttpS:JSONEncode(t) end
 local function lDecode(s)
  local ok,v=pcall(function() return HttpS:JSONDecode(s) end)
  if ok and type(v)=="table" then return v end
 end

 --! functions
 local requestSending=false
 local fSetClipboard,fRequest,fStringChar,fToString,fStringSub,fOsTime,fMathRandom,fMathFloor,fGetHwid=setclipboard or toclipboard,request or http_request or syn_request,string.char,tostring,string.sub,os.time,math.random,math.floor,gethwid or function() return LP.UserId end
 local cachedLink,cachedTime="",0
 local identifier
 local function getId()
  if not identifier then
   local ok,h=pcall(fGetHwid)
   identifier=lDigest(fToString(ok and h or LP.UserId))
  end
  return identifier
 end
 local function send(opts)
  if not fRequest then return nil end
  local ok,res=pcall(fRequest,opts)
  if ok and type(res)=="table" then return res end
 end

 --! pick host (يُحدَّد عند التهيئة)
 local host="https://api.platoboost.com"
 local function pickHost()
  local r=send({Url=host.."/public/connectivity",Method="GET"})
  if not r or (r.StatusCode~=200 and r.StatusCode~=429) then host="https://api.platoboost.net" end
 end

 local function cacheLink()
  if cachedTime+(10*60)<fOsTime() then
   local response=send({
    Url=host.."/public/start",
    Method="POST",
    Body=lEncode({service=service,identifier=getId()}),
    Headers={["Content-Type"]="application/json"}
   })
   if response and response.StatusCode==200 then
    local decoded=lDecode(response.Body)
    if decoded and decoded.success==true and type(decoded.data)=="table" and decoded.data.url then
     cachedLink=decoded.data.url
     cachedTime=fOsTime()
     return true,cachedLink
    else
     local msg=fToString(decoded and decoded.message or "تعذر إنشاء الرابط")
     onMessage(msg)
     return false,msg
    end
   elseif response and response.StatusCode==429 then
    local msg="طلبات كثيرة، انتظر 20 ثانية ثم أعد المحاولة"
    onMessage(msg)
    return false,msg
   end
   local msg="تعذر إنشاء الرابط، تأكد من الاتصال بالإنترنت"
   onMessage(msg)
   return false,msg
  else
   return true,cachedLink
  end
 end

 local generateNonce=function()
  local str=""
  for _=1,16 do
   str=str..fStringChar(fMathFloor(fMathRandom()*(122-97+1))+97)
  end
  return str
 end

 local copyLink=function()
  local success,link=cacheLink()
  if success then
   if fSetClipboard then pcall(fSetClipboard,link) else print("[LOTRIX] "..link) end
  end
  return success,link
 end

 -- يتحقق من رد السيرفر (valid + hash) ويرجع true عند النجاح
 local function checkValid(decoded,nonce)
  if useNonce then
   if decoded.data.hash==lDigest("true".."-"..nonce.."-"..secret) then return true end
   onMessage("فشل التحقق من سلامة الرد")
   return false
  end
  return true
 end

 local redeemKey=function(key)
  local nonce=generateNonce()
  local endpoint=host.."/public/redeem/"..fToString(service)
  local body={identifier=getId(),key=key}
  if useNonce then body.nonce=nonce end
  local response=send({
   Url=endpoint,
   Method="POST",
   Body=lEncode(body),
   Headers={["Content-Type"]="application/json"}
  })
  if response and response.StatusCode==200 then
   local decoded=lDecode(response.Body)
   if not decoded then onMessage("رد غير صالح من السيرفر") return false,"error" end
   if decoded.success==true and type(decoded.data)=="table" then
    if decoded.data.valid==true then
     return checkValid(decoded,nonce),"error"
    else
     onMessage("المفتاح غير صحيح")
     return false,"invalid"
    end
   else
    local m=fToString(decoded.message or "")
    if fStringSub(m,1,27)=="unique constraint violation" then
     onMessage("لديك مفتاح فعّال بالفعل، انتظر انتهاءه قبل استخدام مفتاح جديد")
    else
     onMessage(m~="" and m or "رفض السيرفر الطلب")
    end
    return false,"error"
   end
  elseif response and response.StatusCode==429 then
   onMessage("طلبات كثيرة، انتظر 20 ثانية ثم أعد المحاولة")
   return false,"error"
  else
   onMessage("السيرفر لم يستجب، حاول لاحقاً")
   return false,"error"
  end
 end

 -- يرجع: (نجح؟، السبب) — السبب "invalid" فقط إذا المفتاح نفسه خاطئ/منتهي
 local verifyKey=function(key)
  if requestSending==true then
   onMessage("يوجد طلب قيد التنفيذ، انتظر قليلاً")
   return false,"error"
  end
  requestSending=true
  local nonce=generateNonce()
  local endpoint=host.."/public/whitelist/"..fToString(service).."?identifier="..getId().."&key="..HttpS:UrlEncode(key)
  if useNonce then endpoint=endpoint.."&nonce="..nonce end
  local response=send({Url=endpoint,Method="GET"})
  requestSending=false
  if response and response.StatusCode==200 then
   local decoded=lDecode(response.Body)
   if not decoded then onMessage("رد غير صالح من السيرفر") return false,"error" end
   if decoded.success==true and type(decoded.data)=="table" then
    if decoded.data.valid==true then
     return checkValid(decoded,nonce),"error"
    else
     if fStringSub(key,1,4)=="KEY_" then
      return redeemKey(key)
     else
      onMessage("المفتاح غير صحيح")
      return false,"invalid"
     end
    end
   else
    onMessage(fToString(decoded.message or "رفض السيرفر الطلب"))
    return false,"error"
   end
  elseif response and response.StatusCode==429 then
   onMessage("طلبات كثيرة، انتظر 20 ثانية ثم أعد المحاولة")
   return false,"error"
  else
   onMessage("السيرفر لم يستجب، حاول لاحقاً")
   return false,"error"
  end
 end

 -- غير مستخدمة حالياً: أعلام (flags) من لوحة Platoboost
 local getFlag=function(name)
  local nonce=generateNonce()
  local endpoint=host.."/public/flag/"..fToString(service).."?name="..HttpS:UrlEncode(name)
  if useNonce then endpoint=endpoint.."&nonce="..nonce end
  local response=send({Url=endpoint,Method="GET"})
  if response and response.StatusCode==200 then
   local decoded=lDecode(response.Body)
   if decoded and decoded.success==true and type(decoded.data)=="table" then
    if useNonce then
     if decoded.data.hash==lDigest(fToString(decoded.data.value).."-"..nonce.."-"..secret) then return decoded.data.value end
     onMessage("فشل التحقق من سلامة الرد")
     return nil
    end
    return decoded.data.value
   elseif decoded then
    onMessage(fToString(decoded.message or ""))
   end
  end
  return nil
 end

 --! حفظ المفتاح محلياً
 local rf,wf,isf=ext("readfile"),ext("writefile"),ext("isfile")
 local function loadSaved()
  if not (KEY_FILE and rf and isf) then return nil end
  local ok,v=pcall(function() if isf(KEY_FILE) then return rf(KEY_FILE) end end)
  if ok and type(v)=="string" then
   v=v:gsub("%s+","")
   if v~="" then return v end
  end
 end
 local function saveKey(k) if KEY_FILE and wf then pcall(wf,KEY_FILE,k) end end

 ---------------- واجهة المفتاح ----------------
 local P={bg=Color3.fromRGB(13,13,15),panel=Color3.fromRGB(22,22,26),card=Color3.fromRGB(33,33,38),
  g=Color3.fromRGB(196,198,208),g2=Color3.fromRGB(236,237,242),gd=Color3.fromRGB(72,72,82),
  text=Color3.fromRGB(240,240,244),sub=Color3.fromRGB(150,150,160),
  amber=Color3.fromRGB(255,214,90),red=Color3.fromRGB(255,84,84),ok=Color3.fromRGB(60,255,140)}
 local gh=ext("gethui")
 local gHost
 if gh then local ok,h=pcall(gh) if ok and h then gHost=h end end
 if not gHost then
  local ok=pcall(function() local t=Instance.new("Folder") t.Parent=CG t:Destroy() end)
  gHost=ok and CG or LP:WaitForChild("PlayerGui")
 end
 local GN="LOTRIX_KEYGATE"
 pcall(function() local o=gHost:FindFirstChild(GN) if o then o:Destroy() end end)

 local function new(cls,props,parent)
  local o=Instance.new(cls)
  for k,v in pairs(props or {}) do o[k]=v end
  if parent then o.Parent=parent end
  return o
 end
 local function round(o,r) new("UICorner",{CornerRadius=UDim.new(0,r)},o) end
 local function outline(o,c,t) new("UIStroke",{Color=c,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
 local function text(parent,t,sz,col,font,pos,size)
  return new("TextLabel",{BackgroundTransparency=1,Text=t,TextSize=sz,TextColor3=col,Font=font,TextWrapped=true,Position=pos,Size=size},parent)
 end

 local DW,DH=400,310
 local gui=new("ScreenGui",{Name=GN,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=1000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},gHost)
 local uiScale=new("UIScale",{},gui)
 local function rescale()
  local cam=WS.CurrentCamera
  local v=cam and cam.ViewportSize or Vector2.new(1000,600)
  uiScale.Scale=math.clamp(math.min(v.X*.85/DW,v.Y*.85/DH),.5,2.5)
 end
 rescale()
 local camConn
 pcall(function() camConn=WS.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale) end)

 new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.45,BorderSizePixel=0},gui)
 local card=new("Frame",{Size=UDim2.fromOffset(DW,DH),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=P.bg,BorderSizePixel=0},gui)
 round(card,14) outline(card,P.gd,1.5)

 local closeB=new("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(8,8),BackgroundColor3=P.card,Text="✕",TextSize=16,TextColor3=P.sub,Font=Enum.Font.GothamBold,AutoButtonColor=true},card)
 round(closeB,8)
 text(card,"LOTRIX VX",28,P.g2,Enum.Font.GothamBlack,UDim2.fromOffset(50,12),UDim2.fromOffset(DW-100,34))
 text(card,"STEAL AN EGG  •  نظام المفتاح",15,P.sub,Enum.Font.SourceSansBold,UDim2.fromOffset(20,48),UDim2.fromOffset(DW-40,20))
 text(card,"انسخ الرابط  •  أكمل المهام  •  الصق المفتاح  •  تحقق",14,P.sub,Enum.Font.SourceSansBold,UDim2.fromOffset(20,76),UDim2.fromOffset(DW-40,34))

 local function button(t,y,bg,fg)
  local b=new("TextButton",{Size=UDim2.fromOffset(DW-32,40),Position=UDim2.fromOffset(16,y),BackgroundColor3=bg,Text=t,TextSize=17,TextColor3=fg,Font=Enum.Font.GothamBold,AutoButtonColor=true},card)
  round(b,10) outline(b,P.gd,1)
  return b
 end
 local copyB=button("نسخ رابط المفتاح",118,P.card,P.text)
 local keyBox=new("TextBox",{Size=UDim2.fromOffset(DW-32,40),Position=UDim2.fromOffset(16,168),BackgroundColor3=P.panel,Text="",PlaceholderText="الصق المفتاح هنا",PlaceholderColor3=P.sub,TextSize=16,TextColor3=P.text,Font=Enum.Font.Code,ClearTextOnFocus=false,TextWrapped=false,ClipsDescendants=true},card)
 round(keyBox,10) outline(keyBox,P.gd,1)
 local verifyB=button("تحقق من المفتاح",218,P.g2,P.bg)
 local statusL=text(card,"جاري التهيئة...",14,P.sub,Enum.Font.SourceSansBold,UDim2.fromOffset(16,266),UDim2.fromOffset(DW-32,34))

 local SC={ok=P.ok,warn=P.amber,err=P.red,info=P.sub}
 local function setStatus(t,k)
  if statusL and statusL.Parent then statusL.Text=tostring(t) statusL.TextColor3=SC[k or "info"] or P.sub end
 end
 onMessage=function(m) setStatus(m,"warn") print("[LOTRIX] "..tostring(m)) end

 ---------------- التشغيل ----------------
 local state="wait" -- wait | ok | closed
 local ready,busy=false,false
 local function finish(s) if state=="wait" then state=s end end
 local function gateCleanup() finish("closed") end
 ENV._SARAB_EGG_CLEANUP=gateCleanup -- إعادة تشغيل السكربت تُغلق البوابة القديمة

 closeB.MouseButton1Click:Connect(function() finish("closed") end)

 copyB.MouseButton1Click:Connect(function()
  if not ready or busy then setStatus(ready and "انتظر قليلاً..." or "جاري التهيئة...","info") return end
  busy=true
  setStatus("جاري إنشاء الرابط...","info")
  local ok,link=copyLink()
  busy=false
  if ok then
   setStatus(fSetClipboard and "تم نسخ الرابط، افتحه في المتصفح وأكمل المهام" or "الرابط طُبع في الكونسول (F9)","ok")
  end
 end)

 local function doVerify(key)
  if not ready or busy then setStatus(ready and "انتظر قليلاً..." or "جاري التهيئة...","info") return end
  key=key:gsub("%s+","")
  if key=="" then setStatus("الصق المفتاح أولاً","warn") return end
  busy=true
  setStatus("جاري التحقق...","info")
  local ok,reason=verifyKey(key)
  busy=false
  if ok then
   saveKey(key)
   setStatus("تم التحقق ✓","ok")
   finish("ok")
  elseif reason=="invalid" then
   saveKey("")
  end
 end
 verifyB.MouseButton1Click:Connect(function() doVerify(keyBox.Text) end)

 task.spawn(function()
  if not fRequest then
   setStatus("المشغّل لا يدعم الطلبات (request)","err")
   return
  end
  -- فحص عشوائية الـnonce (من مكتبة Platoboost)
  for _=1,5 do
   local oNonce=generateNonce()
   task.wait(.2)
   if generateNonce()==oNonce then
    onMessage("platoboost nonce error.")
    setStatus("خطأ في التهيئة (nonce)","err")
    return
   end
  end
  pickHost()
  ready=true
  setStatus("انسخ الرابط وأكمل المهام ثم الصق المفتاح","info")
  task.spawn(cacheLink)
  local saved=loadSaved()
  if saved then
   keyBox.Text=saved
   setStatus("جاري التحقق من المفتاح المحفوظ...","info")
   doVerify(saved)
  end
 end)

 while state=="wait" and gui.Parent do task.wait(.1) end
 if state=="ok" then task.wait(.6) end
 pcall(function() if camConn then camConn:Disconnect() end end)
 pcall(function() gui:Destroy() end)
 if ENV._SARAB_EGG_CLEANUP==gateCleanup then ENV._SARAB_EGG_CLEANUP=nil end
 return state=="ok"
end)()
if not gateOk then return end
end

---------------- الإعدادات ----------------
local CFG={
 Name="LOTRIX_VX_EGG",Ver="v5.0",
 GuardWords={"guard","boss","حارس"},
 TrapWords={"trap","snare","tripwire","landmine","spike","فخ"},
 RefreshSec=260, -- تحديث قائمة البيض كل 4 دقائق و20 ثانية
}
local WAYPOINTS={
 CFrame.new(4747.71,70.57,-335.25),
 CFrame.new(3520.94,70.73,-343.74),
 CFrame.new(2446.02,70.88,-351.18),
 CFrame.new(1352.11,71.02,-358.75),
 CFrame.new(544.49,71.13,-364.34),
}
local ROUTE_WAIT=0.4

---------------- الحالة ----------------
local S={busy=false,eggs={},sel=nil,carry=false,nextAt=0,scanning=false,
 freeze={on=false,list={},saved={}},bossOn=false,trap={on=false},mon={on=false,map={}},
 steal={on=false,token=0,active=false},ev={reg={},raw={},n=0,hooked={}},pen={eggs={},nextScan=0,lastBuild=0}}
local alive,conns,F=true,{},{}
local statusLabel
local function track(c) conns[#conns+1]=c return c end
local function disc(c) if c then pcall(function() c:Disconnect() end) end end

local C={bg=Color3.fromRGB(13,13,15),panel=Color3.fromRGB(22,22,26),card=Color3.fromRGB(33,33,38),
 g=Color3.fromRGB(196,198,208),g2=Color3.fromRGB(236,237,242),gd=Color3.fromRGB(72,72,82),
 text=Color3.fromRGB(240,240,244),sub=Color3.fromRGB(150,150,160),off=Color3.fromRGB(58,58,66),
 amber=Color3.fromRGB(255,214,90),red=Color3.fromRGB(255,84,84),money=Color3.fromRGB(60,255,140),white=Color3.new(1,1,1)}
local KC={ok=C.money,warn=C.amber,err=C.red,info=C.sub}
local function notify(t,k)
 print("[LOTRIX] "..tostring(t))
 if statusLabel and statusLabel.Parent then statusLabel.Text=tostring(t) statusLabel.TextColor3=KC[k or "info"] or C.sub end
end
local function getChar() return LP.Character end
local function getHum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function copyText(t) local f=ext("setclipboard") or ext("toclipboard") if f then return (pcall(f,t)) end return false end

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
local function fmtTime(s) s=math.max(0,math.floor(s)) return string.format("%d:%02d",math.floor(s/60),s%60) end

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
local NOISE={eggfitbounds=1,eggpoint=1,eggbounds=1}
local function isNoise(i) return NOISE[string.lower(i.Name)]~=nil end
local function primary(i)
 if i:IsA("BasePart") then return i end
 if i:IsA("Model") then return i.PrimaryPart or i:FindFirstChildWhichIsA("BasePart",true) end
end
local function posOf(i)
 local ok,cf=pcall(function() return i:GetPivot() end)
 if ok and cf then return cf.Position end
 local p=primary(i) return p and p.Position
end

local host
do
 local gh=ext("gethui")
 if gh then local ok,h=pcall(gh) if ok and h then host=h end end
 if not host then
  local ok=pcall(function() local t=Instance.new("Folder") t.Parent=CG t:Destroy() end)
  host=ok and CG or LP:WaitForChild("PlayerGui")
 end
 for _,p in ipairs({host,LP:FindFirstChild("PlayerGui")}) do
  if p then pcall(function() for _,n in ipairs({CFG.Name,"SARAB_EGG_ESP","LOTRIX_EGG_ESP"}) do local o=p:FindFirstChild(n) if o then o:Destroy() end end end) end
 end
end
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
 {"Cave Dragon","تنين الكهف"},{"Kitsune","كيتسوني","Divine",4.8e10},{"Night Flame","اللهب الليلي","Divine",8e10},{"Archangel","رئيس الملائكة","Divine",2.27e11},{"World Burner","محرق العالم","Divine",5e11},{"Aetherion","إيثيريون","Divine",7.1e11},{"Royal Sky Whale","حوت السماء الملكي","Divine",4.22e11},
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
local AREA={
 ["Enchanted Forest"]={"الغابة المسحورة","أرواح الغابة","50B"},["Abyss Ocean"]={"المحيط العميق","حارس الأعماق","2.5M"},
 ["Cosmic"]={"الكون","الحارس الكوني","700M"},["Volcano"]={"البركان","سيربيروس","700K"},["Snow"]={"الثلج","اليتي","170K"},
 ["Forest"]={"الغابة","الدجاجة","0"},["Cherry Blossom"]={"زهر الكرز","كيتسوني","2.5B"},["Desert"]={"الصحراء","العقرب","10K"},
 ["Prehistoric"]={"ما قبل التاريخ","تي ريكس","18M"},["Light Dark"]={"الملائكة والشياطين","حراس النور والظلام","20B"},
 ["Jungle"]={"الأدغال","النمر","40K"},["Lake"]={"البحيرة","البجعة","900"},["Titan Temple"]={"معبد العمالقة","الغوريلا العملاق","7B"},
}
---------------- الأيقونة (صورتك) ----------------
local ICON_B64=[==[
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
]==]
local INTRO_B64=[==[
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
]==]
local introAsset
do
 local wf,gca=ext("writefile"),(ext("getcustomasset") or ext("getsynasset"))
 if wf and gca then
  pcall(function()
   local A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   local map={} for i=1,64 do map[string.byte(A,i)]=i-1 end
   local data=INTRO_B64:gsub("%s","")
   local out={}
   for i=1,#data,4 do
    local a,b,c,d=string.byte(data,i,i+3)
    local n=map[a]*262144+map[b]*4096+(map[c] or 0)*64+(map[d] or 0)
    local c1,c2,c3=math.floor(n/65536),math.floor(n/256)%256,n%256
    if d==61 then
     if c==61 then out[#out+1]=string.char(c1) else out[#out+1]=string.char(c1,c2) end
    else out[#out+1]=string.char(c1,c2,c3) end
   end
   wf("lotrix_intro.jpg",table.concat(out))
   introAsset=gca("lotrix_intro.jpg")
  end)
 end
end

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


local AREA_ORDER={"Forest","Lake","Desert","Jungle","Snow","Volcano","Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple","Light Dark","Enchanted Forest"}
local AREA_RANK={} for i,a in ipairs(AREA_ORDER) do AREA_RANK[a]=i end
local function areaAr(a) local e=a and AREA[a] return e and e[1] or "منطقة غير معروفة" end

---------------- أحداث البيض من السيرفر (قراءة فقط) ----------------
local function evShow(v,d)
 d=d or 0
 local t=typeof(v)
 if t=="table" then
  if d>=3 then return "{...}" end
  local p,n={},0
  for k,x in pairs(v) do n=n+1 if n>30 then p[#p+1]="..." break end p[#p+1]=tostring(k).."="..evShow(x,d+1) end
  return "{"..table.concat(p,", ").."}"
 elseif t=="CFrame" then local q=v.Position return string.format("CF(%.0f,%.0f,%.0f)",q.X,q.Y,q.Z)
 elseif t=="Instance" then local ok,r=pcall(function() return v:GetFullName() end) return ok and r or tostring(v)
 end
 return tostring(v)
end
local function eggHandle(t)
 if type(t)~="table" then return end
 if not (t.AssetCategory or t.BoundsCFrame or t.Uid or t.Category) then return end
 if not t.Uid and not t.NestId then return end
 -- NestId (Slot_001...) يتكرر في كل المناطق، لذلك المفتاح هو Uid أو المنطقة+العش
 local key=t.Uid and tostring(t.Uid) or (tostring(t.AreaId or "")..":"..tostring(t.NestId))
 local rec=S.ev.reg[key]
 if not rec then rec={data={}} S.ev.reg[key]=rec end
 for k,v in pairs(t) do rec.data[k]=v end
 rec.t=os.clock()
end
local function onEggEvent(...)
 local args={...}
 S.ev.n=S.ev.n+1
 S.ev.raw[#S.ev.raw+1]=string.format("[%.1f] ",os.clock()%1000)..evShow(args)
 while #S.ev.raw>40 do table.remove(S.ev.raw,1) end
 for _,a in ipairs(args) do
  if type(a)=="table" then
   eggHandle(a)
   for _,x in pairs(a) do if type(x)=="table" then eggHandle(x) end end
  end
 end
end
local function onCarry(t)
 if type(t)~="table" or t.IsCarrying==nil then return end
 S.carry=(t.IsCarrying==true)
 if S.carry then
  S.carryAt=os.clock()
  if S.bossOn then pcall(F.alarmWindow) end
  if S.bossOn and not S.steal.active then F.bossRoute() end
 end
end
-- بيضك داخل العش: السيرفر يرسل لكل بيضة {uid, amount} (amount = دخلها بالثانية، مجموعها = زيادة مالك كل ثانية)
local function onPen(list)
 if type(list)~="table" then return end
 for _,x in pairs(list) do
  if type(x)=="table" and x.uid and type(x.amount)=="number" then
   local u=tostring(x.uid)
   local e=S.pen.eggs[u]
   if not e then e={} S.pen.eggs[u]=e end
   e.amount=x.amount e.t=os.clock()
  end
 end
end
local function hookEvents()
 for _,d in ipairs(RepS:GetDescendants()) do
  if d:IsA("RemoteEvent") and d.Name=="Rouse" and not S.ev.hooked[d] then
   S.ev.hooked[d]=true
   pcall(function() track(d.OnClientEvent:Connect(function() if S.bossOn and F.alarmWindow then pcall(F.alarmWindow) end end)) end)
  end
  if d:IsA("RemoteEvent") and d.Name=="CoinsGathered" and not S.ev.hooked[d] then
   S.ev.hooked[d]=true
   pcall(function() track(d.OnClientEvent:Connect(onPen)) end)
  end
 end
 for _,d in ipairs(RepS:GetDescendants()) do
  if d:IsA("RemoteEvent") and not S.ev.hooked[d] and string.find(d:GetFullName(),"EggWorld",1,true) then
   S.ev.hooked[d]=true
   local isCarry=(d.Name=="FieldEggCarry")
   pcall(function()
    track(d.OnClientEvent:Connect(function(...)
     onEggEvent(...)
     if isCarry then onCarry((...)) end
    end))
   end)
  end
 end
end

---------------- مسح البيض ----------------
local function areaRoot()
 local w=WS:FindFirstChild("World")
 local a=w and w:FindFirstChild("Areas")
 return a and a:FindFirstChild("GuardAreas")
end
local function areaOf(i,root)
 local o=i
 for _=1,16 do
  if not o or o==WS or o==game then return nil end
  if o.Parent and root and o.Parent==root then return o.Name end
  o=o.Parent
 end
end
local function hasRecord(m)
 local n=0
 for _,d in ipairs(m:GetDescendants()) do
  n=n+1 if n>80 then break end
  if d:IsA("StringValue") and string.find(string.lower(d.Name),"record",1,true) then return true end
 end
 return false
end
local function eggCandidate(d)
 if not (d:IsA("Model") or d:IsA("BasePart")) then return false end
 if inChar(d) or inTread(d) or isNoise(d) then return false end
 if d:GetAttribute("GuardState")~=nil or string.lower(d.Name)=="guard" then return false end
 if d:GetAttribute("AssetCategory")~=nil then return true end
 if d:IsA("Model") then
  if findPet(d.Name,true) then return true end
  if hasWord(d.Name,{"egg","pet"}) and not hasWord(d.Name,{"nest","bound","point","fit","pen","hatch","tread"}) and hasRecord(d) then return true end
 end
 return false
end
-- يقرأ أرقام المال من خصائص/قيم البيضة: rate بالثانية، stored مبلغ متجمّع
local function readMoney(inst)
 local rate,stored,other
 local function put(k,v)
  if type(v)~="number" then return end
  local l=string.lower(tostring(k))
  if string.find(l,"min",1,true) and (string.find(l,"coin",1,true) or string.find(l,"money",1,true) or string.find(l,"income",1,true)) then rate=rate or (v/60) return end
  if string.find(l,"persec",1,true) or string.find(l,"per_sec",1,true) or string.find(l,"rate",1,true) or string.find(l,"income",1,true) or string.find(l,"produc",1,true) or string.find(l,"earn",1,true) or string.find(l,"profit",1,true) then rate=rate or v return end
  if string.find(l,"stored",1,true) or string.find(l,"gather",1,true) or string.find(l,"collect",1,true) or string.find(l,"accum",1,true) or string.find(l,"pending",1,true) or string.find(l,"balance",1,true) then stored=stored or v return end
  if string.find(l,"coin",1,true) or string.find(l,"money",1,true) or string.find(l,"cash",1,true) then other=other or v end
 end
 for k,v in pairs(inst:GetAttributes()) do put(k,v) end
 local n=0
 for _,d in ipairs(inst:GetDescendants()) do
  n=n+1 if n>80 then break end
  if d:IsA("NumberValue") or d:IsA("IntValue") then put(d.Name,d.Value) end
  for k,v in pairs(d:GetAttributes()) do put(k,v) end
 end
 return rate,stored,other
end
local function entryFromInst(inst,root)
 local cat=inst:GetAttribute("AssetCategory")
 local muts
 local n=0
 for _,d in ipairs(inst:GetDescendants()) do
  n=n+1 if n>80 then break end
  if d:IsA("StringValue") and string.find(string.lower(d.Name),"record",1,true) then
   pcall(function()
    local t=HttpS:JSONDecode(d.Value)
    if type(t)=="table" and t.Category then
     cat=tostring(t.Category)
     if type(t.Mutations)=="table" and #t.Mutations>0 then muts=table.concat(t.Mutations,"، ") end
    end
   end)
  end
 end
 local pet=(cat and findPet(tostring(cat),false)) or findPet(inst.Name,false)
 local rate,stored,other=readMoney(inst)
 local en=pet and pet[1] or tostring(cat or inst.Name)
 local a=areaOf(inst,root)
 local pos=posOf(inst)
 if not pos then return nil end
 return {inst=inst,pos=pos,nameEn=en,nameAr=pet and pet[2] or en,rar=pet and pet[3] and (RAR[pet[3]] or pet[3]),
  rate=rate or (pet and pet[4]),stored=stored or other,muts=muts,area=a,
  key=string.format("%s|%s|%d|%d",tostring(a),en,math.floor(pos.X/4),math.floor(pos.Z/4))}
end
local function nearestArea(pos,root)
 if not root then return nil end
 local best,bd
 for _,ar in ipairs(root:GetChildren()) do
  local p=ar:FindFirstChild("Guard") and primary(ar.Guard) or ar:FindFirstChildWhichIsA("BasePart",true)
  if p then
   local d=(p.Position-pos).Magnitude
   if not bd or d<bd then best,bd=ar.Name,d end
  end
 end
 if bd and bd<700 then return best end
end
local function scanEggs()
 local list,got={},{}
 local root=areaRoot()
 local scanRoot=root or WS
 local n=0
 for _,d in ipairs(scanRoot:GetDescendants()) do
  n=n+1 if n%2500==0 then task.wait() end
  if d.Parent and eggCandidate(d) then
   local o,dup=d.Parent,false
   for _=1,8 do
    if not o or o==scanRoot then break end
    if got[o] then dup=true break end
    o=o.Parent
   end
   if not dup then
    got[d]=true
    local e=entryFromInst(d,root)
    if e then list[#list+1]=e end
   end
  end
 end
 -- بيض معروف من أحداث السيرفر ولم يظهر كمجسّم عندك (بعيد/غير محمّل)
 local seen={}
 for _,rec in pairs(S.ev.reg) do
  if not seen[rec] then
   seen[rec]=true
   local dta=rec.data
   local cf=dta.BoundsCFrame or dta.BottomCFrame
   if typeof(cf)=="CFrame" and os.clock()-(rec.t or 0)<3600 and dta.State~="Carried" and dta.State~="GuardCarried" then
    local p=cf.Position
    local dup=false
    for _,e in ipairs(list) do if (e.pos-p).Magnitude<8 then dup=true break end end
    if not dup then
     local cat=dta.AssetCategory or dta.Category
     local pet=cat and findPet(tostring(cat),false)
     local en=pet and pet[1] or tostring(cat or "Egg")
     local a=(dta.AreaId and tostring(dta.AreaId)) or nearestArea(p,root)
     list[#list+1]={pos=p,nameEn=en,nameAr=pet and pet[2] or ((cat and en) or "بيضة"),rar=pet and pet[3] and (RAR[pet[3]] or pet[3]),
      rate=pet and pet[4],muts=nil,area=a,fromEvent=true,uid=dta.Uid and tostring(dta.Uid) or nil,state=dta.State,
      key=string.format("%s|%s|%d|%d",tostring(a),en,math.floor(p.X/4),math.floor(p.Z/4))}
    end
   end
  end
 end
 table.sort(list,function(x,y)
  local rx,ry=AREA_RANK[x.area or ""] or 99,AREA_RANK[y.area or ""] or 99
  if rx~=ry then return rx<ry end
  return (x.rate or 0)>(y.rate or 0)
 end)
 return list
end
local function eggLines(e)
 local l1="🥚 "..e.nameAr..(e.rar and (" — "..e.rar) or "").."  •  "..areaAr(e.area)
 local l2
 if e.rate then l2='<font color="#3CFF8C">💰 '..abbr(e.rate).."/ث • "..abbr(e.rate*60).."/د</font>" else l2="💰 الدخل غير معروف" end
 if e.stored then l2=l2..'  <font color="#3CFF8C">🧺 '..abbr(e.stored).."</font>" end
 return l1,l2
end

---------------- كشف تجميع المال (فوق كل بيضة) ----------------
local espF=Instance.new("Folder") espF.Name="LOTRIX_EGG_ESP"
local function clearEsp()
 for _,m in pairs(S.mon.map) do pcall(function() m.b:Destroy() end) pcall(function() if m.pt then m.pt:Destroy() end end) end
 S.mon.map={}
end
local function paintEsp()
 clearEsp()
 if not S.mon.on then return end
 local cnt=0
 for _,e in ipairs(S.eggs) do
  if cnt>=120 then break end
  local adornee,pt
  if e.inst and e.inst.Parent then adornee=primary(e.inst) end
  if not adornee then
   pt=Instance.new("Part") pt.Name="LOTRIX_EggMark" pt.Anchored=true pt.CanCollide=false pt.CanQuery=false pt.CanTouch=false pt.Transparency=1 pt.Size=Vector3.new(1,1,1) pt.Position=e.pos pt.Parent=WS
   adornee=pt
  end
  local ok,bb,ll=pcall(function()
   local b=Instance.new("BillboardGui") b.Adornee=adornee b.Size=UDim2.fromOffset(250,58) b.StudsOffset=Vector3.new(0,3.5,0) b.AlwaysOnTop=true b.MaxDistance=500 b.Parent=espF
   local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.fromScale(1,1) l.Font=Enum.Font.SourceSansBold l.TextSize=15 l.TextColor3=C.g2 l.TextStrokeTransparency=.3 l.TextWrapped=true l.RichText=true l.Parent=b
   return b,l
  end)
  if ok then
   local l1,l2=eggLines(e)
   ll.Text=l1.."\n"..l2
   S.mon.map[e.key..cnt]={b=bb,pt=pt,l=ll,e=e}
   cnt=cnt+1
  elseif pt then pcall(function() pt:Destroy() end) end
 end
end
local function updateEspText()
 for _,m in pairs(S.mon.map) do
  local e=m.e
  if e.inst and e.inst.Parent and m.l and m.l.Parent then
   local rate,stored,other=readMoney(e.inst)
   if rate then e.rate=rate end
   if stored or other then e.stored=stored or other end
   local l1,l2=eggLines(e)
   m.l.Text=l1.."\n"..l2
  end
 end
end

---------------- تحديث القائمة ----------------
local rebuildList -- يُعرَّف في الواجهة
function F.refresh(silent)
 if S.scanning then return end
 S.scanning=true
 task.spawn(function()
  pcall(hookEvents)
  local ok,res=pcall(scanEggs)
  S.scanning=false
  S.nextAt=os.clock()+CFG.RefreshSec
  if not alive then return end
  if not ok then notify("خطأ أثناء مسح البيض: "..tostring(res),"err") return end
  S.eggs=res
  if S.sel then
   local still=false
   for _,e in ipairs(res) do if e.key==S.sel then still=true break end end
   if not still then
    S.sel=nil
    if S.steal.on and not S.steal.active then F.steal(false) F.stealSet(false) end
   end
  end
  pcall(paintEsp)
  if rebuildList then pcall(rebuildList) end
  if not silent then
   if #res==0 then notify("لا بيض ظاهر الآن — اقترب من أعشاش الحراس (اللعبة تحمّل القريب فقط) ثم حدّث","warn")
   else notify("تم العثور على "..#res.." بيضة","ok") end
  end
 end)
end

function F.money(on)
 S.mon.on=on
 if not on then clearEsp() return true,"تم إيقاف كشف المال","info" end
 if #S.eggs>0 then paintEsp() end
 F.refresh(false)
 return true,"كشف المال مفعّل — جارٍ مسح البيض...","warn"
end

---------------- الزعماء: طريقة البرومبت + مسار الانتقال ----------------
local promptState={enabled=false,original={},desc=nil,shown=nil,triggered=nil,busy=false}

local function patchBossPrompt(obj)
 if not promptState.enabled or not obj or not obj:IsA("ProximityPrompt") then return end
 if promptState.original[obj]==nil then
  promptState.original[obj]={hold=obj.HoldDuration,line=obj.RequiresLineOfSight}
 end
 pcall(function()
  obj.HoldDuration=0
  obj.RequiresLineOfSight=false
 end)
end

local function restoreBossPrompts()
 for prompt,values in pairs(promptState.original) do
  if prompt and prompt.Parent then
   pcall(function()
    prompt.HoldDuration=values.hold
    prompt.RequiresLineOfSight=values.line
   end)
  end
 end
 table.clear(promptState.original)
end

local function bossPromptTriggered(prompt,player)
 if not promptState.enabled or player~=LP or promptState.busy then return end
 local character=LP.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not humanoid or not root or humanoid.Health<=0 then return end

 promptState.busy=true
 task.spawn(function()
  local camera=WS.CurrentCamera
  local savedCameraType=camera and camera.CameraType
  local savedCameraCFrame=camera and camera.CFrame
  local savedPlatformStand=humanoid.PlatformStand
  local savedBreakJoints=humanoid.BreakJointsOnDeath

  local ok,err=pcall(function()
   if camera then
    camera.CameraType=Enum.CameraType.Scriptable
    camera.CFrame=savedCameraCFrame
   end
   humanoid.BreakJointsOnDeath=false
   for _,d in ipairs(character:GetDescendants()) do
    if d:IsA("Motor6D") then d.Enabled=true end
   end

   root.AssemblyLinearVelocity=Vector3.zero
   root.AssemblyAngularVelocity=Vector3.zero

   for _,waypoint in ipairs(WAYPOINTS) do
    if not promptState.enabled or not root.Parent or humanoid.Health<=0 then break end
    humanoid.PlatformStand=true
    humanoid.Health=math.min(100,humanoid.MaxHealth)
    root.CFrame=waypoint
    root.AssemblyLinearVelocity=Vector3.zero
    if camera and savedCameraCFrame then camera.CFrame=savedCameraCFrame end
    task.wait(0.02)
   end

   local finalCFrame=WAYPOINTS[#WAYPOINTS]
   local finish=os.clock()+0.35
   while promptState.enabled and os.clock()<finish and root.Parent and humanoid.Health>0 do
    humanoid.Health=math.min(100,humanoid.MaxHealth)
    root.CFrame=finalCFrame
    root.AssemblyLinearVelocity=Vector3.zero
    if camera and savedCameraCFrame then camera.CFrame=savedCameraCFrame end
    RS.Heartbeat:Wait()
   end
  end)

  pcall(function()
   if humanoid.Parent then
    humanoid.PlatformStand=savedPlatformStand
    humanoid.BreakJointsOnDeath=savedBreakJoints
   end
   if camera then
    camera.CameraType=savedCameraType
    if savedCameraCFrame then camera.CFrame=savedCameraCFrame end
   end
  end)
  promptState.busy=false
  if ok then notify("اكتمل مسار التنقّل عبر نقاط الزعماء","ok")
  else notify("تعذّر تنفيذ المسار: "..tostring(err),"err") end
 end)
end

local function setBossPromptMode(on)
 promptState.enabled=on
 if on then
  for _,obj in ipairs(WS:GetDescendants()) do patchBossPrompt(obj) end
  if promptState.desc then disc(promptState.desc) end
  if promptState.shown then disc(promptState.shown) end
  if promptState.triggered then disc(promptState.triggered) end
  promptState.desc=WS.DescendantAdded:Connect(patchBossPrompt)
  promptState.shown=PPS.PromptShown:Connect(patchBossPrompt)
  promptState.triggered=PPS.PromptTriggered:Connect(bossPromptTriggered)
  return true
 end

 disc(promptState.desc) promptState.desc=nil
 disc(promptState.shown) promptState.shown=nil
 disc(promptState.triggered) promptState.triggered=nil
 restoreBossPrompts()
 return true
end

-- توافق مع بقية وظائف السكربت التي تستدعي F.freeze.
function F.freeze(on)
 if not on then return true,"تمت إعادة إعدادات التجميد القديمة","info" end
 return true,"ميزة التجميد القديمة غير مستخدمة في طريقة البرومبت الجديدة","info"
end

-- يبقى مسار البيضة الأصلي متاحاً عند اكتشاف حمل البيضة.
local route={busy=false}
function F.bossRoute(waitForFinish)
 if route.busy or not S.bossOn then return false end
 local root=getRoot()
 if not root then return false end
 route.busy=true
 local origin=root.CFrame
 local done,success=false,false
 task.spawn(function()
  local ok,err=pcall(function()
   for _,cf in ipairs(WAYPOINTS) do
    if not alive or not S.bossOn then break end
    local rr=getRoot()
    if not rr then break end
    rr.CFrame=cf
    rr.AssemblyLinearVelocity=Vector3.zero
    task.wait(ROUTE_WAIT)
   end
  end)
  local rr=getRoot()
  if rr then rr.CFrame=origin rr.AssemblyLinearVelocity=Vector3.zero end
  route.busy=false success=ok done=true
  if ok then notify("انتهى مسار الانتقال وعدت لمكانك","ok")
  else notify("خطأ في مسار الانتقال: "..tostring(err),"err") end
 end)
 if waitForFinish then
  local t0=os.clock()
  while not done and alive and os.clock()-t0<15 do task.wait(0.1) end
  return done and success
 end
 return true
end

---------------- إخفاء إنذار السرقة (محلي) ----------------
local ALERTW={"alert","alarm","warn","stolen","thief","rouse","danger","siren","انذار","إنذار","تحذير","سرق","اركض","اهرب","chase","escape","vignette"}
local SS=game:GetService("SoundService")
S.alarm={untilT=0,log={},conns={},hooked={}}
local function ours(d)
 local o=d
 for _=1,12 do
  if not o then return false end
  if o.Name==CFG.Name then return true end
  o=o.Parent
 end
 return false
end
local function alarmLog(t)
 local a=S.alarm
 if #a.log<30 then a.log[#a.log+1]=t end
 notify("أُخفي إنذار: "..t,"info")
end
local function hideAlarm(d)
 local a=S.alarm
 if not S.bossOn or os.clock()>a.untilT or ours(d) then return end
 if d:IsA("Sound") then
  pcall(function() d.Volume=0 d:Stop() end)
  alarmLog("صوت "..d.Name)
 elseif d:IsA("GuiObject") then
  local txt=(d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
  local tt=string.gsub(txt,"%s","")
  if hasWord(d.Name,ALERTW) or hasWord(txt,ALERTW) or tt=="!" or tt=="!!" or tt=="‼" then
   pcall(function() d.Visible=false end)
   alarmLog(d.Name)
  end
 end
end
function F.alarmWindow()
 local a=S.alarm
 a.untilT=os.clock()+6
 -- أصوات الإنذار التي تعمل الآن
 for _,root in ipairs({SS,LP:FindFirstChild("PlayerGui")}) do
  if root then
   local n=0
   for _,d in ipairs(root:GetDescendants()) do
    n=n+1 if n>1500 then break end
    if d:IsA("Sound") and d.IsPlaying and hasWord(d.Name,ALERTW) then hideAlarm(d) end
   end
  end
 end
end
local function alarmHook(on)
 local a=S.alarm
 for _,c in ipairs(a.conns) do disc(c) end a.conns={}
 a.hooked={}
 if not on then return end
 local pg=LP:FindFirstChild("PlayerGui")
 for _,root in ipairs({pg,SS}) do
  if root then
   a.conns[#a.conns+1]=root.DescendantAdded:Connect(function(d) task.defer(hideAlarm,d) end)
  end
 end
 -- عناصر موجودة مسبقاً قد يُظهرها اللعبة عند الإنذار
 if pg then
  local n=0
  for _,d in ipairs(pg:GetDescendants()) do
   n=n+1 if n>2500 then break end
   if d:IsA("GuiObject") and not ours(d) and hasWord(d.Name,ALERTW) then
    a.conns[#a.conns+1]=d:GetPropertyChangedSignal("Visible"):Connect(function()
     if d.Visible then hideAlarm(d) end
    end)
   end
  end
 end
end
function F.boss(on)
 S.bossOn=on
 pcall(alarmHook,on)
 local ok,err=pcall(setBossPromptMode,on)
 if not ok then
  S.bossOn=false
  pcall(setBossPromptMode,false)
  pcall(alarmHook,false)
  return false,"تعذّر تفعيل طريقة البرومبت: "..tostring(err),"err"
 end
 if not on then
  return true,"تم إيقاف الميزة وإرجاع إعدادات التفاعل الأصلية","info"
 end
 pcall(hookEvents)
 return true,"تم تفعيل طريقة البرومبت: تفاعل فوري ومسار عبر 5 نقاط عند تشغيل Prompt","warn"
end

---------------- حذف الفخاخ ----------------
local function isTrap(d)
 if not (d:IsA("Model") or d:IsA("BasePart")) then return false end
 if d:GetAttribute("AssetCategory")~=nil or d:GetAttribute("GuardState")~=nil then return false end
 if inChar(d) or inTread(d) or isNoise(d) then return false end
 if not hasWord(d.Name,CFG.TrapWords) then return false end
 if hasWord(d.Name,{"egg","guard","nest","pet","boss"}) then return false end
 if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then return false end
 return true
end
local function trapSweep()
 local n,names=0,{}
 local i=0
 for _,d in ipairs(WS:GetDescendants()) do
  i=i+1 if i%3000==0 then task.wait() end
  if d.Parent and isTrap(d) then
   n=n+1
   if #names<3 and not names[d.Name] then names[d.Name]=true names[#names+1]=d.Name end
   pcall(function() d:Destroy() end)
  end
 end
 return n,names
end
function F.traps(on)
 local t=S.trap t.on=on disc(t.conn) t.conn=nil
 if not on then return true,"أُوقف الحذف التلقائي للفخاخ","info" end
 t.conn=WS.DescendantAdded:Connect(function(d)
  task.delay(.25,function() if alive and t.on and d.Parent and isTrap(d) then pcall(function() d:Destroy() end) end end)
 end)
 task.spawn(function()
  local n,names=trapSweep()
  if n==0 then notify("حذف الفخاخ مفعّل — لا فخاخ ظاهرة الآن (الأسماء المعروفة: trap / snare / spike)","warn")
  else notify("حُذف "..n.." فخ ("..table.concat(names,"، ")..") من شاشتك — السيرفر قد يظل يفعّلها","warn") end
 end)
 return true,"جارٍ حذف الفخاخ... وأي فخ جديد يُحذف تلقائياً","warn"
end

---------------- تفريم البيض: اجرِ إلى بيضة محددة واسرقها ----------------
local function promptPos(d)
 local p=d.Parent
 if not p then return nil end
 if p:IsA("BasePart") then return p.Position end
 if p:IsA("Attachment") then return p.WorldPosition end
 if p:IsA("Model") then return posOf(p) end
end
local function findStealPrompt(e)
 local pos=e.pos
 local best,bd
 local function consider(d,limit)
  if not (d:IsA("ProximityPrompt") and d.Enabled) or inChar(d) or inTread(d) then return end
  local pp=promptPos(d) if not pp then return end
  local dist=(pp-pos).Magnitude
  if dist<=limit and (not bd or dist<bd) then best,bd=d,dist end
 end
 if e.inst and e.inst.Parent then for _,d in ipairs(e.inst:GetDescendants()) do consider(d,1e9) end end
 if not best then
  local root=areaRoot() or WS
  local i=0
  for _,d in ipairs(root:GetDescendants()) do
   i=i+1 if i%3000==0 then task.wait() end
   consider(d,18)
  end
 end
 return best
end
local function curPos(e)
 if e.inst and e.inst.Parent then return posOf(e.inst) or e.pos end
 return e.pos
end
local function flat(v) return Vector3.new(v.X,0,v.Z) end
local function walkTo(pos,stopDist,timeout,cancel)
 local t0=os.clock()
 local last,lastT,stuck=nil,t0,0
 while alive and not cancel() do
  local r,h=getRoot(),getHum()
  if not r or not h then return false end
  if (flat(r.Position)-flat(pos)).Magnitude<=stopDist then return true end
  if os.clock()-t0>timeout then return false end
  h:MoveTo(pos)
  if not last then last=r.Position end
  if os.clock()-lastT>1.2 then
   if (r.Position-last).Magnitude<2 then
    h.Jump=true stuck=stuck+1
    if stuck>=3 then
     local dir=flat(pos-r.Position)
     if dir.Magnitude>0 then r.CFrame=r.CFrame+dir.Unit*10+Vector3.new(0,3,0) end
     stuck=0
    end
   else stuck=0 end
   last=r.Position lastT=os.clock()
  end
  task.wait(.15)
 end
 return false
end
local function findAsk()
 for _,d in ipairs(RepS:GetDescendants()) do
  if d:IsA("RemoteFunction") and d.Name=="AskFieldEggCarry" then return d end
 end
end
local function selEntry()
 for _,e in ipairs(S.eggs) do if e.key==S.sel then return e end end
end
function F.stealSet(on) end -- يُربط بالواجهة (يحدّث مفتاح التفريم)
function F.steal(on)
 local st=S.steal
 if not on then st.on=false st.token=st.token+1 return true,"أُوقف التفريم","info" end
 if not S.sel or not selEntry() then return false,"اختر بيضة من القائمة أولاً","warn" end
 if st.active or S.busy then return false,"عملية قيد التنفيذ","warn" end
 if not getRoot() then return false,"لا توجد شخصية حالياً","err" end
 st.on=true st.token=st.token+1 st.active=true S.busy=true
 local token=st.token
 local function cancel() return (not alive) or (not st.on) or st.token~=token end
 task.spawn(function()
  local ok,err=pcall(function()
   local e=selEntry()
   local r=getRoot()
   local origin=r.CFrame
   local hadF=S.freeze.on
   if not hadF then pcall(F.freeze,true) end
   notify("أجري نحو "..e.nameAr.." — "..areaAr(e.area),"info")
   local tgt=curPos(e)
   local dist=(flat(r.Position)-flat(tgt)).Magnitude
   local ws=(getHum() and getHum().WalkSpeed or 16) if ws<8 then ws=16 end
   local reached=walkTo(tgt,6,dist/ws*1.8+12,cancel)
   if cancel() then if not hadF then pcall(F.freeze,false) end return end
   local rr=getRoot()
   if rr and (rr.Position-tgt).Magnitude>12 then rr.CFrame=CFrame.new(tgt+Vector3.new(0,3,0)) rr.AssemblyLinearVelocity=Vector3.zero task.wait(.3) end
   S.carry=false
   local got=false
   local ask=e.uid and findAsk()
   if ask then
    for _=1,3 do
     if cancel() then break end
     pcall(function() return ask:InvokeServer({Uid=e.uid}) end)
     local t0=os.clock()
     while os.clock()-t0<1.5 and not S.carry do task.wait(.1) end
     if S.carry then got=true break end
    end
   end
   if not got and not cancel() then
    local pr=findStealPrompt(e)
    local fp=ext("fireproximityprompt")
    if pr and fp then
     for _=1,3 do
      if cancel() then break end
      pcall(function() pr.HoldDuration=0 end)
      pcall(fp,pr)
      local t0=os.clock()
      while os.clock()-t0<1.5 and not S.carry do task.wait(.1) end
      if S.carry then got=true break end
     end
    end
   end
   if cancel() then if not hadF then pcall(F.freeze,false) end return end
   if not got then
    notify("لم يؤكد السيرفر الحمل — اقترب أكثر أو حدّث القائمة (قد تكون البيضة أُخذت)","warn")
    if not hadF then pcall(F.freeze,false) end
    return
   end
   notify("سُرقت "..e.nameAr.." ✓","ok")
   if S.bossOn then F.bossRoute(true) end
   local r3=getRoot()
   if r3 then
    local back=walkTo(origin.Position,8,45,function() return not alive end)
    if not back then local r4=getRoot() if r4 then r4.CFrame=origin r4.AssemblyLinearVelocity=Vector3.zero end end
   end
   if not hadF then pcall(F.freeze,false) end
  end)
  st.active=false S.busy=false
  if not ok then notify("خطأ في التفريم: "..tostring(err),"err") end
  if st.token==token then st.on=false F.stealSet(false) end
  F.refresh(true)
 end)
 return true,"بدأ التفريم","warn"
end

---------------- تقرير للدعم ----------------
function F.report()
 local L={"LOTRIX VX v5 report","eggs="..#S.eggs.." events="..S.ev.n.." carry="..tostring(S.carry)}
 local root=areaRoot()
 L[#L+1]="GuardAreas="..tostring(root~=nil)
 if root then
  for _,ar in ipairs(root:GetChildren()) do
   local nests=ar:FindFirstChild("Nests")
   L[#L+1]="area "..ar.Name.." nests="..(nests and #nests:GetChildren() or 0)
  end
 end
 for i,e in ipairs(S.eggs) do
  if i>40 then break end
  L[#L+1]=string.format("egg %s | %s | rate=%s | stored=%s | ev=%s | %s",e.nameEn,tostring(e.area),tostring(e.rate),tostring(e.stored),tostring(e.fromEvent==true),e.inst and e.inst:GetFullName() or "-")
 end
 local tn,seen={},{}
 local i=0
 for _,d in ipairs(WS:GetDescendants()) do
  i=i+1 if i>60000 then break end
  if (d:IsA("Model") or d:IsA("BasePart")) and hasWord(d.Name,CFG.TrapWords) and not seen[d.Name] and #tn<15 then seen[d.Name]=true tn[#tn+1]=d.Name.." ["..d.ClassName.."]" end
 end
 L[#L+1]="trap-like names: "..table.concat(tn,", ")
 -- أين تحتفظ اللعبة ببيانات البيض؟ (للاكتشاف)
 if root then
  local shown=0
  for _,ar in ipairs(root:GetChildren()) do
   local nests=ar:FindFirstChild("Nests")
   if nests and shown<2 then
    shown=shown+1
    for _,nm in ipairs(nests:GetChildren()) do
     local at={}
     for k,v in pairs(nm:GetAttributes()) do at[#at+1]=tostring(k).."="..tostring(v) end
     local ch={}
     for _,c in ipairs(nm:GetChildren()) do ch[#ch+1]=c.Name.."["..c.ClassName.."]" end
     L[#L+1]="nest "..nm:GetFullName().." attrs{"..table.concat(at,", ").."} children{"..table.concat(ch,", ").."}"
    end
   end
  end
 end
 local ua,k=0,0
 for _,d in ipairs(WS:GetDescendants()) do
  k=k+1 if k>80000 then break end
  if ua<12 and (d:IsA("Model") or d:IsA("BasePart")) and (d:GetAttribute("Uid")~=nil or d:GetAttribute("EggUid")~=nil or d:GetAttribute("NestId")~=nil) then
   ua=ua+1
   L[#L+1]="has-uid "..d:GetFullName()
  end
 end
 L[#L+1]="ask remote: "..tostring(findAsk()~=nil)
 L[#L+1]="hidden alarms: "..table.concat(S.alarm.log,", ")
 L[#L+1]="-- events --"
 for _,s in ipairs(S.ev.raw) do L[#L+1]=s end
 local t=table.concat(L,"\n")
 print(t)
 return true,"التقرير "..(copyText(t) and "نُسخ للحافظة" or "طُبع في الكونسول (F9)"),"ok"
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

local DW,DH=470,330
local gui=new("ScreenGui",{Name=CFG.Name,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},host)
local uiScale=new("UIScale",{},gui)
local function rescale()
 local cam=WS.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(1000,600)
 uiScale.Scale=math.clamp(math.min(v.X*.6/DW,v.Y*.8/DH),.5,3)
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
local sub=label(header,"STEAL AN EGG • v5",10,C.sub,true,CENTER) sub.Size=UDim2.new(1,0,0,14) sub.Position=UDim2.fromOffset(0,28)
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

local bar=new("Frame",{Size=UDim2.new(1,-16,0,32),Position=UDim2.new(0,8,1,-38),BackgroundColor3=C.panel},main)
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

-- الشريط الجانبي + الصفحات
local sidebar=new("Frame",{Size=UDim2.fromOffset(104,DH-100),Position=UDim2.fromOffset(8,56),BackgroundColor3=C.panel},main)
corner(sidebar,12) stroke(sidebar,C.gd,1,.3)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)
new("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},sidebar)
local content=new("Frame",{Size=UDim2.fromOffset(DW-128,DH-100),Position=UDim2.fromOffset(120,56),BackgroundTransparency=1,ClipsDescendants=true},main)
local pages,tabBtns={},{}
local list
local ord=0
local function nxt() ord=ord+1 return ord end
local function newPage(id)
 local sf=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.g,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},content)
 new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
 new("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,6)},sf)
 pages[id]=sf list=sf return sf
end
local function showPage(id)
 for k,p in pairs(pages) do p.Visible=(k==id) end
 for k,b in pairs(tabBtns) do
  local on=(k==id)
  b.BackgroundColor3=on and C.gd or C.card
 end
end
local function addTab(id,icon,txt)
 local b=new("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.card,Text="",AutoButtonColor=false,LayoutOrder=nxt()},sidebar)
 corner(b,10) stroke(b,C.gd,1,.4)
 local ic=label(b,icon,17,C.g2,false,CENTER) ic.Size=UDim2.fromOffset(24,40) ic.Position=UDim2.new(1,-28,0,0)
 local t=label(b,txt,13,C.text,true) t.Size=UDim2.new(1,-38,1,0) t.Position=UDim2.fromOffset(4,0)
 b.MouseButton1Click:Connect(function() fx(b) showPage(id) end)
 tabBtns[id]=b
end

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
 return function(v) on=v paint() end
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
local function noteText(t)
 local n=label(list,t,10,C.sub) n.Size=UDim2.new(1,0,0,0) n.AutomaticSize=Enum.AutomaticSize.Y n.LayoutOrder=nxt()
end


espF.Parent=host

---- الصفحة: الأدوات ----
newPage("tools")
section("الزعيم")
toggleCard("نوم عميق للزعيم","تفاعل Prompt فوري + مسار عبر 5 نقاط + إخفاء إنذار السرقة محلياً",function(on) return F.boss(on) end)
section("الأرض")
toggleCard("حذف الفخاخ","يحذف الفخاخ الآن وأي فخ جديد حتى لا تسقط البيضة",function(on) return F.traps(on) end)
noteText("كل شيء هنا يعمل على جهازك فقط. السيرفر هو الذي يقرر في النهاية.")

---- الصفحة: تفريم البيض ----
newPage("eggs")
section("تفريم البيض")
local soon=card("COMING SOON","This feature will be available very soon.")
soon.Size=UDim2.new(1,0,0,88)
local soonText=label(soon,"COMING SOON",20,C.g2,true,CENTER)
soonText.Size=UDim2.new(1,-12,0,32)
soonText.Position=UDim2.new(0,6,0,48)
soonText.TextXAlignment=CENTER

---- الصفحة: بيضي — البيض المكتشف في الماب ----
newPage("pen")
section("البيض الموجود في الماب")
local mapSummary=card("البيض المكتشف محلياً","يتم عرض البيوض التي استطاع جهازك اكتشافها وتحميلها من الماب.")
mapSummary.Size=UDim2.new(1,0,0,62)
local mapCount=label(mapSummary,"0 بيضة",15,C.money,true,CENTER)
mapCount.Size=UDim2.new(1,-12,0,24)
mapCount.Position=UDim2.fromOffset(6,34)

local mapRefresh=card("تحديث قائمة البيض","اضغط لإعادة فحص البيوض الموجودة حولك.")
local mapRefreshButton=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=6},mapRefresh)
local MAPBASE=nxt()
local mapRows={}
local function mapEggUpdate(rebuild)
 local total=#S.eggs
 local totalStored=0
 local storedCount=0
 for _,e in ipairs(S.eggs) do
  if e.inst and e.inst.Parent then
   local rate,stored,other=readMoney(e.inst)
   if rate then e.rate=rate end
   if stored or other then e.stored=stored or other end
  end
  if type(e.stored)=="number" then
   totalStored=totalStored+e.stored
   storedCount=storedCount+1
  end
 end
 mapCount.Text=tostring(total).." بيضة مكتشفة • "..(storedCount>0 and (abbr(totalStored).." مال جاهز للجمع") or "مبالغ الجمع غير متاحة حالياً")
 if not rebuild then return end
 for _,r in ipairs(mapRows) do pcall(function() r:Destroy() end) end
 mapRows={}
 if total==0 then
  local empty=label(pages.pen,"لا توجد بيوض مكتشفة حالياً. اقترب من مناطق البيوض ثم اضغط تحديث.",12,C.sub,false,CENTER)
  empty.Size=UDim2.new(1,0,0,48)
  empty.LayoutOrder=MAPBASE+1
  mapRows[#mapRows+1]=empty
  return
 end
 for i,e in ipairs(S.eggs) do
  if i>80 then break end
  local storedText=type(e.stored)=="number" and abbr(e.stored) or "غير متاح"
  local rateText=type(e.rate)=="number" and (" • "..abbr(e.rate).."/ث") or ""
  local areaText=areaAr(e.area)
  local row=new("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=C.card,LayoutOrder=MAPBASE+i},pages.pen)
  corner(row,9) stroke(row,C.gd,1,.45)
  local titleText=label(row,"🥚 "..tostring(e.nameAr or e.nameEn or "بيضة"),13,C.text,true)
  titleText.Size=UDim2.new(1,-12,0,20)
  titleText.Position=UDim2.fromOffset(6,3)
  local detail=label(row,areaText.." • جاهز للجمع: "..storedText..rateText,11,C.money,false)
  detail.Size=UDim2.new(1,-12,0,20)
  detail.Position=UDim2.fromOffset(6,25)
  mapRows[#mapRows+1]=row
 end
 if total>80 then
  local more=label(pages.pen,"+"..tostring(total-80).." بيضة أخرى",11,C.sub,false,CENTER)
  more.Size=UDim2.new(1,0,0,22)
  more.LayoutOrder=MAPBASE+82
  mapRows[#mapRows+1]=more
 end
end
mapRefreshButton.MouseButton1Click:Connect(function()
 fx(mapRefresh)
 F.refresh(false)
 mapEggUpdate(true)
end)
rebuildList=function() mapEggUpdate(true) end
mapEggUpdate(true)

addTab("tools","🛠","الأدوات")
addTab("eggs","🥚","تفريم البيض")
addTab("pen","🥚","بيضي")
showPage("tools")

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
 S.steal.on=false S.steal.token=S.steal.token+1
 S.bossOn=false S.mon.on=false
 pcall(setBossPromptMode,false) pcall(F.freeze,false) pcall(F.traps,false) pcall(clearEsp) pcall(alarmHook,false)
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

hookEvents()
track(LP.CharacterAdded:Connect(function() task.delay(2,function() if alive then F.refresh(true) end end) end))
task.spawn(function()
 local n=0
 while alive do
  n=n+1
  if cd.Parent then cd.Text=fmtTime(S.nextAt-os.clock()) end
  if S.nextAt>0 and os.clock()>=S.nextAt and not S.scanning and not S.steal.active then F.refresh(true) end
  if S.mon.on and n%5==0 then pcall(updateEspText) end
  if pages.pen and pages.pen.Visible then pcall(mapEggUpdate,n%3==0) end
  task.wait(1)
 end
end)
F.refresh(true)

local function intro()
 local g=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(17,18,23),BackgroundTransparency=0,ZIndex=50},gui)
 new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(42,45,55),Color3.fromRGB(13,14,19)),Rotation=90},g)

 local ring=new("Frame",{Size=UDim2.fromOffset(184,184),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.32),BackgroundColor3=Color3.fromRGB(235,238,245),BackgroundTransparency=1,ZIndex=51},g)
 corner(ring,100)
 stroke(ring,Color3.fromRGB(220,226,240),3,0.08)

 local avatar=new("ImageLabel",{Size=UDim2.fromOffset(156,156),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.32),BackgroundColor3=Color3.fromRGB(28,30,38),BorderSizePixel=0,Image=introAsset or "",ScaleType=Enum.ScaleType.Crop,ZIndex=52},g)
 corner(avatar,100)
 stroke(avatar,Color3.fromRGB(245,247,255),2,0.05)

 local title=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-30,0,52),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.59),Text="LOTRIX VX",TextSize=42,Font=Enum.Font.GothamBlack,TextColor3=Color3.fromRGB(250,251,255),TextTransparency=0,ZIndex=52},g)
 local subtitle=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-30,0,25),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.655),Text="ROBLOX  •  DELTA  •  SCRIPTS",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(205,211,225),TextTransparency=0,ZIndex=52},g)
 local support=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-32,0,24),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.715),Text="اشترك لدعم استمرار تطوير السكربتات",TextSize=14,Font=Enum.Font.GothamSemibold,TextColor3=Color3.fromRGB(238,240,248),TextTransparency=0,ZIndex=52},g)

 local bar=new("Frame",{Size=UDim2.new(.58,0,0,9),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.79),BackgroundColor3=Color3.fromRGB(66,70,82),BorderSizePixel=0,ZIndex=52},g)
 corner(bar,8)
 local fill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.fromRGB(235,239,250),BorderSizePixel=0,ZIndex=53},bar)
 corner(fill,8)
 new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(150,165,195),Color3.fromRGB(255,255,255)),Rotation=0},fill)

 local percent=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromOffset(100,22),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.835),Text="0%",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(245,247,255),ZIndex=52},g)
 local msg=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-30,0,20),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.885),Text="جاري تجهيز LOTRIX VX...",TextSize=13,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(190,196,210),ZIndex=52},g)

 local isc=new("UIScale",{},g)
 local function fit()
  local v=gui.AbsoluteSize
  isc.Scale=math.clamp(math.min(v.X/700,v.Y/520),.55,1.35)
 end
 fit()
 local t0=os.clock()
 while alive and os.clock()-t0<5 do
  local progress=math.clamp((os.clock()-t0)/5,0,1)
  fill.Size=UDim2.fromScale(progress,1)
  percent.Text=tostring(math.floor(progress*100+0.5)).."%"
  if progress<.25 then msg.Text="تهيئة النظام..."
  elseif progress<.5 then msg.Text="فحص الشخصية..."
  elseif progress<.75 then msg.Text="تحميل الأدوات..."
  elseif progress<1 then msg.Text="تقريباً انتهينا..."
  else msg.Text="جاهز!" end
  task.wait(.03)
 end
 if not alive then return end
 main.Visible=true
 popIn()
 local fade=TS:Create(g,TweenInfo.new(.35),{GroupTransparency=1})
 fade:Play()
 fade.Completed:Wait()
 g:Destroy()
end
notify("LOTRIX VX جاهز — محلي فقط","ok")
task.spawn(function() local ok,e=pcall(intro) if not ok then main.Visible=true warn("[LOTRIX] intro: "..tostring(e)) end end)