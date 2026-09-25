extends Node3D

# Compara la misma animación en: mannequin UE | referencia sin fix | Mixamo recién importado | player.tscn
# En vivo: ←/→ cambian de animación, Espacio pausa, R reinicia.
# Con --shots=<dir> guarda capturas y sale.

const UE_FBX := "res://assets/animations/AS_Idle_Seq.FBX"
const MIXAMO_FBX := "res://assets/models/paladin_north/Paladin J Nordstrom.fbx"
const PLAYER_SCENE := "res://scenes/player.tscn"
const LIBRARY := "res://assets/animations/great_sword.res"
# Verdad de referencia: FBX importado SIN fix silhouette, con su propia animación embebida
const GROUND_TRUTH := "res://test/_gt_idle_combat.FBX"
const GROUND_TRUTH_ANIM := "AS_Idle_Combat_Seq"

@export var animations: PackedStringArray = ["AS_Idle_Combat_Seq", "AS_Combo_Attack_01_02_Seq"]
@export var times: PackedFloat32Array = [0.0, 0.4]

var _players: Array[AnimationPlayer] = []
var _gt_player: AnimationPlayer
var _shots_dir := ""
var _anim_list: PackedStringArray = []
var _anim_index := 0
var _label: Label

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shots_dir = arg.trim_prefix("--shots=")

	var lib: AnimationLibrary = load(LIBRARY)
	if "--fresh-lib" in OS.get_cmdline_user_args():
		lib = _fresh_library()
	var live := _shots_dir == ""
	_add_character(load(UE_FBX).instantiate(), -1.5 if live else -2.25, lib)
	_add_character(load(MIXAMO_FBX).instantiate(), 0.0 if live else 0.75, lib)
	_add_character(_player_armature(), 1.5 if live else 2.25, lib)
	# La referencia solo sirve para las capturas (en vivo ya no coincide, el mannequin ahora usa fix)
	if _shots_dir != "" and ResourceLoader.exists(GROUND_TRUTH):
		# El FBX de animación no trae mesh: su animación va sobre el mannequin (mismo import, sin fix)
		var src: Node = load(GROUND_TRUTH).instantiate()
		var src_ap: AnimationPlayer = src.find_children("*", "AnimationPlayer", true, false)[0]
		var gt_lib := AnimationLibrary.new()
		gt_lib.add_animation("gt", src_ap.get_animation(src_ap.get_animation_list()[0]))
		src.free()
		var gt: Node3D = load(UE_FBX).instantiate()
		gt.position.x = -0.75
		add_child(gt)
		_gt_player = AnimationPlayer.new()
		gt.add_child(_gt_player)
		_gt_player.root_node = _gt_player.get_path_to(gt)
		_gt_player.add_animation_library("", gt_lib)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.1, 4.5)
	add_child(cam)
	cam.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, 30, 0)
	add_child(light)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.25, 0.27, 0.3)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.6, 0.6, 0.6)
	add_child(env)

	if _shots_dir != "":
		_take_shots.call_deferred()
	else:
		_anim_list = lib.get_animation_list()
		_anim_index = maxi(_anim_list.find(animations[0]), 0)
		var ui := CanvasLayer.new()
		add_child(ui)
		_label = Label.new()
		_label.position = Vector2(16, 16)
		_label.add_theme_font_size_override("font_size", 22)
		ui.add_child(_label)
		for ap in _players:
			ap.animation_finished.connect(_on_finished)
		_play_current()

func _unhandled_input(event: InputEvent) -> void:
	if _anim_list.is_empty() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_RIGHT:
			_anim_index = (_anim_index + 1) % _anim_list.size()
			_play_current()
		KEY_LEFT:
			_anim_index = (_anim_index - 1 + _anim_list.size()) % _anim_list.size()
			_play_current()
		KEY_SPACE:
			for ap in _players:
				if ap.is_playing():
					ap.pause()
				else:
					ap.play()
		KEY_R:
			_play_current()

func _play_current() -> void:
	var anim_name := _anim_list[_anim_index]
	for ap in _players:
		ap.stop()
		ap.play("gs/" + anim_name)
	_label.text = "%d/%d  %s
UE mannequin  |  Mixamo (FBX)  |  player.tscn
←/→ cambiar   Espacio pausa   R reiniciar" % [_anim_index + 1, _anim_list.size(), anim_name]

# Las animaciones que no loopean se repiten igual, sincronizadas
func _on_finished(_anim: StringName) -> void:
	_play_current()

