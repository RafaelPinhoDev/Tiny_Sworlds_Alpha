class_name Player
extends CharacterBody2D

#Para criar categorias do inspector
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export_category("Sword")
@export var sword_damage: int = 2
@export var death_prefab: PackedScene

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 10
@export var ritual_scene: PackedScene
@export_category("Movement")
@export var speed: float = 3


#Onready só usa a variavel depois que a função fica pronta
#variável parra a animação do jogador com o tipo AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#Váriavel para a movimentação do personagem
@onready var sprite: Sprite2D = $Sprite2D 
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
var input_vector: Vector2 = Vector2(0,0)
@onready var health_progess_bar: ProgressBar = $HealthProgessBar

#variável para o jogador correr, retornando falso
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false 
var attack_cooldown:  float = 0.0
var hit_box_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

#Sinal para informar quando o player coleta a carne
signal  meat_collected(value:int)

func _ready():
	GameManager.player = self

#Eessa função lida melhor com frames
func _process(delta: float) -> void:
	GameManager.player_position = position
	
	#Chama a função de leitura dos inputs
	read_input()
	#Chama o temporizador 
	update_attack_cooldown(delta)
	
	if Input.is_action_just_pressed("attack"): 
		attack()
	
	#Preocessar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	#Processar dano
	update_hitbox_detection(delta)
	
	#Chamar ritual
	update_ritual(delta)
	
	#Atualizar health bar
	#vai passar o valor maximo da vida pra barra de vida e o valor atual para o valor da barra
	health_progess_bar.max_value = max_health
	health_progess_bar.value = health
	
	
# Lida melhor com coisas fisicas do que o processs, que lida melhor com renderização
func _physics_process(delta):
	#Configura a velocidade ideal do personagem
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	#chama a função para o personagem se movimentar
	move_and_slide()

func read_input() -> void: 
	#Obter o imput vector (quais teclas o jogador irá usar)
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down" )
	
	#Apagar DeadZone do Controle
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	# Atualizar os is_running pra ver se o personagem estiver correndo
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

#atualizar temporizador de ataque 
func update_attack_cooldown(delta: float) -> void:
	if  is_attacking:
		attack_cooldown -= delta #0.6 - 0.016 = 0.584
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play ("idle")

#função para atacar	
func attack() -> void:
	if is_attacking:
		return
	#attack_side_1 ou attack_side_2
	#Tocar animação
	animation_player.play("attack_side_1")
	# Tempo da animação
	attack_cooldown = 0.6
	#Marcar Ataque
	is_attacking = true
	
	
#Funçãoo de danoos que o inimigo irá receber
func deal_damage_to_enemies() -> void: 
	#Pega todos os corrpos que estão dentro da área
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		#se o corpo pertenxer ao grupo dos inimigos
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			#Calcula a direção do enemy para o personagem
			var direction_to_enemy = (enemy.position - position).normalized()
			#Identifica para qual posição o jogador está olhando e define se o ataque irá causa dano no inimigo
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

#Tocar animação de correr ou ficar parado
func play_run_idle_animation() -> void:		
	if not is_attacking:
		if was_running != is_running:
			#verifica se o personagem esta parado ou correndo, 
			#se estiver parado, toca a animação dele correndo e vice versa
			if is_running: 
				animation_player.play("run")
			else: 
				animation_player.play("idle")
				
func update_ritual(delta: float) -> void:
	#Atualizar Temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	#Criar Ritual
	var ritual = ritual_scene.instantiate()
	#Adiciona o ritual para seguir o player
	ritual.damage_amount = ritual_damage
	add_child(ritual)

			
#Girar sprite (Posição do jogador)
func rotate_sprite() -> void:
	if input_vector.x > 0:
		#Desmarcar flip_h (ofset) do sprite2d 
		sprite.flip_h = false
	elif input_vector.x < 0:
		#Marcar flip_h do Sprite2d
		sprite.flip_h = true

func update_hitbox_detection(delta: float) -> void :
	#Temporizador 
	hit_box_cooldown -= delta
	#se for maior que zero, pula essa função
	if hit_box_cooldown > 0: return
	#Frequencia (2x por segundo)
	hit_box_cooldown = 0.5
	#Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
		#dano do inimigo
			var damage_amount = 1
			damage(damage_amount)
		
			
func damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	if health <= 0:
		die()
		
		
func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)	
	#Destruir coisas 
	queue_free()


#Função de regenerar vida

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Cura: " , amount)
	print("Vida:" , health , "/" , max_health )
	return health

	
