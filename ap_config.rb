# ActivityPuc Configuration
ACTOR_ID = "reasonset"
AP_HOSTNAME = "chienomi.org"
ACTOR_ID_PREFIX = ["https:/", AP_HOSTNAME].join("/")
ACTOR_BASEPATH = ["ap", "users", ACTOR_ID].join("/")
ACTOR_PATH = [ACTOR_BASEPATH, "actor"].join("/")
ACTOR_URL = [ACTOR_ID_PREFIX, ACTOR_PATH].join("/")
AP_ID = [ACTOR_ID, AP_HOSTNAME].join("@")

# Server Configuration
# STATIC_PUBLIC_ROOT = "/srv/http/chienomi.ap"
STATIC_PUBLIC_ROOT = "/home/haruka/wrk/server/WebApps/ChienomiAP/static"
STATIC_ACTOR_ROOT = [STATIC_PUBLIC_ROOT, ACTOR_BASEPATH].join("/")
STATIC_DB_OUTBOX = [STATIC_ACTOR_ROOT, "outbox"].join("/")
STATIC_DB_CREATES = [STATIC_ACTOR_ROOT, "creates"].join("/")
STATIC_DB_NOTES = [STATIC_ACTOR_ROOT, "notes"].join("/")
SERVER_HOST = "127.0.4.1"
SERVER_PORT = 8001

# Application Configuration
ID_DIGEST_SALT = "ChI"
COLLECTION_PREFIX = "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/outbox"
JOBQUEUE_ROOT = "/home/haruka/tmp/chienomi-ap/jobs"
