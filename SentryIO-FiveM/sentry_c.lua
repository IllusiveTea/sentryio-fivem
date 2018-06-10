function SentryIO_Fatal(fatalType, fatal)
	TriggerServerEvent("SentryIO_Fatal", fatalType, fatal)
end

function SentryIO_Error(errorType, error)
	TriggerServerEvent("SentryIO_Error", errorType, error)
end

function SentryIO_Warning(warningType, warning)
	TriggerServerEvent("SentryIO_Warning", warningType, warning)
end

function SentryIO_Info(infoType, info)
	TriggerServerEvent("SentryIO_Info", infoType, info)
end

function SentryIO_Debug(debugType, debug)
	TriggerServerEvent("SentryIO_Debug", debugType, debug)
end
