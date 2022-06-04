--Meta class
Command = {name = ""}

--Derived class method new

function Command:new(name)
    -- Base Command
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = name or ""
    return o
end

function Command:run()
end

function Command:error(err_msg)
    err_msg = err_msg or ""
    print("Command Error: " .. self.name .. " " .. err_msg)
end

function Command:respond()
    return "NP"
end

function Command:execute()
    self:run()
    return self:respond()
end

GameCommand = Command:new("GameCommand")

function GameCommand:new(name)
    local o = Command:new(name)
    setmetatable(o, self)
    self.__index = self
    o.response = false
    return o
end

function GameCommand:run()
end

function GameCommand:execute()
    self:run()
end

-- MOVE COMMAND

MoveCommand = GameCommand:new("Move")

function MoveCommand:new(object)
    local o = GameCommand:new("Move")
    setmetatable(o, self)
    self.__index = self
    o.name = "Move"
    o.player = object["player"]
    o.direction = object["direction"]
    return o
end

function MoveCommand:run()
    if gamestate == "game" or gamestate == "levelscreen" then
        local i = self.player
        if self.direction == "up" and not objects["player"][i].jumping then
            objects["player"][i]:jump()
        else 
            marioKeys[i][self.direction] = 30
        end
    else 
        self:error("Trying to move in game state " .. gamestate)
    end
end


-- RELOAD COMMAND

ReloadCommand = GameCommand:new("Reload")

function ReloadCommand:new(object)
    local o = GameCommand:new("Reload")
    setmetatable(o, self)
    self.__index = self
    o.name = "Reload"
    o.player = object["player"]
    return o
end

function ReloadCommand:run()
    if gamestate == "game" or gamestate == "levelscreen" then
        local i = self.player
        objects["player"][i]:removeportals()
    else 
        self:error("Trying to reload in game state " .. gamestate)
    end
end

-- USE COMMAND

UseCommand = GameCommand:new("Use")

function UseCommand:new(object)
    local o = GameCommand:new("Use")
    setmetatable(o, self)
    self.__index = self
    o.name = "Use"
    o.side = object["side"]
    o.player = object["player"]
    return o
end

function UseCommand:run()
    if gamestate == "game" or gamestate == "levelscreen" then
        local i = self.player
        if self.side == "left" then
            objects["player"][i].pointingangle = math.rad (90)
        else
            objects["player"][i].pointingangle = math.rad (-90)
        end
        objects["player"][i]:use()
    else 
        self:error("Trying to use in game state " .. gamestate)
    end
end

-- SHOOT PORTAL COMMAND

PortalCommand = GameCommand:new("Portal")

function PortalCommand:new(object)
    local o = GameCommand:new("Portal")
    setmetatable(o, self)
    self.__index = self
    o.name = "Portal"
    o.player = object["player"]
    o.portal = object["portal"]
    o.angle =  object["angle"]
    return o
end


