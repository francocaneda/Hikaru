extends CharacterBody2D

@export var velocidad := 350.0
@export var tiempo_cambio_direccion := 1.0 

var jugador: Node2D
var direccion_aleatoria: Vector2
var temporizador: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: Area2D = $Detector

func _ready():
	# Obtener referencia al jugador.
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	detector.body_entered.connect(_on_Detector_body_entered)
	detector.body_exited.connect(_on_Detector_body_exited)
	
	add_to_group("Enemigo")
	
	_cambiar_direccion()

func _physics_process(delta):
	temporizador += delta
	if temporizador >= tiempo_cambio_direccion:
		_cambiar_direccion()
		temporizador = 0.0

	velocity = direccion_aleatoria * velocidad
	move_and_slide()

	_actualizar_animacion(velocity)

func _cambiar_direccion():
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)
	direccion_aleatoria = Vector2(x, y).normalized()

func _actualizar_animacion(direccion: Vector2):
	if direccion == Vector2.ZERO:
		anim.stop()
		return

	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			anim.play("enemigoderecha")
		else:
			anim.play("enemigoizquierda")
	else:
		if direccion.y > 0:
			anim.play("enemigoabajo")
		else:
			anim.play("enemigoarriba")

func _on_Detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		
		call_deferred("go_to_game_over")
		print("¡Game Over!")

@warning_ignore("unused_parameter")
func _on_Detector_body_exited(body: Node2D) -> void:
	pass


func go_to_game_over():
	# Limpiamos el inventario visual del HUD
	HUD.resetear_inventario()
	
	# Limpiamos el inventario interno del jugador (si existe)
	if is_instance_valid(jugador):
		jugador.inventario.clear()
		
	get_tree().paused = true
	MusicManager.stop()
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")
		
func morir():
	queue_free()
