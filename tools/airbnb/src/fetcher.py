import json
import logging
from datetime import datetime, timedelta

import pyairbnb

from config import LISTING_CACHE

logger = logging.getLogger("airbnb")


def get_listing_details(
	listing_id, currency="CAD", check_in=None, check_out=None, force_refresh=False
):
	"""
	Get full details for a specific listing with file-based caching.
	"""
	cache_file = LISTING_CACHE / f"{listing_id}.json"

	# Check cache first
	if cache_file.exists() and not force_refresh:
		# Check if cache is older than 24 hours
		file_time = datetime.fromtimestamp(cache_file.stat().st_mtime)
		if datetime.now() - file_time < timedelta(hours=24):
			logger.info(f"CACHE HIT: Listing {listing_id} (last updated {file_time})")
			with open(cache_file, "r") as f:
				return json.load(f)
		else:
			logger.info(f"CACHE MISS (EXPIRED): Listing {listing_id} (older than 24h)")
	else:
		logger.info(f"CACHE MISS: Listing {listing_id} not found in cache")

	# Fetch from API if not in cache or expired
	logger.info(f"API FETCH: Fetching listing {listing_id}...")
	try:
		import time

		time.sleep(1)  # Small delay to avoid aggressive rate limiting

		# Removing check_in/check_out as they are likely causing the internal library crash
		details = pyairbnb.get_details(room_id=listing_id, currency=currency)

		if details:
			with open(cache_file, "w") as f:
				json.dump(details, f, indent=4)

		return details
	except Exception as e:
		logger.error(f"Error fetching details for listing {listing_id}: {e}")
		return None


def search_listings(
	location_coords,
	check_in,
	check_out,
	min_price=0,
	max_price=1000,
	currency="CAD",
	place_type=None,
	amenities=None,
	language="en",
	free_cancellation=False,
	zoom_value=15,
):
	"""
	Search for Airbnb listings within a bounding box using pyairbnb.search_all.
	"""

	logger.info(
		f"Searching for {place_type or 'all types'} in {currency} between {check_in} and {check_out} (range {min_price}-{max_price})..."
	)

	try:
		results = pyairbnb.search_all(
			check_in=check_in,
			check_out=check_out,
			ne_lat=location_coords["ne_lat"],
			ne_long=location_coords["ne_long"],
			sw_lat=location_coords["sw_lat"],
			sw_long=location_coords["sw_long"],
			zoom_value=zoom_value,
			price_min=min_price,
			price_max=max_price,
			currency=currency,
			place_type=place_type,
			amenities=amenities,
			language=language,
			free_cancellation=free_cancellation,
		)
		logger.debug(f"API returned {len(results)} results")
		return results
	except Exception as e:
		logger.error(f"Error fetching listings: {e}")
		return []


if __name__ == "__main__":
	# Setup minimal logging for internal test
	logging.basicConfig(level=logging.INFO)
	# Simple test for Montreal area
	montreal_coords = {
		"ne_lat": 45.52,
		"ne_long": -73.55,
		"sw_lat": 45.50,
		"sw_long": -73.57,
	}

	listings = search_listings(montreal_coords, "2026-10-03", "2026-10-31")
	logger.info(f"Found {len(listings)} listings.")

	if listings:
		first = listings[0]
		first_id = first.get("room_id")
		logger.info(f"Fetching details for the first listing: {first_id}")
		details = get_listing_details(first_id)
		if details:
			logger.info(f"Name: {details.get('title')}")
			logger.info(f"Reviews: {len(details.get('reviews', []))} found in details")
