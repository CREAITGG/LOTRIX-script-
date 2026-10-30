--[[ GuardEgg_Server — سكربت سيرفر لـ Roblox Studio
     حارس ينام، يستيقظ عند سرقة بيضة، يطارد السارق، ثم يعود وينام.
     ضعه كـ Script (وليس LocalScript) داخل ServerScriptService.

     التجهيز في Workspace:
       Guards  (Folder)  : كل حارس Model فيه Humanoid و HumanoidRootPart
       Eggs    (Folder)  : كل بيضة Model أو Part وفيها ProximityPrompt
       SafeZone (Part، اختياري): لمسها وأنت تحمل بيضة = تسليم ناجح

     خصائص (Attributes) اختيارية على الحارس:
       StaysAsleep (bool)  → true نوم عميق دائم، false يستيقظ (الافتراضي من DEFAULT_STAYS_ASLEEP)
       WakeDelay (number)  = 0.3   → ثوانٍ بين السرقة والاستيقاظ
       ChaseSpeed (number) = 24    → سرعة المطاردة
       CatchDistance (number) = 6  → المسافة التي يُسقط عندها البيضة
       GiveUpDistance (number) = 120 → يترك المطاردة إذا ابتعد عن بيته
     خصائص اختيارية على البيضة:
       GuardName (string)  → اسم الحارس المرتبط؛ وإلا يُختار أقرب حارس
]]

local Players = game:GetService("Players")

-- true = كل الحراس ينامون حتى لو سُرقت البيضة (غيّرها إلى false ليستيقظوا)
local DEFAULT_STAYS_ASLEEP = true

local guardsFolder = workspace:WaitForChild("Guards")
local eggsFolder = workspace:WaitForChild("Eggs")
local safeZone = workspace:FindFirstChild("SafeZone")

local G = {}        -- [guardModel] = {home=CFrame, hum=Humanoid, root=Part, token=0}
local carrying = {} -- [player] = {egg=Instance, origin=CFrame, guard=Model, weld=WeldConstraint}

---------------- الحراس ----------------
local function setState(g, state, target)
	g:SetAttribute("GuardState", state)
	g:SetAttribute("Sleeping", state == "Sleeping")
	g:SetAttribute("TargetPlayer", target and target.UserId or 0)
end

local function sleepNow(g)
	local d = G[g]
	d.hum.WalkSpeed = 0
	d.hum:MoveTo(d.root.Position)
	setState(g, "Sleeping")
end

local function initGuard(g)
	if not g:IsA("Model") or G[g] then return end
	local hum = g:FindFirstChildOfClass("Humanoid")
	local root = g:FindFirstChild("HumanoidRootPart")
	if not hum or not root then
		warn("[GuardEgg] الحارس " .. g.Name .. " يحتاج Humanoid و HumanoidRootPart")
		return
	end
	G[g] = { home = root.CFrame, hum = hum, root = root, token = 0 }
	sleepNow(g)
end

local function attr(g, name, default)
	local v = g:GetAttribute(name)
	if v == nil then return default end
	return v
end

local function nearestGuard(pos)
	local best, bd
	for g, d in pairs(G) do
		local dist = (d.root.Position - pos).Magnitude
		if not bd or dist < bd then best, bd = g, dist end
	end
	return best
end

---------------- إسقاط/إرجاع البيضة ----------------
local function dropEgg(player, deliver)
	local c = carrying[player]
	if not c then return end
	carrying[player] = nil
	if c.weld then c.weld:Destroy() end
	local egg = c.egg
	if egg and egg.Parent then
		if deliver then
			egg:SetAttribute("Delivered", true)
			egg:Destroy()
		else
			egg:PivotTo(c.origin) -- تعود لعشها
			local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt then prompt.Enabled = true end
		end
	end
end

---------------- المطاردة ----------------
local function chase(g, player)
	local d = G[g]
	d.token = d.token + 1
	local token = d.token
	setState(g, "Chasing", player)
	d.hum.WalkSpeed = attr(g, "ChaseSpeed", 24)
	local catchDist = attr(g, "CatchDistance", 6)
	local giveUp = attr(g, "GiveUpDistance", 120)

	while d.token == token and player.Parent and carrying[player] and carrying[player].guard == g do
		local char = player.Character
		local pr = char and char:FindFirstChild("HumanoidRootPart")
		if not pr then break end
		local dist = (pr.Position - d.root.Position).Magnitude
		if dist <= catchDist then
			dropEgg(player, false) -- أمسك بك: تسقط البيضة
			break
		end
		if (d.root.Position - d.home.Position).Magnitude > giveUp then break end
		d.hum:MoveTo(pr.Position)
		task.wait(0.2)
	end

	if d.token ~= token then return end -- بدأت مطاردة أحدث
	setState(g, "ReturningHome")
	d.hum.WalkSpeed = 16
	d.hum:MoveTo(d.home.Position)
	local t0 = os.clock()
	while d.token == token and os.clock() - t0 < 20 and (d.root.Position - d.home.Position).Magnitude > 5 do
		task.wait(0.3)
	end
	if d.token == token then
		g:PivotTo(d.home)
		sleepNow(g)
	end
end

local function wake(g, player)
	local stay = g:GetAttribute("StaysAsleep")
	if stay == nil then stay = DEFAULT_STAYS_ASLEEP end
	if stay then return end -- نوم عميق
	setState(g, "Waking", player)
	task.wait(attr(g, "WakeDelay", 0.3))
	local c = carrying[player]
	if c and c.guard == g then
		chase(g, player)
	else
		sleepNow(g)
	end
end

---------------- البيض ----------------
local function initEgg(egg)
	local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then return end
	prompt.Triggered:Connect(function(player)
		if carrying[player] or not prompt.Enabled then return end
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local g = G[guardsFolder:FindFirstChild(egg:GetAttribute("GuardName") or "")]
			or nearestGuard(egg:GetPivot().Position)
		local origin = egg:GetPivot()
		prompt.Enabled = false
		egg:PivotTo(root.CFrame * CFrame.new(0, 0, -2.5))
		local primary = egg:IsA("BasePart") and egg or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart", true)
		local weld
		if primary then
			weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = primary
			weld.Parent = primary
		end
		carrying[player] = { egg = egg, origin = origin, guard = g, weld = weld }
		if g then task.spawn(wake, g, player) end
	end)
end

---------------- تسليم البيضة وتنظيف الحالات ----------------
if safeZone and safeZone:IsA("BasePart") then
	safeZone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		local c = player and carrying[player]
		if c then
			local g = c.guard
			dropEgg(player, true)
			if g and G[g] then G[g].token = G[g].token + 1 task.spawn(function()
				setState(g, "ReturningHome")
				G[g].hum:MoveTo(G[g].home.Position)
				task.wait(3)
				g:PivotTo(G[g].home)
				sleepNow(g)
			end) end
		end
	end)
end

local function hookPlayer(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function() dropEgg(player, false) end)
	end)
end
Players.PlayerAdded:Connect(hookPlayer)
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerRemoving:Connect(function(p) dropEgg(p, false) end)

---------------- التشغيل ----------------
for _, g in ipairs(guardsFolder:GetChildren()) do initGuard(g) end
guardsFolder.ChildAdded:Connect(initGuard)
for _, e in ipairs(eggsFolder:GetChildren()) do initEgg(e) end
eggsFolder.ChildAdded:Connect(initEgg)
