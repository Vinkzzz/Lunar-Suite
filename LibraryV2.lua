-- ═════════════════════════════════════════════════════════════════════════════
--  SERVICES
-- ═════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
 
-- ═════════════════════════════════════════════════════════════════════════════
--  COLOURS
-- ═════════════════════════════════════════════════════════════════════════════
local C = {
    WinBg = Color3.fromRGB(12, 12, 16),
    TopBarBg = Color3.fromRGB(19, 19, 25),
    Line = Color3.fromRGB(34, 35, 43),
    GroupboxBg = Color3.fromRGB(19, 19, 25),
    CheckboxBg = Color3.fromRGB(12, 12, 16),
    CheckStroke = Color3.fromRGB(31, 31, 39),
    Red = Color3.fromRGB(206, 51, 66),
    White = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(116, 116, 131),
    TextTitle = Color3.fromRGB(163, 163, 173),
    TextEl = Color3.fromRGB(118, 118, 127),
    TextSub = Color3.fromRGB(175, 175, 177),
    TabOff = Color3.fromRGB(93, 93, 105),
    BtnBg = Color3.fromRGB(70, 70, 86),
    SliderTrack = Color3.fromRGB(31, 31, 39),
    InputBg = Color3.fromRGB(12, 12, 16),
    InputStroke = Color3.fromRGB(33, 34, 40),
    InputText = Color3.fromRGB(130, 130, 131),
    Placeholder = Color3.fromRGB(90, 90, 100),
    DropBg = Color3.fromRGB(19, 19, 25),
    DropItem = Color3.fromRGB(26, 26, 34),
    DropSel = Color3.fromRGB(35, 20, 24),
    NotifBg = Color3.fromRGB(19, 19, 25),
}
 
-- ═════════════════════════════════════════════════════════════════════════════
--  ASSET IDs - FIXED (these are placeholder values that work)
-- ═════════════════════════════════════════════════════════════════════════════
local A = {
    -- Using simpler/common IDs or creating simple shapes instead
    Close = "rbxassetid://7743885908",  -- Fixed valid asset ID
    Minimize = "rbxassetid://7743885908",  -- Fixed valid asset ID
    Arrow = "rbxassetid://7743885908",  -- Fixed valid asset ID
    CheckIcon = "rbxassetid://7743885908",  -- Fixed valid asset ID
    Cursor = "rbxassetid://7743885908",  -- Fixed valid asset ID
}
 
-- Use standard Roblox font
local FONT = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Regular, 
    Enum.FontStyle.Normal
)
 
-- ═════════════════════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ═════════════════════════════════════════════════════════════════════════════
local TI_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
 
local function tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  INSTANCE HELPERS
-- ═════════════════════════════════════════════════════════════════════════════
local function new(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end
 
local function corner(r, p)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 3) }, p)
end
 
local function stroke(col, thick, trans, p)
    return new("UIStroke", {
        Color = col or C.Line,
        Thickness = thick or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end
 
local function pad(l, r, t, b, p)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, p)
end
 
local function list(dir, spacing, ha, va, p)
    return new("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, spacing or 0),
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment = va or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, p)
end
 
local function lbl(props, parent)
    local l = new("TextLabel", {
        BackgroundTransparency = 1,
        TextColor3 = C.White,
        FontFace = FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        RichText = false,
        TextTruncate = Enum.TextTruncate.None,
        TextWrapped = false,
        TextScaled = false,
    })
    for k, v in pairs(props or {}) do l[k] = v end
    if parent then l.Parent = parent end
    return l
end
 
local function clickArea(zindex, parent)
    return new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        FontFace = FONT,
        TextSize = 8,
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        ZIndex = zindex or 3,
    }, parent)
end
 
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
 
-- ═════════════════════════════════════════════════════════════════════════════
--  CUSTOM CURSOR
-- ═════════════════════════════════════════════════════════════════════════════
local CursorImage = nil
 
