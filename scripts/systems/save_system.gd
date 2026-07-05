extends RefCounted

const SAVE_SLOT_COUNT := 3
const SAVE_PATH := "user://aquarium_guard_save.json"


static func empty_slot() -> Dictionary:
	return {
		"exists": false,
		"name": "",
		"highest_unlocked_level": 1,
		"unlocked_cleaner_snail": false,
		"unlocked_bubble_seahorse": false,
		"unlocked_electric_jellyfish": false,
		"cleared_levels": [],
		"total_play_seconds": 0.0,
	}


static func normalize_slot(raw_slot: Dictionary, max_level: int) -> Dictionary:
	var normalized := empty_slot()
	normalized["exists"] = bool(raw_slot.get("exists", false))
	normalized["name"] = str(raw_slot.get("name", "未命名存档")).strip_edges()
	if normalized["name"] == "":
		normalized["name"] = "未命名存档"
	normalized["highest_unlocked_level"] = clamp(int(raw_slot.get("highest_unlocked_level", 1)), 1, max_level)
	normalized["unlocked_cleaner_snail"] = bool(raw_slot.get("unlocked_cleaner_snail", false))
	normalized["unlocked_bubble_seahorse"] = bool(raw_slot.get("unlocked_bubble_seahorse", false))
	normalized["unlocked_electric_jellyfish"] = bool(raw_slot.get("unlocked_electric_jellyfish", false))
	normalized["total_play_seconds"] = max(0.0, float(raw_slot.get("total_play_seconds", 0.0)))
	var levels: Array[int] = []
	var raw_levels: Variant = raw_slot.get("cleared_levels", [])
	if raw_levels is Array:
		for level_value in raw_levels:
			var level: int = clamp(int(level_value), 1, max_level)
			if not levels.has(level):
				levels.append(level)
	normalized["cleared_levels"] = levels
	return normalized


static func slot_cleared_count(slot: Dictionary) -> int:
	var slot_levels: Variant = slot.get("cleared_levels", [])
	if slot_levels is Array:
		return slot_levels.size()
	return 0


static func first_existing_slot_index(slots: Array[Dictionary]) -> int:
	for slot_index in range(slots.size()):
		if bool(slots[slot_index].get("exists", false)):
			return slot_index
	return -1


static func first_empty_slot_index(slots: Array[Dictionary]) -> int:
	for slot_index in range(slots.size()):
		if not bool(slots[slot_index].get("exists", false)):
			return slot_index
	return -1


static func default_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for slot_index in range(SAVE_SLOT_COUNT):
		slots.append(empty_slot())
	return slots


static func read_save_file() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("读取存档失败：%s" % SAVE_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if not parsed is Dictionary:
		push_warning("存档格式无效，已忽略。")
		return {}
	return parsed


static func write_save_file(active_slot_index: int, save_slots: Array[Dictionary]) -> void:
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("写入存档失败：%s" % SAVE_PATH)
		return
	var save_data := {
		"active_slot_index": active_slot_index,
		"slots": save_slots,
	}
	save_file.store_string(JSON.stringify(save_data))
