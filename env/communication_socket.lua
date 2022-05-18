-- load namespace
local socket = require("socket")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 55555))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
-- print a message informing what's up
local env_channel = love.thread.getChannel("pythonCommands")
local send_channel = love.thread.getChannel("loveRewards")


-- wait for a connection from any client
server:settimeout(40)
local client, con_status = server:accept()
print(con_status)
if not con_status then
    print("Connected with the client")
    local close = false
    while not close do
        -- receive the line
        local line, status = client:receive()
        -- if there was no error, send it back to the client
        if not status then
            if line == "close" then
                close = true
            else
                env_channel:push(line)
                local response_recived = false
                while not response_recived do
                    local response = send_channel:pop() or default_channel_pop
                    if response ~= default_channel_pop then
                        if response ~= "NP" then
                            client:send(response .. "\n")
                        end 
                        response_recived = true
                    end
                end
            end
        else
            close = true
        end
        -- done with client, close the object
    end
    client:close()
end