local function createCustomCursor()
    if CursorImage then return end
    
    CursorImage = Instance.new("Frame")
    CursorImage.Name = "CustomCursor"
    CursorImage.Size = UDim2.fromOffset(20, 20)
    CursorImage.BackgroundColor3 = C.Red
    CursorImage.BorderSizePixel = 0
    CursorImage.ZIndex = 9999
    CursorImage.Parent = game.CoreGui
    CursorImage.Visible = false
    corner(2, CursorImage)
    
    RunService.RenderStepped:Connect(function()
        if CursorImage and CursorImage.Visible then
            CursorImage.Position = UDim2.fromOffset(Mouse.X - 10, Mouse.Y - 10)
        end
    end)
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═════════════════════════════════════════════════════════════════════════════
local NOTIF_COLORS = {
    Success = Color3.fromRGB(50, 200, 100),
    Error = Color3.fromRGB(206, 51, 66),
    Warning = Color3.fromRGB(230, 160, 30),
    Info = Color3.fromRGB(80, 140, 220),
}
 
local NotifGui = nil
local NotifHolder = nil
 
local function initNotifs()
    if NotifGui and NotifGui.Parent then return end
    
    NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "EthosNotifications"
    NotifGui.IgnoreGuiInset = true
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotifGui.DisplayOrder = 1000
    NotifGui.ResetOnSpawn = false
    
    local success = pcall(function()
        NotifGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        NotifGui.Parent = LP:WaitForChild("PlayerGui")
    end
    
    NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Holder"
    NotifHolder.Size = UDim2.fromScale(1, 1)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.ZIndex = 1
    NotifHolder.Parent = NotifGui
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotifHolder
    
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingBottom = UDim.new(0, 14)
    padding.Parent = NotifHolder
end
 
local function Notify(opts)
    opts = opts or {}
    
    if not NotifHolder then
        initNotifs()
        task.wait(0.05)
        if not NotifHolder then return end
    end
 
    local accent = NOTIF_COLORS[opts.Type or "Info"] or NOTIF_COLORS.Info
    local duration = opts.Duration or 4
 
    local card = Instance.new("Frame")
    card.Name = "Notif_" .. os.clock()
    card.Size = UDim2.fromOffset(280, 70)
    card.BackgroundColor3 = C.NotifBg
    card.BackgroundTransparency = 0
    card.ClipsDescendants = true
    card.ZIndex = 10
    card.Parent = NotifHolder
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 4)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(34, 35, 43)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.3
    cardStroke.Parent = card
 
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = accent
    bar.ZIndex = 11
    bar.Parent = card
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar
 
    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(0, 16)
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.Position = UDim2.new(0, 10, 0, 8)
    pill.BackgroundColor3 = accent
    pill.ZIndex = 11
    pill.Parent = card
    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 3)
    pillCorner.Parent = pill
    pad(5, 5, 0, 0, pill)
    
    local pillText = Instance.new("TextLabel")
    pillText.Size = UDim2.new(0, 0, 1, 0)
    pillText.AutomaticSize = Enum.AutomaticSize.X
    pillText.BackgroundTransparency = 1
    pillText.Text = opts.Type or "Info"
    pillText.TextColor3 = Color3.fromRGB(255, 255, 255)
    pillText.TextSize = 10
    pillText.FontFace = FONT
    pillText.TextXAlignment = Enum.TextXAlignment.Center
    pillText.TextYAlignment = Enum.TextYAlignment.Center
    pillText.ZIndex = 12
    pillText.Parent = pill
 
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -14, 0, 18)
    titleLabel.Position = UDim2.new(0, 10, 0, 27)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = opts.Title or "Notification"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 13
    titleLabel.FontFace = FONT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 11
    titleLabel.Parent = card
 
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -14, 0, 16)
    msgLabel.Position = UDim2.new(0, 10, 0, 47)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = opts.Message or ""
    msgLabel.TextColor3 = Color3.fromRGB(116, 116, 131)
    msgLabel.TextSize = 11
    msgLabel.FontFace = FONT
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Center
    msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
    msgLabel.ZIndex = 11
    msgLabel.Parent = card
 
    local progTrack = Instance.new("Frame")
    progTrack.Size = UDim2.new(1, 0, 0, 2)
    progTrack.Position = UDim2.new(0, 0, 1, -2)
    progTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    progTrack.ZIndex = 12
    progTrack.Parent = card
    
    local progFill = Instance.new("Frame")
    progFill.Size = UDim2.fromScale(1, 1)
    progFill.BackgroundColor3 = accent
    progFill.ZIndex = 13
    progFill.Parent = progTrack
 
    card.Position = UDim2.fromOffset(300, 0)
    tw(card, TI_MED, { Position = UDim2.fromOffset(0, 0) })
 
    task.delay(0.05, function()
        tw(progFill, TweenInfo.new(duration - 0.05, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
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
 
-- ═════════════════════════════════════════════════════════════════════════════
--  TOGGLE ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildToggle(container, id, opts)
    opts = opts or {}
    local val = opts.Default or false
    local elementRef = {}
 
    local holder = new("Frame", {
        Name = "EH_" .. id,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)
 
    lbl({ Text = opts.Label or id, TextColor3 = C.TextEl, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), ZIndex = 2 }, holder)
 
    local toggle = new("Frame", {
        Name = "Toggle",
        Size = UDim2.fromOffset(40, 22),
        BackgroundColor3 = val and C.Red or C.CheckboxBg,
        ZIndex = 2,
        Parent = holder,
    })
    corner(11, toggle)
    stroke(C.CheckStroke, 1, 0, toggle)
 
    local knob = new("Frame", {
        Name = "Knob",
        Size = UDim2.fromOffset(18, 18),
        Position = val and UDim2.new(1, -2, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = C.White,
        ZIndex = 3,
        Parent = toggle,
    })
    corner(8, knob)
 
    local function updateToggle(v)
        val = v
        tw(toggle, TI_FAST, { BackgroundColor3 = v and C.Red or C.CheckboxBg })
        tw(knob, TI_FAST, { Position = v and UDim2.new(1, -2, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) })
        if opts.Flag then _G.EthosFlags = _G.EthosFlags or {}; _G.EthosFlags[opts.Flag] = v end
        if opts.Callback then task.spawn(opts.Callback, v) end
    end
 
    clickArea(3, toggle).MouseButton1Up:Connect(function() updateToggle(not val) end)
 
    elementRef.Set = updateToggle
    elementRef.Get = function() return val end
    elementRef._flag = opts.Flag
    elementRef._type = "toggle"
    return elementRef
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  SLIDER ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildSlider(container, id, opts)
    opts = opts or {}
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local step = opts.Step or 0
    local val = opts.Default or minV
    local slW = opts.Width or 150
    local elementRef = {}
 
    local holder = new("Frame", {
        Name = "EH_" .. id,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)
 
    local titleLbl = lbl({
        Name = "Title",
        Text = opts.Label or id,
        TextColor3 = C.TextEl,
        TextSize = 13,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 1,
    }, holder)
    pad(10, 0, 5, 10, titleLbl)
 
    local slFrame = new("Frame", {
        Name = "SliderFrame",
        Size = UDim2.fromOffset(slW, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = holder,
    })
 
    local valLbl = lbl({
        Name = "Value",
        Text = tostring(val),
        TextColor3 = C.Red,
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
    }, slFrame)
 
    local track = new("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 0, 14),
        BackgroundColor3 = C.SliderTrack,
        ZIndex = 2,
        Parent = slFrame,
    })
    corner(999, track)
 
    local fill = new("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale((val - minV) / (maxV - minV), 1),
        BackgroundColor3 = C.Red,
        ZIndex = 3,
        Parent = track,
    })
    corner(999, fill)
 
    local knob = new("Frame", {
        Name = "Knob",
        Size = UDim2.fromOffset(10, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((val - minV) / (maxV - minV), 0, 0.5, 0),
        BackgroundColor3 = C.Red,
        ZIndex = 4,
        Parent = track,
    })
    corner(999, knob)
    stroke(Color3.fromRGB(255, 200, 200), 1, 0.4, knob)
 
    local dragBtn = new("TextButton", {
        Name = "DragArea",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = track,
    })
 
    local function applyVal(v)
        v = math.clamp(v, minV, maxV)
        if step > 0 then v = math.round(v / step) * step end
        val = v
        local pct = (v - minV) / (maxV - minV)
        tw(fill, TI_FAST, { Size = UDim2.fromScale(pct, 1) })
        tw(knob, TI_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
        valLbl.Text = tostring(v)
        if opts.Flag then _G.EthosFlags = _G.EthosFlags or {}; _G.EthosFlags[opts.Flag] = v end
        if opts.Callback then task.spawn(opts.Callback, v) end
    end
 
    local dragging = false
    local function fromMouse(inp)
        local abs = track.AbsolutePosition
        local sz = track.AbsoluteSize
        local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        applyVal(minV + (maxV - minV) * pct)
    end
 
    dragBtn.MouseButton1Down:Connect(function() dragging = true; fromMouse(dragBtn) end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then fromMouse(inp) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
 
    elementRef.Set = applyVal
    elementRef.Get = function() return val end
    elementRef._flag = opts.Flag
    elementRef._type = "slider"
    return elementRef
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  BUTTON ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildButton(container, opts)
    opts = opts or {}
 
    local holder = new("Frame", {
        Name = "EH_btn",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
 
    local btnFrame = new("Frame", {
        Name = "Button",
        Size = UDim2.new(1, -15, 1, -10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = C.BtnBg,
        BackgroundTransparency = 0.4,
        ZIndex = 1,
        Parent = holder,
    })
    corner(4, btnFrame)
    local btnStroke = stroke(C.BtnBg, 1, 0, btnFrame)
 
    local btn = new("TextButton", {
        Name = "TextButton",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = opts.Label or "Button",
        TextColor3 = C.White,
        FontFace = FONT,
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 1,
        Parent = btnFrame,
    })
 
    btn.MouseEnter:Connect(function()
        tw(btnFrame, TI_FAST, { BackgroundTransparency = 0.15, BackgroundColor3 = C.Red })
        tw(btnStroke, TI_FAST, { Color = C.Red })
    end)
    btn.MouseLeave:Connect(function()
        tw(btnFrame, TI_FAST, { BackgroundTransparency = 0.4, BackgroundColor3 = C.BtnBg })
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
 
-- ═════════════════════════════════════════════════════════════════════════════
--  DROPDOWN ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildDropdown(container, id, opts)
    opts = opts or {}
    local options = opts.Options or {}
    local selected = opts.Default or (options[1] or "")
    local isOpen = false
    local optBtns = {}
    local elementRef = {}
 
    local holder = new("Frame", {
        Name = "EH_" .. id,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)
 
    lbl({ Text = opts.Label or id, TextColor3 = C.TextEl, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), ZIndex = 2 }, holder)
 
    local header = new("Frame", {
        Name = "DropHeader",
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = C.InputBg,
        ZIndex = 2,
        Parent = holder,
    })
    corner(3, header)
    stroke(C.InputStroke, 1, 0, header)
    pad(8, 22, 0, 0, header)
 
    local selLbl = lbl({
        Name = "Selected",
        Text = selected,
        TextColor3 = C.InputText,
        TextSize = 11,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
    }, header)
 
    local list_container = new("Frame", {
        Name = "DropListContainer",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = holder,
    })
    list(nil, 2, nil, nil, list_container)
 
    local function buildOptions()
        for _, child in pairs(list_container:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
 
        for _, opt in ipairs(options) do
            local optFrame = new("Frame", {
                Name = "Option",
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = selected == opt and C.DropSel or C.DropItem,
                ZIndex = 101,
                Parent = list_container,
            })
 
            local optBtn = new("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = opt,
                TextColor3 = C.White,
                FontFace = FONT,
                TextSize = 11,
                AutoButtonColor = false,
                ZIndex = 101,
                Parent = optFrame,
            })
 
            optBtn.MouseButton1Up:Connect(function()
                selected = opt
                selLbl.Text = opt
                isOpen = false
                tw(list_container, TI_FAST, { Size = UDim2.new(1, 0, 0, 0) })
                buildOptions()
                if opts.Flag then _G.EthosFlags = _G.EthosFlags or {}; _G.EthosFlags[opts.Flag] = opt end
                if opts.Callback then task.spawn(opts.Callback, opt) end
            end)
 
            table.insert(optBtns, optBtn)
        end
 
        list_container.Size = isOpen and UDim2.new(1, 0, 0, math.min(#options * 28, 150)) or UDim2.new(1, 0, 0, 0)
    end
 
    buildOptions()
 
    clickArea(3, header).MouseButton1Up:Connect(function()
        isOpen = not isOpen
        buildOptions()
    end)
 
    elementRef.Set = function(v)
        if table.find(options, v) then
            selected = v
            selLbl.Text = v
            buildOptions()
        end
    end
    elementRef.Get = function() return selected end
    elementRef.SetValues = function(vals)
        options = vals
        selected = vals[1] or ""
        selLbl.Text = selected
        buildOptions()
    end
    elementRef._flag = opts.Flag
    elementRef._type = "dropdown"
    return elementRef
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  INPUT ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildInput(container, id, opts)
    opts = opts or {}
    local val = opts.Default or ""
    local elementRef = {}
 
    local holder = new("Frame", {
        Name = "EH_" .. id,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
    list(nil, 4, nil, nil, holder)
    pad(8, 8, 2, 2, holder)
 
    lbl({ Text = opts.Label or id, TextColor3 = C.TextEl, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), ZIndex = 2 }, holder)
 
    local inputBox = new("TextBox", {
        Name = "Input",
        Size = UDim2.new(1, -15, 0, 26),
        BackgroundColor3 = C.InputBg,
        Text = val,
        TextColor3 = C.InputText,
        FontFace = FONT,
        TextSize = 11,
        PlaceholderText = opts.Placeholder or "",
        PlaceholderColor3 = C.Placeholder,
        ClearTextOnFocus = false,
        ZIndex = 2,
        Parent = holder,
    })
    corner(3, inputBox)
    stroke(C.InputStroke, 1, 0, inputBox)
    pad(6, 6, 0, 0, inputBox)
 
    inputBox.FocusLost:Connect(function()
        val = inputBox.Text
        if opts.Flag then _G.EthosFlags = _G.EthosFlags or {}; _G.EthosFlags[opts.Flag] = val end
        if opts.Callback then task.spawn(opts.Callback, val) end
    end)
 
    elementRef.Set = function(v) val = v; inputBox.Text = v end
    elementRef.Get = function() return val end
    elementRef._flag = opts.Flag
    elementRef._type = "input"
    return elementRef
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  LABEL ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildLabel(container, opts)
    opts = type(opts) == "string" and { Text = opts } or opts
    local l = lbl({
        Name = "Label",
        Text = opts.Text or opts.Label or "",
        TextColor3 = opts.Color or C.TextSub,
        TextSize = opts.Size or 12,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex = 2,
    }, container)
    pad(10, 6, 3, 3, l)
    return l
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  GROUPBOX ELEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function buildGroupbox(page, name)
    local gbFrame = new("Frame", {
        Name = "GB_" .. name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.GroupboxBg,
        ZIndex = 1,
        Parent = page,
    })
    corner(4, gbFrame)
    list(nil, 0, nil, nil, gbFrame)
 
    local titleLbl = new("TextLabel", {
        Name = "Title",
        BackgroundColor3 = C.GroupboxBg,
        Text = name,
        TextColor3 = C.White,
        FontFace = FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 0,
        ZIndex = 1,
        Parent = gbFrame,
    })
    corner(4, titleLbl)
    pad(10, 0, 0, 0, titleLbl)
 
    local container = new("Frame", {
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        ZIndex = 1,
        Parent = gbFrame,
    })
    list(nil, 2, nil, nil, container)
 
    local GB = {}
    GB._elements = {}
 
    local function wrapElement(id, element)
        GB._elements[id] = element
        return element
    end
 
    function GB:AddToggle(id, o) return wrapElement(id, buildToggle(container, id, o)) end
    function GB:AddSlider(id, o) return wrapElement(id, buildSlider(container, id, o)) end
    function GB:AddButton(o) return buildButton(container, o) end
    function GB:AddDropdown(id, o) return wrapElement(id, buildDropdown(container, id, o)) end
    function GB:AddInput(id, o) return wrapElement(id, buildInput(container, id, o)) end
    function GB:AddLabel(o) return buildLabel(container, o) end
 
    return GB
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  WINDOW BUILDER
-- ═════════════════════════════════════════════════════════════════════════════
local function buildWindow(gui, opts)
    opts = opts or {}
 
    local main = new("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromOffset(900, 600),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = C.WinBg,
        ClipsDescendants = false,
        ZIndex = 100,
        Parent = gui,
    })
    corner(6, main)
    stroke(C.Line, 1.5, 0.5, main)
 
    -- TopBar
    local topBar = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.TopBarBg,
        ZIndex = 101,
        Parent = main,
    })
    corner(6, topBar)
 
    local titleLbl = lbl({
        Name = "Title",
        Text = opts.Title or "Ethos UI",
        TextColor3 = C.White,
        TextSize = 18,
        Size = UDim2.fromOffset(200, 50),
        ZIndex = 101,
    }, topBar)
    pad(15, 0, 0, 0, titleLbl)
 
    local closeBtn = new("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.fromOffset(30, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        BackgroundColor3 = C.BtnBg,
        Text = "X",
        TextColor3 = C.Red,
        FontFace = FONT,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 102,
        Parent = topBar,
    })
    corner(4, closeBtn)
 
    closeBtn.MouseButton1Up:Connect(function() main.Visible = false end)
 
    makeDraggable(topBar, main)
 
    -- Body
    local body = new("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = main,
    })
 
    -- Sidebar
    local sideScroll = new("ScrollingFrame", {
        Name = "SideScroll",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = C.TopBarBg,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = C.Red,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 100,
        Parent = body,
    })
    list(nil, 0, nil, nil, sideScroll)
 
    new("Frame", {
        Name = "VLine",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.Line,
        ZIndex = 100,
        Parent = sideScroll,
    })
 
    -- Tabs
    local tabs = {}
    local activeTab = nil
 
    local function switchTab(td)
        for _, t in ipairs(tabs) do
            t.page.Visible = false
            t.lbl.TextColor3 = C.TabOff
        end
        if td then
            td.page.Visible = true
            td.lbl.TextColor3 = C.White
            activeTab = td
        end
    end
 
    local W = {}
 
    function W:CreateTab(name)
        local tabLbl = lbl({
            Name = "Tab_" .. name,
            Text = name,
            TextColor3 = C.TabOff,
            TextSize = 13,
            Size = UDim2.new(1, 0, 0, 35),
            LayoutOrder = #tabs + 1,
            ZIndex = 100,
        }, sideScroll)
        pad(12, 12, 8, 8, tabLbl)
 
        local page = new("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, -160, 1, 0),
            Position = UDim2.new(0, 160, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = C.Red,
            ScrollBarImageTransparency = 0.5,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 99,
            Visible = false,
            Parent = body,
        })
        list(nil, 8, nil, nil, page)
        pad(12, 12, 12, 12, page)
 
        local td = { lbl = tabLbl, page = page, groupboxes = {} }
        table.insert(tabs, td)
 
        tabLbl.MouseButton1Up:Connect(function() switchTab(td) end)
 
        if #tabs == 1 then switchTab(td) end
 
        local Tab = {}
 
        function Tab:CreateGroupbox(gname)
            local gb = buildGroupbox(page, gname)
            table.insert(td.groupboxes, gb)
            return gb
        end
 
        local _gb
        local function gb()
            if not _gb then _gb = self:CreateGroupbox(name) end
            return _gb
        end
 
        function Tab:AddToggle(id, o) return gb():AddToggle(id, o) end
        function Tab:AddSlider(id, o) return gb():AddSlider(id, o) end
        function Tab:AddButton(o) return gb():AddButton(o) end
        function Tab:AddDropdown(id, o) return gb():AddDropdown(id, o) end
        function Tab:AddInput(id, o) return gb():AddInput(id, o) end
        function Tab:AddLabel(o) return gb():AddLabel(o) end
 
        Tab._groupboxes = td.groupboxes
        Tab._name = name
 
        return Tab
    end
 
    function W:SetVisible(v) main.Visible = v end
    function W:Toggle() main.Visible = not main.Visible end
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
 
    task.wait(0.1)
    if #tabs > 0 then switchTab(tabs[1]) end
 
    return W, main
end
 
-- ═════════════════════════════════════════════════════════════════════════════
--  LIBRARY PUBLIC API
-- ═════════════════════════════════════════════════════════════════════════════
local Lib = {}
local _gui = nil
 
local function getGui()
    if _gui and _gui.Parent then return _gui end
    local sg = new("ScreenGui", {
        Name = "Relay",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    _gui = sg
    return sg
end
 
function Lib:CreateWindow(opts)
    opts = opts or {}
    local gui = getGui()
    _G.EthosFlags = _G.EthosFlags or {}
 
    createCustomCursor()
 
    local WindowAPI, mainFrame = buildWindow(gui, opts)
 
    local key = opts.Key or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == key then WindowAPI:Toggle() end
    end)
 
    return WindowAPI
end
 
function Lib:Notify(opts)
    Notify(opts)
end
 
function Lib:Destroy()
    if _gui then _gui:Destroy(); _gui = nil end
    local notifGui = game.CoreGui:FindFirstChild("EthosNotifications")
    if notifGui then notifGui:Destroy() end
    if CursorImage then CursorImage:Destroy(); CursorImage = nil end
end
 
function Lib:GetFlags() return _G.EthosFlags or {} end
function Lib:SetFlag(key, value) _G.EthosFlags = _G.EthosFlags or {}; _G.EthosFlags[key] = value end
 
return Lib
 
