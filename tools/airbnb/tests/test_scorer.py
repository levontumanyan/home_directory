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
