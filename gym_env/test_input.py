from mario_env import mari0_env

# File to test the actions of the environment by hand

e = mari0_env()
e.reset()
f = e.command_factory
while True:
    print("player : ")
    player = input()
    print("pos : ")
    pos = input()
    print("val: ")
    val = input()
    try:
        player = int(player)
        pos = int(pos)
        val = int(val)
    except:
        break
    e._send_command(f.parse_str(player, pos, val))


e.close()