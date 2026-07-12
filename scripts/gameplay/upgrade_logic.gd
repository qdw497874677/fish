extends RefCounted

const GameplayTuning := preload("res://scripts/data/gameplay_tuning.gd")


static func can_offer(upgrade_pool: Array, selected_ids: Array[String], selection_count: int, offer_count: int) -> bool:
	if selection_count >= GameplayTuning.TACTICAL_UPGRADE_MAX_SELECTIONS or offer_count >= GameplayTuning.TACTICAL_UPGRADE_MAX_OFFERS:
		return false
	return available_upgrades(upgrade_pool, selected_ids).size() >= GameplayTuning.TACTICAL_UPGRADE_OFFER_COUNT


static func available_upgrades(upgrade_pool: Array, selected_ids: Array[String]) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for upgrade_value in upgrade_pool:
		var upgrade: Dictionary = upgrade_value
		if not selected_ids.has(str(upgrade.get("id", ""))):
			available.append(upgrade)
	return available


static func create_offers(upgrade_pool: Array, selected_ids: Array[String]) -> Array[Dictionary]:
	var available := available_upgrades(upgrade_pool, selected_ids)
	available.shuffle()
	var offers: Array[Dictionary] = []
	for index in range(mini(GameplayTuning.TACTICAL_UPGRADE_OFFER_COUNT, available.size())):
		offers.append(available[index])
	return offers


static func can_select(upgrade_id: String, offers: Array[Dictionary], selected_ids: Array[String], selection_count: int) -> bool:
	if upgrade_id == "" or selection_count >= GameplayTuning.TACTICAL_UPGRADE_MAX_SELECTIONS or selected_ids.has(upgrade_id):
		return false
	for offer in offers:
		if str(offer.get("id", "")) == upgrade_id:
			return true
	return false


static func has_upgrade(selected_ids: Array[String], upgrade_id: String) -> bool:
	return selected_ids.has(upgrade_id)


static func growth_multiplier(selected_ids: Array[String]) -> float:
	return GameplayTuning.TACTICAL_GROWTH_MULTIPLIER if has_upgrade(selected_ids, "efficient_farming") else 1.0


static func coin_life_multiplier(selected_ids: Array[String]) -> float:
	return GameplayTuning.TACTICAL_COIN_LIFE_MULTIPLIER if has_upgrade(selected_ids, "coin_preservation") else 1.0


static func coin_magnet_multiplier(selected_ids: Array[String]) -> float:
	return GameplayTuning.TACTICAL_COIN_MAGNET_MULTIPLIER if has_upgrade(selected_ids, "coin_preservation") else 1.0


static func guard_range_multiplier(selected_ids: Array[String]) -> float:
	return GameplayTuning.TACTICAL_GUARD_RANGE_MULTIPLIER if has_upgrade(selected_ids, "guard_training") else 1.0


static func guard_cooldown_multiplier(selected_ids: Array[String]) -> float:
	return GameplayTuning.TACTICAL_GUARD_COOLDOWN_MULTIPLIER if has_upgrade(selected_ids, "guard_training") else 1.0


static func should_drop_emergency_food(selected_ids: Array[String]) -> bool:
	return has_upgrade(selected_ids, "emergency_supply")
