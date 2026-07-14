--[[
╔══════════════════════════════════════════════════════════════════╗
║           ETHOS // RE  ·  UI Library  v2.2                       ║
║  Features: Tab Sorter (Dropdown Categories)                     ║
║            Built-in Settings Tab (Themes + Config)              ║
║            Save/Load Config System                              ║
║            ThemeManager Integration                             ║
╚══════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
--  EXACT COLOURS (extracted directly from Relay.lua)
-- ═══════════════════════════════════════════════════════════════
local C = {
    WinBg       = Color3.fromRGB(12,  12,  16 ),
    TopBarBg    = Color3.fromRGB(19,  19,  25 ),
    Line        = Color3.fromRGB(34,  35,  43 ),
    GroupboxBg  = Color3.fromRGB(19,  19,  25 ),
    CheckboxBg  = Color3.fromRGB(12,  12,  16 ),
    CheckStroke = Color3.fromRGB(31,  31,  39 ),
    Red         = Color3.fromRGB(206, 51,  66 ),
    White       = Color3.fromRGB(255, 255, 255),
    TextGray    = Color3.fromRGB(116, 116, 131),
    TextTitle   = Color3.fromRGB(163, 163, 173),
    TextEl      = Color3.fromRGB(118, 118, 127),
    TextSub     = Color3.fromRGB(175, 175, 177),
    TabOff      = Color3.fromRGB(93,  93,  105),
    BtnBg       = Color3.fromRGB(70,  70,  86 ),
    SliderTrack = Color3.fromRGB(31,  31,  39 ),
    InputBg     = Color3.fromRGB(12,  12,  16 ),
    InputStroke = Color3.fromRGB(33,  34,  40 ),
    InputText   = Color3.fromRGB(130, 130, 131),
    Placeholder = Color3.fromRGB(90,  90,  100),
    DropBg      = Color3.fromRGB(19,  19,  25 ),
    DropItem    = Color3.fromRGB(26,  26,  34 ),
    DropSel     = Color3.fromRGB(35,  20,  24 ),
    NotifBg     = Color3.fromRGB(19,  19,  25 ),
}

-- ═══════════════════════════════════════════════════════════════
--  EXACT ASSET IDs (from Relay.lua)
-- ═══════════════════════════════════════════════════════════════
local A = {
    Close     = "rbxassetid://89555599605432",
    Minimize  = "rbxassetid://107635635765106",
    Arrow     = "rbxassetid://128254015050703",
    CheckIcon = "rbxassetid://83941192767745",
    Cursor    = "rbxassetid://131481965346967",
}

local FONT = Font.new(
    "rbxasset://textures/9a743830a53af75ddb339483839094c951328dc5ebc84d387297433a80b3a46f.font",
    Enum.FontWeight.Regular, Enum.FontStyle.Normal
)

-- ═══════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ═══════════════════════════════════════════════════════════════
local TI_FAST   = TweenInfo.new(0.10, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_MED    = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_SLOW   = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- ═══════════════════════════════════════════════════════════════
--  INSTANCE CONSTRUCTORS
-- ═══════════════════════════════════════════════════════════════
local function new(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function corner(r, p)
    return new("UICorner", {CornerRadius = UDim.new(0, r or 3)}, p)
end

local function stroke(col, thick, trans, p)
    return new("UIStroke", {
        Color               = col   or C.Line,
        Thickness           = thick or 1,
        Transparency        = trans or 0,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    }, p)
end

local function pad(l, r, t, b, p)
    return new("UIPadding", {
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, p)
end

local function list(dir, spacing, ha, va, p)
    return new("UIListLayout", {
        FillDirection       = dir     or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, spacing or 0),
        HorizontalAlignment = ha      or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va      or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    }, p)
end

local function lbl(props, parent)
    local l = new("TextLabel", {
        BackgroundTransparency = 1,
        TextColor3             = C.White,
        FontFace               = FONT,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        RichText               = false,
        TextTruncate           = Enum.TextTruncate.None,
        TextWrapped            = false,
        TextScaled             = false,
    })
    for k, v in pairs(props or {}) do l[k] = v end
    if parent then l.Parent = parent end
    return l
end

local function clickArea(zindex, parent)
    return new("TextButton", {
        BackgroundTransparency = 1,
        Text                   = "",
        FontFace               = Font.new("rbxasset://fonts/families/LegacyArial.json"),
        TextSize               = 8,
        AutoButtonColor        = true,
        Size                   = UDim2.fromScale(1, 1),
        ZIndex                 = zindex or 3,
    }, parent)
end

-- ═══════════════════════════════════════════════════════════════
--  DRAG
-- ═══════════════════════════════════════════════════════════════
local function makeDraggable(handle, target)
    local drag, startM, startP = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        drag = true
        startM = Vector2.new(i.Position.X, i.Position.Y)
        startP = target.Position
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = Vector2.new(i.Position.X, i.Position.Y) - startM
        target.Position = UDim2.new(
            startP.X.Scale, startP.X.Offset + d.X,
            startP.Y.Scale, startP.Y.Offset + d.Y
        )
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local NotifGui, NotifHolder

local function initNotifs()
    NotifGui = new("ScreenGui", {
        Name            = "EthosNotifications",
        IgnoreGuiInset  = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 1000,
        ResetOnSpawn    = false,
    })
    local ok = pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
    if not ok then NotifGui.Parent = LP:WaitForChild("PlayerGui") end

    NotifHolder = new("Frame", {
        Name                   = "Holder",
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex                 = 1,
        Parent                 = NotifGui,
    })
    list(Enum.FillDirection.Vertical, 6,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom, NotifHolder)
    pad(0, 14, 0, 14, NotifHolder)
end

local NOTIF_COLORS = {
    Success = Color3.fromRGB(50,  200, 100),
    Error   = Color3.fromRGB(206, 51,  66 ),
    Warning = Color3.fromRGB(230, 160, 30 ),
    Info    = Color3.fromRGB(80,  140, 220),
}

function Notify(opts)
    opts = opts or {}
    if not NotifHolder then initNotifs() end

    local accent   = NOTIF_COLORS[opts.Type or "Info"] or NOTIF_COLORS.Info
    local duration = opts.Duration or 4

    local card = new("Frame", {
        Name                   = "Notif",
        Size                   = UDim2.fromOffset(280, 70),
        BackgroundColor3       = C.NotifBg,
        BackgroundTransparency = 0,
        ClipsDescendants       = true,
        ZIndex                 = 10,
        Parent                 = NotifHolder,
    })
    corner(4, card)
    stroke(C.Line, 1, 0.3, card)

    local bar = new("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        ZIndex           = 11,
        Parent           = card,
    })
    corner(2, bar)

    local pill = new("Frame", {
        Size             = UDim2.fromOffset(0, 16),
        AutomaticSize    = Enum.AutomaticSize.X,
        Position         = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = accent,
        ZIndex           = 11,
        Parent           = card,
    })
    corner(3, pill)
    pad(5, 5, 0, 0, pill)
    lbl({
        Text          = opts.Type or "Info",
        TextColor3    = C.White,
        TextSize      = 10,
        Size          = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex        = 12,
    }, pill)

    lbl({
        Text       = opts.Title or "Notification",
        TextColor3 = C.White,
        TextSize   = 13,
        Size       = UDim2.new(1, -14, 0, 18),
        Position   = UDim2.new(0, 10, 0, 27),
        ZIndex     = 11,
    }, card)

    lbl({
        Text         = opts.Message or "",
        TextColor3   = C.TextGray,
        TextSize     = 11,
        Size         = UDim2.new(1, -14, 0, 16),
        Position     = UDim2.new(0, 10, 0, 47),
        ZIndex       = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)

    local progTrack = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        ZIndex           = 12,
        Parent           = card,
    })
    local progFill = new("Frame", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundColor3 = accent,
        ZIndex           = 13,
        Parent           = progTrack,
    })

    card.Position = UDim2.fromOffset(300, 0)
    tw(card, TI_MED, { Position = UDim2.fromOffset(0, 0) })

    task.delay(0.05, function()
        tw(progFill,
            TweenInfo.new(duration - 0.05, Enum.EasingStyle.Linear),
            { Size = UDim2.fromScale(0, 1) })
    end)

    task.delay(duration, function()
        tw(card, TI_MED, { Position = UDim2.fromOffset(310, 0) })
        task.delay(0.25, function() card:Destroy() end)
    end)

    card.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            tw(card, TI_FAST, { Position = UDim2.fromOffset(310, 0) })
            task.delay(0.15, function() card:Destroy() end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  THEME MANAGER INTEGRATION
-- ═══════════════════════════════════════════════════════════════
local ThemeManager = nil

local function loadThemeManager()
    if ThemeManager then return ThemeManager end
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Vinkzzz/Lunar-Suite/refs/heads/main/ThemeManager.lua"))()
    end)
    
    if success and result then
        ThemeManager = result
        ThemeManager:SetFolder("EthosSettings")
        ThemeManager:SetLibrary({
            FontColor = C.White,
            MainColor = C.WinBg,
            AccentColor = C.Red,
            BackgroundColor = C.GroupboxBg,
            OutlineColor = C.Line,
            GetDarkerColor = function(self, color)
                local r, g, b = color.R * 0.7, color.G * 0.7, color.B * 0.7
                return Color3.new(r, g, b)
            end,
            UpdateColorsUsingRegistry = function() end,
            Notify = function(msg) Notify({Title = "Theme", Message = msg, Type = "Info"}) end
        })
        return ThemeManager
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════
local ConfigSystem = {}

function ConfigSystem:GetFolder()
    return "EthosSettings"
end

function ConfigSystem:EnsureFolder()
    local folder = self:GetFolder()
    if not isfolder(folder) then
        makefolder(folder)
    end
    local configFolder = folder .. "/configs"
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
end

function ConfigSystem:GetConfigs()
    self:EnsureFolder()
    local configs = {}
    local folder = self:GetFolder() .. "/configs"
    for _, file in ipairs(listfiles(folder)) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    table.sort(configs)
    return configs
end

function ConfigSystem:SaveConfig(name, data)
    self:EnsureFolder()
    local folder = self:GetFolder() .. "/configs"
    local path = folder .. "/" .. name .. ".json"
    local json = HttpService:JSONEncode(data)
    writefile(path, json)
    return true
end

function ConfigSystem:LoadConfig(name)
    self:EnsureFolder()
    local folder = self:GetFolder() .. "/configs"
    local path = folder .. "/" .. name .. ".json"
    if not isfile(path) then return nil end
    local json = readfile(path)
    local success, data = pcall(HttpService.JSONDecode, HttpService, json)
    if success then
        return data
    end
    return nil
end

function ConfigSystem:DeleteConfig(name)
    self:EnsureFolder()
    local folder = self:GetFolder() .. "/configs"
    local path = folder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: TOGGLE
-- ═══════════════════════════════════════════════════════════════
local function buildToggle(container, id, opts)
    opts = opts or {}
    local value = opts.Default or false
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })

    local titleLbl = lbl({
        Name          = "Title",
        Text          = opts.Label or id,
        TextColor3    = C.TextEl,
        TextSize      = 13,
        Size          = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex        = 1,
    }, holder)
    pad(10, 0, 5, 10, titleLbl)

    local ckOuter = new("Frame", {
        Name             = "Checkmark",
        Size             = UDim2.fromOffset(18, 18),
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -8, 0.5, 0),
        BackgroundColor3 = C.CheckboxBg,
        ZIndex           = 2,
        Parent           = holder,
    })
    corner(3, ckOuter)
    local ckStroke = stroke(C.CheckStroke, 1.3, 0, ckOuter)

    local glowF = new("Frame", {
        Name                   = "Glow",
        Size                   = UDim2.fromOffset(20, 20),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3       = C.Red,
        BackgroundTransparency = 1,
        ZIndex                 = 0,
        Parent                 = ckOuter,
    })
    corner(2, glowF)
    local glowS = stroke(C.Red, 2, 1, glowF)

    local ckImg = new("ImageLabel", {
        Name                 = "Checkicon",
        Image                = A.CheckIcon,
        ImageColor3          = C.White,
        ImageTransparency    = 1,
        Size                 = UDim2.fromOffset(13, 13),
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex               = 2,
        ScaleType            = Enum.ScaleType.Fit,
        Parent               = ckOuter,
    })

    local ckBtn  = clickArea(4, ckOuter)
    local rowBtn = clickArea(3, holder)

    local function set(v)
        value = v
        if v then
            tw(ckOuter,  TI_FAST, { BackgroundColor3 = C.Red })
            tw(ckStroke, TI_FAST, { Color = C.Red, Transparency = 1 })
            tw(glowF,    TI_FAST, { BackgroundTransparency = 0.65 })
            tw(glowS,    TI_FAST, { Transparency = 0.35 })
            tw(ckImg,    TI_FAST, { ImageTransparency = 0 })
            tw(titleLbl, TI_FAST, { TextColor3 = C.White })
        else
            tw(ckOuter,  TI_FAST, { BackgroundColor3 = C.CheckboxBg })
            tw(ckStroke, TI_FAST, { Color = C.CheckStroke, Transparency = 0 })
            tw(glowF,    TI_FAST, { BackgroundTransparency = 1 })
            tw(glowS,    TI_FAST, { Transparency = 1 })
            tw(ckImg,    TI_FAST, { ImageTransparency = 1 })
            tw(titleLbl, TI_FAST, { TextColor3 = C.TextEl })
        end
        if opts.Flag then
            _G.EthosFlags = _G.EthosFlags or {}
            _G.EthosFlags[opts.Flag] = v
        end
        if opts.Callback then task.spawn(opts.Callback, v) end
    end

    rowBtn.MouseEnter:Connect(function()
        if not value then tw(titleLbl, TI_FAST, { TextColor3 = C.TextSub }) end
    end)
    rowBtn.MouseLeave:Connect(function()
        if not value then tw(titleLbl, TI_FAST, { TextColor3 = C.TextEl }) end
    end)
    rowBtn.MouseButton1Up:Connect(function() set(not value) end)
    ckBtn.MouseButton1Up:Connect(function() set(not value) end)

    if value then set(true) end

    elementRef.Set = set
    elementRef.Get = function() return value end
    elementRef._flag = opts.Flag
    elementRef._type = "toggle"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: SLIDER