# Arma la librería en memoria desde los FBX tal como están importados ahora
func _fresh_library() -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	for anim_name in animations:
		var found := _find_fbx("res://assets/animations/great_sword", anim_name + ".FBX")
		var n: Node = load(found).instantiate()
		var ap: AnimationPlayer = n.find_children("*", "AnimationPlayer", true, false)[0]
		lib.add_animation(anim_name, ap.get_animation(ap.get_animation_list()[0]).duplicate(true))
		n.free()
	return lib

func _find_fbx(dir: String, file: String) -> String:
	if FileAccess.file_exists(dir.path_join(file)):
		return dir.path_join(file)
	for sub in DirAccess.get_directories_at(dir):
		var r := _find_fbx(dir.path_join(sub), file)
		if r != "":
			return r
	return ""

func _player_armature() -> Node3D:
	# Solo el Armature del player (sin scripts ni state machine)
	var player := (load(PLAYER_SCENE) as PackedScene).instantiate()
	var armature: Node3D = player.get_node("Armature")
	player.remove_child(armature)
	player.free()
	for n in armature.find_children("*", "", true, false):
		if not is_instance_valid(n):
			continue
		if n is SkeletonModifier3D or n is BoneAttachment3D:
			n.get_parent().remove_child(n)
			n.free()
	var root := Node3D.new()
	root.add_child(armature)
	armature.owner = root
	var skel: Skeleton3D = armature.get_node("Skeleton3D")
	skel.owner = root
	skel.unique_name_in_owner = true
	for mi in skel.find_children("*", "MeshInstance3D", true, false):
		mi.owner = root
	return root

func _add_character(root: Node3D, x: float, lib: AnimationLibrary) -> void:
	root.position.x = x
	add_child(root)
	var ap := AnimationPlayer.new()
	root.add_child(ap)
	ap.root_node = ap.get_path_to(root)
	ap.add_animation_library("gs", lib)
	_players.append(ap)

func _pose(anim_name: String, t: float) -> void:
	if anim_name == "rest":
		if _gt_player:
			_gt_player.stop()
			for s in _gt_player.get_parent().find_children("*", "Skeleton3D", true, false):
				s.reset_bone_poses()
		for ap in _players:
			ap.stop()
			for s in ap.get_node(ap.root_node).find_children("*", "Skeleton3D", true, false):
				s.reset_bone_poses()
		return
	if _gt_player:
		if anim_name == GROUND_TRUTH_ANIM:
			_gt_player.play("gt")
			_gt_player.seek(t, true)
			_gt_player.pause()
		else:
			_gt_player.stop()
			for s in _gt_player.get_parent().find_children("*", "Skeleton3D", true, false):
				s.reset_bone_poses()
	for ap in _players:
		ap.play("gs/" + anim_name)
		ap.seek(t, true)
		ap.pause()

func _print_bones(anim_name: String, t: float) -> void:
	print("== %s t=%.1f" % [anim_name, t])
	var skels: Array[Skeleton3D] = []
	for ap in _players:
		skels.append(ap.get_node(ap.root_node).find_children("*", "Skeleton3D", true, false)[0])
	for b in ["Hips", "Spine", "UpperChest", "LeftUpperArm", "RightUpperArm", "RightHand", "LeftUpperLeg"]:
		var line := "  %-14s" % b
		var ref := skels[0].get_bone_global_pose(skels[0].find_bone(b))
		for s in skels:
			var g := s.get_bone_global_pose(s.find_bone(b))
			line += "  diff=%6.1f deg" % rad_to_deg(g.basis.get_rotation_quaternion().angle_to(ref.basis.get_rotation_quaternion()))
		print(line)
	var hips := skels[0].find_bone("Hips")
	print("  UE Hips pose rot=%s  rest rot=%s" % [skels[0].get_bone_pose_rotation(hips), skels[0].get_bone_rest(hips).basis.get_rotation_quaternion()])
	var mh := skels[1].find_bone("Hips")
	print("  MX Hips pose rot=%s  rest rot=%s" % [skels[1].get_bone_pose_rotation(mh), skels[1].get_bone_rest(mh).basis.get_rotation_quaternion()])

func _take_shots() -> void:
	DirAccess.make_dir_recursive_absolute(_shots_dir)
	for anim_name in ["rest"] + Array(animations):
		for t in ([0.0] if anim_name == "rest" else times):
			_pose(anim_name, t)
			for i in 4:
				await RenderingServer.frame_post_draw
			if anim_name != "rest":
				_print_bones(anim_name, t)
			var img := get_viewport().get_texture().get_image()
			img.save_png(_shots_dir.path_join("%s_%.1f.png" % [anim_name, t]))
	get_tree().quit()
