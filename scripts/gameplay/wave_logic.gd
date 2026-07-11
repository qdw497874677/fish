extends RefCounted


static func tick_timer(value: float, delta: float) -> float:
	return max(0.0, value - delta)


static func tick_spawn_timer(value: float, delta: float) -> float:
	return value - delta


static func should_spawn_enemy(enemy_spawn_timer: float) -> bool:
	return enemy_spawn_timer <= 0.0


static func tick_safe_reward_timer(value: float, delta: float) -> float:
	return max(0.0, value - delta)


static func should_start_safe_reward(enemy_count_after_defeat: int, game_over: bool, level_cleared: bool) -> bool:
	return enemy_count_after_defeat == 0 and not game_over and not level_cleared


static func is_safe_reward_active(safe_reward_timer: float, game_over: bool, level_cleared: bool) -> bool:
	return safe_reward_timer > 0.0 and not game_over and not level_cleared


static func next_enemy_spawn_timer(base_timer: float) -> float:
	var minimum_timer: float = max(3.0, base_timer * 0.9)
	var maximum_timer: float = max(minimum_timer + 0.8, base_timer + 4.5)
	return randf_range(minimum_timer, maximum_timer)


static func has_enemy_capacity(level_config: Dictionary, active_enemy_count: int) -> bool:
	var active_cap: int = max(1, int(level_config.get("enemy_active_cap", 1)))
	return active_enemy_count < active_cap


static func enemy_count_for_wave(level_config: Dictionary, active_enemy_count: int) -> int:
	var minimum_count: int = max(1, int(level_config.get("enemy_wave_min", 1)))
	var maximum_count: int = max(minimum_count, int(level_config.get("enemy_wave_max", minimum_count)))
	var active_cap: int = max(1, int(level_config.get("enemy_active_cap", maximum_count)))
	var available_slots: int = max(0, active_cap - active_enemy_count)
	return min(randi_range(minimum_count, maximum_count), available_slots)


static func is_pre_invasion_warning_active(enemy_spawn_timer: float, warning_threshold: float, game_over: bool, level_cleared: bool) -> bool:
	return enemy_spawn_timer > 0.0 and enemy_spawn_timer <= warning_threshold and not game_over and not level_cleared


static func is_defense_pressure_active(enemy_count: int, game_over: bool, level_cleared: bool) -> bool:
	return enemy_count > 0 and not game_over and not level_cleared
