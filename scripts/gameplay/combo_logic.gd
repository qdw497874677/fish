extends RefCounted

const GameplayTuning := preload("res://scripts/data/gameplay_tuning.gd")


static func tick_combo_timer(current_timer: float, delta: float) -> float:
	return max(0.0, current_timer - delta)


static func should_reset_streak(current_timer: float) -> bool:
	return current_timer <= 0.0


static func advance_streak(current_streak: int) -> int:
	return min(GameplayTuning.COIN_COMBO_MAX, max(0, current_streak + 1))


static func streak_multiplier(streak: int) -> float:
	var bonus_steps: int = max(0, streak - 1)
	return min(GameplayTuning.COIN_COMBO_MAX_MULTIPLIER, 1.0 + float(bonus_steps) * GameplayTuning.COIN_COMBO_BONUS_PER_STEP)


static func collected_coin_value(base_value: int, streak: int) -> int:
	return max(base_value, int(round(float(base_value) * streak_multiplier(streak))))


static func bonus_percent(streak: int) -> int:
	return int(round((streak_multiplier(streak) - 1.0) * 100.0))
