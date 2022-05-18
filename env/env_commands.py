from platform import platform


class Command:
    def __init__(self, name) -> None:
        self.name = name

class StartGameCommand(Command):
    def __init__(self, map: str) -> None:
        super().__init__("MapSelection")
        self.map = map

class MoveLeftCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Move")
        self.player = player
        self.direction = "left"

class MoveRightCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Move")
        self.player = player
        self.direction = "right"

class MoveUpCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Move")
        self.player = player
        self.direction = "up"

class ReloadCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Reload")
        self.player = player

class UseCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Use")
        self.player = player

class Portal1Command(Command):
    def __init__(self, player: int, angle: int) -> None:
        super().__init__("Portal")
        self.player = player
        self.portal = 1
        self.angle = angle

class Portal2Command(Command):
    def __init__(self, player: int, angle: int) -> None:
        super().__init__("Portal")
        self.player = player
        self.portal = 2
        self.angle = angle

class CursorCommand(Command):
    def __init__(self, player: int) -> None:
        super().__init__("Cursor")
        self.player = player

class ResetCommand(Command):
    def __init__(self) -> None:
        super().__init__("Reset")

class Factory:
    def __init__(self) -> None:
        self.register = {}
    
    def register(self, position: int, command: Command) -> None:
        self.register[position] = command

    def parse_action(self, player: int, action) -> str:
        commands = []
        for i, arg in enumerate(action):
            if arg != 0:
               commands.append(self.register[i](player))







    