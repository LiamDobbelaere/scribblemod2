include('core/scribblemod2_core.lua')

if CLIENT then
    net.Receive("SCM2_SetEntityScale", function(len, ply)
        local ent = net:ReadEntity()
        local x = net:ReadFloat()
        local y = net:ReadFloat()
        local z = net:ReadFloat()

        local scale = Vector(x, y, z)
        local mat = Matrix()
        mat:Scale(scale)
        ent:EnableMatrix("RenderMultiply", mat)
    end)

    local function GetPlaceholderText()
        return "really wide crate"
    end

    local function showScribblemodMenu()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Scribblemod")
        frame:SetSize(400, 100)
        frame:Center()
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        end

        local textEntry = vgui.Create("DTextEntry", frame)
        textEntry:Dock(FILL)
        textEntry:SetFont("DermaLarge")
        textEntry:SetHeight(40)
        textEntry:SetTabbingDisabled(true)
        textEntry:SetPlaceholderText(GetPlaceholderText())
        textEntry.OnEnter = function(self)
            local val = self:GetValue()
            local words = string.Split(val, ' ')
            local query = words[#words]
            local results = search.GetResults(query, "props", 1)
            local resultToUse = nil

            for _, result in pairs(results) do
                local modelName = result["words"][1]
                local modelNameSplit = string.Split(modelName, '/')
                local modelNameMdl = modelNameSplit[#modelNameSplit]
                local resultToUseMdl = nil

                if resultToUse ~= nil then
                    local resultToUseSplit = string.Split(resultToUse, '/')
                    resultToUseMdl = resultToUseSplit[#resultToUseSplit]
                end

                if resultToUse == nil or (resultToUse ~= nil and #modelNameMdl <= #resultToUseMdl) then
                    resultToUse = modelName
                end
            end

            if resultToUse == nil then
                LocalPlayer():ChatPrint("Can't find anything for query: " .. query)
                frame:Close()
                return
            end

            net.Start("SCM2_SpawnRequest")
            net.WriteString(self:GetValue())
            net.WriteString(resultToUse)
            net.SendToServer()

            frame:Close()
        end

        textEntry:RequestFocus()
    end

    concommand.Add("scribblemod_menu", function(ply, cmd, args)
        showScribblemodMenu()
    end)
end

-- Tell the server/client that SCM2 is running
if CLIENT then
    ScmLog("This server has SCM2, bind something to scribblemod_menu!")
else
    ScmLog("SCM2 running on this server!")
end
