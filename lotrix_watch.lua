-- LOTRIX WATCH: read-only listener. It only listens, it never fires anything.
-- Run it, then steal an egg and get chased. It stops by itself after DURATION seconds.
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local P=game:GetService("Players")
local LP=P.LocalPlayer
local DURATION=120
local KW={"guard","boss","egg","trap","alert","caught","patrol","rouse","strike","steal","carry","ragdoll"}
local out,conns={},{}
local t0=os.clock()
local function add(s)
 if #out<500 then out[#out+1]=string.format("[%5.1f] %s",os.clock()-t0,s) end
end
local function has(n)
 n=string.lower(n)
 for _,k in ipairs(KW) do if string.find(n,k,1,true) then return true end end
 return false
end
local function show(v,d)
 d=d or 0
 local t=typeof(v)
 if t=="table" then
  if d>=2 then return "{...}" end
  local parts,n={},0
  for k,x in pairs(v) do
   n=n+1
   if n>8 then parts[#parts+1]="..." break end
   parts[#parts+1]=tostring(k).."="..show(x,d+1)
  end
  return "{"..table.concat(parts,", ").."}"
 elseif t=="Instance" then
  local ok,r=pcall(function() return v:GetFullName() end)
  return ok and r or tostring(v)
 end
 return tostring(v)
end
local function snap(tag)
 local n=0
 for _,d in ipairs(WS:GetDescendants()) do
  if n<30 and d:IsA("Model") and d:GetAttribute("GuardState")~=nil then
   n=n+1
   add(tag.." GUARD "..d:GetFullName().." state="..show(d:GetAttribute("GuardState")).." target="..show(d:GetAttribute("TargetPlayer")).." wake="..show(d:GetAttribute("WakeTargetPlayer")))
   if tag=="START" then
    conns[#conns+1]=d.AttributeChanged:Connect(function(k)
     add("GUARD "..d:GetFullName().." "..k.."="..show(d:GetAttribute(k)))
    end)
   end
  end
 end
 if n==0 then add(tag.." no models with a GuardState attribute found") end
end

local hooked=0
for _,d in ipairs(RS:GetDescendants()) do
 if d:IsA("RemoteEvent") and has(d.Name) then
  local ok=pcall(function()
   conns[#conns+1]=d.OnClientEvent:Connect(function(...)
    local parts={}
    for i=1,math.min(select("#",...),5) do parts[i]=show((select(i,...))) end
    add("EVENT "..d.Name.." ("..table.concat(parts,", ")..")")
   end)
  end)
  if ok then hooked=hooked+1 end
 end
end
add("hooked "..hooked.." RemoteEvents (listen only)")

conns[#conns+1]=LP.AttributeChanged:Connect(function(k)
 add("PLAYER attr "..k.."="..show(LP:GetAttribute(k)))
end)
local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum then
 conns[#conns+1]=hum.StateChanged:Connect(function(_,new)
  add("HUMANOID state "..tostring(new))
 end)
end

snap("START")
pcall(function()
 game:GetService("StarterGui"):SetCore("SendNotification",{Title="LOTRIX WATCH",Text="Listening "..DURATION.."s - steal an egg now",Duration=6})
end)

task.delay(DURATION,function()
 for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
 snap("END")
 local t=table.concat(out,"\n")
 print(t)
 local f=setclipboard or toclipboard
 if f then pcall(f,t) end
 pcall(function()
  game:GetService("StarterGui"):SetCore("SendNotification",{Title="LOTRIX WATCH",Text=f and "Done - copied to clipboard" or "Done - open console F9",Duration=8})
 end)
end)
