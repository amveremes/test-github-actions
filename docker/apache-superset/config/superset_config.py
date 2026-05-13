import logging
import os

from dotenv import load_dotenv
from urllib.parse import quote_plus
from celery.schedules import crontab
from flask_caching.backends.filesystemcache import FileSystemCache
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address


# define fonction for get env variable
def getenv(key, default=None, secrets_dir="/run/secrets"):
    secret_path = os.path.join(secrets_dir, key)
    try:
        with open(secret_path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except (FileNotFoundError, OSError):
        return os.getenv(key, default)


# Load .env file
load_dotenv()
logger = logging.getLogger()

# Read Secrets
DATABASE_PASSWORD = getenv("postgres_password")
ADMIN_PASSWORD = getenv("admin_password")
ADMIN_EMAIL = getenv("admin_email")
SUPERSET_SECRET_KEY = getenv("superset_secret_key")
SECRET_KEY = SUPERSET_SECRET_KEY
PYTHONUNBUFFERED = getenv("PYTHONUNBUFFERED")
COMPOSE_PROJECT_NAME = getenv("COMPOSE_PROJECT_NAME")
DEV_MODE = getenv("DEV_MODE", "true")

enc_password = quote_plus(DATABASE_PASSWORD)

# database configurations
SQLALCHEMY_DATABASE_URI = (
    f"postgresql+psycopg2://superset:{enc_password}@superset_db/superset"
)

# Cache
REDIS_HOST = getenv("REDIS_HOST", "superset_cache")
REDIS_PORT = getenv("REDIS_PORT", "6379")
REDIS_CELERY_DB = getenv("REDIS_CELERY_DB", "0")
REDIS_RESULTS_DB = getenv("REDIS_RESULTS_DB", "1")

# Debug
FLASK_DEBUG = getenv("FLASK_DEBUG", "true")
SUPERSET_LOG_LEVEL = getenv("SUPERSET_LOG_LEVEL", "info")

SUPERSET_APP_ROOT = getenv("SUPERSET_APP_ROOT", "/")
SUPERSET_ENV = getenv("SUPERSET_ENV", "development")
SUPERSET_LOAD_EXAMPLES = getenv("SUPERSET_LOAD_EXAMPLES", "no")
CYPRESS_CONFIG = getenv("CYPRESS_CONFIG", "false")
SUPERSET_PORT = getenv("SUPERSET_PORT", "8088")


RESULTS_BACKEND = FileSystemCache("/app/pythonpath/cache")

CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_HOST": REDIS_HOST,
    "CACHE_REDIS_PORT": REDIS_PORT,
    "CACHE_REDIS_DB": REDIS_RESULTS_DB,
}
DATA_CACHE_CONFIG = CACHE_CONFIG

RATELIMIT_STORAGE_URI = getenv("RATELIMIT_STORAGE_URI")

# Initialisation de Flask-Limiter
limiter = Limiter(
    get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri=RATELIMIT_STORAGE_URI,
)


class CeleryConfig:
    broker_url = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_CELERY_DB}"
    imports = (
        "superset.sql_lab",
        "superset.tasks.scheduler",
        "superset.tasks.thumbnails",
        "superset.tasks.cache",
    )
    result_backend = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_RESULTS_DB}"
    worker_prefetch_multiplier = 1
    task_acks_late = False
    beat_schedule = {
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
        "reports.prune_log": {
            "task": "reports.prune_log",
            "schedule": crontab(minute=10, hour=0),
        },
    }


CELERY_CONFIG = CeleryConfig

FEATURE_FLAGS = {"ALERT_REPORTS": True, "DASHBOARD_RBAC": True}
ALERT_REPORTS_NOTIFICATION_DRY_RUN = True

TALISMAN_ENABLED = getenv("TALISMAN_ENABLED", "false")
WTF_CSRF_ENABLED = getenv("WTF_CSRF_ENABLED", "false")

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = getenv("MAPBOX_API_KEY", "")

SQLLAB_CTAS_NO_LIMIT = getenv("SQLLAB_CTAS_NO_LIMIT", "True")

ENABLE_PLAYWRIGHT = getenv("ENABLE_PLAYWRIGHT", "false")
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = getenv("PUPPETEER_SKIP_CHROMIUM_DOWNLOAD", "true")
BUILD_SUPERSET_FRONTEND_IN_DOCKER = getenv("BUILD_SUPERSET_FRONTEND_IN_DOCKER", "true")
