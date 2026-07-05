extends RefCounted


static func tick_timer(value: float, delta: float) -> float:
	return max(0.0, value - delta)


static func tick_spawn_timer(value: float, delta: float) -> float:
	return value - delta


static func should_spawn_enemy(enemy_spawn_timer: float) -> bool:
	return enemy_spawn_timer <= 0.0


static func next_enemy_spawn_timer(base_timer: float) -> float:
	return randf_range(base_timer, base_timer + 7.0)


static func is_pre_invasion_warning_active(enemy_spawn_timer: float, warning_threshold: float, game_over: bool, level_cleared: bool) -> bool:
	return enemy_spawn_timer > 0.0 and enemy_spawn_timer <= warning_threshold and not game_over and not level_cleared


static func is_defense_pressure_active(enemy_count: int, game_over: bool, level_cleared: bool) -> bool:
	return enemy_count > 0 and not game_over and not level_cleared
