Citizen.CreateThread(function()
	enabled = true

	SentryIO = { }

	SentryConfig = {
		publickey = GetConvar("SentryIO_PublicKey", "none"),
		privkey = GetConvar("SentryIO_PrivKey", "none"),
		projectid = GetConvar("SentryIO_ProjectId", "none"),
		webhook = GetConvar("SentryIO_DiscordWebhook", "none")
	}

	local hextable = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'}

	local function RandomHex(length)
		local s = ""
		for i = 1, length do
			math.randomseed(os.clock()^5)
			s = s..hextable[math.random(1,16)]
		end
		return s
	end

	local function GenerateUUID()
		return string.format("%s6%s2%s%s", RandomHex(10), RandomHex(5), RandomHex(2), RandomHex(13))
	end

	local function GetTimestamp()
		local t = os.date("!*t")
		return ("%04d-%02d-%02dT%02d:%02d:%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
	end

	function SentryIO:Issue(errorType, error, severity)
		if enabled then
			local data = {
				["event_id"] = GenerateUUID(),
				["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
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
				["Authorization"] = "DSN "..SentryConfig.publickey,
				["X-Sentry-Auth"] = 'Sentry sentry_version=7,sentry_timestamp='..os.time()..',sentry_key='..SentryConfig.publickey..',sentry_secret='..SentryConfig.privkey..',sentry_client=raven-Lua/1.0'
			}

			PerformHttpRequest('https://sentry.io/api/'..SentryConfig.projectid..'/store/', function(statusCode, data, headers)
				if statusCode ~= 200 then
					print("An error occured, Status Code: "..statusCode)
					print(data)
					print("Error occured, waiting to retry...")
					Wait(2000)
					--SentryIO:Issue(errorType, error, severity)
				end
			end, 'POST', json.encode(data), headers)

			if SentryConfig.webhook ~= "none" then
				local embeds = {
					{
						["title"] = errorType,
						["description"] = error,
						["color"] = 31743,
						["footer"] =  {
							["icon_url"] = "https://sentry-brand.storage.googleapis.com/sentry-glyph-white.png",
							["text"] = "SentryIO-FiveM",
						},
					}
				}

				PerformHttpRequest(SentryConfig.webhook, function(statusCode, text, headers)
					if text then
						print(text)
					end
				end, 'POST', json.encode({ avatar_url = "https://sentry-brand.storage.googleapis.com/sentry-glyph-white.png", username = "SentryIO-FiveM", embeds = embeds}), { ["Content-Type"] = 'application/json' })
			end
		end
	end

	RegisterNetEvent("SentryIO:Fatal")
	AddEventHandler("SentryIO:Fatal", function(fatalType, fatal)
		SentryIO:Issue(fatalType, fatal, "fatal")
	end)

	RegisterNetEvent("SentryIO:Error")
	AddEventHandler("SentryIO:Error", function(errorType, error)
		SentryIO:Issue(errorType, error, "error")
	end)

	RegisterNetEvent("SentryIO:Warning")
	AddEventHandler("SentryIO:Warning", function(warningType, warning)
		SentryIO:Issue(warningType, warning, "warning")
	end)

	RegisterNetEvent("SentryIO:Info")
	AddEventHandler("SentryIO:Info", function(infoType, info)
		SentryIO:Issue(infoType, info, "info")
	end)

	RegisterNetEvent("SentryIO:Debug")
	AddEventHandler("SentryIO:Debug", function(debugType, debug)
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

	CheckForUpdate()
end)
