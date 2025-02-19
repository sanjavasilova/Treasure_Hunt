extends Node3D

signal chest_collected

@export var score_value: int = 10
var collected: bool = false

@export var chest_texture: Texture = preload("res://assets/chest/Textures/chest_01_1001_BaseColor.png")

func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				var material = mesh.surface_get_material(0).duplicate()
				material.albedo_texture = chest_texture
				mesh.surface_set_material(0, material)

	var area = $Area3D
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not collected and body.is_in_group("player"):
		collected = true
		emit_signal("chest_collected")
		queue_free()
