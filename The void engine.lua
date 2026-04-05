-- =============================================
-- THE VOID ENGINE
-- =============================================

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

if CoreGui:FindFirstChild("RemoteSpy_Void_Elegant") then 
    CoreGui.RemoteSpy_Void_V9_Elegant:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteSpy_Void_Elegant"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Configuración de Estado
local spyEnabled = true

-- Paleta de Colores 
local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(10, 10, 10),
    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(180, 180, 180) -- Gris claro para detalles secundarios
}

-- [ CONTENEDOR PRINCIPAL ]
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

-- Borde Blanco de la GUi
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- [ BARRA SUPERIOR ]
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Theme.Header
Header.BorderSizePixel = 0
Header.Parent = Main

-- Línea divisoria blanca
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.BackgroundColor3 = Theme.Border
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VOID ENGINE"
Title.RichText = true
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- [ CONTENEDOR DE BOTONES ]
local BtnHolder = Instance.new("Frame")
BtnHolder.Size = UDim2.new(0, 400, 1, 0)
BtnHolder.Position = UDim2.new(1, -410, 0, 0)
BtnHolder.BackgroundTransparency = 1
BtnHolder.Parent = Header

local Layout = Instance.new("UIListLayout", BtnHolder)
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
Layout.VerticalAlignment = Enum.VerticalAlignment.Center
Layout.Padding = UDim.new(0, 15)

local function createBtn(txt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 85, 0, 25)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = Theme.Text -- Siempre Blanco
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 10
    b.Parent = BtnHolder
    return b
end

local btnToggle = createBtn("DETENER SPY")
local btnCopy = createBtn("COPIAR")
local btnClear = createBtn("BORRAR")
local btnMinimize = createBtn("—")

-- [ ÁREA DE CONTENIDO ]
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Caja de Filtro con Borde Blanco
local FilterBox = Instance.new("TextBox")
FilterBox.Size = UDim2.new(1, -40, 0, 30)
FilterBox.Position = UDim2.new(0, 20, 0, 15)
FilterBox.BackgroundColor3 = Theme.Background
FilterBox.BorderSizePixel = 0
FilterBox.PlaceholderText = "FILTRAR REMOTOS..."
FilterBox.Text = ""
FilterBox.TextColor3 = Theme.Text
FilterBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
FilterBox.Font = Enum.Font.GothamMedium
FilterBox.TextSize = 10
FilterBox.Parent = Content

local FilterStroke = Instance.new("UIStroke", FilterBox)
FilterStroke.Color = Color3.fromRGB(60, 60, 60)
FilterStroke.Thickness = 1

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -40, 1, -95)
Scroll.Position = UDim2.new(0, 20, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 1
Scroll.ScrollBarImageColor3 = Theme.Border
Scroll.Parent = Content

local LogText = Instance.new("TextBox")
LogText.Size = UDim2.new(1, 0, 1, 0)
LogText.BackgroundTransparency = 1
LogText.MultiLine = true
LogText.TextEditable = false
LogText.RichText = true
LogText.Text = "<i>Sincronizando...</i>"
LogText.TextColor3 = Theme.Text
LogText.Font = Enum.Font.RobotoMono
LogText.TextSize = 10
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = Scroll

-- [ CONTADOR DE LÍNEAS ]
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(0, 200, 0, 20)
CounterLabel.Position = UDim2.new(1, -220, 1, -25)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "LOGS: 0 | FILTRADOS: 0"
CounterLabel.TextColor3 = Theme.Text -- Blanco
CounterLabel.Font = Enum.Font.GothamMedium
CounterLabel.TextSize = 9
CounterLabel.TextXAlignment = Enum.TextXAlignment.Right
CounterLabel.Parent = Content

-- ==================== LÓGICA CORE ====================
local fullLogData = {}
local logQueue = {}

local function updateUI()
    local filter = FilterBox.Text:lower()
    local filteredText = ""
    local count = 0
    
    for _, log in pairs(fullLogData) do
        if log.Raw:lower():find(filter) then
            filteredText = filteredText .. log.Formatted .. "\n"
            count = count + 1
        end
    end
    
    LogText.Text = filteredText
    CounterLabel.Text = "LOGS: " .. #fullLogData .. " | FILTRADOS: " .. count
    Scroll.CanvasSize = UDim2.new(0, 0, 0, LogText.TextBounds.Y + 10)
end

-- Botón Detener / Resumen (Mantiene color blanco)
btnToggle.MouseButton1Click:Connect(function()
    spyEnabled = not spyEnabled
    btnToggle.Text = spyEnabled and "DETENER SPY" or "RESUMEN SPY"
    
    StarterGui:SetCore("SendNotification", {
        Title = "Void Spy", 
        Text = spyEnabled and "Captura reanudada." or "Captura pausada.", 
        Duration = 1.5
    })
end)

-- Copiar
btnCopy.MouseButton1Click:Connect(function()
    local filter = FilterBox.Text:lower()
    local textToCopy = ""
    for _, log in pairs(fullLogData) do
        if log.Raw:lower():find(filter) then
            textToCopy = textToCopy .. log.Raw .. "\n"
        end
    end
    setclipboard(textToCopy)
    StarterGui:SetCore("SendNotification", {Title = "Void Spy", Text = "Copiado.", Duration = 1})
end)

-- Borrar
btnClear.MouseButton1Click:Connect(function()
    fullLogData = {}
    updateUI()
end)

-- [ HOOK DE RED ]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if spyEnabled and (method == "FireServer" or method == "InvokeServer") then
        local name = tostring(self)
        if name ~= "CameraCFrame" and name ~= "Ping" then
            local args = {...}
            local argStr = ""
            for i, v in pairs(args) do
                local val = typeof(v) == "string" and '"'..v..'"' or tostring(v)
                argStr = argStr .. val .. (i == #args and "" or ", ")
            end
            
            local rawCode = string.format('game.%s:%s(%s)', self:GetFullName(), method, argStr)
            -- Hora en gris oscuro para no distraer, código en blanco puro
            local formatted = string.format("<font color='#666666'>[%s]</font> %s", os.date("%H:%M:%S"), rawCode)
            
            table.insert(logQueue, {Raw = rawCode, Formatted = formatted})
        end
    end
    return oldNamecall(self, ...)
end)

RunService.Heartbeat:Connect(function()
    if #logQueue > 0 then
        for _, log in ipairs(logQueue) do
            table.insert(fullLogData, log)
            if #fullLogData > 400 then table.remove(fullLogData, 1) end
        end
        logQueue = {}
        updateUI()
    end
end)

FilterBox:GetPropertyChangedSignal("Text"):Connect(updateUI)

-- Minimizar
local isMinimized = false
btnMinimize.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Main:TweenSize(isMinimized and UDim2.new(0, 650, 0, 45) or UDim2.new(0, 650, 0, 420), "Out", "Quart", 0.3, true)
    Content.Visible = not isMinimized
    btnMinimize.Text = isMinimized and "+" or "—"
end)

print("VOID ENGINE")
