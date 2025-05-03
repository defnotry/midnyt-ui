local MidnytUI = {}

-- Default color scheme
local colors = {
    background = Color3.fromRGB(30, 30, 30),
    surface = Color3.fromRGB(51, 51, 51),
    text = Color3.fromRGB(255, 255, 255),
    primary = Color3.fromRGB(25, 118, 210)
}

function MidnytUI.newWindow(title)
    -- Create main container
    local screenGui = Instance.new("ScreenGui")
    local window = Instance.new("Frame")
    local windowCorner = Instance.new("UICorner")
    local titleBar = Instance.new("Frame")
    local titleText = Instance.new("TextLabel")
    local minimizeButton = Instance.new("TextButton")
    local navBar = Instance.new("Frame")
    local contentContainer = Instance.new("Frame")

    -- ScreenGui setup
    screenGui.Name = "MidnytUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main window setup
    window.Name = "MainWindow"
    window.Size = UDim2.new(0, 450, 0, 300)
    window.Position = UDim2.new(0.5, -225, 0.5, -150)
    window.BackgroundColor3 = colors.surface
    window.BackgroundTransparency = 0.1
    window.Parent = screenGui

    -- Window rounded corners
    windowCorner.CornerRadius = UDim.new(0, 8)
    windowCorner.Parent = window

    -- Title bar setup
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = colors.background
    titleBar.BackgroundTransparency = 0.2
    titleBar.Parent = window

    -- Title text
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0.8, 0, 1, 0)
    titleText.Font = Enum.Font.Gotham
    titleText.Text = title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 14
    titleText.BackgroundTransparency = 1
    titleText.Parent = titleBar

    -- Minimize button
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -30, 0, 0)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = colors.text
    minimizeButton.TextSize = 16
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Parent = titleBar

    -- Navigation bar setup
    navBar.Name = "NavigationBar"
    navBar.Size = UDim2.new(0, 100, 1, -30)
    navBar.Position = UDim2.new(0, 0, 0, 30)
    navBar.BackgroundTransparency = 1
    navBar.Parent = window

    -- Content container setup
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -100, 1, -30)
    contentContainer.Position = UDim2.new(0, 100, 0, 30)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = window

    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Minimize functionality
    local minimized = false
    local originalSize = window.Size
    local minimizedSize = UDim2.new(0, 450, 0, 30)

    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        window.Size = minimized and minimizedSize or originalSize
        navBar.Visible = not minimized
        contentContainer.Visible = not minimized
    end)

    -- Public methods
    local public = {
        _screenGui = screenGui,
        _navBar = navBar,
        _contentContainer = contentContainer,
        _tabs = {}
    }

    function public:AddTab(tabName)
        local tabButton = Instance.new("TextButton")
        local tabContent = Instance.new("ScrollingFrame")

        -- Tab button setup
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, #self._tabs * 45)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tabName
        tabButton.TextColor3 = colors.text
        tabButton.BackgroundColor3 = colors.background
        tabButton.BackgroundTransparency = 0.2
        tabButton.Parent = self._navBar

        -- Tab content frame
        tabContent.Name = tabName
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.ScrollBarThickness = 5
        tabContent.Parent = self._contentContainer

        -- Add rounded corners to button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = tabButton

        -- Tab switching logic
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(self._tabs) do
                tab.content.Visible = false
                tab.button.BackgroundColor3 = colors.background
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = colors.primary
        end)

        table.insert(self._tabs, {
            button = tabButton,
            content = tabContent
        })

        -- Activate first tab
        if #self._tabs == 1 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = colors.primary
        end

        return tabContent
    end

    function public:Destroy()
        self._screenGui:Destroy()
    end

    return public
end

return MidnytUI
