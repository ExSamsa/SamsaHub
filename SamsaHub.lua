local Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()

-- Инициализация окна
local Window = Rayfield:CreateWindow({
   Name = "SamsaHUB | MM2 HvH",
   LoadingTitle = "Загрузка чит-хаба...",
   LoadingSubtitle = "by Possidon01 ",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Переменные и сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Настройки функций по умолчанию
local Config = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Noclip = false,
    ESP = false,
    Aimbot = false,
    Triggerbot = false
}

-- Хранилище для ESP
local ESP_Objects = {}

-- Получение роли игрока в MM2
local function GetPlayerRole(player)
    if not player or not player:FindFirstChild("Backpack") or not player.Character then return "Innocent" end
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

-- ПОИСК ЦЕЛИ ДЛЯ АИМБОТА (Ищет Мардера, если мы Шериф)
local function GetAimbotTarget()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if GetPlayerRole(player) == "Murderer" and player.Character.Humanoid.Health > 0 then
                return player.Character.HumanoidRootPart
            end
        end
    end
    return nil
end

-- ================= ВКЛАДКА: ГЛАВНОЕ =================
local MainTab = Window:CreateTab("Главное", 4483362458)

MainTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
       Config.WalkSpeed = Value
   end,
})

MainTab:CreateSlider({
   Name = "Сила прыжка (JumpPower)",
   Range = {50, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
       Config.JumpPower = Value
   end,
})

MainTab:CreateToggle({
   Name = "Бесконечный прыжок (Полет)",
   CurrentValue = false,
   Callback = function(Value)
       Config.InfJump = Value
   end,
})

MainTab:CreateToggle({
   Name = "Проход сквозь стены (Noclip без падения под пол)",
   CurrentValue = false,
   Callback = function(Value)
       Config.Noclip = Value
   end,
})

-- ================= ВКЛАДКА: ВИЗУАЛЫ (ESP) =================
local VisualsTab = Window:CreateTab("Визуалы", 4483362458)

local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function CreateHighlight()
        if not player.Character then return end
        local highlight = player.Character:FindFirstChild("MM2_ESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "MM2_ESP"
            highlight.Parent = player.Character
        end
        
        -- Логика цветов по ролям
        local role = GetPlayerRole(player)
        if role == "Murderer" then
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
        elseif role == "Sheriff" then
            highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
        else
            highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый
        end
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
    end

    if player.Character then CreateHighlight() end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Config.ESP then CreateHighlight() end
    end)
end

VisualsTab:CreateToggle({
   Name = "Включить ESP (Роли)",
   CurrentValue = false,
   Callback = function(Value)
       Config.ESP = Value
       if not Value then
           for _, p in pairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("MM2_ESP") then
                   p.Character.MM2_ESP:Destroy()
               end
           end
       end
   end,
})

-- ================= ВКЛАДКА: COMBAT (АИМБОТ) =================
local CombatTab = Window:CreateTab("Бой", 4483362458)

CombatTab:CreateToggle({
   Name = "Жесткий Аимбот на Мардера (HvH)",
   CurrentValue = false,
   Callback = function(Value)
       Config.Aimbot = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Триггербот (Авто-выстрел при наведении)",
   CurrentValue = false,
   Callback = function(Value)
       Config.Triggerbot = Value
   end,
})


-- ================= ЯДРО СКРИПТА (МНОГОПОТОЧНЫЕ ЦИКЛЫ) =================

-- 1. Цикл для Скорости, Прыжка, Ноклипа и Аимбота (Каждый кадр)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if char and hum and hrp then
        -- Применение ползунков
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
        
        -- Безопасный Ноклип (Отключает коллизию только у верхних частей тела, чтобы не падать под пол)
        if Config.Noclip then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" then
                    part.CanCollide = false
                end
            end
        end
        
        -- ХВХ Аимбот (Мгновенно разворачивает камеру на Мардера без плавности)
        if Config.Aimbot and GetPlayerRole(LocalPlayer) == "Sheriff" then
            local target = GetAimbotTarget()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
    
    -- Обновление цветов ESP в реальном времени
    if Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            ApplyESP(p)
        end
    end
end)

-- 2. Обработка бесконечного прыжка
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Config.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState("Jumping")
        end
    end
end)

-- 3. Жесткий Триггербот (HvH стиль)
task.spawn(function()
    while task.wait() do
        if Config.Triggerbot and GetPlayerRole(LocalPlayer) == "Sheriff" then
            local char = LocalPlayer.Character
            local gun = char and char:FindFirstChild("Gun")
            
            -- Проверяем, куда смотрит прицел мыши/камеры
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target.Parent then
                local hitPlayer = Players:GetPlayerFromCharacter(mouse.Target.Parent) or Players:GetPlayerFromCharacter(mouse.Target.Parent.Parent)
                
                -- Если навелись на Мардера и пистолет в руках — стреляем кликом
                if hitPlayer and GetPlayerRole(hitPlayer) == "Murderer" and gun then
                    mouse1click() -- Эмулирует моментальный клик мыши для выстрела
                    task.wait(0.3) -- Задержка против спам-фильтра игры
                end
            end
        end
    end
end)

-- Уведомление об успешной инициализации
Rayfield:Notify({
   Title = "SamsaHUB",
   Content = "Чит успешно активирован! Кнопки готовы.",
   Duration = 4,
})
