-- atlanta mixed with linoria

local repo = 'https://raw.githubusercontent.com/Vinkzzz/Lunar-Suite/main/'

local function get(file)
    return game:HttpGet(repo .. file .. '?v=' .. tostring(tick()))
end

local Library = loadstring(get('Library.lua'))()
local ThemeManager = loadstring(get('ThemeManager.lua'))()
local SaveManager = loadstring(get('SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = { Accent = 'Lunar', Rest = '.win' },
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Showcase'),
    Settings = Window:AddTab('UI Settings')
}


--tab
local TogglesBox = Tabs.Main:AddLeftGroupbox('Toggles & Inputs')

TogglesBox:AddToggle('ExampleToggle', {
    Text = 'Standard Toggle',
    Default = false,
    Tooltip = 'This is a tooltip containing extra info!',
})

TogglesBox:AddToggle('KeybindToggle', {
    Text = 'Toggle with Keybind',
    Default = false,
}):AddKeyPicker('ExampleKeybind', {
    Default = 'F',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Example Keybind',
})

TogglesBox:AddToggle('ColorToggle', {
    Text = 'Toggle with ColorPicker',
    Default = true,
}):AddColorPicker('ExampleColor', {
    Default = Color3.fromRGB(0, 150, 255),
    Title = 'Toggle Color',
    Transparency = 0,
})

TogglesBox:AddDivider()

TogglesBox:AddInput('ExampleInput', {
    Default = 'Default text',
    Numeric = false, 
    Finished = false, 
    Text = 'Custom Text Box',
    Tooltip = 'Input custom strings here',
    Placeholder = 'Placeholder text...',
})

TogglesBox:AddInput('NumericInput', {
    Default = '100',
    Numeric = true,
    Finished = false,
    Text = 'Numeric Text Box',
    Placeholder = 'Enter numbers...',
})

local SlidersBox = Tabs.Main:AddRightGroupbox('Sliders & Dropdowns')

SlidersBox:AddSlider('ExampleSlider', {
    Text = 'Standard Slider',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

SlidersBox:AddSlider('FloatSlider', {
    Text = 'Float Slider',
    Default = 2.5,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Suffix = ' multiplier',
})

SlidersBox:AddDivider()

SlidersBox:AddDropdown('SingleDropdown', {
    Values = { 'Option 1', 'Option 2', 'Option 3' },
    Default = 1,
    Multi = false,
    Text = 'Single-Select Dropdown',
    Tooltip = 'Select one option',
})

SlidersBox:AddDropdown('MultiDropdown', {
    Values = { 'Apple', 'Banana', 'Orange', 'Mango' },
    Default = 1,
    Multi = true,
    Text = 'Multi-Select Dropdown',
})

local ButtonsBox = Tabs.Main:AddLeftGroupbox('Buttons & Tabboxes')

ButtonsBox:AddButton({
    Text = 'Standard Button',
    Func = function()
        Library:Notify('Standard button pressed!', 3)
    end,
    DoubleClick = false,
})

ButtonsBox:AddButton({
    Text = 'Double-Click Button',
    Func = function()
        Library:Notify('Double-click triggered!', 3)
    end,
    DoubleClick = true,
})

local ExampleTabbox = Tabs.Main:AddRightTabbox()
local Tab1 = ExampleTabbox:AddTab('Nested Tab 1')
local Tab2 = ExampleTabbox:AddTab('Nested Tab 2')

Tab1:AddToggle('NestedToggle1', { Text = 'Nested Toggle', Default = false })
Tab2:AddSlider('NestedSlider2', { Text = 'Nested Slider', Default = 10, Min = 0, Max = 20, Rounding = 0 })

-- ui settings
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Unload Script',
    Func = function() Library:Unload() end,
    DoubleClick = true,
    Tooltip = 'Double-click to completely unload the UI setup',
})

MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind',
})

local WidgetsBox = Tabs.Settings:AddRightGroupbox('Built-in Widgets')

WidgetsBox:AddToggle('ShowLeaderboard', {
    Text = 'Leaderboard',
    Default = false,
    Tooltip = 'Show Priority tagging system',
})

Toggles.ShowLeaderboard:OnChanged(function()
    Library:SetLeaderboardVisibility(Toggles.ShowLeaderboard.Value)
end)

WidgetsBox:AddToggle('ShowChatLog', {
    Text = 'Chat Log',
    Default = false,
    Tooltip = 'Show chat messages and priority colors',
})

Toggles.ShowChatLog:OnChanged(function()
    Library:SetChatLogVisibility(Toggles.ShowChatLog.Value)
end)

WidgetsBox:AddToggle('ShowViewmodel', {
    Text = 'Viewmodel',
    Default = false,
    Tooltip = 'Drag to rotate, scroll to zoom live viewmodel',
})

Toggles.ShowViewmodel:OnChanged(function()
    Library:SetViewmodelVisibility(Toggles.ShowViewmodel.Value)
end)

WidgetsBox:AddDivider()

WidgetsBox:AddButton({
    Text = 'Refresh Visuals',
    Func = function()
        Library:UpdateLeaderboard()
        Library:RefreshViewmodel()
        Library:Notify('Refreshed visual widgets', 2)
    end,
})



Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    Library:SetWatermark(('Lunar.win | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library.KeybindFrame.Visible = true

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('lunar.win')
SaveManager:SetFolder('lunar.win/config')

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    print('Library correctly unloaded.')
    Library.Unloaded = true
end)
