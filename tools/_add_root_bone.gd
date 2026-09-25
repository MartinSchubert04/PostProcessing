@tool
extends EditorScenePostImport

# Agrega un hueso Root como padre de Hips (Mixamo no lo trae).
# Corre después del retarget, así que el nombre coincide con los tracks %Skeleton3D:Root.
func _post_import(scene: Node) -> Object:
	for s: Skeleton3D in scene.find_children("*", "Skeleton3D", true, false):
		var hips := s.find_bone("Hips")
		if hips >= 0 and s.find_bone("Root") < 0:
			var root := s.add_bone("Root")
			s.set_bone_parent(hips, root)
			print("[add_root_bone] Root agregado en ", s.name, " (idx %d, Hips %d)" % [root, hips])
	return scene
