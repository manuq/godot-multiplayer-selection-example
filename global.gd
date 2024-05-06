extends Node

var lobby_scene = preload("res://lobby.tscn")
var player_selection_scene = preload("res://player_selection.tscn")

# multiplayer:
var client_peer: ENetMultiplayerPeer
const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 1705
const MAX_CLIENTS = 3 # 4 players
signal connected_as_server
signal connected_as_client

# game:
enum PlayerKinds {Human, Bot}
enum Teams {TeamA, TeamB}
enum Players {TeamAP1, TeamBP1, TeamAP2, TeamBP2}
var player_by_peer = {} # maps peers to players
var _previous_player: Players
signal players_changed


func host_or_join_game():
	client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error != OK:
		print(error)
		join_existing_game(DEFAULT_IP)
		return
	print("hosting game")
	multiplayer.multiplayer_peer = client_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if _previous_player != null:
		player_by_peer[multiplayer.get_unique_id()] = _previous_player
	else:
		player_by_peer[multiplayer.get_unique_id()] = Players.TeamAP1
	players_changed.emit()
	connected_as_server.emit()


func join_existing_game(ip: String):
	print("joining game")
	client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(ip, DEFAULT_PORT)
	if error != OK:
		print(error)
		return
	multiplayer.multiplayer_peer = client_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


@rpc("authority", "call_remote", "reliable")
func _update_client_players(_player_by_peer):
	prints("update players in", multiplayer.get_unique_id())
	player_by_peer = _player_by_peer
	_previous_player = player_by_peer[multiplayer.get_unique_id()]
	players_changed.emit()


@rpc("any_peer", "call_local", "reliable")
func request_player_change(player):
	var sender_id = multiplayer.get_remote_sender_id()
	var current_player = player_by_peer[sender_id]
	if player in player_by_peer.values():
		return
	player_by_peer.erase(sender_id)
	player_by_peer[sender_id] = player
	players_changed.emit()
	_update_client_players.rpc(player_by_peer)
	prints("peer", sender_id, "now plays as", Players.keys()[player])


func _on_peer_connected(id):
	if multiplayer.is_server():
		prints("peer", id, "joined the game")
		var player: Players
		for p in Players.values():
			if p not in player_by_peer.values():
				player = p
				break
		player_by_peer[id] = player
		players_changed.emit()
		_update_client_players.rpc(player_by_peer)
	elif id != 1:
		prints(multiplayer.get_unique_id(), ": another player joined")


func _on_peer_disconnected(id):
	if multiplayer.is_server():
		prints("peer", id, "left the game")
		player_by_peer.erase(id)
		players_changed.emit()
		_update_client_players.rpc(player_by_peer)
	elif id != 1:
		prints(multiplayer.get_unique_id(), ": another player left")


func _on_connected_to_server():
	if _previous_player != null:
		request_player_change.rpc_id(1, _previous_player)
	connected_as_client.emit()


func _on_connection_failed():
	print("Connection failed, go back to lobby")
	go_to_lobby()


func _on_server_disconnected():
	print("Server disconnected, rejoin")
	multiplayer.multiplayer_peer = null
	player_by_peer = {}
	host_or_join_game()


func go_to_lobby():
	get_tree().change_scene_to_packed(lobby_scene)


func go_to_player_selection():
	get_tree().change_scene_to_packed(player_selection_scene)