function PortalCommand:run()
    if gamestate == "game" or gamestate == "levelscreen" then
        local i = self.player
        if self.angle > 180 then
            self.angle = self.angle - 360
        end
        objects["player"][i].pointingangle = math.rad (self.angle)
        shootportal(i, self.portal, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
    else 
        self:error("Trying to shoot portal in game state " .. gamestate)
    end
end


-- CHANGE CURSOR OWNER COMMAND

CursorCommand = GameCommand:new("Cursor")

function CursorCommand:new(object)
    local o = GameCommand:new("Cursor")
    self.__index = self
    setmetatable(o, self)
    o.name = "Cursor"
    o.player = object["player"]
    return o
end

function CursorCommand:run()
    if gamestate == "game" or gamestate == "levelscreen" then
        mouseowner = self.player
    else 
        self:error("Trying to change curson in game state " .. gamestate)
    end
end

-- START GAME COMMAND

StartGameCommand = GameCommand:new("MapSelection")

function StartGameCommand:new(object)
    local o = GameCommand:new("MapSelection")
    setmetatable(o, self)
    self.__index = self
    o.name = "MapSelection"
    o.map = object["map"]
    o.players = object["players"]
    return o
end

function StartGameCommand:run()
    if gamestate == "intro" or gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
        mappacks()
        local found = false
        for i, name in ipairs(mappackname) do
            if name == self.map then
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
        players = self.players
        for i = 1, players do
            marioDeads[i] = 0
        end
    else
        self.error("Trying to select map in game state " .. gamestate)
    end
end

-- Reset Command

ResetCommand = GameCommand:new("Reset")


function ResetCommand:new(object)
    local o = GameCommand:new("Reset")
    setmetatable(o, self)
    o.name = "Reset"
    self.__index = self
    return o
end

function ResetCommand:run()
    for i = 1, players do
		marioDeads[i] = 0
	end
    last_distance = false
    if gamestate == "levelscreen" or gamestate == "game" then
        pausemenuopen = true
        love.audio.stop()
        pausemenuopen = false
        menuprompt = false
        menu_load()
        selectworld()
    elseif gamestate == "menu" then
        selectworld()
    else 
        self:error("Trying to reset in game state " .. gamestate)
    end
end

--Close command

CloseCommand = GameCommand:new("Close")

function CloseCommand:new(object)
    local o = GameCommand:new("Close")
    setmetatable(o, self)
    o.name = "Close"
    self.__index = self
    return o
end

function CloseCommand:run()
    love.audio.stop()
    love.event.quit()
end

-- Eval end game command

EvalGameOverCommand = Command:new("EvalGameOver")

function EvalGameOverCommand:new()
    local o = Command:new("EvalGameOver")
    setmetatable(o, self)
    o.name = "EvalGameOver"
    self.__index = self
    return o
end

function EvalGameOverCommand:respond()
    if gamestate == "mappackfinished" or gamestate == "gameover" then
        return 1
    end
    return 0
end

-- Rewards Command

GetRewardsCommand = Command:new("GetRewards")

function GetRewardsCommand:new()
    local o = Command:new("GetRewards")
    setmetatable(o, self)
    o.name = "GetRewards"
    self.__index = self
    return o
end


CHECKPOINT_REWARD = 100
END_REWARD = 1000
DIE_REWARD = -10
PLAYER_OUT_OF_CAMERA_REWARD = -5

function GetRewardsCommand:respond()
    -- Rewards are assigned as follows: 
    -- If the mari0 that's closest to the starting point moves farther from it +1
    -- if one of the marios goes out of the camera, reward -10
    -- If one of the mario's dies, -10
    -- If reach the end of the level, +100
    -- If reach the end of the mappack +1000
    if not last_distance then
        last_distance = 0
    end
    local reward = 0
    local aux = 0
    local actual_min_mario_dist = distance_to_end
    
    for i = 1, players do
        reward = reward + DIE_REWARD * marioDeads[i]
		marioDeads[i] = 0
        aux = objects["player"][i].x
        if aux < actual_min_mario_dist then
            actual_min_mario_dist = aux
        end
        if aux < xscroll then
            reward = reward + PLAYER_OUT_OF_CAMERA_REWARD
        end
	end
    if not last_distance then
        last_distance = actual_min_mario_dist
    end
    if last_distance < actual_min_mario_dist then
        reward = reward + math.ceil(actual_min_mario_dist - last_distance)
        last_distance = actual_min_mario_dist
    end
    if nextLevelReward then
        if gamestate == "mappackfinished" then
            reward = reward + END_REWARD
        end
        reward = reward + CHECKPOINT_REWARD
        nextLevelReward = false
    end
    return reward
end


-- Command Factory

Factory = {}
Factory.registryTable = {}

function Factory:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Factory:parse_command(command_obj)
    -- Funtion to parse a list of objects into commands
    local commands = {}
    for i, command in pairs(command_obj) do
        table.insert(commands, self:instantiate(command))
    end
    return commands
end

function Factory:instantiate(object)
    -- Funtion to instantiate a command using his name
    for k,v in pairs(self.registryTable) do
        if v.name == object["name"] then
            return v:new(object)
        end
    end
    return Command:new("Error " .. object["name"])
end

function Factory:registry(com)
    -- Function to register a command as usable
    table.insert( self.registryTable, com )
end

function register_all_commands()
    factory:registry(StartGameCommand)
    factory:registry(MoveCommand)
    factory:registry(CursorCommand)
    factory:registry(PortalCommand)
    factory:registry(UseCommand)
    factory:registry(ReloadCommand)
    factory:registry(ResetCommand)
    factory:registry(EvalGameOverCommand)
    factory:registry(GetRewardsCommand)
    factory:registry(CloseCommand)
end

function parse_command(command_str)
    local f = Factory:new()
    return f:parse_command(command_str)
end