-- ═══════════════════════════════════════════════════════════════
local function buildSlider(container, id, opts)
    opts = opts or {}
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local step = opts.Step or opts.Increment or 1
    local val  = math.clamp(opts.Default or minV, minV, maxV)
    local slW  = opts.Width or 130
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })

    local titleLbl = lbl({
        Name          = "Title",
        Text          = opts.Label or id,
        TextColor3    = C.TextEl,
        TextSize      = 13,
        Size          = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex        = 1,
    }, holder)
    pad(10, 0, 5, 10, titleLbl)

    local slFrame = new("Frame", {
        Name                   = "SliderFrame",
        Size                   = UDim2.fromOffset(slW, 24),
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -8, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = holder,
    })

    local valLbl = lbl({
        Name           = "Value",
        Text           = tostring(val),
        TextColor3     = C.Red,
        TextSize       = 11,
        Size           = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 3,
    }, slFrame)

    local track = new("Frame", {
        Name             = "Track",
        Size             = UDim2.new(1, 0, 0, 5),
        Position         = UDim2.new(0, 0, 0, 14),
        BackgroundColor3 = C.SliderTrack,
        ZIndex           = 2,
        Parent           = slFrame,
    })
    corner(999, track)

    local fill = new("Frame", {
        Name             = "Fill",
        Size             = UDim2.fromScale((val - minV) / (maxV - minV), 1),
        BackgroundColor3 = C.Red,
        ZIndex           = 3,
        Parent           = track,
    })
    corner(999, fill)

    local knob = new("Frame", {
        Name             = "Knob",
        Size             = UDim2.fromOffset(10, 10),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new((val - minV) / (maxV - minV), 0, 0.5, 0),
        BackgroundColor3 = C.Red,
        ZIndex           = 4,
        Parent           = track,
    })
    corner(999, knob)
    stroke(Color3.fromRGB(255, 200, 200), 1, 0.4, knob)

    local dragBtn = new("TextButton", {
        Name                   = "DragArea",
        Size                   = UDim2.new(1, 0, 0, 18),
        Position               = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Text                   = "",
        AutoButtonColor        = false,
        ZIndex                 = 5,
        Parent                 = track,
    })

    local function applyVal(v)
        v = math.clamp(v, minV, maxV)
        if step > 0 then v = math.round(v / step) * step end
        val = v
        local pct = (v - minV) / (maxV - minV)
        tw(fill, TI_FAST, { Size = UDim2.fromScale(pct, 1) })
        tw(knob, TI_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
        valLbl.Text = tostring(v)
        if opts.Flag then
            _G.EthosFlags = _G.EthosFlags or {}
            _G.EthosFlags[opts.Flag] = v
        end
        if opts.Callback then task.spawn(opts.Callback, v) end
    end

    local dragging = false
    local function fromMouse(inp)
        local abs = track.AbsolutePosition
        local sz  = track.AbsoluteSize
        local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        applyVal(minV + (maxV - minV) * pct)
    end

    dragBtn.MouseButton1Down:Connect(function(_, inp)
        dragging = true
        fromMouse(inp)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            fromMouse(inp)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    elementRef.Set = applyVal
    elementRef.Get = function() return val end
    elementRef._flag = opts.Flag
    elementRef._type = "slider"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: BUTTON
-- ═══════════════════════════════════════════════════════════════
local function buildButton(container, opts)
    opts = opts or {}

    local holder = new("Frame", {
        Name                   = "EH_btn",
        Size                   = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })

    local btnFrame = new("Frame", {
        Name                   = "Button",
        Size                   = UDim2.new(1, -15, 1, -10),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3       = C.BtnBg,
        BackgroundTransparency = 0.4,
        ZIndex                 = 1,
        Parent                 = holder,
    })
    corner(4, btnFrame)
    local btnStroke = stroke(C.BtnBg, 1, 0, btnFrame)

    local btn = new("TextButton", {
        Name                   = "TextButton",
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text                   = opts.Label or "Button",
        TextColor3             = C.White,
        FontFace               = FONT,
        TextSize               = 13,
        AutoButtonColor        = true,
        ZIndex                 = 1,
        Parent                 = btnFrame,
    })

    btn.MouseEnter:Connect(function()
        tw(btnFrame,  TI_FAST, { BackgroundTransparency = 0.15, BackgroundColor3 = C.Red })
        tw(btnStroke, TI_FAST, { Color = C.Red })
    end)
    btn.MouseLeave:Connect(function()
        tw(btnFrame,  TI_FAST, { BackgroundTransparency = 0.4, BackgroundColor3 = C.BtnBg })
        tw(btnStroke, TI_FAST, { Color = C.BtnBg })
    end)
    btn.MouseButton1Down:Connect(function()
        tw(btnFrame, TI_FAST, { BackgroundTransparency = 0.05 })
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btnFrame, TI_FAST, { BackgroundTransparency = 0.15 })
        if opts.Callback then task.spawn(opts.Callback) end
    end)

    return btn
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: DROPDOWN
-- ═══════════════════════════════════════════════════════════════
local function buildDropdown(container, id, opts)
    opts = opts or {}
    local options  = opts.Options or {}
    local selected = opts.Default or (options[1] or "")
    local isOpen   = false
    local optBtns  = {}
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants       = false,
        ZIndex                 = 2,
        Parent                 = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)

    lbl({
        Text       = opts.Label or id,
        TextColor3 = C.TextEl,
        TextSize   = 11,
        Size       = UDim2.new(1, 0, 0, 14),
        ZIndex     = 2,
    }, holder)

    local header = new("Frame", {
        Name             = "DropHeader",
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = C.InputBg,
        ZIndex           = 2,
        Parent           = holder,
    })
    corner(3, header)
    stroke(C.InputStroke, 1, 0, header)
    pad(8, 22, 0, 0, header)

    local selLbl = lbl({
        Name       = "Selected",
        Text       = selected,
        TextColor3 = C.InputText,
        TextSize   = 12,
        Size       = UDim2.fromScale(1, 1),
        ZIndex     = 3,
    }, header)

    local arrowImg = new("ImageButton", {
        Name                   = "Arrow",
        Image                  = A.Arrow,
        ImageColor3            = C.TextGray,
        Size                   = UDim2.fromOffset(12, 12),
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -6, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 3,
        Parent                 = header,
    })

    local listWrap = new("Frame", {
        Name                   = "ListWrap",
        Size                   = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        ZIndex                 = 25,
        Parent                 = holder,
    })

    local listF = new("Frame", {
        Name             = "ListFrame",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.DropBg,
        ZIndex           = 26,
        Parent           = listWrap,
    })
    corner(3, listF)
    stroke(C.InputStroke, 1, 0, listF)
    list(nil, 1, nil, nil, listF)
    pad(2, 2, 2, 2, listF)

    local OPT_H = 24

    local function setSelected(v)
        selected = v
        selLbl.Text = v
        if opts.Flag then
            _G.EthosFlags = _G.EthosFlags or {}
            _G.EthosFlags[opts.Flag] = v
        end
        if opts.Callback then task.spawn(opts.Callback, v) end
    end

    for _, opt in ipairs(options) do
        local isSel = opt == selected
        local ob = new("TextButton", {
            Name                   = "Opt_"..opt,
            Size                   = UDim2.new(1, 0, 0, OPT_H),
            BackgroundColor3       = isSel and C.DropSel or C.DropItem,
            BackgroundTransparency = isSel and 0 or 0.45,
            Text                   = opt,
            TextColor3             = isSel and C.Red or C.TextGray,
            FontFace               = FONT,
            TextSize               = 12,
            TextXAlignment         = Enum.TextXAlignment.Left,
            AutoButtonColor        = false,
            ZIndex                 = 27,
            Parent                 = listF,
        })
        corner(2, ob)
        pad(8, 0, 0, 0, ob)
        optBtns[opt] = ob

        ob.MouseEnter:Connect(function()
            if opt ~= selected then
                tw(ob, TI_FAST, { BackgroundTransparency = 0.2, BackgroundColor3 = C.DropItem })
            end
        end)
        ob.MouseLeave:Connect(function()
            if opt ~= selected then
                tw(ob, TI_FAST, { BackgroundTransparency = 0.45, BackgroundColor3 = C.DropItem })
            end
        end)
        ob.MouseButton1Up:Connect(function()
            if optBtns[selected] then
                tw(optBtns[selected], TI_FAST, {
                    BackgroundColor3       = C.DropItem,
                    BackgroundTransparency = 0.45,
                })
                optBtns[selected].TextColor3 = C.TextGray
            end
            tw(ob, TI_FAST, {
                BackgroundColor3       = C.DropSel,
                BackgroundTransparency = 0,
            })
            ob.TextColor3 = C.Red
            setSelected(opt)
            isOpen = false
            tw(listWrap, TI_MED, { Size = UDim2.new(1, 0, 0, 0) })
            tw(arrowImg, TI_FAST, { Rotation = 0 })
        end)
    end

    local totalH = #options * (OPT_H + 1) + 4

    local function toggleOpen()
        isOpen = not isOpen
        tw(listWrap, TI_MED, { Size = UDim2.new(1, 0, 0, isOpen and totalH or 0) })
        tw(arrowImg,  TI_FAST, { Rotation = isOpen and 180 or 0 })
    end

    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then toggleOpen() end
    end)
    arrowImg.MouseButton1Up:Connect(toggleOpen)

    elementRef.Set = setSelected
    elementRef.Get = function() return selected end
    elementRef._flag = opts.Flag
    elementRef._type = "dropdown"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: INPUT (TextBox)
