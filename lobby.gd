extends Control


func _ready():
	Global.connected_as_server.connect(_on_connected)
	Global.connected_as_client.connect(_on_connected)


func _on_start_button_pressed():
	Global.host_or_join_game()


func _on_connected():
	Global.go_to_player_selection()
