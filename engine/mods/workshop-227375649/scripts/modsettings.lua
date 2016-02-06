settings = {}

local function SettingsPath(name)
   return '../mods/'..name..'_settings.lua'
end

function LoadSettings(name, default_sett)
	local sett_path = SettingsPath(name)
	local f=io.open(sett_path,"r")
   	if f~=nil then   		
   		io.close(f)
   		local sett = dofile(sett_path)
   		for k,v in pairs(sett) do
   			settings[k] = v
   		end
   	else
   		SaveSettings(name, default_sett)
   	end

   	if default_sett then
	   	for k,v in pairs(default_sett) do
	   		if not settings[k] then
	   			settings[k] = v
	   		end
	   	end
   	end

   	return settings
end

function SaveSettings(name, sett)
   local sett_path = SettingsPath(name)
   local f=io.open(sett_path,"w")
   if f~=nil then
      f:write('return {')
      for k,v in pairs(sett) do
         f:write(k..'=\''..v..'\',')
      end
      f:write('}')
      io.close(f)      
   end
end