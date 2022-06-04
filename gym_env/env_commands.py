from ast import arg
import numpy as np

class Command:
    def __init__(self, name) -> None:
        self.name = name
        self.need_response = True

class GameCommand(Command):
    def __init__(self, name, player) -> None:
        super().__init__(name)
        self.player = player
        self.need_response = False

class StartGameCommand(Command):
    def __init__(self, map: str, players: int = 2) -> None:
        super().__init__("MapSelection")
        self.map = map
        self.players = players
        self.need_response = False


class ResetCommand(Command):
    def __init__(self) -> None:
        super().__init__("Reset")
        self.need_response = False

class CloseCommand(Command):
    def __init__(self) -> None:
        super().__init__("Close")
        self.need_response = False

class EvalGameOverCommand(Command):
    def __init__(self) -> None:
        super().__init__("EvalGameOver")

class GetRewardsCommand(Command):
    def __init__(self) -> None:
        super().__init__("GetRewards")

class MoveCommand(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Move", player=player)
        self.player = player
        if len(args) >= 0:
            if args[0] == 1:
                self.direction = "left"
            else:
                self.direction = "right"
        else:
            self.direction = "left"

class MoveUpCommand(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Move", player=player)
        self.player = player
        self.direction = "up"

class ReloadCommand(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Reload", player=player)
        self.player = player

class UseCommand(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Use", player=player)
        self.player = player
        if args[0] == 1:
            self.side = "left"
        else:
            self.side = "right"

class Portal1Command(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Portal", player=player)
        self.player = player
        self.portal = 1
        self.angle = args[0] if len(args) >= 0 else 0

class Portal2Command(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Portal", player=player)
        self.player = player
        self.portal = 2
        self.angle = args[0] if len(args) >= 0 else 0

class CursorCommand(GameCommand):
    def __init__(self, player: int, *args) -> None:
        super().__init__("Cursor", player=player)

class Factory:
    def __init__(self) -> None:
        self.register = {}
    
    def registry(self, position: int, command: Command) -> None:
        """
        Function to register an action to a certain position in the action array
        """
        self.register[position] = command

    def parse_action(self, player: int, action) -> list:
        """
        Function that recives an numpy array containing the action and the player and returns a list
        with the commands respective to the action
        """
        commands = []
        for i, arg in np.ndenumerate(action):
            if arg != 0:
               commands.append(self.register[i[0]](player, int(arg)).__dict__)
        return commands
    
    def parse_str(self, player: int, pos: int, val: int) -> list:
        """
        Debug function to return a command based on the position of it in the action array
        """
        return self.register[pos](player, int(val))







    