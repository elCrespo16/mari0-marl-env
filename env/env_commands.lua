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
    print("Command Error: " .. self.name .. " " .. err_msg)
end

function Command:respond()
    return "NP"
end

-- MOVE COMMAND

local MoveCommand = Command:new()

function MoveCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Move"
    self.player = object["player"]
    self.direction = object["direction"]
    return o
end

function MoveCommand:run()
    if gamestate == "game" then
        local i = self.player
        if self.direction == "up" then
            objects["player"][i]:jump()
        elseif self.direction == "left"  then
            objects["player"][i]:leftkey()
        elseif self.direction == "right" then
            objects["player"][i]:rightkey()
        end
    else 
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self.respond()
end


-- RELOAD COMMAND

local ReloadCommand = Command:new()

function ReloadCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Reload"
    self.player = object["player"]
    return o
end

function ReloadCommand:run()
    if gamestate == "game" then
        local i = self.player
        objects["player"][i]:removeportals()
    else 
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self.respond()
end

-- USE COMMAND

local UseCommand = Command:new()

function UseCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Use"
    self.player = object["player"]
    return o
end

function UseCommand:run()
    if gamestate == "game" then
        local i = self.player
        objects["player"][i]:use()
    else 
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self.respond()
end

-- SHOOT PORTAL COMMAND

local PortalCommand = Command:new()

function PortalCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Portal"
    self.player = object["player"]
    self.portal = object["portal"]
    self.angle =  object["angle"]
    return o
end

function PortalCommand:run()
    if gamestate == "game" then
        local i = self.player
        objects["player"][i].pointingangle = self.angle
        shootportal(i, self.portal, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
    else 
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self.respond()
end


-- CHANGE CURSOR OWNER COMMAND

local CursorCommand = Command:new()

function CursorCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Cursor"
    self.player = object["player"]
    return o
end

function CursorCommand:run()
    if gamestate == "game" then
        mouseowner = self.player
    else 
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self.respond()
end

-- START GAME COMMAND

local StartGameCommand = Command:new()

function StartGameCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "MapSelection"
    self.map = object["map"]
    return o
end

function StartGameCommand:run()
    if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
        gamestate = "mappackmenu"
        mappacks()
        local found = false
        for i, name in ipairs(mappackname) do
            if name == self.map then
                print("Map found")
                if mappackbackground[i] then
                    loadbackground(mappackbackground[i] .. ".txt")
                else
                    loadbackground("1-1.txt")
                end
                mappack = mappacklist[i]
                gamestate = "menu"
			    saveconfig()
                found = true
            end
        end
        if not found then
            self:error("Map " .. self.map .. " not found")
        end
        players = 2
        selectworld()
    else
        self:error("Trying to select map in game state " .. gamestate)
    end
    return self:respond()
end

-- Reset Command

local ResetCommand = Command:new()


function ResetCommand:new(object)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = "Reset"
    return o
end

function ResetCommand:run()
    
end

-- Command Factory

local Factory = {}
Factory.registryTable = {}

function Factory:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local json = require "env.json"

function Factory:parse_command(command_str)
    local command_obj = json.decode(command_str)
    return Factory:instantiate(command_obj)
end

function Factory:instantiate(object)
    for k,v in pairs(self.registryTable) do
        if v.name == object["name"] then
            return v:new(object)
        end
    end
    return Command:new(object["name"])
end

function Factory:registry(command)
    print( "Registering class '" .. command.name .. "'" )
    table.insert( self.registryTable, command )
end


Factory:registry(StartGameCommand)
Factory:registry(MoveCommand)
Factory:registry(CursorCommand)
Factory:registry(PortalCommand)
Factory:registry(UseCommand)
Factory:registry(ReloadCommand)
Factory:registry(ResetCommand)

function parse_command(command_str)
    local f = Factory:new()
    return f:parse_command(command_str)
end