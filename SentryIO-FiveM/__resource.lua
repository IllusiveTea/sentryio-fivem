resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'A sentry.io wrapper for FiveM'

server_script 'sentry.lua'

server_export 'SentryIO_Fatal'
server_export 'SentryIO_Error'
server_export 'SentryIO_Warning'
server_export 'SentryIO_Info'
server_export 'SentryIO_Debug'