-- ═══════════════════════════════════════════════════════════════
local function buildInput(container, id, opts)
    opts = opts or {}
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })

    local titleLbl = lbl({
        Name          = "Title",
        Text          = opts.Label or id,
        TextColor3    = C.TextEl,
        TextSize      = 13,
        Size          = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex        = 1,
    }, holder)
    pad(10, 0, 5, 10, titleLbl)

    local tbFrame = new("Frame", {
        Name                   = "Textbox",
        Size                   = UDim2.new(0, 0, 1, -6),
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -8, 0.5, 0),
        AutomaticSize          = Enum.AutomaticSize.X,
        BackgroundColor3       = C.InputBg,
        ZIndex                 = 2,
        Parent                 = holder,
    })
    corner(3, tbFrame)
    local tbStroke = stroke(C.InputStroke, 1, 0, tbFrame)
    pad(5, 5, 5, 5, tbFrame)

    local box = new("TextBox", {
        Name                   = "TextBox",
        Size                   = UDim2.fromOffset(0, 0),
        AutomaticSize          = Enum.AutomaticSize.XY,
        AnchorPoint            = Vector2.new(0, 0.5),
        Position               = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        PlaceholderText        = opts.Placeholder or "",
        PlaceholderColor3      = C.Placeholder,
        Text                   = opts.Default or "",
        TextColor3             = C.InputText,
        FontFace               = FONT,
        TextSize               = 12,
        ClearTextOnFocus       = false,
        ClipsDescendants       = true,
        ZIndex                 = 1,
        Parent                 = tbFrame,
    })

    local minW = opts.MinWidth or 80
    box:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if box.AbsoluteSize.X < minW then
            tbFrame.Size = UDim2.new(0, minW, 1, -6)
        end
    end)
    tbFrame.Size = UDim2.new(0, minW, 1, -6)

    box.Focused:Connect(function()
        tw(tbStroke, TI_FAST, { Color = C.Red })
    end)
    box.FocusLost:Connect(function(enter)
        tw(tbStroke, TI_FAST, { Color = C.InputStroke })
        if opts.Flag then
            _G.EthosFlags = _G.EthosFlags or {}
            _G.EthosFlags[opts.Flag] = box.Text
        end
        if opts.Callback then task.spawn(opts.Callback, box.Text, enter) end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if opts.OnChange then task.spawn(opts.OnChange, box.Text) end
    end)

    elementRef.Set = function(v) box.Text = v end
    elementRef.Get = function() return box.Text end
    elementRef._flag = opts.Flag
    elementRef._type = "input"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: KEYBIND
