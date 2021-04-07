function ScmLog(msg)
    MsgC(Color(0, 255, 0), "[Scribblemod2] ")
    if CLIENT then
        MsgC(Color(255, 222, 102), "(Client) " .. msg .. "\n")
    else
        MsgC(Color(137, 222, 255), "(Server) " .. msg .. "\n")
    end
end

-- Register net events
if SERVER then
    util.AddNetworkString("SCM2_SpawnRequest")
    util.AddNetworkString("SCM2_SetEntityScale")

    local function applyModelScale(ent, x, y, z, ply)
        local min, max = ent:GetModelBounds()

        ent:PhysicsInitBox(min, max * Vector(x / 2, y / 2, z / 2))
        ent:PhysWake()

        net.Start("SCM2_SetEntityScale")
        net.WriteEntity(ent)
        net.WriteFloat(x)
        net.WriteFloat(y)
        net.WriteFloat(z)
        net.Send(ply)
    end

    local scmAttributes = {}
    local scmPreInit = {}
    local scmPostInit = {}

    function ScmRegisterPreinit(fn)
        table.insert(scmPreInit, fn)
    end

    function ScmRegisterPostInit(fn)
        table.insert(scmPostInit, fn)
    end

    function ScmRegisterAttribute(name, fn)
        scmAttributes[name] = fn
    end

    function ScmRegisterAttributes(names, fn)
        for _, name in pairs(names) do
            RegisterAttribute(name, fn)
        end
    end

    net.Receive("SCM2_SpawnRequest", function(len, ply)
        local query = net:ReadString()
        local modelName = net:ReadString()

        ScmLog("Got a spawn request: " .. query)

        local newEntity = ents.Create("prop_physics")
        newEntity:SetModel(modelName)

        local min, max = newEntity:GetModelBounds()

        if min == nil or max == nil then
            min = Vector(0, 0, 0)
            max = Vector(0, 0, 0)
        end

        newEntity:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, max.z))
        newEntity:Spawn()

        for _, fn in pairs(scmPreInit) do
            fn(newEntity)
        end

        local words = string.Split(query, ' ')
        for i, word in pairs(words) do
            if i ~= #words and scmAttributes[word] then

                scmAttributes[word](newEntity)
            end
        end

        for _, fn in pairs(scmPostInit) do
            fn(newEntity)
        end

        newEntity:Activate()
    end)
end

-- Time to load the mods, only after core is ready for stuff
include('scribblemod2_mods.lua')
