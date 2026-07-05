extends RefCounted


static func create_hit_effect(position: Vector2, defeated: bool) -> Dictionary:
	return {
		"pos": position,
		"life": 0.36 if defeated else 0.24,
		"max_life": 0.36 if defeated else 0.24,
		"defeated": defeated,
		"text": "+%d" % (40 if defeated else 1) if defeated else "-1",
	}


static func create_guard_effect(origin: Vector2, target: Vector2) -> Dictionary:
	return {
		"origin": origin,
		"target": target,
		"life": 0.22,
		"max_life": 0.22,
	}


static func update_hit_effect(effect: Dictionary, delta: float) -> void:
	effect["life"] = effect["life"] - delta
	effect["pos"] = effect["pos"] + Vector2(0, -42.0 * delta)


static func update_guard_effect(effect: Dictionary, delta: float) -> void:
	effect["life"] = effect["life"] - delta


static func should_remove_effect(effect: Dictionary) -> bool:
	return effect["life"] <= 0.0


static func shake_time_for_hit(defeated: bool) -> float:
	return 0.16 if defeated else 0.09


static func shake_strength_for_hit(defeated: bool) -> float:
	return 6.0 if defeated else 3.5