-- ═══════════════════════════════════════════════════════════════
local function buildKeybind(container, id, opts)
    opts = opts or {}
    local key       = opts.Default or Enum.KeyCode.Unknown
    local listening = false
    local conn
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })

    local titleLbl = lbl({
        Name          = "Title",
        Text          = opts.Label or id,
        TextColor3    = C.TextEl,
        TextSize      = 13,
        Size          = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex        = 1,
    }, holder)
    pad(10, 0, 5, 10, titleLbl)

    local kbFrame = new("Frame", {
        Name             = "KeybindFrame",
        Size             = UDim2.fromOffset(80, 22),
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -8, 0.5, 0),
        BackgroundColor3 = C.InputBg,
        ZIndex           = 2,
        Parent           = holder,
    })
    corner(3, kbFrame)
    local kbStroke = stroke(C.InputStroke, 1, 0, kbFrame)
    pad(6, 6, 0, 0, kbFrame)

    local keyLbl = lbl({
        Name           = "KeyLabel",
        Text           = key == Enum.KeyCode.Unknown and "None" or key.Name,
        TextColor3     = C.Red,
        TextSize       = 12,
        Size           = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 3,
    }, kbFrame)

    local clickBtn = clickArea(4, kbFrame)

    clickBtn.MouseButton1Up:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        tw(kbStroke, TI_FAST, { Color = C.Red })

        conn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                key = inp.KeyCode
                keyLbl.Text = key.Name
                listening = false
                tw(kbStroke, TI_FAST, { Color = C.InputStroke })
                if conn then conn:Disconnect(); conn = nil end
                if opts.Flag then
                    _G.EthosFlags = _G.EthosFlags or {}
                    _G.EthosFlags[opts.Flag] = key
                end
            end
        end)
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or listening then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key then
            if opts.Callback then task.spawn(opts.Callback, key) end
        end
    end)

    elementRef.Set = function(k) key = k; keyLbl.Text = k.Name end
    elementRef.Get = function() return key end
    elementRef._flag = opts.Flag
    elementRef._type = "keybind"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: COLORPICKER
