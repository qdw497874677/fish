extends RefCounted


static func create_enemy(spawn_position: Vector2, level_config: Dictionary) -> Dictionary:
	var roll := randf()
	var is_thief: bool = roll < float(level_config["thief_enemy_chance"])
	var is_tank: bool = not is_thief and randf() < float(level_config["tank_enemy_chance"])
	var enemy_type := "thief" if is_thief else ("tank" if is_tank else "normal")
	return {
		"pos": spawn_position,
		"hp": 4 if is_thief else (9 if is_tank else 5),
		"max_hp": 4 if is_thief else (9 if is_tank else 5),
		"speed": 96.0 if is_thief else (52.0 if is_tank else 78.0),
		"attack_cooldown": 0.0,
		"tank": is_tank,
		"type": enemy_type,
	}


static func update_chase_fish(enemy: Dictionary, target_fish: Dictionary, delta: float) -> void:
	var direction: Vector2 = (target_fish["pos"] - enemy["pos"]).normalized()
	enemy["pos"] = enemy["pos"] + direction * enemy["speed"] * delta
	enemy["attack_cooldown"] = max(0.0, enemy["attack_cooldown"] - delta)


static func update_drift_without_fish(enemy: Dictionary, delta: float) -> void:
	enemy["pos"] = enemy["pos"] + Vector2(0, 20.0 * delta)


static func can_attack_fish(enemy: Dictionary, target_fish: Dictionary, enemy_radius: float, fish_radius: float) -> bool:
	return enemy["pos"].distance_to(target_fish["pos"]) < enemy_radius + fish_radius and enemy["attack_cooldown"] <= 0.0


static func reset_attack_cooldown(enemy: Dictionary) -> void:
	enemy["attack_cooldown"] = 1.2


static func update_chase_coin(enemy: Dictionary, target_coin: Dictionary, delta: float) -> void:
	var direction: Vector2 = (target_coin["pos"] - enemy["pos"]).normalized()
	enemy["pos"] = enemy["pos"] + direction * enemy["speed"] * delta


static func can_steal_coin(enemy: Dictionary, target_coin: Dictionary, enemy_radius: float, coin_radius: float) -> bool:
	return enemy["pos"].distance_to(target_coin["pos"]) < enemy_radius + coin_radius
