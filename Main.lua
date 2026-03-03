--[[
  QWERTY-UI · Exploit Edition · v2.0.0
  github.com/Qwerty-off-keyboard/QWERTY-UI-le-Roblox-

  FULL LOADSTRING (paste into executor):
  loadstring(game:HttpGet("https://raw.githubusercontent.com/Qwerty-off-keyboard/QWERTY-UI-le-Roblox-/main/QWERTY-UI.lua"))()
--]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

local T = {
    BG           = Color3.fromRGB(10,  10,  18),
    Surface      = Color3.fromRGB(15,  15,  26),
    Panel        = Color3.fromRGB(19,  17,  34),
    TabBar       = Color3.fromRGB(13,  12,  22),
    Element      = Color3.fromRGB(22,  20,  38),
    ElementHover = Color3.fromRGB(30,  27,  52),
    Input        = Color3.fromRGB(14,  13,  26),
    TrackBg      = Color3.fromRGB(28,  26,  50),
    ToggleOn     = Color3.fromRGB(70,  220, 145),
    ToggleOff    = Color3.fromRGB(48,  44,  80),
    Accent       = Color3.fromRGB(110, 80,  255),
    AccentB      = Color3.fromRGB(140, 110, 255),
    AccentDim    = Color3.fromRGB(60,  42,  160),
    Cyan         = Color3.fromRGB(80,  220, 255),
    Gold         = Color3.fromRGB(255, 200, 70),
    Border       = Color3.fromRGB(55,  48,  95),
    BorderDim    = Color3.fromRGB(35,  32,  62),
    Text         = Color3.fromRGB(238, 235, 255),
    TextSub      = Color3.fromRGB(155, 145, 205),
    TextMuted    = Color3.fromRGB(85,  78,  130),
    TextAccent   = Color3.fromRGB(165, 140, 255),
    NSuccess     = Color3.fromRGB(70,  220, 145),
    NError       = Color3.fromRGB(255, 70,  100),
    NWarn        = Color3.fromRGB(255, 200, 70),
    NInfo        = Color3.fromRGB(80,  185, 255),
}

local tFast = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tMed  = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local function tw(o, i, p) TweenService:Create(o, i, p):Play() end
local function linTI(t)    return TweenInfo.new(t, Enum.EasingStyle.Linear) end

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end
local function Corner(r, p)  return New("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = p }) end
local function Stroke(c, th, tr, p) return New("UIStroke", { Color = c or T.Border, Thickness = th or 1, Transparency = tr or 0, Parent = p }) end
local function Grad(c0, c1, rot, p)
    return New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0,c0), ColorSequenceKeypoint.new(1,c1) }), Rotation = rot or 90, Parent = p })
end
local function Shadow(sz, tr, parent)
    return New("ImageLabel", {
        Name = "_Shadow", AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1,
        Position = UDim2.new(0.5,0,0.5,8), Size = UDim2.new(1, sz or 40, 1, sz or 40),
        ZIndex = math.max((parent.ZIndex or 1)-1, 0),
        Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0), ImageTransparency = tr or 0.5,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450), Parent = parent,
    })
end
local function Draggable(win, handle)
    local drag, start, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true; start=i.Position; origin=win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            win.Position = UDim2.new(origin.X.Scale, origin.X.Offset+d.X, origin.Y.Scale, origin.Y.Offset+d.Y)
        end
    end)
end

