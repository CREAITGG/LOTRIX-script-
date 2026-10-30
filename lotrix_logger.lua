--[[ LOTRIX VX LOGGER — أداة تسجيل للقراءة فقط (لا ترسل ولا تغيّر شيئاً) ]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local RepS=game:GetService("ReplicatedStorage")
local CG=game:GetService("CoreGui")
local LP=Players.LocalPlayer
if not LP then return end
local ENV=(getgenv and getgenv()) or _G
if type(ENV._LOTRIX_LOG_CLEANUP)=="function" then pcall(ENV._LOTRIX_LOG_CLEANUP) end
local function ext(n) local ok,v=pcall(function() return ENV[n] end) if ok and type(v)=="function" then return v end end

local C={bg=Color3.fromRGB(13,13,15),panel=Color3.fromRGB(22,22,26),card=Color3.fromRGB(33,33,38),
 g=Color3.fromRGB(196,198,208),g2=Color3.fromRGB(236,237,242),gd=Color3.fromRGB(72,72,82),
 text=Color3.fromRGB(240,240,244),sub=Color3.fromRGB(150,150,160),red=Color3.fromRGB(255,84,84),money=Color3.fromRGB(60,255,140)}

local alive,rec=true,false
local conns,hooks,log,t0={},{},{},0
local MAXL=1500
local perName={}
local function track(c) conns[#conns+1]=c return c end
local function disc(c) if c then pcall(function() c:Disconnect() end) end end
local function add(s)
 if not rec then return end
 if #log<MAXL then log[#log+1]=string.format("[%6.1f] %s",os.clock()-t0,s) end
end
local function show(v,d)
 d=d or 0
 local t=typeof(v)
 if t=="table" then
  if d>=2 then return "{...}" end
  local p,n={},0
  for k,x in pairs(v) do n=n+1 if n>8 then p[#p+1]="..." break end p[#p+1]=tostring(k).."="..show(x,d+1) end
  return "{"..table.concat(p,", ").."}"
 elseif t=="Instance" then
  local ok,r=pcall(function() return v:GetFullName() end)
  return ok and r or tostring(v)
 end
 return tostring(v)
end
local function copyText(t) local f=ext("setclipboard") or ext("toclipboard") if f then return (pcall(f,t)) end return false end

---------------- التسجيل ----------------
local function isGuard(m) return m:IsA("Model") and string.find(string.lower(m.Name),"guard",1,true)~=nil end
local function attrDump(m)
 local p={}
 for k,v in pairs(m:GetAttributes()) do p[#p+1]=k.."="..show(v) end
 table.sort(p)
 return table.concat(p,", ")
end
local hooked={}
local function hookGuard(m)
 if hooked[m] then return end
 hooked[m]=true
 add("GUARD "..m:GetFullName().." attrs: "..attrDump(m))
 hooks[#hooks+1]=m.AttributeChanged:Connect(function(k) add("GUARD "..m.Parent.Name.."/"..m.Name.." "..k.."="..show(m:GetAttribute(k))) end)
end
local function scanGuards()
 local n=0
 for _,d in ipairs(WS:GetDescendants()) do
  if isGuard(d) then n=n+1 if n<=40 then hookGuard(d) end end
 end
 return n
end
local remoteSeen={}
local function hookRemote(d)
 if remoteSeen[d] or not d:IsA("RemoteEvent") then return end
 remoteSeen[d]=true
 pcall(function()
  hooks[#hooks+1]=d.OnClientEvent:Connect(function(...)
   if not rec then return end
   local nme=d.Name
   perName[nme]=(perName[nme] or 0)+1
   if perName[nme]>40 then if perName[nme]==41 then add("EVENT "..nme.." (كثير — أخفي البقية)") end return end
   local parts={}
   for i=1,math.min(select("#",...),5) do parts[i]=show((select(i,...))) end
   add("EVENT "..nme.." ("..table.concat(parts,", ")..")")
  end)
 end)
end
local outHooked=false
-- يسجّل ما يرسله جهازك للسيرفر (قراءة فقط، يمرّر كل شيء كما هو)
local function hookOutgoing()
 if outHooked then return true end
 local hm,gm=ext("hookmetamethod"),ext("getnamecallmethod")
 if not hm or not gm then return false end
 local nc=ext("newcclosure") or function(f) return f end
 local old
 local ok=pcall(function()
  old=hm(game,"__namecall",nc(function(self,...)
   if rec and alive then
    local m=gm()
    if m=="FireServer" or m=="InvokeServer" then
     local args,an={...},select("#",...)
     pcall(function()
      local nme=tostring(self.Name)
      local k="OUT "..nme
      perName[k]=(perName[k] or 0)+1
      if perName[k]<=25 then
       local parts={}
       for i=1,math.min(an,5) do parts[i]=show(args[i]) end
       add("OUT "..m.." "..nme.." ("..table.concat(parts,", ")..")")
      end
     end)
    end
   end
   return old(self,...)
  end))
 end)
 outHooked=ok
 return ok
end
local function hookChar(ch)
 local h=ch:WaitForChild("Humanoid",10)
 if not h then return end
 hooks[#hooks+1]=h.StateChanged:Connect(function(_,n) add("ME state "..tostring(n)) end)
 hooks[#hooks+1]=h.HealthChanged:Connect(function(v) add("ME health "..string.format("%.0f",v)) end)
 hooks[#hooks+1]=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() add("ME walkspeed "..string.format("%.1f",h.WalkSpeed)) end)
 hooks[#hooks+1]=h:GetPropertyChangedSignal("PlatformStand"):Connect(function() add("ME platformstand "..tostring(h.PlatformStand)) end)
 hooks[#hooks+1]=ch.ChildAdded:Connect(function(c) add("ME +child "..c.ClassName..":"..c.Name) end)
 hooks[#hooks+1]=ch.ChildRemoved:Connect(function(c) add("ME -child "..c.ClassName..":"..c.Name) end)
 hooks[#hooks+1]=ch.DescendantAdded:Connect(function(c)
  local k=c.ClassName
  if k=="BodyVelocity" or k=="LinearVelocity" or k=="BodyForce" or k=="VectorForce" or k=="BodyPosition" or k=="AlignPosition" or k=="BodyGyro" or k=="AngularVelocity" or k=="Ragdoll" then add("ME +mover "..k..":"..c.Name.." in "..(c.Parent and c.Parent.Name or "?")) end
 end)
end
local lastPos
local onBeat_last=0
local acc,gacc=0,0
local function onBeat(dt)
 if not rec then return end
 local ch=LP.Character local r=ch and ch:FindFirstChild("HumanoidRootPart")
 if r then
  local v=r.AssemblyLinearVelocity.Magnitude
  if v>90 and os.clock()-(onBeat_last or 0)>1.5 then onBeat_last=os.clock() add(string.format("ME speed spike %.0f studs/s",v)) end
  if lastPos and (r.Position-lastPos).Magnitude>40 then add(string.format("ME jump %.0f studs (انتقال/سحب)",(r.Position-lastPos).Magnitude)) end
  lastPos=r.Position
 end
 gacc=gacc+dt
 if gacc>=3 then
  gacc=0
  if r then
   local best,bd
   for m in pairs(hooked) do
    local p=m.Parent and (m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true))
    if p then local d=(p.Position-r.Position).Magnitude if not bd or d<bd then best,bd=m,d end end
   end
   if best then add(string.format("NEAREST guard %.0f studs: %s | %s",bd,best.Parent.Name,attrDump(best))) end
  end
 end
end

local function startRec()
 if rec then return end
 rec=true log={} perName={} t0=os.clock() lastPos=nil hooked={}
 for _,c in ipairs(hooks) do disc(c) end hooks={}
 remoteSeen={}
 for _,d in ipairs(RepS:GetDescendants()) do hookRemote(d) end
 hooks[#hooks+1]=RepS.DescendantAdded:Connect(hookRemote)
 hooks[#hooks+1]=WS.DescendantAdded:Connect(function(d) if rec and isGuard(d) then task.delay(.3,function() if rec then hookGuard(d) end end) end end)
 hooks[#hooks+1]=LP.AttributeChanged:Connect(function(k) add("PLAYER attr "..k.."="..show(LP:GetAttribute(k))) end)
 local ls=LP:FindFirstChild("leaderstats")
 if ls then for _,v in ipairs(ls:GetChildren()) do if v:IsA("ValueBase") then hooks[#hooks+1]=v.Changed:Connect(function(x) add("STAT "..v.Name.."="..show(x)) end) end end end
 local n=scanGuards()
 add("بدأ التسجيل — حراس مرصودون: "..n)
 add("تسجيل ما يرسله جهازك للسيرفر (OUT): "..(hookOutgoing() and "يعمل" or "غير مدعوم في منفّذك"))
 if LP.Character then task.spawn(hookChar,LP.Character) end
 hooks[#hooks+1]=LP.CharacterAdded:Connect(function(ch) add("ME respawn") lastPos=nil task.spawn(hookChar,ch) end)
end
local function stopRec()
 if not rec then return end
 add("انتهى التسجيل")
 rec=false
 for _,c in ipairs(hooks) do disc(c) end hooks={}
end
track(RS.Heartbeat:Connect(onBeat))

---------------- الواجهة ----------------
local host
do
 local gh=ext("gethui")
 if gh then local ok,h=pcall(gh) if ok and h then host=h end end
 if not host then
  local ok=pcall(function() local t=Instance.new("Folder") t.Parent=CG t:Destroy() end)
  host=ok and CG or LP:WaitForChild("PlayerGui")
 end
end
local function new(cls,props,parent)
 local o=Instance.new(cls)
 for k,v in pairs(props or {}) do o[k]=v end
 if parent then o.Parent=parent end
 return o
end
local function corner(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function stroke(o,c,t,tr) return new("UIStroke",{Color=c or C.gd,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
local function label(p,t,sz,col,bold,al)
 return new("TextLabel",{BackgroundTransparency=1,Text=t,TextSize=sz or 14,TextColor3=col or C.text,Font=bold and Enum.Font.GothamBold or Enum.Font.SourceSansBold,TextWrapped=true,TextXAlignment=al or Enum.TextXAlignment.Right},p)
end
local gui=new("ScreenGui",{Name="LOTRIX_VX_LOGGER",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},host)
local DW,DH=300,380
local uiScale=new("UIScale",{},gui)
local function rescale()
 local cam=WS.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(1000,600)
 uiScale.Scale=math.clamp(math.min(v.X*.55/DW,v.Y*.8/DH),.5,3)
end
rescale()
if WS.CurrentCamera then track(WS.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)) end
local main=new("Frame",{Size=UDim2.fromOffset(DW,DH),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=C.bg,ClipsDescendants=true},gui)
corner(main,16) stroke(main,C.g,1.5,.2)
new("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(38,38,44),Color3.fromRGB(10,10,12)),Rotation=90},main)
local header=new("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1},main)
local ttl=label(header,"LOTRIX VX",20,C.g2,true,Enum.TextXAlignment.Center) ttl.Font=Enum.Font.GothamBlack ttl.Size=UDim2.new(1,0,0,26) ttl.Position=UDim2.fromOffset(0,4)
local sb=label(header,"LOGGER — تسجيل (قراءة فقط)",10,C.sub,true,Enum.TextXAlignment.Center) sb.Size=UDim2.new(1,0,0,14) sb.Position=UDim2.fromOffset(0,28)
local function hbtn(txt,x)
 local b=new("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.fromOffset(x,10),BackgroundColor3=C.card,Text=txt,TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.g2,AutoButtonColor=false},header)
 corner(b,8) stroke(b,C.gd,1,.3) return b
end
local closeB=hbtn("✕",8) local hideB=hbtn("—",40)
new("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.fromOffset(12,48),BackgroundColor3=C.gd,BorderSizePixel=0},main)

local function draggable(handle,target,onTap)
 local st
 track(handle.InputBegan:Connect(function(i)
  local t=i.UserInputType
  if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
   st={input=i,start=i.Position,pos=target.Position,moved=false}
   local c c=i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then c:Disconnect() local s=st st=nil if s and not s.moved and onTap then onTap() end end
   end)
  end
 end))
 track(UIS.InputChanged:Connect(function(i)
  if st and (i==st.input or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-st.start
   if d.Magnitude>8 then st.moved=true end
   if st.moved then local k=uiScale.Scale target.Position=UDim2.new(st.pos.X.Scale,st.pos.X.Offset+d.X/k,st.pos.Y.Scale,st.pos.Y.Offset+d.Y/k) end
  end
 end))
end
draggable(header,main)

local statusL
local function notify(t,col) if statusL then statusL.Text=t statusL.TextColor3=col or C.sub end end
local function bigBtn(y,txt,fn)
 local b=new("TextButton",{Size=UDim2.new(1,-24,0,38),Position=UDim2.fromOffset(12,y),BackgroundColor3=C.card,Text=txt,TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.g2,AutoButtonColor=false},main)
 corner(b,10) stroke(b,C.gd,1,.3)
 b.MouseButton1Click:Connect(function()
  local sc=b:FindFirstChildOfClass("UIScale") or new("UIScale",{},b)
  sc.Scale=.95 TS:Create(sc,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
  fn(b)
 end)
 return b
end
local recB
recB=bigBtn(58,"● بدء التسجيل",function(b)
 if not rec then startRec() b.Text="■ إيقاف التسجيل" b.TextColor3=C.red notify("يسجّل الآن — اسرق بيضة واترك الحارس يضربك",C.money)
 else stopRec() b.Text="● بدء التسجيل" b.TextColor3=C.g2 notify("توقّف التسجيل — "..#log.." سطر. اضغط نسخ",C.sub) end
end)
bigBtn(102,"📋 نسخ السجل",function()
 if #log==0 then notify("السجل فارغ — ابدأ التسجيل أولاً",C.red) return end
 local t=table.concat(log,"\n")
 print(t)
 notify(copyText(t) and ("نُسخ "..#log.." سطر — الصقه في المحادثة") or "لا يدعم النسخ — افتح الكونسول F9",C.money)
end)
bigBtn(146,"🗑 مسح السجل",function() log={} perName={} notify("تم المسح",C.sub) end)

local box=new("Frame",{Size=UDim2.new(1,-24,1,-246),Position=UDim2.fromOffset(12,190),BackgroundColor3=C.panel,ClipsDescendants=true},main)
corner(box,10) stroke(box,C.gd,1,.3)
local live=new("TextLabel",{Size=UDim2.new(1,-10,1,-6),Position=UDim2.fromOffset(5,3),BackgroundTransparency=1,Text="السجل الحي يظهر هنا",TextSize=10,TextColor3=C.sub,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Bottom,TextWrapped=true},box)
local bar=new("Frame",{Size=UDim2.new(1,-24,0,34),Position=UDim2.new(0,12,1,-40),BackgroundColor3=C.panel},main)
corner(bar,10) stroke(bar,C.gd,1,.3)
statusL=label(bar,"جاهز — قراءة فقط، لا يغيّر شيئاً",12,C.sub,false,Enum.TextXAlignment.Center)
statusL.Size=UDim2.new(1,-12,1,0) statusL.Position=UDim2.fromOffset(6,0)

local floatB=new("TextButton",{Size=UDim2.fromOffset(52,52),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,44,.5,0),BackgroundColor3=C.card,Text="L",TextSize=26,Font=Enum.Font.GothamBlack,TextColor3=C.g2,Visible=false,AutoButtonColor=false},gui)
corner(floatB,26) stroke(floatB,C.g2,2,.1)
hideB.MouseButton1Click:Connect(function() main.Visible=false floatB.Visible=true end)
draggable(floatB,floatB,function() main.Visible=true floatB.Visible=false end)

local function cleanup()
 if not alive then return end
 alive=false rec=false
 for _,c in ipairs(hooks) do disc(c) end
 for _,c in ipairs(conns) do disc(c) end
 pcall(function() gui:Destroy() end)
 ENV._LOTRIX_LOG_CLEANUP=nil
end
ENV._LOTRIX_LOG_CLEANUP=cleanup
closeB.MouseButton1Click:Connect(cleanup)

task.spawn(function()
 while alive do
  if main.Visible then
   local n=#log
   if n>0 then
    local from=math.max(1,n-11)
    local t={}
    for i=from,n do t[#t+1]=log[i] end
    live.Text=table.concat(t,"\n")
    sb.Text="LOGGER — "..n.." سطر"..(rec and " ● يسجّل" or "")
   end
  end
  task.wait(.5)
 end
end)
