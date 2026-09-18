import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

# Project paths
ROOT_DIR = Path(__file__).parent.parent
BENCHMARKS_PATH = ROOT_DIR / "benchmarks.json"
SEARCH_FILTERS_PATH = ROOT_DIR / "search_filters.json"
AMENITIES_PATH = ROOT_DIR / "amenities.json"

# Cache paths
CACHE_DIR = ROOT_DIR / ".cache"
LISTING_CACHE = CACHE_DIR / "listings"
CITY_CACHE = CACHE_DIR / "cities.json"

# Logging paths
LOG_DIR = ROOT_DIR / "logs"
LOG_FILE = LOG_DIR / "app.log"

# Reports path
REPORTS_DIR = ROOT_DIR / "reports"

# Ensure directories exist
LISTING_CACHE.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

# Test Data (for caching and integration tests)
TEST_DATA_DIR = ROOT_DIR / "tests" / "data"
TEST_LISTING_ID = "19643333"

# API Keys
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
