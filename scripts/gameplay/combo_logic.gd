extends RefCounted


static func tick_combo_timer(current_timer: float, delta: float) -> float:
	return max(0.0, current_timer - delta)


static func should_reset_streak(current_timer: float) -> bool:
	return current_timer <= 0.0


static func advance_streak(current_streak: int, max_streak: int) -> int:
	return min(max_streak, max(0, current_streak + 1))


static func streak_multiplier(streak: int, bonus_per_step: float, max_multiplier: float) -> float:
	var bonus_steps: int = max(0, streak - 1)
	return min(max_multiplier, 1.0 + float(bonus_steps) * bonus_per_step)


static func collected_coin_value(base_value: int, streak: int, bonus_per_step: float, max_multiplier: float) -> int:
	return max(base_value, int(round(float(base_value) * streak_multiplier(streak, bonus_per_step, max_multiplier))))


static func bonus_percent(streak: int, bonus_per_step: float, max_multiplier: float) -> int:
	return int(round((streak_multiplier(streak, bonus_per_step, max_multiplier) - 1.0) * 100.0))
