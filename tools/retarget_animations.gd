@tool
extends EditorScript

# Carpeta con FBX (se escanea recursivamente) -> AnimationLibrary que se genera
const PACKS := {
	"res://assets/animations/great_sword/": "res://assets/animations/great_sword.res",
	"res://assets/animations/sword_shield/": "res://assets/animations/sword_shield.res",
}
# FBX ya configurado a mano (BoneMap + Rest Fixer + Reimport). Todos los packs
# tienen que usar el mismo esqueleto que este (UE4 Mannequin).
const REFERENCE := "res://assets/animations/sword_shield/Attack_01_Seq.FBX"
const LOOP_KEYWORDS := ["Idle", "Walk", "Jog", "Run", "Loop"]
# Transiciones (Idle_to_Walk, Walk_Stop...) no deben loopear aunque digan "Walk"
const NO_LOOP_KEYWORDS := ["_to_", "Stop", "Start", "Attack", "Turn"]

# Paso 1: copia el retarget y reimporta. Paso 2: arma las AnimationLibrary.
const STEP := 2

func _run() -> void:
	if STEP == 1:
		_apply_retarget()
	else:
		for folder in PACKS:
			_build_library(folder, PACKS[folder])

func _fbx_files(folder: String) -> PackedStringArray:
	var out := PackedStringArray()
	_collect_fbx(folder, out)
	return out

func _collect_fbx(dir: String, out: PackedStringArray) -> void:
	for file in DirAccess.get_files_at(dir):
		if file.to_lower().ends_with(".fbx"):
			out.append(dir.path_join(file))
	for sub in DirAccess.get_directories_at(dir):
		_collect_fbx(dir.path_join(sub), out)

func _apply_retarget() -> void:
	var ref := ConfigFile.new()
	if ref.load(REFERENCE + ".import") != OK:
		push_error("No encuentro " + REFERENCE + ".import")
		return
	var ref_subs: Dictionary = ref.get_value("params", "_subresources", {})
	if not ref_subs.has("nodes"):
		push_error("El FBX de referencia no tiene el retarget configurado")
		return

	var to_reimport := PackedStringArray()
	for folder in PACKS:
		for path in _fbx_files(folder):
			if path.to_lower() == REFERENCE.to_lower():
				continue
			var cfg := ConfigFile.new()
			if cfg.load(path + ".import") != OK:
				push_warning("Sin .import (¿no se importó todavía?): " + path)
				continue
			var subs: Dictionary = cfg.get_value("params", "_subresources", {})
			subs["nodes"] = ref_subs["nodes"].duplicate(true)
			cfg.set_value("params", "_subresources", subs)
			cfg.save(path + ".import")
			to_reimport.append(path)

	EditorInterface.get_resource_filesystem().reimport_files(to_reimport)
	print("Retarget aplicado a %d archivos" % to_reimport.size())

func _should_loop(anim_name: String) -> bool:
	if "_Loop" in anim_name:
		return true
	if NO_LOOP_KEYWORDS.any(func(k): return k in anim_name):
		return false
	return LOOP_KEYWORDS.any(func(k): return k in anim_name)

func _build_library(folder: String, library_out: String) -> void:
	var lib := AnimationLibrary.new()
	for path in _fbx_files(folder):
		var scene: PackedScene = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if scene == null:
			push_warning("No se pudo cargar: " + path)
			continue
		var root := scene.instantiate()
		var players := root.find_children("*", "AnimationPlayer", true, false)
		if players.is_empty():
			push_warning("Sin AnimationPlayer: " + path)
			root.free()
			continue
		var player: AnimationPlayer = players[0]
		var key := path.get_file().get_basename()
		for anim_name in player.get_animation_list():
			if anim_name == &"RESET":
				continue
			var anim: Animation = player.get_animation(anim_name).duplicate(true)
			if _should_loop(key):
				anim.loop_mode = Animation.LOOP_LINEAR
			var final_key := key
			var n := 2
			while lib.has_animation(final_key):
				final_key = "%s_%d" % [key, n]
				n += 1
			lib.add_animation(final_key, anim)
		root.free()

	var err := ResourceSaver.save(lib, library_out)
	if err != OK:
		push_error("No se pudo guardar %s (error %d)" % [library_out, err])
		return
	print("Librería guardada con %d animaciones en %s" % [lib.get_animation_list().size(), library_out])
