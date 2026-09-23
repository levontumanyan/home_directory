import pytest

from src.scorer import Scorer


@pytest.fixture
def benchmarks():
	return {
		"metrics": {
			"value": {
				"weight": 1.0,
				"function": "fixed_decay",
				"params": {"decay_rate": 0.1},
			}
		},
		"penalties": [
			{
				"name": "Low Rating",
				"condition": {"field": "review_score", "operator": "<", "value": 4.5},
				"multiplier": 0.5,
			}
		],
		"hard_filters": {"must_have_amenities": ["wifi"]},
	}


def test_scorer_passes_hard_filters(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1)
	listing = {
		"amenities": [
			{"title": "Internet", "values": [{"title": "Wifi", "available": True}]}
		],
		"price": {"amount": 100},
		"rating": {"guest_satisfaction": 4.8, "review_count": 20},
	}
	score, penalties = scorer.calculate_score(listing)
	assert score > 0
	assert len(penalties) == 0


def test_scorer_fails_hard_filters(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1)
	listing = {
		"amenities": [
			{"title": "Internet", "values": [{"title": "Wifi", "available": False}]}
		],
		"price": {"amount": 100},
		"rating": {"guest_satisfaction": 4.8, "review_count": 20},
	}
	score, penalties = scorer.calculate_score(listing)
	assert score == 0
	assert any("FAILED: Missing wifi" in p for p in penalties)


def test_scorer_applies_penalty(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1)
	listing = {
		"amenities": [
			{"title": "Internet", "values": [{"title": "Wifi", "available": True}]}
		],
		"price": {"amount": 100},
		"rating": {"guest_satisfaction": 4.0, "review_count": 20},
	}
	# Base score: 100 - (100 * 0.1) = 90
	# Penalty: 90 * 0.5 = 45
	score, penalties = scorer.calculate_score(listing)
	assert score == 45.0
	assert "Low Rating" in penalties


def test_scorer_fast_wifi_requirement_passed(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1, require_fast_wifi=True)
	listing = {
		"amenities": [
			{"title": "Internet", "values": [{"title": "Wifi", "available": True}]}
		],
		"highlights": [
			{"title": "Fast wifi", "subtitle": "At 100 Mbps, you can take video calls"}
		],
		"price": {"amount": 100},
		"rating": {"guest_satisfaction": 4.8, "review_count": 20},
	}
	score, penalties = scorer.calculate_score(listing)
	assert score > 0
	assert len(penalties) == 0


def test_scorer_fast_wifi_requirement_failed(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1, require_fast_wifi=True)
	listing = {
		"amenities": [
			{"title": "Internet", "values": [{"title": "Wifi", "available": True}]}
		],
		"highlights": [],
		"price": {"amount": 100},
		"rating": {"guest_satisfaction": 4.8, "review_count": 20},
	}
	score, penalties = scorer.calculate_score(listing)
	assert score == 0
	assert any("FAILED: Missing verified fast wifi" in p for p in penalties)


def test_scorer_keyword_analysis_with_reviews(benchmarks):
	scorer = Scorer(benchmarks, num_nights=1)
	listing = {
		"reviews": [
			{"comments": "Very clean and quiet, excellent fast wifi!"},
			{"comments": "Great place with a nice desk to work."},
		]
	}
	score = scorer._keyword_analysis(
		listing,
		{
			"positive_keywords": ["clean", "quiet", "fast wifi", "desk"],
			"negative_keywords": ["loud", "dirty"],
		},
	)
	assert score > 80.0


def test_extract_review_evidence(benchmarks):
	scorer = Scorer(benchmarks)
	listing = {
		"reviews": [
			{"comments": "The wifi was fast and zoom calls were flawless."},
			{"comments": "The street was very noisy and loud at night."},
			{
				"comments": "We cooked every day in the well-equipped kitchen with a great oven."
			},
		]
	}
	evidence = scorer.extract_review_evidence(listing)
	assert len(evidence["wifi_positive"]) == 1
	assert "wifi was fast" in evidence["wifi_positive"][0]
	assert len(evidence["noise_negative"]) == 1
	assert "noisy" in evidence["noise_negative"][0]
	assert len(evidence["kitchen_positive"]) == 1
	assert "cooked every day" in evidence["kitchen_positive"][0]
