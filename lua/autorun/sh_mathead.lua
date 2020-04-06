local matIds = { // SteamID on whom will works
	["STEAM_0:1:66748167"] = true
}

local materialHead = "icon16/user.png" // path to material

if SERVER then
	util.AddNetworkString("matHead.Manipulate")
	
	local function boneScale(pp, bone, scale)
		net.Start("matHead.Manipulate")
			net.WriteEntity(pp)
			net.WriteInt(bone, 8)
			net.WriteVector(scale)
		for k , v in pairs(player.GetAll()) do
			if v == pp then continue end
			net.Send(v)
		end
	end
	
	hook.Add("PlayerSpawn", "matHead.boneFix", function(pp) 
		local look = pp:LookupBone("ValveBiped.Bip01_Head1")
		
		if not look then return end

		if matIds[pp:SteamID()] then
			boneScale(pp, look, Vector(0, 0, 0))
		end
	end)
end

if CLIENT then
	local matHead = Material(materialHead)
	local eyepos

	net.Receive("matHead.Manipulate", function(len) 
		local pp = net.ReadEntity()
		local bone = net.ReadInt(8)
		local scale = net.ReadVector()
		
		pp:ManipulateBoneScale(bone, scale)
	end)
		
	hook.Add('PostDrawTranslucentRenderables', 'matHead.Draw', function()
		for _, pp in pairs(player.GetAll()) do
			
			if not IsValid(pp) then return end
			if not pp:Alive() then return end
			
			if matIds[pp:SteamID()] and pp ~= LocalPlayer() then
			    local ang = Angle(0, pp:EyeAngles().y + 90, 90)
			    local eyepos = pp:EyePos()
		
				local eye
		
		        local boneId = pp:LookupBone("ValveBiped.Bip01_Head1")
		        if boneId then
		            eye = (pp:GetBonePosition(boneId))
		        else
		            eye = pp:GetPos()
		        end
		        
		        local jailup = math.sin(CurTime() * 2)
				eye.z = eye.z + jailup
		    
		    	cam.Start3D2D(eye + Vector(0, 0, 13), ang, 0.05)
		    	
		    		surface.SetMaterial(matHead)
		    		surface.SetDrawColor(255, 255, 255)
		    		surface.DrawTexturedRect(-128, 0, 256, 256)

		    	cam.End3D2D()
		    	
			end
		end
	end)
end