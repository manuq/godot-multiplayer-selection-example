extends Control

@onready var _buttons_by_player = {
	Global.Players.TeamAP1: %TeamAP1Button,
	Global.Players.TeamBP1: %TeamBP1Button,
	Global.Players.TeamAP2: %TeamAP2Button,
	Global.Players.TeamBP2: %TeamBP2Button,
}


func _update_players():
	var is_server = multiplayer.is_server()
	%StartButton.visible = is_server
	%ServerLabel.visible = is_server
	%ClientLabel.visible = not is_server

	for player in _buttons_by_player.keys():
		if player not in Global.player_by_peer.values():
			var button: Button = _buttons_by_player[player]
			button.text = "BOT"
			button.disabled = false

	for peer in Global.player_by_peer.keys():
		var player = Global.player_by_peer[peer]
		var button: Button = _buttons_by_player[player]
		if peer == multiplayer.get_unique_id():
			button.text = "ME\n" + str(peer)
		else:
			button.text = "PLAYER\n" + str(peer)
		button.disabled = true


func _ready():
	_update_players()
	Global.players_changed.connect(_update_players)


func _on_team_ap_1_button_pressed():
	Global.request_player_change.rpc_id(1, Global.Players.TeamAP1)


func _on_team_bp_1_button_pressed():
	Global.request_player_change.rpc_id(1, Global.Players.TeamBP1)


func _on_team_ap_2_button_pressed():
	Global.request_player_change.rpc_id(1, Global.Players.TeamAP2)


func _on_team_bp_2_button_pressed():
	Global.request_player_change.rpc_id(1, Global.Players.TeamBP2)


func _on_start_button_pressed():
	print("start! the game itself is not implemented")
