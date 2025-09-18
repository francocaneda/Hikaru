extends CharacterBody2D

@export var velocidad := 250.0
var jugador

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte

func _ready():
	# Referencia al jugador, verificando que exista.
	if get_parent().has_node("Jugador"):
		jugador = get_parent().get_node("Jugador")
	
	$Detector.body_entered.connect(_on_Detector_body_entered)
	
	# Conecta la senal del sonido para borrar el nodo cuando termine de sonar.
	if is_instance_valid(sonido_muerte):
		sonido_muerte.finished.connect(queue_free)

func _physics_process(delta):
	# Verifica que la referencia a jugador sea valida antes de usarla.
	if is_instance_valid(jugador):
		var direccion = (jugador.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		_actualizar_animacion(direccion)
	else:
		velocity = Vector2.ZERO

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

# Funcion que maneja el fin del juego
func go_to_game_over():
	# Limpia el HUD y el inventario del jugador.
	HUD.resetear_inventario()
	
	if is_instance_valid(jugador):
		jugador.inventario.clear()
	
	if MusicManager.is_playing():
		MusicManager.stop()
	
	get_tree().paused = true
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")

func morir():
	queue_free()
