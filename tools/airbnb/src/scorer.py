import logging

logger = logging.getLogger("airbnb")


class Scorer:
	def __init__(self, benchmarks, num_nights=1):
		self.benchmarks = benchmarks
		self.metrics = benchmarks.get("metrics", {})
		self.penalties = benchmarks.get("penalties", [])
		self.hard_filters = benchmarks.get("hard_filters", {})
		self.num_nights = num_nights

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
		if must_haves:
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
		# Placeholder for sentiment analysis
		# For now, return a neutral/high score if no reviews, or 80 as default
		return 80
