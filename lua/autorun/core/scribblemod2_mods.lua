if SERVER then
    ScmRegisterPreinit(function(ent)
        ent.scm_multiplier = 1
    end)

    -- ScmRegisterPostInit(function(ent)
    --    if ent:GetModelScale() ~= 1 then
    --        local min, max = ent:GetModelBounds()

    --        ent:PhysicsInitBox(min, max)
    --        ent:PhysWake()
    --    end
    -- end)

    -- Multipliers
    local function Multiplier(n)
        return function(ent)
            ent.scm_multiplier = ent.scm_multiplier * n
        end
    end
    local multipliers = {
        really = Multiplier(2),
        kinda = Multiplier(0.75)
    }

    for key, fn in pairs(multipliers) do
        ScmRegisterAttribute(key, fn)
    end

    local function SizeModifier(n, inverseMultiplier)
        return function(ent)
            if (inverseMultiplier) then
                ent:SetModelScale(n / ent.scm_multiplier)
            else
                ent:SetModelScale(n * ent.scm_multiplier)
            end

            ent.scm_multiplier = 1
        end
    end
    local sizeModifiers = {
        big = SizeModifier(2),
        small = SizeModifier(0.5, true)
    }

    for key, fn in pairs(sizeModifiers) do
        ScmRegisterAttribute(key, fn)
    end

    local function ColorModifier(col)
        return function(ent)
            local curr = ent:GetColor()
            local multipliedCol = Color(math.min(255, col.r * ent.scm_multiplier),
                                      math.min(255, col.g * ent.scm_multiplier),
                                      math.min(255, col.b * ent.scm_multiplier),
                                      math.min(255, col.a * ent.scm_multiplier))

            if multipliedCol.a < 255 then
                ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
            end

            ent:SetColor(Color((curr.r + multipliedCol.r) * 0.5, (curr.g + multipliedCol.g) * 0.5,
                             (curr.b + multipliedCol.b) * 0.5, (curr.a + multipliedCol.a) * 0.5))
        end
    end
    local colorModifiers = {
        red = ColorModifier(Color(255, 0, 0, 255)),
        green = ColorModifier(Color(0, 255, 0, 255)),
        blue = ColorModifier(Color(0, 0, 255, 255)),
        transparent = ColorModifier(Color(0, 0, 0, 128))
    }

    for key, fn in pairs(colorModifiers) do
        ScmRegisterAttribute(key, fn)
    end
end
