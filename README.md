# mari0 multi agent environment

This project provides an multi agent environment compatible with the [PettingZoo](https://www.pettingzoo.ml/) API implementing the ParallelEnv Class. The goal of this project is to provide an environment based on the opensource game [Mari0](https://stabyourself.net/mari0/). This README will be used to describe the basic setup instructions, architecture of the environment, etc. This projects is as well my final Computer Science Degree Project and therefore you will find the documentation of it inside the `tfg_documentation folder`.

## Enviroment characteristics

This environment enforces the cooperation between agents. The maximum ammount of players is 4. Also you can play along the IA, see steps section to see how to do it. The observartions of this environment are 600 * 800 RBG images. And the action space of this enviroment is an array of 6 positions as follows:

0. Move left (1) or right (2) or NOOP (0)

1. Jump (1) or NOOP (0)

2. Reload portals (1) or NOOP (0)

3. Use object on the left (1) or use object on the right (2) or NOOP (0)

4. NOOP (0) or shoot portal 1 with an angle (from 1 to 360)

5. NOOP (0) or shoot portal 2 with an angle (from 1 to 360)

The rewards of the envrionment goes as follows: -0.1 for every step, 1 everytime the player closest to the start advances, -10 everytime a player dies, -10 if a player goes out of the screen, 100 once you finish a level.


## Contributing

Feel free to fork this repository and improve upon it. If you come up with something you'd like to see incorporated, submit a pull request. Implementing all the technology inside Docker will be a great place to start. Also any other Mari0 mappack for cooperative play can be helpful.

## Setup

This project is only available in Linux.

### Pre-requisites:

- Installing LÖVE 11.2

- Having Python and all the requirements installed. See `requirements.txt` to install them.

- Install Xvfb

- Install x11vnc and some VNC client (Vinagre is recommended). This optional because the render function works fine, but I find it a better way to see what is happening inside the environment.

### Steps

- You have to set inside the `config.yml` file the position of the game folder.

- You have to take the `bowser` folder inside the `mappacks` and put the content inside the local [LÖVE folder](https://love2d.org/wiki/love.filesystem). Once you have all the requirements you just need to train your agents inside the environment. 

The env takes two arguments.

- The number of agents: It can be up to 4 if you don't want an human to play or 3 if you want a human to play.

- Human: Bool that tells if you want a human to play. See further steps to check more on this.

Once you start the program this is what you will see:

1. When you initialize the env class the console will display some messages about the virtual display used. Only take this into account if you want to use the VNC server, because you will need to tell the server which display is going to be used.

2. Next you will see some errors about the ALSA lib. Don't worry about them, they are just that the sound won't be played because of using a virtual display. Also you might see some errors about the shaders. Ignore them, they are errors from the base game.

3. If you want to use the x11vnc, then in another console run `x11vnc -display :[the display that you are using, probably 99]`

4. Next you will have to open your VNC client and connect to the server you have just set. This step is specific to the client you are using.

5. ## That's it!

### Steps to play AI and human.

If you want to play with the AI, you will have to set the human parameter of the environment to true. With this, the environment won't use a virtual display and the game display will be shown on your monitor. But you are not completely done.

1. You have calculate the position of the game display top left corner.

2. You will have to go to the file `config.yml` and set the `offset_x` and `offset_y` with the values you have obtained in the previous step.

3. If you want to configure the keybindings of the human player then you should start the game using `love [path to the game folder]` and configure it manually.

## Folder structure

If you want to contrubute to the project then you might want to know the folder structure.

- The final degree project documentation is inside the `tfg_documentation` folder. It's all written in Latex.

- All the contents from the enviroment are inside the `gym_env` folder.

- The structure of the game is the same as the original game. The modified files of this game are: `game.lua, main.lua and mario.lua`

### Examples

If you want to see examples of agents trained in this environment see the files `gym_env/agents_baseline.py and gym_env/agents_baseline_train.py`

MIT License