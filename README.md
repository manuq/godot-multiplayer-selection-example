# Godot multiplayer player selection example

The example shows the player selection UI for a multiplayer game, 2 teams of 2
players each. Players can choose to play in VS or in coop.

- The host is also a player.
- 1 to 4 real players, the rest are bots.
- If a client player disconnects, they are replaced by a bot.
- If the host player disconnects, another client becomes the host  and all
  players maintain their previous selection.

The example uses the high-level multiplayer in Godot based on ENet
([ENetMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html#class-enetmultiplayerpeer)).

## How to run the example
Import the project into Godot. Then go to **Debug -> Run multiple instances** and
select the amount of instances to run in parallel. Then run the project.
