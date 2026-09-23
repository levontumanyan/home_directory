import csv
import json
import logging
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("airbnb")


def _format_date_human(date_str):
	"""Converts YYYY-MM-DD to MMM DD, YYYY (e.g., OCT 03, 2026)"""
	try:
		dt = datetime.strptime(date_str, "%Y-%m-%d")
		return dt.strftime("%b %d, %Y").upper()
	except (ValueError, TypeError):
		return date_str


def generate_csv_report(
	new_listings, output_path, location=None, check_in=None, check_out=None
):
	"""
	Generates or updates a CSV report from a list of scored listings.
	If the file exists, it merges new_listings with existing ones, removing duplicates by ID,
	re-sorting by score descending, and re-ranking.
	"""
	headers = [
		"Rank",
		"Score",
		"Listing ID",
		"Title",
		"Price",
		"Orig Price",
		"Discount %",
		"Currency",
		"Review Count",
		"Review Rating",
		"Total Amenities",
		"Penalties Applied",
		"Listing URL",
	]

	# 1. Load existing listings if file exists
	combined_listings = {}

	if Path(output_path).exists():
		try:
			with open(output_path, "r", newline="", encoding="utf-8") as f:
				reader = csv.DictReader(f)
				for row in reader:
					# Convert back to internal types for sorting
					listing_id = str(row["Listing ID"])
					combined_listings[listing_id] = {
						"score": float(row["Score"]),
						"id": listing_id,
						"name": row["Title"],
						"price": float(row["Price"]),
						"orig_price": float(row.get("Orig Price") or row["Price"]),
						"discount_pct": float(row.get("Discount %") or 0.0),
						"currency": row["Currency"],
						"review_count": int(row["Review Count"]),
						"rating": float(row["Review Rating"]),
						"amenities": int(row["Total Amenities"]),
						"penalties": [
							p.strip()
							for p in row["Penalties Applied"].split(",")
							if p.strip()
						],
						"url": row["Listing URL"],
					}
			logger.info(
				f"Loaded {len(combined_listings)} existing listings from {output_path}"
			)
		except Exception as e:
			logger.warning(
				f"Could not read existing report {output_path}: {e}. Starting fresh."
			)

	# 2. Merge new listings (overwrite if ID already exists)
	for listing in new_listings:
		listing_id = str(listing["id"])
		listing["id"] = listing_id
		combined_listings[listing_id] = listing

	# 3. Sort by score descending
	sorted_listings = sorted(
		combined_listings.values(), key=lambda x: x["score"], reverse=True
	)

	# 4. Re-assign ranks
	for i, listing in enumerate(sorted_listings):
		listing["rank"] = i + 1

	# 5. Write back to CSV
	try:
		with open(output_path, "w", newline="", encoding="utf-8") as f:
			writer = csv.DictWriter(f, fieldnames=headers)
			writer.writeheader()
			for listing in sorted_listings:
				writer.writerow(
					{
						"Rank": listing["rank"],
						"Score": listing["score"],
						"Listing ID": listing["id"],
						"Title": listing["name"],
						"Price": listing["price"],
						"Orig Price": listing.get("orig_price", listing["price"]),
						"Discount %": listing.get("discount_pct", 0.0),
						"Currency": listing["currency"],
						"Review Count": listing["review_count"],
						"Review Rating": listing["rating"],
						"Total Amenities": listing["amenities"],
						"Penalties Applied": ", ".join(listing["penalties"]),
						"Listing URL": f"https://www.airbnb.ca/rooms/{listing['id']}",
					}
				)
		logger.info(f"Report successfully saved/merged at {output_path}")
		return True
	except Exception as e:
		logger.error(f"Failed to save CSV report: {e}")
		return False


