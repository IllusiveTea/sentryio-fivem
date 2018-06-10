resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'A sentry.io wrapper for FiveM'

client_script 'sentry_c.lua'
server_script 'sentry.lua'

server_export 'SentryIO_Fatal'
server_export 'SentryIO_Error'
server_export 'SentryIO_Warning'
server_export 'SentryIO_Info'
server_export 'SentryIO_Debug'

export 'SentryIO_Fatal'
export 'SentryIO_Error'
export 'SentryIO_Warning'
export 'SentryIO_Info'
export 'SentryIO_Debug'