-- Notification system
local _ng, _nh
local function _ensureNotifs()
    if _ng and _ng.Parent then return end
    _ng = New("ScreenGui", { Name="QWERTY_Notifs", ResetOnSpawn=false, DisplayOrder=9999 })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(_ng) end end)
    if not pcall(function() _ng.Parent = CoreGui end) then _ng.Parent = LP:WaitForChild("PlayerGui") end
    _nh = New("Frame", { BackgroundTransparency=1, AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-18,1,-18), Size=UDim2.new(0,340,1,0), Parent=_ng })
    New("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,8), Parent=_nh })
end

local function Notify(title, msg, ntype, dur)
    ntype = (ntype or "info"):lower(); dur = dur or 4
    _ensureNotifs()
    local cmap = { success=T.NSuccess, error=T.NError, warn=T.NWarn, info=T.NInfo }
    local imap = { success="✔", error="✖", warn="⚠", info="ℹ" }
    local acc  = cmap[ntype] or T.NInfo
    local card = New("Frame", { BackgroundColor3=T.Panel, Size=UDim2.new(1,0,0,72), BackgroundTransparency=1, ClipsDescendants=true, Parent=_nh })
    Corner(12,card); Stroke(T.Border,1,0.35,card); Shadow(24,0.55,card)
    local bar = New("Frame",{BackgroundColor3=acc,Size=UDim2.new(0,3,1,0),BorderSizePixel=0,Parent=card}); Corner(6,bar)
    New("Frame",{BackgroundColor3=acc,BackgroundTransparency=0.82,Size=UDim2.new(0,44,1,0),BorderSizePixel=0,Parent=card})
    local ib = New("Frame",{BackgroundColor3=acc,BackgroundTransparency=0.78,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,14,0.5,0),Size=UDim2.new(0,28,0,28),Parent=card}); Corner(99,ib)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=imap[ntype] or "ℹ",TextColor3=acc,TextSize=15,Font=Enum.Font.GothamBold,Parent=ib})
    New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,50,0,10),Size=UDim2.new(1,-60,0,20),Text=title,TextColor3=T.Text,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
    New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,50,0,32),Size=UDim2.new(1,-60,0,32),Text=msg,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=card})
    local prog = New("Frame",{BackgroundColor3=acc,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,3,1,0),Size=UDim2.new(1,-3,0,2),BorderSizePixel=0,Parent=card}); Corner(2,prog)
    card.Position = UDim2.new(1,20,0,0)
    tw(card, tMed, { BackgroundTransparency=0, Position=UDim2.new(0,0,0,0) })
    tw(prog, linTI(dur), { Size=UDim2.new(0,0,0,2) })
    task.delay(dur, function()
        tw(card, tMed, { BackgroundTransparency=1, Position=UDim2.new(1,20,0,0) })
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- Window
local function Window(title, cfg)
    cfg = cfg or {}
    local W = cfg.Width or 760
    local H = cfg.Height or 540
    local self = { _tabs={}, _active=nil }

    local gui = New("ScreenGui", { Name="QWERTY_"..title:gsub("%s","_"), ResetOnSpawn=false, DisplayOrder=999, IgnoreGuiInset=true })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = CoreGui end) then gui.Parent = LP:WaitForChild("PlayerGui") end

    local win = New("Frame", { BackgroundColor3=T.BG, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,0,0,0), ClipsDescendants=false, Parent=gui })
    Corner(14,win); Stroke(T.Border,1.5,0,win); Shadow(65,0.35,win)
    local clip = New("Frame", { BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ClipsDescendants=true, Parent=win }); Corner(14,clip)

    -- Title bar
    local tb = New("Frame", { BackgroundColor3=T.Surface, Size=UDim2.new(1,0,0,52), Parent=clip })
    Grad(Color3.fromRGB(28,22,55), T.Surface, 125, tb)
    New("Frame",{BackgroundColor3=T.Border,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BorderSizePixel=0,Parent=tb})

    -- Traffic light dots
    local df = New("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,14,0.5,0),Size=UDim2.new(0,72,0,14),Parent=tb})
    for i, c in ipairs({ Color3.fromRGB(255,95,87), Color3.fromRGB(255,189,46), Color3.fromRGB(40,202,66) }) do
        local d = New("Frame",{BackgroundColor3=c,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,(i-1)*21,0.5,0),Size=UDim2.new(0,13,0,13),Parent=df}); Corner(99,d)
        local s = New("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.55,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,2),Size=UDim2.new(0,5,0,3),BorderSizePixel=0,Parent=d}); Corner(99,s)
    end

    New("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-180,1,0),Text=title,TextColor3=T.Text,TextSize=16,Font=Enum.Font.GothamBold,Parent=tb})
    local vb = New("Frame",{BackgroundColor3=T.Accent,BackgroundTransparency=0.75,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0.5,0),Size=UDim2.new(0,84,0,20),Parent=tb}); Corner(20,vb); Stroke(T.Accent,1,0.5,vb)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="QWERTY v2.0",TextColor3=T.TextAccent,TextSize=10,Font=Enum.Font.GothamBold,Parent=vb})
    Draggable(win, tb)

    -- Sidebar
    local sb = New("Frame",{BackgroundColor3=T.TabBar,Position=UDim2.new(0,0,0,52),Size=UDim2.new(0,160,1,-52),Parent=clip})
    Grad(Color3.fromRGB(14,12,28),T.TabBar,90,sb)
    New("Frame",{BackgroundColor3=T.Border,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,1,1,0),BorderSizePixel=0,Parent=sb})
    New("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-10),Size=UDim2.new(1,-16,0,16),Text="QWERTY-UI",TextColor3=T.TextMuted,TextSize=10,Font=Enum.Font.GothamBold,Parent=sb})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),Parent=sb})
    New("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=sb})

    local ch = New("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,161,0,53),Size=UDim2.new(1,-161,1,-53),Parent=clip})

    task.defer(function() tw(win, tMed, { Size=UDim2.new(0,W,0,H) }) end)

    function self:Tab(name, emoji)
        local td = { _name=name }
        local btn = New("TextButton",{BackgroundColor3=T.Accent,BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),Text=(emoji and emoji.."  " or "")..name,TextColor3=T.TextMuted,TextSize=12,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,Parent=sb})
        Corner(8,btn)
        local stripe = New("Frame",{BackgroundColor3=T.Accent,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-6,0.5,0),Size=UDim2.new(0,3,0,20),BorderSizePixel=0,Parent=btn}); Corner(4,stripe)
        local scroll = New("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ScrollBarThickness=3,ScrollBarImageColor3=T.Border,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=ch})
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7),Parent=scroll})
        New("UIPadding",{PaddingTop=UDim.new(0,14),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingBottom=UDim.new(0,14),Parent=scroll})
        td._btn=btn; td._stripe=stripe; td._scroll=scroll
        btn.MouseEnter:Connect(function() if self._active~=td then tw(btn,tFast,{BackgroundTransparency=0.9,TextColor3=T.TextSub}) end end)
        btn.MouseLeave:Connect(function() if self._active~=td then tw(btn,tFast,{BackgroundTransparency=1,TextColor3=T.TextMuted}) end end)
        btn.MouseButton1Click:Connect(function() self:_select(td) end)
        table.insert(self._tabs,td)
        if #self._tabs==1 then task.defer(function() self:_select(td) end) end

        local function El(h)
            local f = New("Frame",{BackgroundColor3=T.Element,Size=UDim2.new(1,0,0,h or 44),ClipsDescendants=false,Parent=scroll})
            Corner(10,f); Stroke(T.BorderDim,1,0.4,f); return f
        end

        local Tab = {}

        function Tab:Button(text, cb, desc)
            local el = El(desc and 58 or 44)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,desc and 8 or 0),Size=UDim2.new(1,-80,0,22),Text=text,TextColor3=T.Text,TextSize=13,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            if desc then New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,30),Size=UDim2.new(1,-80,0,20),Text=desc,TextColor3=T.TextMuted,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el}) end
            local pill = New("TextButton",{BackgroundColor3=T.Accent,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.new(0,56,0,26),Text="Run",TextColor3=Color3.new(1,1,1),TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,Parent=el})
            Corner(8,pill); Grad(T.AccentB,T.AccentDim,90,pill)
            local function ripple()
                local r=New("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.65,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,0,0,0),ZIndex=10,Parent=el}); Corner(99,r)
                tw(r,TweenInfo.new(0.45,Enum.EasingStyle.Quint),{Size=UDim2.new(0,350,0,350),BackgroundTransparency=1})
                task.delay(0.45,function() r:Destroy() end)
            end
            pill.MouseEnter:Connect(function() tw(pill,tFast,{BackgroundColor3=T.AccentB}) end)
            pill.MouseLeave:Connect(function() tw(pill,tFast,{BackgroundColor3=T.Accent}) end)
            pill.MouseButton1Click:Connect(function() ripple(); if cb then pcall(cb) end end)
            local z=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,-72,1,0),Text="",AutoButtonColor=false,Parent=el})
            z.MouseEnter:Connect(function() tw(el,tFast,{BackgroundColor3=T.ElementHover}) end)
            z.MouseLeave:Connect(function() tw(el,tFast,{BackgroundColor3=T.Element}) end)
            z.MouseButton1Click:Connect(function() ripple(); if cb then pcall(cb) end end)
        end

        function Tab:Toggle(text, default, cb, desc)
            local state = default==true
            local el = El(desc and 58 or 44)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,desc and 8 or 0),Size=UDim2.new(1,-74,0,22),Text=text,TextColor3=T.Text,TextSize=13,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            if desc then New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,30),Size=UDim2.new(1,-74,0,20),Text=desc,TextColor3=T.TextMuted,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el}) end
            local track=New("Frame",{BackgroundColor3=state and T.ToggleOn or T.ToggleOff,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0.5,0),Size=UDim2.new(0,46,0,25),Parent=el}); Corner(99,track)
            local knob=New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0,0.5),Position=state and UDim2.new(0,23,0.5,0) or UDim2.new(0,2,0.5,0),Size=UDim2.new(0,21,0,21),Parent=track}); Corner(99,knob)
            local function refresh()
                tw(track,tFast,{BackgroundColor3=state and T.ToggleOn or T.ToggleOff})
                tw(knob, tFast,{Position=state and UDim2.new(0,23,0.5,0) or UDim2.new(0,2,0.5,0)})
            end
            local z=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,Parent=el})
            z.MouseEnter:Connect(function() tw(el,tFast,{BackgroundColor3=T.ElementHover}) end)
            z.MouseLeave:Connect(function() tw(el,tFast,{BackgroundColor3=T.Element}) end)
            z.MouseButton1Click:Connect(function() state=not state; refresh(); if cb then pcall(cb,state) end end)
            refresh()
            local api={}
            function api:Set(v) state=v; refresh(); if cb then pcall(cb,state) end end
            function api:Get() return state end
            return api
        end

        function Tab:Slider(text, min, max, default, cb, suffix)
            min=min or 0; max=max or 100; default=math.clamp(default or min,min,max)
            local val=default
            local el=El(66)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,10),Size=UDim2.new(0.6,0,0,18),Text=text,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            local vl=New("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0.35,0,0,18),Text=tostring(val)..(suffix or ""),TextColor3=T.TextAccent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,Parent=el})
            local tbg=New("Frame",{BackgroundColor3=T.TrackBg,Position=UDim2.new(0,16,0,44),Size=UDim2.new(1,-32,0,8),Parent=el}); Corner(6,tbg)
            local fill=New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new((val-min)/(max-min),0,1,0),Parent=tbg}); Corner(6,fill); Grad(T.Cyan,T.Accent,90,fill)
            local knob=New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((val-min)/(max-min),0,0.5,0),Size=UDim2.new(0,17,0,17),Parent=tbg}); Corner(99,knob); Stroke(T.Accent,2,0.3,knob)
            local drag=false
            tbg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
            UserInputService.InputChanged:Connect(function(i)
                if not drag then return end
                if i.UserInputType==Enum.UserInputType.MouseMovement then
                    local pct=math.clamp((i.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
                    val=math.round(min+pct*(max-min)); vl.Text=tostring(val)..(suffix or "")
                    tw(fill,tFast,{Size=UDim2.new(pct,0,1,0)}); tw(knob,tFast,{Position=UDim2.new(pct,0,0.5,0)})
                    if cb then pcall(cb,val) end
                end
            end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
            local api={}
            function api:Set(v)
                val=math.clamp(v,min,max); local pct=(val-min)/(max-min)
                vl.Text=tostring(val)..(suffix or "")
                tw(fill,tFast,{Size=UDim2.new(pct,0,1,0)}); tw(knob,tFast,{Position=UDim2.new(pct,0,0.5,0)})
                if cb then pcall(cb,val) end
            end
            function api:Get() return val end
            return api
        end

        function Tab:Dropdown(text, options, default, cb)
            local sel=default or options[1]; local open=false
            local el=El(44); el.ClipsDescendants=false
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,0),Size=UDim2.new(0.5,0,1,0),Text=text,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            local sl=New("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-36,0.5,0),Size=UDim2.new(0.42,0,1,0),Text=sel,TextColor3=T.TextAccent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,Parent=el})
            local ar=New("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.new(0,18,0,18),Text="▾",TextColor3=T.TextMuted,TextSize=14,Font=Enum.Font.GothamBold,Parent=el})
            local pan=New("Frame",{BackgroundColor3=T.Panel,Position=UDim2.new(0,0,1,5),Size=UDim2.new(1,0,0,0),ClipsDescendants=true,ZIndex=30,Visible=false,Parent=el}); Corner(10,pan); Stroke(T.Border,1,0.3,pan)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=pan})
            New("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5),Parent=pan})
            for _,opt in ipairs(options) do
                local ob=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),Text="  "..opt,TextColor3=opt==sel and T.TextAccent or T.TextSub,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=31,Parent=pan})
                ob.MouseEnter:Connect(function() tw(ob,tFast,{BackgroundTransparency=0.88,TextColor3=T.Text}); ob.BackgroundColor3=T.Accent end)
                ob.MouseLeave:Connect(function() tw(ob,tFast,{BackgroundTransparency=1,TextColor3=opt==sel and T.TextAccent or T.TextSub}) end)
                ob.MouseButton1Click:Connect(function()
                    sel=opt; sl.Text=opt
                    for _,c in ipairs(pan:GetChildren()) do if c:IsA("TextButton") then c.TextColor3=c.Text:sub(3)==opt and T.TextAccent or T.TextSub end end
                    open=false; tw(pan,tFast,{Size=UDim2.new(1,0,0,0)}); tw(ar,tFast,{Rotation=0})
                    task.delay(0.15,function() pan.Visible=false end)
                    if cb then pcall(cb,sel) end
                end)
            end
            local totalH=#options*32+10
            local z=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,Parent=el})
            z.MouseEnter:Connect(function() tw(el,tFast,{BackgroundColor3=T.ElementHover}) end)
            z.MouseLeave:Connect(function() tw(el,tFast,{BackgroundColor3=T.Element}) end)
            z.MouseButton1Click:Connect(function()
                open=not open; pan.Visible=true
                tw(pan,tFast,{Size=open and UDim2.new(1,0,0,totalH) or UDim2.new(1,0,0,0)})
                tw(ar,tFast,{Rotation=open and 180 or 0})
                if not open then task.delay(0.15,function() pan.Visible=false end) end
            end)
            local api={}
            function api:Set(v) sel=v; sl.Text=v; if cb then pcall(cb,v) end end
            function api:Get() return sel end
            return api
        end

        function Tab:Input(text, placeholder, cb)
            local el=El(62)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,7),Size=UDim2.new(1,-32,0,18),Text=text,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            local box=New("TextBox",{BackgroundColor3=T.Input,Position=UDim2.new(0,16,0,30),Size=UDim2.new(1,-32,0,24),PlaceholderText=placeholder or "Type here...",PlaceholderColor3=T.TextMuted,Text="",TextColor3=T.Text,TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,Parent=el}); Corner(7,box)
            local sk=Stroke(T.BorderDim,1,0.5,box)
            box.Focused:Connect(function() tw(sk,tFast,{Color=T.Accent,Transparency=0}) end)
            box.FocusLost:Connect(function(enter) tw(sk,tFast,{Color=T.BorderDim,Transparency=0.5}); if enter and cb then pcall(cb,box.Text) end end)
            local api={}; function api:Get() return box.Text end; function api:Set(v) box.Text=v end; return api
        end

        function Tab:Keybind(text, default, cb)
            local key=default or Enum.KeyCode.RightShift; local listening=false
            local el=El(44)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,0),Size=UDim2.new(1,-96,1,0),Text=text,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            local kb=New("TextButton",{BackgroundColor3=T.TrackBg,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.new(0,80,0,26),Text=key.Name,TextColor3=T.TextAccent,TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,Parent=el}); Corner(7,kb); Stroke(T.Border,1,0.5,kb)
            kb.MouseButton1Click:Connect(function() listening=true; kb.Text="Press..."; kb.TextColor3=T.Gold end)
            UserInputService.InputBegan:Connect(function(i,gp)
                if not listening or gp then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; key=i.KeyCode; kb.Text=key.Name; kb.TextColor3=T.TextAccent
                    if cb then pcall(cb,key) end
                end
            end)
            local api={}; function api:Get() return key end; return api
        end

        function Tab:ColorPicker(text, default, cb)
            local col=default or Color3.fromRGB(110,80,255)
            local el=El(72)
            New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,16,0,8),Size=UDim2.new(0.55,0,0,18),Text=text,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
            local sw=New("Frame",{BackgroundColor3=col,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,8),Size=UDim2.new(0,32,0,18),Parent=el}); Corner(6,sw); Stroke(T.Border,1,0.3,sw)
            local hb=New("Frame",{Position=UDim2.new(0,16,0,38),Size=UDim2.new(1,-32,0,16),Parent=el}); Corner(6,hb)
            local ks={}; for i=0,6 do table.insert(ks,ColorSequenceKeypoint.new(math.clamp(i/6,0,1),Color3.fromHSV(i/6,1,1))) end
            New("UIGradient",{Color=ColorSequence.new(ks),Rotation=0,Parent=hb})
            local hk=New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(0,12,0,12),Parent=hb}); Corner(99,hk); Stroke(Color3.new(1,1,1),2,0,hk)
            local drag=false
            hb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
            UserInputService.InputChanged:Connect(function(i)
                if not drag then return end
                local pct=math.clamp((i.Position.X-hb.AbsolutePosition.X)/hb.AbsoluteSize.X,0,1)
                col=Color3.fromHSV(pct,1,1); sw.BackgroundColor3=col; hk.Position=UDim2.new(pct,0,0.5,0)
                if cb then pcall(cb,col) end
            end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
            local api={}; function api:Get() return col end; function api:Set(v) col=v; sw.BackgroundColor3=v; if cb then pcall(cb,v) end end; return api
        end

        function Tab:Label(text)
            New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),Text="  "..text,TextColor3=T.TextMuted,TextSize=11,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=scroll})
        end

        function Tab:Separator(text)
            local wrap=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),Parent=scroll})
            New("Frame",{BackgroundColor3=T.BorderDim,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),Parent=wrap})
            if text then
                local bg=New("TextLabel",{BackgroundColor3=T.BG,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,#text*7+22,0,16),Text=text,TextColor3=T.TextMuted,TextSize=10,Font=Enum.Font.GothamSemibold,Parent=wrap}); Corner(6,bg)
            end
        end

        return Tab
    end

    function self:_select(td)
        if self._active==td then return end
        if self._active then
            local p=self._active
            tw(p._btn,tFast,{BackgroundTransparency=1,TextColor3=T.TextMuted})
            tw(p._stripe,tFast,{Position=UDim2.new(0,-6,0.5,0)})
            p._scroll.Visible=false
        end
        self._active=td
        tw(td._btn,tFast,{BackgroundTransparency=0.88,TextColor3=T.TextAccent})
        td._btn.BackgroundColor3=T.Accent
        tw(td._stripe,tFast,{Position=UDim2.new(0,0,0.5,0)})
        td._scroll.Visible=true
    end

    function self:Destroy() tw(win,tMed,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1}); task.delay(0.3,function() gui:Destroy() end) end
    function self:Toggle() win.Visible=not win.Visible end

    return self
end

local QWERTY = { Window=Window, Notify=Notify, Theme=T, Version="2.0.0" }
getgenv().QWERTY = QWERTY
return QWERTY
