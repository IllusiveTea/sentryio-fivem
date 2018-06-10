Citizen.CreateThread(function()
	enabled = true

	SentryIO = { }

	SentryConfig = {
		publickey = GetConvar("SentryIO_PublicKey", "none"),
		privkey = GetConvar("SentryIO_PrivKey", "none"),
		projectid = GetConvar("SentryIO_ProjectId", "none")
	}

	Citizen.Wait(5000)
	print("["..GetCurrentResourceName().."]: Checking Convars...")
	allgood = true

	for k,v in pairs(SentryConfig) do
		if v == "none" then
			print("["..GetCurrentResourceName().."]: "..k.." is missing from your cfg, this is required for this resource to work!")
			enabled = false
			error(k.." is missing from your cfg, this are required for this resource to work!")
			allgood = false
		end
	end

	if allgood then
		print("["..GetCurrentResourceName().."]: Is setup correctly, enjoy!")
	end

	local hextable = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'}

	local function RandomHex(length)
		local s = ""
		for i = 1, length do
			s = s..hextable[math.random(1,16)]
		end
		return s
	end

	local function GenerateUUID()
		return string.format("%s4%s8%s%s", RandomHex(10), RandomHex(5), RandomHex(2), RandomHex(13))
	end

	local function GetTimestamp()
		local t = os.date("!*t")
		return ("%04d-%02d-%02dT%02d:%02d:%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
	end

	function SentryIO:Issue(errorType, error, severity)
		if enabled then
			local data = {
				["event_id"] = GenerateUUID(),
				["timestamp"] = os.date("!%Y-%m-%dT%TZ"),
				["logger"] = "FiveM.Logger",
				["platform"] = "other",
				["sdk"] = {
					["name"] = "FiveM-Sentry",
					["version"] = "1.0.0"
				},
				["exception"] = {
					["type"] = errorType,
					["value"] = error
				},
				["level"] = severity
			}

			local headers = {
				["Content-Type"] = 'application/json',
				["User-Agent"] = 'raven-Lua/1.0',
				["X-Sentry-Auth"] = 'Sentry sentry_version=7,sentry_timestamp='..os.time()..',sentry_key='..SentryConfig.publickey..',sentry_secret='..SentryConfig.privkey..',sentry_client=raven-Lua/1.0'
			}

			local succ = nil

			PerformHttpRequest('https://sentry.io/api/'..SentryConfig.projectid..'/store/', function(statusCode, data, headers)
			    if statusCode ~= 200 then
			        print("An error occured, Status Code: "..statusCode..", Message: "..data)
					succ = false
				else
					succ = true
			    end
			end, 'POST', json.encode(data), headers)

			while succ == nil do
				Citizen.Wait(100)
			end

			return succ
		end
	end

	function SentryIO_Fatal(fatalType, fatal)
		SentryIO:Issue(fatalType, fatal, "fatal")
	end

	function SentryIO_Error(errorType, error)
		SentryIO:Issue(errorType, error, "error")
	end

	function SentryIO_Warning(warningType, warning)
		SentryIO:Issue(warningType, warning, "warning")
	end

	function SentryIO_Info(infoType, info)
		SentryIO:Issue(infoType, info, "info")
	end

	function SentryIO_Debug(debugType, debug)
		SentryIO:Issue(debugType, debug, "debug")
	end

	RegisterNetEvent("SentryIO_Fatal")
	AddEventHandler("SentryIO_Fatal", function(fatalType, fatal)
		SentryIO:Issue(fatalType, fatal, "fatal")
	end)

	RegisterNetEvent("SentryIO_Error")
	AddEventHandler("SentryIO_Error", function(errorType, error)
		SentryIO:Issue(errorType, error, "error")
	end)

	RegisterNetEvent("SentryIO_Warning")
	AddEventHandler("SentryIO_Warning", function(warningType, warning)
		SentryIO:Issue(warningType, warning, "warning")
	end)

	RegisterNetEvent("SentryIO_Info")
	AddEventHandler("SentryIO_Info", function(infoType, info)
		SentryIO:Issue(infoType, info, "info")
	end)

	RegisterNetEvent("SentryIO_Debug")
	AddEventHandler("SentryIO_Debug", function(debugType, debug)
		SentryIO:Issue(debugType, debug, "debug")
	end)
end)

local verFile = LoadResourceFile(GetCurrentResourceName(), "version.json")
local curVersion = json.decode(verFile).version
Citizen.CreateThread(function()
	local updatePath = "/IllusiveTea/sentryio-fivem"
	local resourceName = "SentryIO-FiveM ("..GetCurrentResourceName()..")"
	function CheckForUpdate()
		PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/SentryIO-FiveM/version.json", function(err, response, headers)
			local data = json.decode(response)
			if curVersion ~= data.version and tonumber(curVersion) < tonumber(data.version) then
				print("\n--------------------------------------------------------------------------")
				print("\n"..resourceName.." is outdated.\nCurrent Version: "..data.version.."\nYour Version: "..curVersion.."\nPlease update it from https://github.com"..updatePath.."")
				print("\nUpdate Changelog:\n"..data.changelog)
				print("\n--------------------------------------------------------------------------")
			elseif tonumber(curVersion) > tonumber(data.version) then
				print("Your version of "..resourceName.." seems to be higher than the current version.")
			else
				print(resourceName.." is up to date!")
			end
		end, "GET", "", {version = 'this'})
		SetTimeout(3600000, CheckForUpdate)
	end

	SetTimeout(2500, CheckForUpdate)
end)
