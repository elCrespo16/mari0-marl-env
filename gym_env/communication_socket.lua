-- load namespace
local socket = require("socket")
local json = require("gym_env.json")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 0))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
io.stderr:write(port .. "\n")
-- print a message informing what's up
local env_channel = love.thread.getChannel("pythonCommands")
local send_channel = love.thread.getChannel("loveRewards")

-- wait for a connection from any client
server:settimeout(90)
local client, con_status = server:accept()
if con_status then
    return
end

server:settimeout(90)
local client, con_status = server:accept()
if not con_status then
    local close = false
    while not close do
        -- receive the line
        client:settimeout(60)
        local line, status = client:receive()
        -- if there was no error, parse command put into channel
        if not status then
            line = json.decode(line)
            local response_recived = true
            -- Check if command needs response and if close command
            for i, val in pairs(line) do
                if val["need_response"] == true then
                    response_recived = false
                end
                if val["name"] == "Close" then
                    close = true
                end
            end
            env_channel:push(line)
            -- if command needs response, wait for response and send
            while not response_recived and not close do
                local response = send_channel:pop()
                if response then
                    if response ~= "NP" then -- Debug purposes
                        if response == "CLOSE" then
                            close = true
                        end
                        response = json.encode(response)
                        client:send(response .. "\n")
                    end

                    response_recived = true
                end
            end
        else
            -- print("Lua: Error " .. status)
            close = true
        end
        -- done with client, close the object
    end
    env_channel:push("CLOSE")
    client:close()
end
