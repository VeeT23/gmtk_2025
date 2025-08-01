extends Node2D

var randomd = RandomNumberGenerator.new()
@onready var player_list: ItemList = $CanvasLayer/CenterContainer/BoxContainer/PlayerList  # Add ItemList node to lobby scene
@onready var start_button: Button = $CanvasLayer/CenterContainer/BoxContainer/Start_Button  # Reference to start button

func _ready() -> void:
	# Update button visibility based on if we're the host
	if multiplayer.is_server():
		start_button.visible = true
		start_button.disabled = false
	else:
		start_button.visible = false
		start_button.disabled = true
	
	# Request initial player list
	if Network.connected_players.size() > 0:
		update_player_list(Network.connected_players)

func update_player_list(players: Dictionary):
	if not player_list:
		return
	
	player_list.clear()
	for id in players:
		var player_name = players[id]
		if id == 1:
			player_name += " (Host)"
		player_list.add_item(player_name)

func _on_start_button_pressed() -> void:
	# Only allow host to start the game
	if not multiplayer.is_server():
		return
	
	# Disable button to prevent multiple clicks
	start_button.disabled = true
	
	# Tell network to start the game for all clients
	Network.rpc("start_game")
