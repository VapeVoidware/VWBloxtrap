local baseDirectory = 'vwroblox/'
local url = 'https://raw.githubusercontent.com/VapeVoidware/VWBloxtrap/'

if not isfolder(baseDirectory:gsub("/$", "")) then
    makefolder(baseDirectory:gsub("/$", ""))
end
local commit = "main"
writefile(baseDirectory.."commithash2.txt", commit)
for i,v in pairs(game:HttpGet(url):split("\n")) do 
    if v:find("commit") and v:find("fragment") then 
        local str = v:split("/")[5]
        commit = str:sub(0, str:find('"') - 1)
        break
    end
end
writefile(baseDirectory.."commithash2.txt", commit)
local function vapeGithubRequest(scripturl, isImportant)
    if isfile(baseDirectory..scripturl) then
        if not shared.VoidDev then
            pcall(function() delfile(baseDirectory..scripturl) end)
        else
            return readfile(baseDirectory..scripturl) 
        end
    end
    local suc, res
    suc, res = pcall(function() return game:HttpGet(url..readfile(baseDirectory.."commithash2.txt").."/"..scripturl, true) end)
    if not suc or res == "404: Not Found" then
        if isImportant then
            game:GetService("Players").LocalPlayer:Kick("Failed to connect to github : "..baseDirectory..scripturl.." : "..res)
        end
        warn(baseDirectory..scripturl, res)
    end
    if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
    return res
end
shared.VapeDeveloper = shared.VapeDeveloper or shared.VoidDev
local function pload(fileName, isImportant, required)
    fileName = tostring(fileName)
    if string.find(fileName, "CustomModules") and string.find(fileName, "Voidware") then
        fileName = string.gsub(fileName, "Voidware", "VW")
    end        
    if shared.VoidDev and shared.DebugMode then warn(fileName, isImportant, required, debug.traceback(fileName)) end
    local res = vapeGithubRequest(fileName, isImportant)
    local a = loadstring(res)
    local suc, err = true, ""
    if type(a) ~= "function" then suc = false; err = tostring(a) else if required then return a() else a() end end
    if (not suc) then 
        if isImportant then
            if (not string.find(string.lower(err), "vape already injected")) and (not string.find(string.lower(err), "rise already injected")) then
				warn("[".."Failure loading critical file! : "..baseDirectory..tostring(fileName).."]: "..tostring(debug.traceback(err)))
            end
        else
            task.spawn(function()
                repeat task.wait() until errorNotification
                if not string.find(res, "404: Not Found") then 
					errorNotification('Failure loading: '..baseDirectory..tostring(fileName), tostring(debug.traceback(err)), 30, 'alert')
                end
            end)
        end
    end
end
shared.pload = pload
getgenv().pload = pload

return pload('loader.lua')