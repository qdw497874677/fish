extends RefCounted


static func create_hit_effect(position: Vector2, defeated: bool, reward_value: int = 0) -> Dictionary:
	return {
		"pos": position,
		"life": 0.36 if defeated else 0.24,
		"max_life": 0.36 if defeated else 0.24,
		"defeated": defeated,
		"kind": "reward" if defeated else "hit",
		"text": "掉落 %d" % reward_value if defeated else "-1",
	}


static func create_loss_effect(position: Vector2, text: String, kind: String) -> Dictionary:
	return {
		"pos": position,
		"life": 0.5,
		"max_life": 0.5,
		"defeated": false,
		"kind": kind,
		"text": text,
	}


static func create_guard_effect(origin: Vector2, target: Vector2) -> Dictionary:
	return {
		"origin": origin,
		"target": target,
		"life": 0.22,
		"max_life": 0.22,
	}


static func create_jellyfish_effect(origin: Vector2, target: Vector2) -> Dictionary:
	return {
		"origin": origin,
		"target": target,
		"life": 0.34,
		"max_life": 0.34,
	}


static func update_hit_effect(effect: Dictionary, delta: float) -> void:
	effect["life"] = effect["life"] - delta
	effect["pos"] = effect["pos"] + Vector2(0, -42.0 * delta)


static func update_guard_effect(effect: Dictionary, delta: float) -> void:
	effect["life"] = effect["life"] - delta


static func update_jellyfish_effect(effect: Dictionary, delta: float) -> void:
	effect["life"] = effect["life"] - delta


static func should_remove_effect(effect: Dictionary) -> bool:
	return effect["life"] <= 0.0


static func shake_time_for_hit(defeated: bool) -> float:
	return 0.16 if defeated else 0.09


static func shake_strength_for_hit(defeated: bool) -> float:
	return 6.0 if defeated else 3.5