-- ═══════════════════════════════════════════════════════════════
local function buildColorpicker(container, id, opts)
    opts = opts or {}
    local color  = opts.Default or Color3.fromRGB(206, 51, 66)
    local h, s, v = Color3.toHSV(color)
    local isOpen = false
    local elementRef = {}

    local holder = new("Frame", {
        Name                   = "EH_"..id,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants       = false,
        ZIndex                 = 2,
        Parent                 = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)

    lbl({
        Text       = opts.Label or id,
        TextColor3 = C.TextEl,
        TextSize   = 11,
        Size       = UDim2.new(1, 0, 0, 14),
        ZIndex     = 2,
    }, holder)

    local headerRow = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, 26),
        BackgroundColor3       = C.InputBg,
        ZIndex                 = 2,
        Parent                 = holder,
    })
    corner(3, headerRow)
    stroke(C.InputStroke, 1, 0, headerRow)
    pad(8, 8, 0, 0, headerRow)

    local swatch = new("Frame", {
        Name             = "Swatch",
        Size             = UDim2.fromOffset(30, 16),
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = color,
        ZIndex           = 3,
        Parent           = headerRow,
    })
    corner(3, swatch)
    stroke(C.Line, 1, 0, swatch)

    local swatchBtn = new("TextButton", {
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text                   = "",
        AutoButtonColor        = false,
        ZIndex                 = 5,
        Parent                 = headerRow,
    })

    local panelWrap = new("Frame", {
        Name                   = "PanelWrap",
        Size                   = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        ZIndex                 = 20,
        Parent                 = holder,
    })

    local panel = new("Frame", {
        Name             = "Panel",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.DropBg,
        ZIndex           = 21,
        Parent           = panelWrap,
    })
    corner(3, panel)
    stroke(C.InputStroke, 1, 0, panel)
    list(nil, 6, nil, nil, panel)
    pad(8, 8, 6, 6, panel)

    local function updateColor()
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        if opts.Flag then
            _G.EthosFlags = _G.EthosFlags or {}
            _G.EthosFlags[opts.Flag] = color
        end
        if opts.Callback then task.spawn(opts.Callback, color) end
    end

    local SLIDERS = {
        { label="H", get=function() return h end, set=function(x) h=x end },
        { label="S", get=function() return s end, set=function(x) s=x end },
        { label="V", get=function() return v end, set=function(x) v=x end },
    }
    local panelH = 6 + 6
    for _, sd in ipairs(SLIDERS) do
        local row = new("Frame", {
            Size                   = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            ZIndex                 = 21,
            Parent                 = panel,
        })
        panelH = panelH + 18 + 6

        lbl({
            Text       = sd.label,
            TextColor3 = C.TextGray,
            TextSize   = 10,
            Size       = UDim2.fromOffset(10, 18),
            ZIndex     = 22,
        }, row)

        local tr = new("Frame", {
            Size             = UDim2.new(1, -16, 0, 5),
            Position         = UDim2.new(0, 14, 0.5, -2),
            BackgroundColor3 = C.SliderTrack,
            ZIndex           = 22,
            Parent           = row,
        })
        corner(999, tr)

        local fl = new("Frame", {
            Size             = UDim2.fromScale(sd.get(), 1),
            BackgroundColor3 = C.Red,
            ZIndex           = 23,
            Parent           = tr,
        })
        corner(999, fl)

        local kn = new("Frame", {
            Size             = UDim2.fromOffset(9, 9),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(sd.get(), 0, 0.5, 0),
            BackgroundColor3 = C.White,
            ZIndex           = 24,
            Parent           = tr,
        })
        corner(999, kn)

        local db = new("TextButton", {
            Size                   = UDim2.new(1, 0, 0, 18),
            Position               = UDim2.new(0, 0, 0.5, -9),
            BackgroundTransparency = 1,
            Text                   = "",
            AutoButtonColor        = false,
            ZIndex                 = 25,
            Parent                 = tr,
        })

        local draggingCP = false
        local function fromCP(inp)
            local abs = tr.AbsolutePosition
            local sz  = tr.AbsoluteSize
            local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            pct = math.round(pct * 100) / 100
            sd.set(pct)
            fl.Size     = UDim2.fromScale(pct, 1)
            kn.Position = UDim2.new(pct, 0, 0.5, 0)
            updateColor()
        end

        db.MouseButton1Down:Connect(function(_, inp)
            draggingCP = true; fromCP(inp)
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if draggingCP and inp.UserInputType == Enum.UserInputType.MouseMovement then
                fromCP(inp)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingCP = false
            end
        end)
    end

    local hexRow = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex                 = 21,
        Parent                 = panel,
    })
    panelH = panelH + 20 + 6

    lbl({
        Text       = "HEX",
        TextColor3 = C.TextGray,
        TextSize   = 10,
        Size       = UDim2.fromOffset(24, 20),
        ZIndex     = 22,
    }, hexRow)

    local hexBox = new("TextBox", {
        Size                   = UDim2.new(1, -30, 1, -4),
        Position               = UDim2.new(0, 28, 0.5, -8),
        BackgroundColor3       = C.InputBg,
        BackgroundTransparency = 0,
        Text                   = "#"..color:ToHex():upper(),
        TextColor3             = C.InputText,
        FontFace               = FONT,
        TextSize               = 11,
        PlaceholderText        = "#RRGGBB",
        PlaceholderColor3      = C.Placeholder,
        ClearTextOnFocus       = false,
        ZIndex                 = 22,
        Parent                 = hexRow,
    })
    corner(3, hexBox)
    local hexStroke = stroke(C.InputStroke, 1, 0, hexBox)
    pad(4, 4, 0, 0, hexBox)

    hexBox.Focused:Connect(function()
        tw(hexStroke, TI_FAST, { Color = C.Red })
    end)
    hexBox.FocusLost:Connect(function()
        tw(hexStroke, TI_FAST, { Color = C.InputStroke })
        local hex = hexBox.Text:gsub("#", "")
        if #hex == 6 then
            local ok, c3 = pcall(Color3.fromHex, hex)
            if ok then
                color = c3
                h, s, v = Color3.toHSV(c3)
                swatch.BackgroundColor3 = c3
                updateColor()
            end
        end
    end)

    swatchBtn.MouseButton1Up:Connect(function()
        isOpen = not isOpen
        tw(panelWrap, TI_MED, { Size = UDim2.new(1, 0, 0, isOpen and panelH or 0) })
    end)

    elementRef.Set = function(c3)
        color = c3; h, s, v = Color3.toHSV(c3)
        swatch.BackgroundColor3 = c3
        hexBox.Text = "#"..c3:ToHex():upper()
    end
    elementRef.Get = function() return color end
    elementRef._flag = opts.Flag
    elementRef._type = "colorpicker"
    return elementRef
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: LABEL
-- ═══════════════════════════════════════════════════════════════
local function buildLabel(container, opts)
    opts = type(opts) == "string" and { Text = opts } or opts
    local l = lbl({
        Name         = "Label",
        Text         = opts.Text or opts.Label or "",
        TextColor3   = opts.Color or C.TextSub,
        TextSize     = opts.Size or 12,
        Size         = UDim2.new(1, 0, 0, 0),
        AutomaticSize= Enum.AutomaticSize.Y,
        TextWrapped  = true,
        ZIndex       = 2,
    }, container)
    pad(10, 6, 3, 3, l)
    return l
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENT: PARAGRAPH
-- ═══════════════════════════════════════════════════════════════
local function buildParagraph(container, opts)
    opts = opts or {}
    local frame = new("Frame", {
        Name                   = "Paragraph",
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = container,
    })
    list(nil, 2, nil, nil, frame)
    pad(10, 6, 4, 4, frame)

    if opts.Title and opts.Title ~= "" then
        lbl({
            Text       = opts.Title,
            TextColor3 = C.TextTitle,
            TextSize   = 13,
            Size       = UDim2.new(1, 0, 0, 18),
            ZIndex     = 3,
        }, frame)
    end
    lbl({
        Text        = opts.Content or "",
        TextColor3  = C.TextGray,
        TextSize    = 12,
        Size        = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex      = 3,
    }, frame)

    return frame
end

-- ═══════════════════════════════════════════════════════════════
--  TAB SORTER (Dropdown Categories like "Combat ▼")
-- ═══════════════════════════════════════════════════════════════
local function createTabSorter(sideScroll, tabs, activeTabRef)
    local categories = {}
    local categoryMap = {}
    local categoryHeaders = {}
    local isExpanded = {}

    -- Group tabs by category
    local function groupTabsByCategory()
        categoryMap = {}
        
        for _, td in ipairs(tabs) do
            local tabName = td.lbl.Text
            local category = "General"
            
            -- Auto-categorize based on tab name
            if string.find(tabName, "Combat") or string.find(tabName, "Parry") or string.find(tabName, "Dodge") or string.find(tabName, "Auto") then
                category = "Combat"
            elseif string.find(tabName, "Movement") or string.find(tabName, "Speed") or string.find(tabName, "Jump") or string.find(tabName, "Flight") then
                category = "Movement"
            elseif string.find(tabName, "Visual") or string.find(tabName, "ESP") or string.find(tabName, "Render") or string.find(tabName, "Player") then
                category = "Visuals"
            elseif string.find(tabName, "Premium") or string.find(tabName, "Pro") or string.find(tabName, "Combat+") or string.find(tabName, "Basketball") then
                category = "Premium"
            elseif string.find(tabName, "Optimization") or string.find(tabName, "Performance") then
                category = "Optimization"
            elseif string.find(tabName, "Setting") or string.find(tabName, "Config") or string.find(tabName, "Theme") then
                category = "SETTINGS"
            end
            
            if not categoryMap[category] then
                categoryMap[category] = {}
            end
            table.insert(categoryMap[category], td)
        end
    end
    
    -- Build category dropdown UI
    local function buildCategoryDropdown()
        -- Clear existing category headers
        for _, child in pairs(sideScroll:GetChildren()) do
            if child:IsA("Frame") and child.Name == "CategoryHeader" then
                child:Destroy()
            end
        end
        
        groupTabsByCategory()
        
        local categoryNames = {}
        for cat, _ in pairs(categoryMap) do
            table.insert(categoryNames, cat)
        end
        table.sort(categoryNames)
        
        -- Create category headers with dropdown arrows
        for _, catName in ipairs(categoryNames) do
            local catTabs = categoryMap[catName]
            
            -- Initialize expansion state
            if isExpanded[catName] == nil then
                isExpanded[catName] = true
            end
            
            -- Category header frame
            local header = new("Frame", {
                Name = "CategoryHeader",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Color3.fromRGB(20, 20, 28),
                BackgroundTransparency = 0.3,
                ZIndex = 2,
                LayoutOrder = #categories,
                Parent = sideScroll,
            })
            
            -- Category title
            local catLbl = lbl({
                Name = "CategoryTitle",
                Text = catName,
                TextColor3 = C.TextTitle,
                TextSize = 14,
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                ZIndex = 3,
            }, header)
            
            -- Arrow (rotates when expanded)
            local catArrow = new("ImageButton", {
                Name = "CategoryArrow",
                Image = A.Arrow,
                ImageColor3 = C.TextGray,
                Size = UDim2.fromOffset(12, 12),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = header,
            })
            
            -- Set initial arrow rotation
            catArrow.Rotation = isExpanded[catName] and 0 or -90
            
            -- Hide/show tabs in this category
            local function toggleCategory()
                isExpanded[catName] = not isExpanded[catName]
                tw(catArrow, TI_FAST, { Rotation = isExpanded[catName] and 0 or -90 })
                
                for _, td in ipairs(catTabs) do
                    td.lbl.Visible = isExpanded[catName]
                end
            end
            
            -- Click to toggle
            catLbl.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggleCategory()
                end
            end)
            catArrow.MouseButton1Up:Connect(toggleCategory)
            
            -- Initially set visibility
            for _, td in ipairs(catTabs) do
                td.lbl.Visible = isExpanded[catName]
            end
            
            -- Store header reference
            table.insert(categoryHeaders, header)
        end
    end
    
    -- Rebuild categories when tabs change
    buildCategoryDropdown()
    
    -- Return API
    return {
        Rebuild = buildCategoryDropdown,
        GetCategories = function() return categoryMap end,
        ExpandAll = function()
            for catName, _ in pairs(categoryMap) do
                isExpanded[catName] = true
            end
            buildCategoryDropdown()
        end,
        CollapseAll = function()
            for catName, _ in pairs(categoryMap) do
                isExpanded[catName] = false
            end
            buildCategoryDropdown()
        end,
        ToggleCategory = function(catName)
            if categoryMap[catName] then
                isExpanded[catName] = not isExpanded[catName]
                buildCategoryDropdown()
            end
        end
    }
