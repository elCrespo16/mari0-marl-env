--Meta class
local Command = {}

--Derived class method new

function Command:new(name)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = name or ""
    return o
end

function Command:run()
    print("Running command not implemented in" .. self.name)
end

function Command:error(err_msg)
    err_msg = err_msg or ""
    print("Command Error " .. self.name .. " " .. err_msg)
end

local MoveCommand = Command:new()

function MoveCommand:new(player, direction)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Move"
    self.player = player
    self.direction = direction
    return o
end

function MoveCommand:run()
    print("Moving player" .. self.player)
end

local StartGameCommand = Command:new()

function StartGameCommand:new(map)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "MapSelection"
    self.map = map
    return o
end

function StartGameCommand:run()
    if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
        menu_keypressed("down", unicode)
    else
        print(gamestate)
        self:error(self.map)
    end
end

function parse_command(command_str)
    print("Moving down")
    local c = StartGameCommand:new()
    c:run()
end