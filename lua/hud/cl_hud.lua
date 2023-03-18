-- 2D vector lib (I refuse to not have vectors for rendering :angry:)
-- credits to bing the superior search engine for generating this :W:

local vec2={__index={}}function vec2.new(a,b)local c=setmetatable({},vec2)c.x=a or 0;c.y=b or 0;return c end
function vec2.__add(a,b)return vec2.new(a.x+b.x,a.y+b.y)end
function vec2.__sub(a,b)return vec2.new(a.x-b.x,a.y-b.y)end
function vec2.__mul(a,b)if type(b)=="number"then return vec2.new(a.x*b,a.y*b)else return a.x*b.x+a.y*b.y end end
function vec2.__div(a,b)return vec2.new(a.x/b,a.y/b)end

-- HUD

hook.Add("HUDShouldDraw", "hide_elements", function(arg)
    if (arg == "DarkRP_LocalPlayerHUD") then return false end
end)

local screen_size = vec2.new(ScrW(), ScrH())
local dpi_scalar = (screen_size.x > screen_size.y) and screen_size.x / 1920 or screen_size.y / 1080
local hud_size = vec2.new((1920 / 6) * dpi_scalar, (1080 / 26) * dpi_scalar)
local hud_padding, hud_margin = 8 * dpi_scalar, 16 * dpi_scalar

hook.Add("OnScreenSizeChanged", "update_vars", function()
	screen_size = vec2.new(ScrW(), ScrH())
    dpi_scalar = (screen_size.x > screen_size.y) and screen_size.x / 1920 or screen_size.y / 1080
    hud_size = vec2.new((1920 / 6) * dpi_scalar, (1080 / 26) * dpi_scalar)
    hud_padding, hud_margin = 8 * dpi_scalar, 16 * dpi_scalar

    surface.CreateFont("onion_hud", {
        font = "Segoe UI",
        extended = false,
        size = 20 * dpi_scalar,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
    
    surface.CreateFont("onion_health", {
        font = "Segoe UI",
        extended = false,
        size = 14 * dpi_scalar,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
end)
hook.Call( "OnScreenSizeChanged", nil, screen_size.x, screen_size.y )

hook.Add("HUDPaint", "render_onion_hud", function()
    local lply = LocalPlayer()

    if (lply and lply:IsPlayer()) then
        local info = {
            name = lply:Nick(),
            health = lply:Health(),
            money = lply:getDarkRPVar("money"),
            job = lply:getDarkRPVar("job"),
            team = lply:Team(),
        }
        info.team_color = team.GetColor(info.team)

        local main_pos, main_size = vec2.new(hud_margin, screen_size.y - hud_size.y * 2 - hud_margin * 2), vec2.new(hud_size.x, hud_size.y)
        local bar1_pos, bar1_size = vec2.new(hud_margin, screen_size.y - hud_size.y - hud_margin), vec2.new(hud_size.x / 2 - hud_margin / 2, hud_size.y)
        local bar2_pos, bar2_size = vec2.new(hud_margin * 1.5 + hud_size.x / 2, screen_size.y - hud_size.y - hud_margin), vec2.new(hud_size.x / 2 - hud_margin / 2, hud_size.y)

        if (onion_hud.main_bar) then -- Render main bar info
            draw.RoundedBox(hud_size.y / 2, main_pos.x, main_pos.y, main_size.x, main_size.y, Color(30, 30, 30))

            render.SetScissorRect(main_pos.x, main_pos.y, main_pos.x + main_size.x, main_pos.y + main_size.y, true)
                surface.SetFont("onion_hud")
                local divider = (onion_hud.show_job and onion_hud.show_name) and " - " or ""
                local draw_text = ((onion_hud.show_name) and info.name or "") .. divider .. ((onion_hud.show_job) and info.job or "")
                local text_size = vec2.new(surface.GetTextSize(draw_text))
                draw.DrawText(draw_text, "onion_hud", main_pos.x + main_size.x / 2, main_pos.y + main_size.y / 2 - text_size.y / 4 - hud_margin / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            render.SetScissorRect(0, 0, 0, 0, false)
        end

        if (onion_hud.bl_bar) then -- Render bottom right bar info
            render.SetScissorRect(bar1_pos.x, bar1_pos.y, bar1_pos.x + bar1_size.x, bar1_pos.y + bar1_size.y, true)
                draw.RoundedBox(bar1_size.y / 2, bar1_pos.x, bar1_pos.y, bar1_size.x, bar1_size.y, Color(30, 30, 30))
                local health_percent = info.health / 100 if (health_percent < 0) then health_percent = 0 elseif (health_percent > 1) then health_percent = 1 end

                local bar_w = bar1_size.x - hud_padding * 2
                draw.RoundedBox(bar1_size.y / 12, bar1_pos.x + hud_padding + (bar_w - (bar_w * health_percent)) / 2, bar1_pos.y + bar1_size.y / 2 - (bar1_size.y / 6) / 2, bar_w * health_percent, bar1_size.y / 6, Color(225, 100, 100))

                local health_text = "hp: " .. tostring(info.health)

                surface.SetFont("onion_health")
                local text_size = vec2.new(surface.GetTextSize(health_text))
                draw.DrawText(health_text, "onion_health", bar1_pos.x + bar1_size.x / 2, bar1_pos.y + bar1_size.y / 2 - (bar1_size.y / 6) / 2 - text_size.y - hud_padding / 4, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            render.SetScissorRect(0, 0, 0, 0, false)
        end

        if (onion_hud.br_bar) then -- Render bottom left bar info
            render.SetScissorRect(bar2_pos.x, bar2_pos.y, bar2_pos.x + bar2_size.x, bar2_pos.y + bar2_size.y, true)
                draw.RoundedBox(bar2_size.y / 2, bar2_pos.x, bar2_pos.y, bar2_size.x, bar2_size.y, Color(30, 30, 30))

                surface.SetFont("onion_hud")
                local money_text = "$" .. tostring(info.money)
                local text_size = vec2.new(surface.GetTextSize(money_text))
                draw.DrawText(money_text, "onion_hud", bar2_pos.x + bar2_size.x / 2, bar2_pos.y + bar2_size.y / 2 - text_size.y / 4 - hud_margin / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end
end)