--[[

    Astral Hub
    File.:    astral_esp.luau
    Desc.:    A universal esp module for current and future Astral scripts

]]

local module = {functions = {}, all = false, box = false, tracer = false, text = false, team = false, colors = {box = Color3.fromRGB(255,0,0), text = Color3.fromRGB(255,0,0), tracer = Color3.fromRGB(255,0,0)}}

local players = game:GetService("Players")

local rs = game:GetService("RunService")

local lp = players.LocalPlayer

local camera = workspace.CurrentCamera

local esp_quads = {}

local function VisualizePlayer(player)
    local box_outline = Drawing.new("Quad")
    box_outline.Color = Color3.fromRGB(0,0,0)
    box_outline.Thickness = 5
    box_outline.Visible = false

    local box = Drawing.new("Quad")
    box.Thickness = 2
    box.Visible = false

    local tracer_outline = Drawing.new("Line")
    tracer_outline.Thickness = 5
    tracer_outline.Color = Color3.fromRGB(0, 0, 0)

    local tracer = Drawing.new("Line")
    tracer.Thickness = 2

    local name_outline = Drawing.new("Text")
    name_outline.Size = 18
    name_outline.Color = Color3.fromRGB(0, 0, 0)
    name_outline.Center = true

    local name = Drawing.new("Text")
    name.Size = 18
    name.Center = true

    local tool_outline = Drawing.new("Text")
    tool_outline.Size = 16
    tool_outline.Color = Color3.fromRGB(0, 0, 0)
    tool_outline.Center = true

    local tool = Drawing.new("Text")
    tool.Size = 16
    tool.Center = true

    esp_quads[player] = {
        main = box, outline = box_outline,
        tracer = tracer, tracerOutline = tracer_outline,
        name = name, nameOutline = name_outline,
        tool = tool, toolOutline = tool_outline,
    }

    local function OnRender()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not module.all then
            box.Visible = false
            box_outline.Visible = false
            tracer.Visible = false
            tracer_outline.Visible = false
            name.Visible = false
            name_outline.Visible = false
            tool.Visible = false
            tool_outline.Visible = false
            return
        end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local size = Vector3.new(2, 5, 1)
            local halfX, halfY, halfZ = size.X / 2, size.Y / 2, size.Z / 2

            local offset = hrp.CFrame.LookVector * halfZ
            local cframe = hrp.CFrame + offset

            local corners = {
                cframe * Vector3.new(-(halfX + 1), halfY, 0), -- Top Left
                cframe * Vector3.new((halfX + 1), halfY, 0),  -- Top Right
                cframe * Vector3.new(-(halfX + 1), -(halfY + 0.5), 0), -- Bottom Left
                cframe * Vector3.new((halfX + 1), -(halfY + 0.5), 0)  -- Bottom Right
            }

            local points, visible = {}, true
            for i, corner in ipairs(corners) do
                local screenPos, isVisible = camera:WorldToViewportPoint(corner)
                if not isVisible then visible = false end
                points[i] = Vector2.new(screenPos.X, screenPos.Y)
            end

            if visible and #points == 4 then
                box_outline.PointA, box.PointA = points[1], points[1]
                box_outline.PointB, box.PointB = points[2], points[2]
                box_outline.PointC, box.PointC = points[4], points[4]
                box_outline.PointD, box.PointD = points[3], points[3]
                
                if module.team then
                    box.Color = player.TeamColor.Color
                else
                    box.Color = module.colors.box
                end

                box_outline.Visible = module.box
                box.Visible = module.box

                local screen_mid_x = camera.ViewportSize.X / 2
                local screen_bottom_y = camera.ViewportSize.Y
                local tracer_position, tracer_visible = camera:WorldToViewportPoint(hrp.Position)

                if tracer_visible then
                    tracer_outline.From = Vector2.new(screen_mid_x, screen_bottom_y)
                    tracer_outline.To = Vector2.new(tracer_position.X, tracer_position.Y)
                    tracer_outline.Visible = module.colors.tracer

                    tracer.From = Vector2.new(screen_mid_x, screen_bottom_y)
                    tracer.To = Vector2.new(tracer_position.X, tracer_position.Y)
                    
                    if module.team then
                        tracer.Color = player.TeamColor.Color
                    else
                        tracer.Color = module.colors.tracer
                    end

                    tracer.Visible = module.tracer
                else
                    tracer.Visible = false
                    tracer_outline.Visible = false
                end

                local equiped_tool = player.Character:FindFirstChildOfClass("Tool")
                local tool_text = equiped_tool and equiped_tool.Name or "No tool equiped"
                local tool_position = ((points[1] + points[2]) / 2)
                tool_position = Vector2.new(tool_position.X, tool_position.Y - 35)

                tool_outline.Position = tool_position + Vector2.new(1, 1)
                tool_outline.Text = tool_text

                tool.Position = tool_position
                tool.Text = tool_text
                
                if module.team then
                    tool.Color = player.TeamColor.Color
                else
                    tool.Color = module.colors.text
                end

                tool_outline.Visible = module.text
                tool.Visible = module.text

                local name_position = Vector2.new(tool_position.X, tool_position.Y + 15)

                name_outline.Position = name_position + Vector2.new(1, 1)
                name_outline.Text = player.Name

                name.Position = name_position
                name.Text = player.Name
                
                if module.team then
                    name.Color = player.TeamColor.Color
                else
                    name.Color = module.colors.text
                end

                name_outline.Visible = module.text
                name.Visible = module.all
            else
                box.Visible = false
                box_outline.Visible = false
                tracer.Visible = false
                tracer_outline.Visible = false
                name.Visible = false
                name_outline.Visible = false
                tool.Visible = false
                tool_outline.Visible = false
            end
        end
    end

    rs.RenderStepped:Connect(OnRender)
    player.CharacterAdded:Connect(OnRender)
end

for _, player in pairs(players:GetPlayers()) do
    if player  == lp then continue end
    VisualizePlayer(player)
end
    
players.PlayerAdded:Connect(function(player)
    VisualizePlayer(player)
end)

return module
