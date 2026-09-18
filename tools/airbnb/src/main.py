import argparse
import json
import logging
import re
import sys
from datetime import datetime

from config import REPORTS_DIR
from fetcher import get_listing_details, search_listings
from reporter import generate_csv_report, generate_json_report
from scorer import Scorer
from utils import (
	check_internet_connection,
	get_city_coords,
	load_amenity_map,
	load_benchmarks,
	load_search_filters,
	setup_logging,
)


def main():
	# Initial parser to check for verbose and json flags before logging setup
	temp_parser = argparse.ArgumentParser(add_help=False)
	temp_parser.add_argument("-v", "--verbose", action="store_true")
	temp_parser.add_argument("--json", action="store_true")
	temp_args, _ = temp_parser.parse_known_args()

	# Configure logging (redirect to stderr when --json is used so stdout stays clean)
	log_level = logging.INFO if temp_args.verbose else logging.WARNING
	log_stream = sys.stderr if temp_args.json else sys.stdout
	logger = setup_logging(level=log_level, stream=log_stream)

	if not check_internet_connection():
		logger.error("No internet connection detected. Please check your network.")
		if temp_args.json:
			print(json.dumps({"error": "No internet connection detected."}))
		sys.exit(1)

	# Load search defaults
	filters = load_search_filters()
	defaults = filters.get("defaults", {})

	# Load amenity mappings (flattened)
	amenity_map = load_amenity_map()

	# Load benchmarks to get "must_haves"
	benchmarks = load_benchmarks()
	must_haves = benchmarks.get("hard_filters", {}).get("must_have_amenities", [])

	# Map human-readable must_haves to pyairbnb IDs
	search_amenities = []
	for amenity in must_haves:
		if amenity in amenity_map:
			search_amenities.append(amenity_map[amenity])

	parser = argparse.ArgumentParser(
		description="Airbnb Benchmarker - Search and Score Listings"
	)
	parser.add_argument(
		"--location",
		type=str,
		default="Montreal",
		help="Location name (e.g., 'Montreal', 'New York')",
	)
	parser.add_argument("--min_price", type=int, default=100, help="Minimum price")
	parser.add_argument("--max_price", type=int, default=250, help="Maximum price")
	parser.add_argument(
		"--check_in",
		type=str,
		default=defaults.get("check_in"),
		help="Check-in date (YYYY-MM-DD)",
	)
	parser.add_argument(
		"--check_out",
		type=str,
		default=defaults.get("check_out"),
		help="Check-out date (YYYY-MM-DD)",
	)
	parser.add_argument(
		"--place_type",
		type=str,
		default=defaults.get("place_type"),
		help="Type of place (e.g., 'Entire home/apt', 'Private room')",
	)
	parser.add_argument(
		"--currency",
		type=str,
		default=defaults.get("currency", "USD"),
		help="Currency code (e.g., 'USD', 'MXN')",
	)
	parser.add_argument(
		"--limit",
		type=int,
		default=None,
		help="Limit the number of listings to fetch and score",
	)
	parser.add_argument(
		"-v", "--verbose", action="store_true", help="Increase output verbosity"
	)
	parser.add_argument(
		"--json",
		action="store_true",
		help="Output JSON summary directly to stdout and suppress human-readable logging",
	)

	args = parser.parse_args()

	coords = get_city_coords(args.location)
	if not coords:
		logger.error(f"Failed to find coordinates for location: {args.location}")
		if args.json:
			print(
				json.dumps(
					{
						"error": f"Failed to find coordinates for location: {args.location}"
					}
				)
			)
		sys.exit(1)

	logger.debug(f"Search Coords: {coords}")
	logger.debug(f"Search Amenities (IDs): {search_amenities}")

	logger.info(
		f"--- Searching in {args.location} (Price: {args.min_price}-{args.max_price}) ---"
	)

	listings = search_listings(
		coords,
		check_in=args.check_in,
		check_out=args.check_out,
		min_price=args.min_price,
		max_price=args.max_price,
		currency=args.currency,
		place_type=args.place_type,
		amenities=search_amenities if search_amenities else None,
		language=defaults.get("language", "en"),
		free_cancellation=defaults.get("free_cancellation", False),
		zoom_value=defaults.get("zoom_value", 15),
	)

	logger.info(f"Found {len(listings)} total listings.")

	if args.limit:
		logger.info(f"Limiting to first {args.limit} listings.")
		listings = listings[: args.limit]

	# Store price data from search results since details API might not return it
	listing_prices = {}
	for listing in listings:
		room_id = str(listing.get("room_id"))
		price_info = listing.get("price", {})
		# Use unit amount if total is 0 or missing
		amount = price_info.get("unit", {}).get("amount", 0)
		if amount == 0:
			amount = price_info.get("total", {}).get("amount", 0)

		currency = price_info.get("unit", {}).get("curency_symbol", args.currency)
		# Clean up currency symbol if it contains extra characters (e.g., "$ USD")
		if " " in currency:
			currency = currency.split(" ")[-1].strip()
		if "\xa0" in currency:
			currency = currency.split("\xa0")[-1].strip()

		listing_prices[room_id] = {"amount": amount, "currency": currency}

	# Calculate number of nights for daily price calculation
	d1 = datetime.strptime(args.check_in, "%Y-%m-%d")
	d2 = datetime.strptime(args.check_out, "%Y-%m-%d")
	num_nights = max(1, (d2 - d1).days)

	# Fetch details for ALL listings (cached after first run)
	# Note: A 1s delay is applied in get_listing_details to avoid rate limiting
	scorer = Scorer(benchmarks, num_nights=num_nights)
	scored_results = []

	from tqdm import tqdm

	if not args.json:
		print(f"\nProcessing {len(listings)} listings...")
	for listing in tqdm(
		listings, desc="Scoring Listings", unit="listing", disable=args.json
	):
		listing_id = listing.get("room_id")
		name = listing.get("name")
		logger.info(f"\n--- [{listing_id}] {name} ---")

		details = get_listing_details(
			listing_id,
			currency=args.currency,
		)
		if details:
			raw_title = details.get("title")
			listing_name = (
				raw_title if isinstance(raw_title, str) and raw_title.strip() else name
			)
			logger.info(f"  Title: {listing_name}")
			rating = details.get("rating", {})
			logger.info(
				f"  Rating: {rating.get('guest_satisfaction')} ({rating.get('review_count')} reviews)"
			)

			total_amenities = sum(
				len(cat.get("values", [])) for cat in details.get("amenities", [])
			)
			logger.info(f"  Amenities: {total_amenities} found")

			# Add captured price back into details for the scorer
			lp = listing_prices.get(
				str(listing_id), {"amount": 0, "currency": args.currency}
			)
			details["price"] = lp

			# Calculate and display score
			score, penalties = scorer.calculate_score(details)
			logger.info(f"  FINAL SCORE: {score}/100")
			if penalties:
				logger.info(f"  Penalties: {', '.join(penalties)}")

			scored_results.append(
				{
					"score": score,
					"id": listing_id,
					"name": listing_name,
					"price": lp["amount"],
					"currency": lp["currency"],
					"review_count": rating.get("review_count", 0),
					"rating": rating.get("guest_satisfaction", 0),
					"amenities": total_amenities,
					"penalties": penalties,
				}
			)
		else:
			logger.error(f"  Failed to fetch details for {listing_id}")

	# Sort results and generate report
	if scored_results:
		# Replace spaces, commas, and slashes with dashes and collapse multiples
		safe_location = re.sub(r"[ ,/]+", "-", args.location).strip("-")

		# Include stay dates in the filenames
		csv_filename = f"{safe_location}-{args.check_in}-{args.check_out}.csv"
		json_filename = f"{safe_location}-{args.check_in}-{args.check_out}.json"
		csv_path = REPORTS_DIR / csv_filename
		json_path = REPORTS_DIR / json_filename

		csv_ok = generate_csv_report(scored_results, csv_path)
		json_ok = generate_json_report(scored_results, json_path)

		if not (csv_ok and json_ok):
			logger.error("Failed to generate one or more report files.")
			if args.json:
				print(json.dumps({"error": "Failed to generate report files."}))
			sys.exit(1)

		if args.json:
			# Load merged listings from the saved JSON report
			try:
				with open(json_path, "r", encoding="utf-8") as f:
					final_listings = json.load(f)
			except Exception:
				final_listings = scored_results

			output_payload = {
				"location": args.location,
				"check_in": args.check_in,
				"check_out": args.check_out,
				"csv_report": str(csv_path),
				"json_report": str(json_path),
				"total_listings": len(final_listings),
				"listings": final_listings,
			}
			print(json.dumps(output_payload, indent=2))
		else:
			from reporter import _format_date_human

			print(f"\nLocation: {args.location}")
			human_range = f"{_format_date_human(args.check_in)} to {_format_date_human(args.check_out)}"
			print(f"Date Range: {human_range}")
			print("\n--- SUCCESS: Reports saved/merged ---")
			print(f"CSV:  {csv_path}")
			print(f"JSON: {json_path}")
	else:
		if args.json:
			print(
				json.dumps(
					{
						"location": args.location,
						"check_in": args.check_in,
						"check_out": args.check_out,
						"total_listings": 0,
						"listings": [],
					},
					indent=2,
				)
			)
		else:
			print("\n--- NO RESULTS: No listings were successfully scored ---")


if __name__ == "__main__":
	main()