def generate_json_report(new_listings, output_path):
	"""
	Generates or updates a JSON report from a list of scored listings.
	If the file exists, it merges new_listings with existing ones, removing duplicates by ID,
	re-sorting by score descending, and re-ranking.
	"""
	combined_listings = {}

	if Path(output_path).exists():
		try:
			with open(output_path, "r", encoding="utf-8") as f:
				data = json.load(f)
				items = data if isinstance(data, list) else data.get("listings", [])
				for item in items:
					listing_id = str(item.get("id") or item.get("Listing ID") or "")
					if listing_id:
						penalties = (
							item.get("penalties") or item.get("Penalties Applied") or []
						)
						if isinstance(penalties, str):
							penalties = [
								p.strip() for p in penalties.split(",") if p.strip()
							]
						combined_listings[listing_id] = {
							"score": float(item.get("score", item.get("Score", 0))),
							"id": listing_id,
							"name": item.get("name", item.get("Title", "")),
							"price": float(item.get("price", item.get("Price", 0))),
							"currency": item.get("currency", item.get("Currency", "")),
							"review_count": int(
								item.get("review_count", item.get("Review Count", 0))
							),
							"rating": float(
								item.get("rating", item.get("Review Rating", 0))
							),
							"amenities": int(
								item.get("amenities", item.get("Total Amenities", 0))
							),
							"penalties": penalties,
							"url": item.get("url")
							or item.get("Listing URL")
							or f"https://www.airbnb.ca/rooms/{listing_id}",
						}
			logger.info(
				f"Loaded {len(combined_listings)} existing listings from {output_path}"
			)
		except Exception as e:
			logger.warning(
				f"Could not read existing JSON report {output_path}: {e}. Starting fresh."
			)

	# Merge new listings
	for listing in new_listings:
		listing_id = str(listing["id"])
		listing_copy = dict(listing)
		listing_copy["id"] = listing_id
		if not listing_copy.get("url"):
			listing_copy["url"] = f"https://www.airbnb.ca/rooms/{listing_id}"
		combined_listings[listing_id] = listing_copy

	# Sort by score descending
	sorted_listings = sorted(
		combined_listings.values(), key=lambda x: x["score"], reverse=True
	)

	# Re-assign ranks
	for i, listing in enumerate(sorted_listings):
		listing["rank"] = i + 1

	try:
		with open(output_path, "w", encoding="utf-8") as f:
			json.dump(sorted_listings, f, indent=2)
		logger.info(f"JSON report successfully saved/merged at {output_path}")
		return True
	except Exception as e:
		logger.error(f"Failed to save JSON report: {e}")
		return False


def generate_survey_report(survey_results, csv_path=None, json_path=None):
	"""
	Saves survey comparison results to CSV and/or JSON.
	"""
	if json_path:
		try:
			with open(json_path, "w", encoding="utf-8") as f:
				json.dump(survey_results, f, indent=2)
			logger.info(f"Survey JSON report saved at {json_path}")
		except Exception as e:
			logger.error(f"Failed to save survey JSON report: {e}")

	if csv_path and survey_results:
		headers = [
			"City",
			"Total Found",
			"Qualified (4.7+)",
			"Median Total",
			"Nightly Median",
			"P25 Total",
			"P75 Total",
			"Avg Monthly Discount %",
			"Discounted Listings %",
			"Currency",
		]
		try:
			with open(csv_path, "w", newline="", encoding="utf-8") as f:
				writer = csv.DictWriter(f, fieldnames=headers)
				writer.writeheader()
				for r in survey_results:
					writer.writerow(
						{
							"City": r.get("city"),
							"Total Found": r.get("total_found"),
							"Qualified (4.7+)": r.get("qualified_count"),
							"Median Total": r.get("median_total"),
							"Nightly Median": r.get("nightly_median"),
							"P25 Total": r.get("p25_total"),
							"P75 Total": r.get("p75_total"),
							"Avg Monthly Discount %": r.get("avg_monthly_discount_pct"),
							"Discounted Listings %": r.get("pct_with_discount"),
							"Currency": r.get("currency"),
						}
					)
			logger.info(f"Survey CSV report saved at {csv_path}")
		except Exception as e:
			logger.error(f"Failed to save survey CSV report: {e}")
