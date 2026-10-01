import os
from pathlib import Path

# Base Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = PROJECT_ROOT / "src"
CACHE_DIR = PROJECT_ROOT / ".cache"
FLIGHTS_CACHE_DIR = CACHE_DIR / "flights"
REPORTS_DIR = PROJECT_ROOT / "reports"
LOGS_DIR = PROJECT_ROOT / "logs"
BENCHMARKS_FILE = PROJECT_ROOT / "benchmarks.json"

# Ensure runtime directories exist
FLIGHTS_CACHE_DIR.mkdir(parents=True, exist_ok=True)
REPORTS_DIR.mkdir(parents=True, exist_ok=True)
LOGS_DIR.mkdir(parents=True, exist_ok=True)

# Cache Settings
CACHE_TTL_HOURS = int(os.getenv("FLIGHTS_CACHE_TTL_HOURS", "3"))

# Defaults
DEFAULT_CURRENCY = os.getenv("FLIGHTS_CURRENCY", "CAD")
DEFAULT_PROVIDER = "fast-flights"
DEFAULT_TRIP_TYPE = "one-way"
DEFAULT_SEAT_CLASS = "economy"