end

-- ═══════════════════════════════════════════════════════════════
--  GROUPBOX
-- ═══════════════════════════════════════════════════════════════
local function buildGroupbox(page, name)
    local gbFrame = new("Frame", {
        Name             = "GB_"..name,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.GroupboxBg,
        ZIndex           = 1,
        Parent           = page,
    })
    stroke(C.Line, 1, 0, gbFrame)
    corner(1, gbFrame)
    pad(0, 0, 0, 5, gbFrame)
    list(nil, 0, nil, nil, gbFrame)

    local titleLbl = lbl({
        Name          = "GroupboxTitle",
        Text          = name,
        TextColor3    = Color3.fromRGB(115, 115, 130),
        TextSize      = 16,
        Size          = UDim2.new(1, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder   = 0,
        ZIndex        = 1,
    }, gbFrame)
    pad(10, 0, 0, 0, titleLbl)

    local arrowBtn = new("ImageButton", {
        Name                   = "GroupboxArrow",
        Image                  = A.Arrow,
        ImageColor3            = Color3.fromRGB(163, 163, 173),
        Size                   = UDim2.fromOffset(15, 15),
        AnchorPoint            = Vector2.new(1, 0),
        Position               = UDim2.new(1, -8, 0, 8),
        BackgroundTransparency = 1,
        ZIndex                 = 1,
        Parent                 = gbFrame,
    })

    local container = new("Frame", {
        Name                   = "Container",
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Position               = UDim2.new(0, 0, 0, 31),
        BackgroundTransparency = 1,
        LayoutOrder            = 2,
        ZIndex                 = 1,
        Parent                 = gbFrame,
    })
    list(nil, 2, nil, nil, container)

    local collapsed = false
    arrowBtn.MouseButton1Up:Connect(function()
        collapsed = not collapsed
        tw(arrowBtn, TI_FAST, { Rotation = collapsed and -90 or 0 })
        container.Visible = not collapsed
        gbFrame.AutomaticSize = collapsed
            and Enum.AutomaticSize.None
            or  Enum.AutomaticSize.Y
        if collapsed then
            gbFrame.Size = UDim2.new(1, 0, 0, 30)
        else
            gbFrame.Size = UDim2.new(1, 0, 0, 0)
            gbFrame.AutomaticSize = Enum.AutomaticSize.Y
        end
        if page.UpdateCanvas then page:UpdateCanvas() end
    end)

    local GB = {}

    function GB:AddToggle(id, o)
        return buildToggle(container, id, o)
    end
    function GB:AddSlider(id, o)
        return buildSlider(container, id, o)
    end
    function GB:AddButton(o)
        return buildButton(container, o)
    end
    function GB:AddDropdown(id, o)
        return buildDropdown(container, id, o)
    end
    function GB:AddInput(id, o)
        return buildInput(container, id, o)
    end
    function GB:AddKeybind(id, o)
        return buildKeybind(container, id, o)
    end
    function GB:AddColorpicker(id, o)
        return buildColorpicker(container, id, o)
    end
    function GB:AddLabel(o)
        return buildLabel(container, o)
    end
    function GB:AddParagraph(o)
        return buildParagraph(container, o)
    end
    
    -- Store all elements for config saving
    GB._elements = {}
    local function wrapElement(id, element)
        GB._elements[id] = element
        return element
    end
    
    -- Override methods to store elements
    local origToggle = GB.AddToggle
    GB.AddToggle = function(self, id, o) return wrapElement(id, origToggle(self, id, o)) end
    
    local origSlider = GB.AddSlider
    GB.AddSlider = function(self, id, o) return wrapElement(id, origSlider(self, id, o)) end
    
    local origDropdown = GB.AddDropdown
    GB.AddDropdown = function(self, id, o) return wrapElement(id, origDropdown(self, id, o)) end
    
    local origInput = GB.AddInput
    GB.AddInput = function(self, id, o) return wrapElement(id, origInput(self, id, o)) end
    
    local origKeybind = GB.AddKeybind
    GB.AddKeybind = function(self, id, o) return wrapElement(id, origKeybind(self, id, o)) end
    
    local origColorpicker = GB.AddColorpicker
    GB.AddColorpicker = function(self, id, o) return wrapElement(id, origColorpicker(self, id, o)) end

    return GB
end

-- ═══════════════════════════════════════════════════════════════
--  WINDOW BUILDER
-- ═══════════════════════════════════════════════════════════════
local function buildWindow(gui, opts)
    opts = opts or {}

    local main = new("Frame", {
        Name             = "MainFrame",
        Size             = UDim2.fromOffset(860, 520),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, -131, 0.5, 84),
        BackgroundColor3 = C.WinBg,
        ClipsDescendants = false,
        ZIndex           = 1,
        Parent           = gui,
    })
    corner(3, main)
    stroke(C.Line, 1.5, 0.5, main)

    -- TopBar
    local topBar = new("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = C.TopBarBg,
        ZIndex           = 1,
        Parent           = main,
    })
    corner(3, topBar)

    new("Frame", {
        Name             = "Line",
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.Line,
        ZIndex           = 1,
        Parent           = topBar,
    })

    local titleRow = new("Frame", {
        Name                   = "TitleRow",
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex                 = 1,
        Parent                 = topBar,
    })
    list(Enum.FillDirection.Horizontal, 7,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, titleRow)

    local titleLbl = lbl({
        Name          = "Title",
        Text          = opts.Title or "Ethos",
        TextColor3    = C.White,
        TextSize      = 16,
        Size          = UDim2.fromOffset(0, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder   = 1,
        ZIndex        = 1,
    }, titleRow)
    pad(10, 0, 0, 0, titleLbl)

    if opts.SubTitle then
        local pill = lbl({
            Name                   = "GameName",
            Text                   = opts.SubTitle,
            TextColor3             = Color3.fromRGB(0,0,0),
            TextSize               = 12,
            Size                   = UDim2.fromOffset(0, 14),
            AutomaticSize          = Enum.AutomaticSize.X,
            BackgroundColor3       = C.Red,
            BackgroundTransparency = 0,
            TextXAlignment         = Enum.TextXAlignment.Center,
            LayoutOrder            = 2,
            ZIndex                 = 1,
        }, titleRow)
        corner(3, pill)
        pad(4, 4, 0, 0, pill)
    end

    if opts.Version then
        local verLbl = lbl({
            Name                   = "Version",
            Text                   = opts.Version,
            TextColor3             = C.TextGray,
            TextSize               = 12,
            Size                   = UDim2.fromOffset(0, 14),
            AutomaticSize          = Enum.AutomaticSize.X,
            BackgroundColor3       = C.TopBarBg,
            BackgroundTransparency = 0,
            TextXAlignment         = Enum.TextXAlignment.Center,
            LayoutOrder            = 3,
            ZIndex                 = 1,
        }, titleRow)
        corner(3, verLbl)
        stroke(C.Line, 1, 0, verLbl)
        pad(4, 4, 0, 0, verLbl)
    end

    local execCount = 0
    local execLbl = lbl({
        Name                   = "Executions",
        Text                   = "0 executions",
        TextColor3             = C.TextGray,
        TextSize               = 12,
        Size                   = UDim2.fromOffset(0, 14),
        AutomaticSize          = Enum.AutomaticSize.X,
        BackgroundColor3       = C.TopBarBg,
        BackgroundTransparency = 0,
        TextXAlignment         = Enum.TextXAlignment.Center,
        LayoutOrder            = 4,
        ZIndex                 = 1,
    }, titleRow)
    corner(3, execLbl)
    stroke(C.Line, 1, 0, execLbl)
    pad(4, 4, 0, 0, execLbl)

    local closeBtn = new("ImageButton", {
        Name                   = "CloseBtn",
        Image                  = A.Close,
        ImageColor3            = C.TextGray,
        Size                   = UDim2.fromOffset(25, 25),
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = topBar,
    })
    closeBtn.MouseEnter:Connect(function() tw(closeBtn, TI_FAST, { ImageColor3 = C.Red }) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn, TI_FAST, { ImageColor3 = C.TextGray }) end)
    closeBtn.MouseButton1Up:Connect(function() main.Visible = false end)

    local minBtn = new("ImageButton", {
        Name                   = "MinBtn",
        Image                  = A.Minimize,
        ImageColor3            = C.White,
        Size                   = UDim2.fromOffset(18, 25),
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -45, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 2,
        Parent                 = topBar,
    })
    local minimized = false
    minBtn.MouseButton1Up:Connect(function()
        minimized = not minimized
        for _, c in ipairs(main:GetChildren()) do
            if c ~= topBar then c.Visible = not minimized end
        end
        tw(main, TI_MED, {
            Size = minimized
                and UDim2.fromOffset(860, 45)
                or  UDim2.fromOffset(860, 520)
        })
    end)

    makeDraggable(topBar, main)

    -- Body
    local body = new("Frame", {
        Name                   = "Body",
        Size                   = UDim2.new(1, 0, 1, -46),
        Position               = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        ZIndex                 = 1,
        Parent                 = main,
    })

    -- Left sidebar
    local sideScroll = new("ScrollingFrame", {
        Name                    = "SideScroll",
        Size                    = UDim2.new(0, 180, 1, 0),
        BackgroundTransparency  = 1,
        BorderSizePixel         = 0,
        ScrollBarThickness      = 0,
        CanvasSize              = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        ZIndex                  = 1,
        Parent                  = body,
    })
    list(nil, 0, nil, nil, sideScroll)

    new("Frame", {
        Name             = "VLine",
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, 180, 0, 0),
        BackgroundColor3 = C.Line,
        ZIndex           = 1,
        Parent           = body,
    })

    -- Tab management
    local tabs      = {}
    local activeTab = nil
    local allGroupboxes = {}

    local function switchTab(td)
        for _, t in ipairs(tabs) do
            t.page.Visible = false
            tw(t.line, TI_FAST, { Size = UDim2.new(0, 0, 0, 5) })
            tw(t.lbl,  TI_FAST, { TextColor3 = C.TabOff })
        end
        td.page.Visible = true
        tw(td.line, TI_MED, { Size = UDim2.new(1, 0, 0, 5) })
        tw(td.lbl,  TI_FAST, { TextColor3 = C.White })
        activeTab = td
    end

    -- Window API
    local W = {}

    function W:CreateTab(name)
        local tabLbl = lbl({
            Name          = "Tab",
            Text          = name,
            TextColor3    = C.TabOff,
            TextSize      = 13,
            Size          = UDim2.new(1, 0, 0, 20),
            LayoutOrder   = #tabs,
            ZIndex        = 1,
        }, sideScroll)
        pad(10, 0, 0, 0, tabLbl)

        local selLine = new("Frame", {
            Name             = "SelectedTabLine",
            Size             = UDim2.new(0, 0, 0, 5),
            AnchorPoint      = Vector2.new(0, 1),
            Position         = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = C.Red,
            ZIndex           = 1,
            Parent           = tabLbl,
        })
        corner(999, selLine)

        local ck = clickArea(3, tabLbl)

        local page = new("ScrollingFrame", {
            Name                    = "Page_"..name,
            Size                    = UDim2.new(1, -181, 1, 0),
            Position                = UDim2.new(0, 181, 0, 0),
            BackgroundTransparency  = 1,
            BorderSizePixel         = 0,
            ScrollBarThickness      = 3,
            ScrollBarImageColor3    = C.Red,
            ScrollBarImageTransparency = 0.5,
            CanvasSize              = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
            ZIndex                  = 1,
            Visible                 = false,
            Parent                  = body,
        })
        list(nil, 10, nil, nil, page)
        pad(6, 6, 6, 6, page)

        function page:UpdateCanvas()
            local totalH = 0
            for _, child in pairs(self:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("GB_") then
                    if child.Visible then
                        totalH = totalH + child.Size.Y.Offset + 10
                    end
                end
            end
            self.CanvasSize = UDim2.new(0, 0, 0, totalH + 20)
        end

        local td = { lbl = tabLbl, line = selLine, page = page, groupboxes = {} }
        table.insert(tabs, td)

        tabLbl.MouseEnter:Connect(function()
            if activeTab ~= td then
                tw(tabLbl, TI_FAST, { TextColor3 = Color3.fromRGB(160, 160, 170) })
            end
        end)
        tabLbl.MouseLeave:Connect(function()
            if activeTab ~= td then
                tw(tabLbl, TI_FAST, { TextColor3 = C.TabOff })
            end
        end)
        ck.MouseButton1Up:Connect(function() switchTab(td) end)

        if #tabs == 1 then switchTab(td) end

        -- Tab API
        local Tab = {}

        function Tab:CreateGroupbox(gname)
            local gb = buildGroupbox(page, gname)
            table.insert(td.groupboxes, gb)
            task.wait(0.05)
            page:UpdateCanvas()
            return gb
        end

        local _gb
        local function gb()
            if not _gb then _gb = buildGroupbox(page, name) end
            return _gb
        end
        function Tab:AddToggle(id, o)      return gb():AddToggle(id, o)      end
        function Tab:AddSlider(id, o)      return gb():AddSlider(id, o)      end
        function Tab:AddButton(o)          return gb():AddButton(o)          end
        function Tab:AddDropdown(id, o)    return gb():AddDropdown(id, o)    end
        function Tab:AddInput(id, o)       return gb():AddInput(id, o)       end
        function Tab:AddKeybind(id, o)     return gb():AddKeybind(id, o)     end
        function Tab:AddColorpicker(id, o) return gb():AddColorpicker(id, o) end
        function Tab:AddLabel(o)           return gb():AddLabel(o)           end
        function Tab:AddParagraph(o)       return gb():AddParagraph(o)       end
        
        -- Store tab reference for config
        Tab._groupboxes = td.groupboxes
        Tab._name = name

        return Tab
    end

    -- Create Tab Sorter
    local tabSorter = createTabSorter(sideScroll, tabs, function() return activeTab end)
    
    -- ── BUILT-IN SETTINGS TAB ────────────────────────────────
    function W:CreateSettingsTab()
        local settingsTab = self:CreateTab("SETTINGS")
        
        -- Theme Groupbox
        local themeGB = settingsTab:CreateGroupbox("Themes")
        
        local tm = loadThemeManager()
        if tm then
            tm:ApplyToGroupbox(themeGB)
        else
            themeGB:AddLabel("Theme Manager not loaded")
            themeGB:AddLabel("Check your internet connection")
            themeGB:AddButton("Retry", function()
                loadThemeManager()
                Notify({Title = "Theme", Message = "Retrying...", Type = "Info"})
            end)
        end
        
        -- Configuration Groupbox
        local configGB = settingsTab:CreateGroupbox("Configuration")
        
        -- Config name input
        local configNameInput = configGB:AddInput("ConfigName", {
            Label = "Config Name",
            Placeholder = "MyConfig",
            Default = "",
        })
        
        -- Save Config button
        configGB:AddButton({Label = "Save Config", Callback = function()
            local name = configNameInput:Get()
            if name == "" then
                Notify({Title = "Config", Message = "Please enter a config name!", Type = "Warning"})
                return
            end
            
            -- Gather all flags
            local configData = {}
            if _G.EthosFlags then
                for k, v in pairs(_G.EthosFlags) do
                    configData[k] = v
                end
            end
            
            -- Also gather all element values
            local elementData = {}
            for _, tab in ipairs(tabs) do
                for _, gb in ipairs(tab.groupboxes) do
                    if gb._elements then
                        for id, element in pairs(gb._elements) do
                            local flag = element._flag
                            if flag then
                                local value = element:Get()
                                if element._type == "colorpicker" then
                                    value = value:ToHex()
                                elseif element._type == "keybind" then
                                    value = value.Name
                                end
                                configData[flag] = value
                            end
                        end
                    end
                end
            end
            
            local success = ConfigSystem:SaveConfig(name, configData)
            if success then
                Notify({Title = "Config", Message = "Config '" .. name .. "' saved successfully!", Type = "Success"})
                -- Refresh config list
                if configDropdown then
                    local configs = ConfigSystem:GetConfigs()
                    configDropdown:SetValues(configs)
                end
            else
                Notify({Title = "Config", Message = "Failed to save config!", Type = "Error"})
            end
        end})
        
        -- Config dropdown
        local configDropdown = configGB:AddDropdown("ConfigList", {
            Label = "Saved Configs",
            Options = ConfigSystem:GetConfigs(),
            Default = ConfigSystem:GetConfigs()[1] or "",
        })
        
        -- Load Config button
        configGB:AddButton({Label = "Load Config", Callback = function()
            local name = configDropdown:Get()
            if name == "" or name == "--" then
                Notify({Title = "Config", Message = "Please select a config!", Type = "Warning"})
                return
            end
            
            local data = ConfigSystem:LoadConfig(name)
            if data then
                -- Apply to flags
                for k, v in pairs(data) do
                    _G.EthosFlags[k] = v
                end
                
                -- Apply to elements
                for _, tab in ipairs(tabs) do
                    for _, gb in ipairs(tab.groupboxes) do
                        if gb._elements then
                            for id, element in pairs(gb._elements) do
                                local flag = element._flag
                                if flag and data[flag] ~= nil then
                                    if element._type == "colorpicker" then
                                        local c3 = Color3.fromHex(data[flag])
                                        element:Set(c3)
                                    elseif element._type == "keybind" then
                                        local key = Enum.KeyCode[data[flag]]
                                        if key then element:Set(key) end
                                    else
                                        element:Set(data[flag])
                                    end
                                end
                            end
                        end
                    end
                end
                
                Notify({Title = "Config", Message = "Config '" .. name .. "' loaded successfully!", Type = "Success"})
            else
                Notify({Title = "Config", Message = "Failed to load config!", Type = "Error"})
            end
        end})
        
        -- Delete Config button
        configGB:AddButton({Label = "Delete Config", Callback = function()
            local name = configDropdown:Get()
            if name == "" or name == "--" then
                Notify({Title = "Config", Message = "Please select a config!", Type = "Warning"})
                return
            end
            
            local success = ConfigSystem:DeleteConfig(name)
            if success then
                Notify({Title = "Config", Message = "Config '" .. name .. "' deleted!", Type = "Success"})
                local configs = ConfigSystem:GetConfigs()
                configDropdown:SetValues(configs)
                configDropdown:Set(configs[1] or "")
            else
                Notify({Title = "Config", Message = "Failed to delete config!", Type = "Error"})
            end
        end})
        
        configGB:AddDivider()
        
        -- Reset All button
        configGB:AddButton({Label = "Reset All Settings", Callback = function()
            _G.EthosFlags = {}
            for _, tab in ipairs(tabs) do
                for _, gb in ipairs(tab.groupboxes) do
                    if gb._elements then
                        for id, element in pairs(gb._elements) do
                            if element._type == "toggle" then
                                element:Set(false)
                            elseif element._type == "slider" then
                                element:Set(0)
                            elseif element._type == "input" then
                                element:Set("")
                            elseif element._type == "keybind" then
                                element:Set(Enum.KeyCode.Unknown)
                            end
                        end
                    end
                end
            end
            Notify({Title = "Config", Message = "All settings reset!", Type = "Warning"})
        end})
        
        return settingsTab
    end

    function W:IncrementExecutions()
        execCount = execCount + 1
        execLbl.Text = execCount.." execution"..(execCount == 1 and "" or "s")
    end

    function W:SetVisible(v) main.Visible = v end
    function W:Toggle()      main.Visible = not main.Visible end
    
    function W:GetTabSorter()
        return tabSorter
    end
    
    function W:GetAllElements()
        local elements = {}
        for _, tab in ipairs(tabs) do
            for _, gb in ipairs(tab.groupboxes) do
                if gb._elements then
                    for id, element in pairs(gb._elements) do
                        elements[id] = element
                    end
                end
            end
        end
        return elements
    end

    return W, main
end

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY PUBLIC API
-- ═══════════════════════════════════════════════════════════════
local Lib  = {}
local _gui = nil

local function getGui()
    if _gui and _gui.Parent then return _gui end
    local sg = new("ScreenGui", {
        Name           = "Relay",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        DisplayOrder   = 998,
    })
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    _gui = sg
    return sg
end

function Lib:CreateWindow(opts)
    opts = opts or {}
    local gui = getGui()
    initNotifs()
    _G.EthosFlags = _G.EthosFlags or {}

    local WindowAPI, mainFrame = buildWindow(gui, opts)

    local key = opts.Key or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == key then WindowAPI:Toggle() end
    end)

    return WindowAPI
end

function Lib:Notify(opts)
    if not NotifHolder then initNotifs() end
    Notify(opts)
end

function Lib:Destroy()
    if _gui     then _gui:Destroy();    _gui     = nil end
    if NotifGui then NotifGui:Destroy(); NotifGui = nil end
end

function Lib:GetFlags()
    return _G.EthosFlags or {}
end

function Lib:SetFlag(key, value)
    _G.EthosFlags = _G.EthosFlags or {}
    _G.EthosFlags[key] = value
end

-- Load ThemeManager on init
loadThemeManager()

return Lib
