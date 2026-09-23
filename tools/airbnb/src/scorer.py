import logging
import re

logger = logging.getLogger("airbnb")


class Scorer:
	def __init__(self, benchmarks, num_nights=1, require_fast_wifi=False):
		self.benchmarks = benchmarks
		self.metrics = benchmarks.get("metrics", {})
		self.penalties = benchmarks.get("penalties", [])
		self.hard_filters = benchmarks.get("hard_filters", {})
		self.num_nights = num_nights
		self.require_fast_wifi = require_fast_wifi

	def calculate_score(self, listing_details):
		"""
		Calculates the final score for a listing based on benchmarks.
		"""
		# 1. Check Hard Filters
		passed, failed_filters = self._passes_hard_filters(listing_details)
		if not passed:
			logger.info(
				f"  Listing failed hard filters: {', '.join(failed_filters)}. Score: 0"
			)
			# Return the failed filters as penalties so they show up in the report
			return 0, [f"FAILED: {f}" for f in failed_filters]

		# 2. Calculate Base Score
		base_score = 0
		for name, config in self.metrics.items():
			func_name = config.get("function")
			weight = config.get("weight", 0)
			params = config.get("params", {})

			metric_score = self._run_metric_function(func_name, listing_details, params)
			weighted_score = metric_score * weight
			base_score += weighted_score
			logger.debug(
				f"  Metric {name}: {metric_score:.2f} (weight {weight}) -> {weighted_score:.2f}"
			)

		# 3. Apply Penalties
		final_score = base_score
		applied_penalties = []
		for penalty in self.penalties:
			if self._check_condition(penalty.get("condition"), listing_details):
				multiplier = penalty.get("multiplier", 1.0)
				final_score *= multiplier
				applied_penalties.append(penalty.get("name"))
				logger.info(f"  Penalty Applied: {penalty.get('name')} ({multiplier}x)")

		return round(final_score, 2), applied_penalties

	def _passes_hard_filters(self, listing):
		# Check must_have_amenities
		must_haves = self.hard_filters.get("must_have_amenities", [])
		failed_filters = []
		if must_haves and listing.get("amenities"):
			# Flatten all amenities from categories
			available_amenities = []
			for category in listing.get("amenities", []):
				for item in category.get("values", []):
					if item.get("available") is not False:
						# The API uses "title" for the amenity name
						name = item.get("title") or item.get("name") or ""
						available_amenities.append(name.lower())

			for must_have in must_haves:
				if not any(must_have.lower() in am for am in available_amenities):
					logger.info(f"  Missing must-have amenity: {must_have}")
					failed_filters.append(f"Missing {must_have}")

		if failed_filters:
			return False, failed_filters

		# Check Fast Wi-Fi requirement if flag is set
		if self.require_fast_wifi:
			wifi_info = self.detect_fast_wifi(listing)
			if not wifi_info.get("verified"):
				logger.info(f"  Missing verified fast wifi: {wifi_info.get('details')}")
				failed_filters.append("Missing verified fast wifi")

		if failed_filters:
			return False, failed_filters
		return True, []

	def _run_metric_function(self, func_name, listing, params):
		if func_name == "percentage_match":
			return self._percentage_match(listing, params)
		elif func_name == "fixed_decay":
			return self._fixed_decay(listing, params)
		elif func_name == "keyword_analysis":
			return self._keyword_analysis(listing, params)
		return 0

	def _check_condition(self, condition, listing):
		if not condition:
			return False

		field = condition.get("field")
		operator = condition.get("operator")
		target_value = condition.get("value")

		actual_value = 0
		if field == "review_count":
			try:
				actual_value = int(listing.get("rating", {}).get("review_count", 0))
			except (ValueError, TypeError):
				actual_value = 0
		elif field == "review_score":
			# guest_satisfaction is often 0-100 or 0-5 depending on API
			try:
				actual_value = float(
					listing.get("rating", {}).get("guest_satisfaction", 0)
				)
				# If guest_satisfaction is e.g. 96 (percent), and target is 4.5 (stars), normalize
				if actual_value > 5 and target_value <= 5:
					actual_value = actual_value / 20.0
			except (ValueError, TypeError):
				actual_value = 0

		if operator == "<":
			return actual_value < target_value
		elif operator == ">":
			return actual_value > target_value
		elif operator == "==":
			return actual_value == target_value

		return False

	# --- Metric Functions (Stubs) ---

	def _percentage_match(self, listing, params):
		# Simple logic: check bonus amenities
		bonus = params.get("bonus_amenities", [])
		if not bonus:
			return 100

		available_amenities = []
		for category in listing.get("amenities", []):
			for item in category.get("values", []):
				if item.get("available") is not False:
					name = item.get("title") or item.get("name") or ""
					available_amenities.append(name.lower())

		matches = 0
		for b in bonus:
			if any(b.lower() in am for am in available_amenities):
				matches += 1

		return (matches / len(bonus)) * 100

	def _fixed_decay(self, listing, params):
		total_price = listing.get("price", {}).get("amount", 0)
		daily_price = (
			total_price / self.num_nights if self.num_nights > 0 else total_price
		)
		decay_rate = params.get("decay_rate", 0.2)

		# 100 points minus the daily price multiplied by the decay rate. Minimum 0.
		score = 100.0 - (daily_price * decay_rate)
		return max(0.0, min(100.0, score))

	def _keyword_analysis(self, listing, params):
		reviews = listing.get("reviews", [])
		if not reviews:
			return 80.0

		pos_keywords = [
			k.lower()
			for k in params.get(
				"positive_keywords",
				[
					"clean",
					"quiet",
					"comfortable",
					"fast wifi",
					"tranquilo",
					"escritorio",
					"fibra",
					"zoom",
				],
			)
		]
		neg_keywords = [
			k.lower()
			for k in params.get(
				"negative_keywords",
				[
					"loud",
					"dirty",
					"smell",
					"slow wifi",
					"ruido",
					"sin mesa",
					"no hot water",
					"cold water",
				],
			)
		]

		pos_count = 0
		neg_count = 0

		for r in reviews:
			comment = (r.get("comments") or "").lower()
			for p in pos_keywords:
				if p in comment:
					pos_count += 1
			for n in neg_keywords:
				if n in comment:
					neg_count += 1

		# Score baseline at 80, boosted by positive keywords, penalized by negative
		score = 80.0 + min(20.0, pos_count * 2.0) - (neg_count * 5.0)
		return max(0.0, min(100.0, score))

	def detect_fast_wifi(self, listing):
		"""
		Detects verified fast wifi across 4 layers:
		1. Highlights (Official Airbnb badge e.g. 'Fast wifi' / 50+ Mbps)
		2. Amenities (Wifi subtitle with verified Mbps)
		3. Description (Host fiber/speed declaration)
		4. Reviews (Guest speed tests or remote work confirmations)
		"""
		# 1. Highlights
		for h in listing.get("highlights", []):
			htitle = (h.get("title") or "").lower()
			hsub = (h.get("subtitle") or "").lower()
			if (
				"fast wifi" in htitle
				or "wifi rápido" in htitle
				or "wifi veloz" in htitle
				or "mbps" in hsub
				or "mbps" in htitle
			):
				speed_match = re.search(
					r"(\d+)\s*mbps", f"{htitle} {hsub}", re.IGNORECASE
				)
				speed = int(speed_match.group(1)) if speed_match else 50
				return {
					"verified": True,
					"source": "badge",
					"speed_mbps": speed,
					"details": h.get("title") or "Airbnb Fast Wifi Badge",
				}

		# 2. Amenities
		for cat in listing.get("amenities", []):
			for val in cat.get("values", []):
				vtitle = (val.get("title") or "").lower()
				vsub = (val.get("subtitle") or "").lower()
				if ("wifi" in vtitle or "internet" in vtitle) and "mbps" in vsub:
					speed_match = re.search(r"(\d+)\s*mbps", vsub, re.IGNORECASE)
					speed = int(speed_match.group(1)) if speed_match else None
					return {
						"verified": True,
						"source": "amenity",
						"speed_mbps": speed,
						"details": f"Amenity verified: {val.get('subtitle')}",
					}

		# 3. Description
		desc = listing.get("description", "") or ""
		speed_match = re.search(r"(\d+)\s*(?:mbps|megas|mb)\b", desc, re.IGNORECASE)
		fiber_match = re.search(
			r"\b(fibra\s*[\w\s]{0,15}|fiber\s*[\w\s]{0,15})\b", desc, re.IGNORECASE
		)
		if speed_match or fiber_match:
			speed = int(speed_match.group(1)) if speed_match else None
			detail = speed_match.group(0) if speed_match else fiber_match.group(0)
			return {
				"verified": True,
				"source": "description",
				"speed_mbps": speed,
				"details": f"Host description: {detail}",
			}

		# 4. Reviews
		for r in listing.get("reviews", []):
			com = (r.get("comments") or "").lower()
			speed_match = re.search(r"(\d+)\s*mbps", com)
			if speed_match:
				speed = int(speed_match.group(1))
				return {
					"verified": True,
					"source": "review",
					"speed_mbps": speed,
					"details": f"Guest review speed test: {speed} Mbps",
				}
			if (
				"fibra" in com
				or ("zoom" in com and "sin problema" in com)
				or "flawless wifi" in com
			):
				return {
					"verified": True,
					"source": "review",
					"speed_mbps": None,
					"details": "Guest review verified remote work / fiber",
				}

		return {
			"verified": False,
			"source": "none",
			"speed_mbps": None,
			"details": "Standard wifi",
		}
