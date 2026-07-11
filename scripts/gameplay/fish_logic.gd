extends RefCounted


static func create_fish(spawn_position: Vector2, fish_type_id: String, fish_config: Dictionary, wander_target: Vector2) -> Dictionary:
	var max_hp: int = int(fish_config.get("max_hp", 1))
	return {
		"pos": spawn_position,
		"velocity": Vector2(randf_range(-70.0, 70.0), randf_range(-35.0, 35.0)),
		"wander_target": wander_target,
		"facing": 1.0 if randf() >= 0.5 else -1.0,
		"type": fish_type_id,
		"growth": 0.0,
		"hunger": 28.0,
		"coin_timer": fish_config["coin_interval"],
		"guard_cooldown": randf_range(0.4, 1.4),
		"hp": max_hp,
		"max_hp": max_hp,
		"alive": true,
	}


static func try_update_feeding(fish: Dictionary, fish_config: Dictionary, food_list: Array[Dictionary], target_food_index: int, fish_radius: float, food_radius: float, growth_bonus_multiplier: float = 1.0) -> bool:
	if target_food_index < 0:
		return false
	var target_food := food_list[target_food_index]
	var direction: Vector2 = (target_food["pos"] - fish["pos"]).normalized()
	fish["velocity"] = direction * 125.0
	if fish["pos"].distance_to(target_food["pos"]) < fish_radius + food_radius:
		fish["hunger"] = min(32.0, fish["hunger"] + 12.0 + target_food["nutrition"] * 4.0)
		fish["growth"] = min(1.0, fish["growth"] + 0.21 * target_food["nutrition"] * fish_config["growth_multiplier"] * growth_bonus_multiplier)
		food_list.remove_at(target_food_index)
	return true


static func guard_target_index(fish: Dictionary, fish_config: Dictionary, enemy_list: Array[Dictionary], nearest_enemy_index: int) -> int:
	if enemy_list.is_empty() or not bool(fish_config.get("guard", false)) or float(fish["growth"]) < 1.0:
		return -1
	return nearest_enemy_index


static func try_update_evasion(fish: Dictionary, fish_config: Dictionary, enemy_position: Vector2, evasion_radius: float, full_strength_radius: float, evasion_speed: float, minimum_blend: float, maximum_blend: float) -> bool:
	if bool(fish_config.get("guard", false)):
		return false
	var offset: Vector2 = fish["pos"] - enemy_position
	var distance := offset.length()
	if distance <= 0.01 or distance >= evasion_radius:
		return false
	var proximity: float = clamp(inverse_lerp(evasion_radius, full_strength_radius, distance), 0.0, 1.0)
	var blend: float = lerp(minimum_blend, maximum_blend, proximity)
	var escape_direction := offset / distance
	var current_velocity: Vector2 = fish["velocity"]
	var escape_velocity := escape_direction * evasion_speed
	if current_velocity.dot(escape_direction) < 0.0:
		blend = max(blend, 0.34)
	fish["velocity"] = current_velocity.lerp(escape_velocity, blend)
	return true


static func apply_enemy_damage(fish: Dictionary, damage: int) -> bool:
	var remaining_hp: int = max(0, int(fish.get("hp", 1)) - damage)
	fish["hp"] = remaining_hp
	return remaining_hp <= 0


static func update_guard_movement(fish: Dictionary, enemy_position: Vector2, attack_range: float) -> void:
	var to_enemy: Vector2 = enemy_position - fish["pos"]
	var distance := to_enemy.length()
	if distance <= 1.0:
		fish["velocity"] = fish["velocity"].lerp(Vector2.ZERO, 0.12)
		return
	var direction := to_enemy / distance
	var preferred_distance := attack_range * 0.72
	if distance > preferred_distance:
		fish["velocity"] = fish["velocity"].lerp(direction * 118.0, 0.18)
	else:
		var orbit_direction := Vector2(-direction.y, direction.x)
		fish["velocity"] = fish["velocity"].lerp(orbit_direction * 52.0, 0.1)
