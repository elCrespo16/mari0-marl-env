-- load namespace
local socket = require("socket")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 55555))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
-- print a message informing what's up
local channel = love.thread.getChannel("pythonCommands")

-- loop forever waiting for clients
while 1 do
    -- wait for a connection from any client
    local client, con_status = server:accept()
    print(con_status)
    local close = false
    while not close do
        print("Connected with the client")
        -- receive the line
        local line, status = client:receive()
        print(line)
        -- if there was no error, send it back to the client
        if not status then
            if line == "close" then
                close = true
                client:close()
            else
                client:send("ack" .. "\n")
                channel:push(line)
            end
        else
            close = true
        end
        -- done with client, close the object
    end
    -- wait for a connection from any client

    -- local client = server:accept()
    -- -- make sure we don't block waiting for this client's line
    -- client:settimeout(10)
    -- -- receive the line
    -- local line, err = client:receive()
    -- -- if there was no error, send it back to the client
    -- if not err then
    --     print(line)
    --     client:send(line .. "\n")
    -- else
    --     print("cagaste")
    -- end
    -- -- done with client, close the object
    -- client:close()
end
