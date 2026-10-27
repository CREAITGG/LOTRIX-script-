-- LOTRIX DIAG: read-only, changes nothing. Stand near a boss/guard, then run it.
local WS=game:GetService("Workspace")
local P=game:GetService("Players")
local LP=P.LocalPlayer
local out={}
local function add(s) out[#out+1]=s end
local KW={"boss","guard","oni","gorilla","tiger","sleep","aggro","chase","steal","egg","trap","hit","damage","alert","wake","caught","grab"}
local function has(n)
 n=string.lower(n)
 for _,k in ipairs(KW) do if string.find(n,k,1,true) then return true end end
 return false
end
add("== REMOTES ==")
local roots={game:GetService("ReplicatedStorage"),game:GetService("ReplicatedFirst"),WS}
local c=0
for _,r in ipairs(roots) do
 for _,d in ipairs(r:GetDescendants()) do
  if c<120 and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent")) and has(d.Name) then
   c=c+1 add(d.ClassName..": "..d:GetFullName())
  end
 end
end
add("== NPC / BOSS ==")
local n=0
for _,d in ipairs(WS:GetDescendants()) do
 if n<6 and d:IsA("Model") and not P:GetPlayerFromCharacter(d) and (has(d.Name) or d:FindFirstChildOfClass("Humanoid")) then
  n=n+1 add("MODEL "..d:GetFullName())
  for k,v in pairs(d:GetAttributes()) do add("  attr "..k.."="..tostring(v)) end
  local m=0
  for _,x in ipairs(d:GetDescendants()) do
   if m<35 and (x:IsA("ValueBase") or x:IsA("Script") or x:IsA("LocalScript") or x:IsA("ProximityPrompt") or x:IsA("Humanoid") or x:IsA("BodyMover")) then
    m=m+1 add("  "..x.ClassName..": "..x.Name..(x:IsA("ValueBase") and (" = "..tostring(x.Value)) or ""))
   end
  end
 end
end
add("== PLAYER ATTR ==")
for k,v in pairs(LP:GetAttributes()) do add(k.."="..tostring(v)) end
local t=table.concat(out,"\n")
print(t)
local f=setclipboard or toclipboard
if f then pcall(f,t) end
pcall(function()
 game:GetService("StarterGui"):SetCore("SendNotification",{Title="LOTRIX DIAG",Text=f and "Copied to clipboard" or "Open console F9",Duration=6})
end)
