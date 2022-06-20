
import functools
import os
import subprocess
import time
import numpy as np
import mss
import yaml
from queue import Empty, Full, Queue

from xvfbwrapper import Xvfb
from threading import Thread
from mario_env_communication import controller
from env_commands import CursorCommand, Factory, GetRewardsCommand, GetRewardsCommand, ResetCommand, CloseCommand, MoveCommand, \
    MoveUpCommand, ReloadCommand, UseCommand, Portal1Command, Portal2Command, EvalGameOverCommand, StartGameCommand
from gym.spaces import MultiDiscrete, Box
from pettingzoo import ParallelEnv
from gym.utils import EzPickle


def env(players: int = 2, human: bool = False):
    """
    The env function often wraps the environment in wrappers by default.
    You can find full documentation for these methods
    elsewhere in the developer documentation.
    """
    return mari0_env(players, human_player=human)


SCR_W = 800  # Screen width
SCR_H = 600  # Screnn height
SCR_D = 3  # Screnn channels, RGB

DEFAULT_STEP_REWARD = -0.1


class mari0_env(ParallelEnv, EzPickle):
    metadata = {"render_modes": ["human"], "name": "mari0"}

    class EnvStatus:
        """
        Class representing the status of the env
        """

        def __init__(self) -> None:
            self.vdisplay_active = False
            self.mss_active = False
            self.game_active = False
            self.communication = False

    def __init__(self, players: int = 2, human_player: bool = False):
        """
        This function defines the number of agents, load the config file, starts the communication thread, starts the game,
        starts the virtual frame buffer and starts the mss module. If the paramenter human_player is True, then the game will
        be inicialized on the main window and the player 1 will be the controlled by the human player.
        """
        EzPickle.__init__(self, players, human_player)
        self.display = 0
        self.initial_display = os.environ["DISPLAY"]
        self.xvfb_process = None
        self.game_proc = None
        self.controller_channel = None
        self.reward_channel = None
        self.communication_thread = None
        self.status = self.EnvStatus()
        self.human_player = human_player
        self.mss_grabber = None
        self._screen = None                     # Pygame screen if render is used
        self.pixel_array = None                 # Last screenshot of the environment
        self.players = players
        self.command_factory = Factory()        # Factory of commands
        if human_player:
            assert players < 4
            self.possible_agents = [
                f"player_{r}" for r in range(1, players + 1)]
        else:
            assert players <= 4
            self.possible_agents = [f"player_{r}" for r in range(0, players)]
        self.load_config()
        self._registerFactory()
        self._start_game()
        port = self.get_communication_port()
        self._start_controller(port)
        self.first_reset = True

    def load_config(self) -> None:
        """
        This method loads the configuration of the environment into self.config
        """
        with open("config.yml") as fb:
            self.config = yaml.safe_load(fb)
        assert "love_game" in self.config
        if self.human_player:
            assert "offset_x" in self.config
            assert "offset_y" in self.config

    def get_communication_port(self) -> int:
        """
        This method reads from the sterr of mari0 expecting the port of the communication socket
        """
        port_found = False
        attemps = 1
        while not port_found and attemps < 5:
            try:
                std = self.game_proc.stderr.readline()
                port = int(std)
                port_found = True
            except:
                attemps += 1
        if attemps == 5:
            self.close()
            raise Exception("Couldn't get communication port")
        return port

    def _start_controller(self, port: int) -> None:
        """
        This method initializes the communication thread between the game and the environment, returning the channels to send and recieve data
        """
        self.controller_channel = Queue(-1)
        self.reward_channel = Queue(-1)
        self.communication_thread = Thread(target=controller, args=(
            self.controller_channel, self.reward_channel, port))
        self.communication_thread.start()
        self.status.communication = True

    def _start_game(self) -> None:
        """
        This method initializes an Xvfb service and the game using the virtual display from Xvfb and the module mss using the vitual display
        """
        game_dir = self.config["love_game"]
        env = "env"
        if self.human_player:
            env = "dev"
        else:
            self.display = self.start_xvfb()
        cmd = ["love", game_dir, env]
        self.game_proc = subprocess.Popen(
            cmd, env=os.environ.copy(), shell=False, stderr=subprocess.PIPE,)
        time.sleep(3)
        if not self.game_proc.poll():  # Poll the process to see if it exited early
            self.status.game_active = True
        else:
            self.close()
            raise Exception("Game couldn't open")

    def start_xvfb(self) -> int:
        """
        This method initializes the xvfb process and returns the number of display used for it
        """
        self.xvfb_process = Xvfb(
            width=SCR_W, height=SCR_H, colordepth=SCR_D * 8)
        self.xvfb_process.start()
        self.status.vdisplay_active = True
        print(f'Using DISPLAY {self.xvfb_process.new_display}')
        return self.xvfb_process.new_display

    @functools.lru_cache(maxsize=None)
    def observation_space(self, agent=None):
        # Gym spaces are defined and documented here: https://gym.openai.com/docs/#spaces
        """
        This function returns the obsevation space of the environment, in this case its an RBG 800*600 image
        """
        return Box(low=0, high=255, shape=(SCR_H, SCR_W, SCR_D), dtype=np.uint8)

    @functools.lru_cache(maxsize=None)
    def action_space(self, agent=None):
        """
        This function returns the action space for each agent. In this case ecery agent has the same action space.
        Particularly, the possible actions in order are Go left or Go Right, Jump, Reload Portals, Use the object next to the player,
        shoot portal 1 in an angle, and shoot portal 2 in an angle. For all the actions 0 means NOOP. For left, right, jump and reload
        there's only the possibility of 1, that means execute this action. For the use action, 1 means use pointing to the left, and 2 
        means pointing to the right. For the portal actions, the value means the angle, and 360 equals to 0 angle. Note that the angles do
        not correspond with normal axis angles. That means that shooting with angle 0 will not shoot to the right of the player, instead
        it will shoot upwards.
        """
        return MultiDiscrete([
            3,  # 0 = NOOP, 1 = LEFT, 2 = RIGHT
            2,  # 0 = NOOP, 1 = Jump
            2,  # 0 = NOOP, 1 = Reload
            3,  # 0 = NOOP, 1 = Use left, 2 = Use right
            361,  # Portal1 0 = NOOP, Otherwise = Angle of shoot
            361  # Portal2 0 = NOOP, Otherwise = Angle of shoot
        ])

    def _registerFactory(self):
        """
        This function registers every command with it's corresponding position on the action space array
        """
        self.command_factory.registry(0, MoveCommand)
        self.command_factory.registry(1, MoveUpCommand)
        self.command_factory.registry(2, ReloadCommand)
        self.command_factory.registry(3, UseCommand)
        self.command_factory.registry(4, Portal1Command)
        self.command_factory.registry(5, Portal2Command)

    def render(self, mode="human"):
        """
        Renders the environment. In human mode, it renders an pygame window and renders the last screenshot taken.
        ADVISE: THIS FUNCTION WORKS CORRECTLY BUT I RECOMMEND CREATING A X11VNC PROCESS TO THE DISPLAY USED AND 
        USE AN VNC VIEWER TO SEE WHAT IS HAPPENING IN REAL TIME.
        """
        if self.pixel_array is None:
            self._observe()
        if mode == "human":
            import pygame
            if self._screen is None:
                if self.status.vdisplay_active:
                    os.environ['DISPLAY'] = self.initial_display
                pygame.init()
                self._screen = pygame.display.set_mode(
                    (SCR_W, SCR_H)
                )
                if self.status.vdisplay_active:
                    os.environ['DISPLAY'] = f':{self.display}'

            myImage = pygame.image.frombuffer(
                self.pixel_array.tobytes(), (SCR_W, SCR_H), "RGB"
            )

            self._screen.blit(myImage, (0, 0))
            pygame.display.update()
        else:
            self.close()
            raise ValueError("bad value for render mode")

    def close(self):
        """
        This function clears the virtual display process, the game process, the mss module and the communication thread
        """
        if self.mss_grabber:
            self.mss_grabber.close()
        if self.status.communication:
            self._send_command(CloseCommand())
        time.sleep(3)
        if self.status.game_active:
            try:
                self.game_proc.terminate()
            except AttributeError:
                pass  # We may be shut down during intialization before these attributes have been set
        if self.status.vdisplay_active:
            self.xvfb_process.stop()

    def reset(self, seed=None):
        """
        This function sets the number of agents, resets the environment to the start of the level and returns
        an screenshot of the start of the level
        """
        if self.first_reset:
            self.mss_grabber = mss.mss()
            time.sleep(2)
            self.status.mss_active = True
            if self.human_player:
                self._send_command(StartGameCommand(
                    "bowser cti", self.players + 1))
                self._send_command(CursorCommand(player=1))
            else:
                self._send_command(StartGameCommand(
                    "bowser cti", self.players))
            self.first_reset = False
        self._send_command(ResetCommand())
        self.agents = self.possible_agents[:]
        time.sleep(5)
        self._observe()
        return {agent: self.pixel_array for agent in self.agents}

    def _send_command(self, command):
        """
        Function to send a command or list of commands to the communication thread
        """
        if not isinstance(command, list):
            command = [command.__dict__]
        try:
            self.controller_channel.put(command, timeout=5)
        except Full:
            pass

    def _get_return_command(self, default_response):
        """
        Function to recive the result of a command from the communication thread
        """
        try:
            return self.reward_channel.get(timeout=5)
        except Empty:
            return default_response

    def _observe(self):
        """
        Function that takes an screenshot of the environment and saves it into self.pixel_array
        """
        offset_x = 0
        offset_y = 0
        if self.human_player:
            offset_x = self.config["offset_x"]
            offset_y = self.config["offset_y"]
        image_array = np.array(self.mss_grabber.grab({"top": offset_y,
                                                      "left": offset_x,
                                                      "width": SCR_W,
                                                      "height": SCR_H}),
                               dtype=np.uint8)
        # drop the alpha channel and flip red and blue channels (BGRA -> RGB)
        self.pixel_array = np.flip(image_array[:, :, :3], 2)
        return self.pixel_array

    def _act(self, player: int, action) -> None:
        """
        Fuction to send the actions of the agent to the game
        """
        commands = self.command_factory.parse_action(
            player=player, action=action)
        self._send_command(commands)

    def _get_rewards(self) -> int:
        """
        Funtion to recive the rewards obtained from the agents. All the agents share the same rewards
        The rewards are assigned as follows: 
        Every step -0.1
        If the mari0 that's closest to the starting point moves farther from it +1
        if one of the marios goes out of the camera, reward -5
        If one of the mario's dies, -10
        If reach the end of the level, +100
        If reach the end of the mappack +1000
        """
        command = GetRewardsCommand()
        self._send_command(command)
        reward = DEFAULT_STEP_REWARD
        reward += self._get_return_command(0)
        # print(f"display: {self.display} -> {reward}")
        return reward

    def _eval_game_over(self) -> bool:
        """
        Function to evaluate if the game if already done, this only happens at the end of the mappack
        or if the game has time left and it has run out or if the game has limit of deads and the players have
        reached it.
        """
        commands = EvalGameOverCommand()
        self._send_command(commands)
        return bool(self._get_return_command(0))

    def _dev_cursor(self, player: int):
        """
        Debug function to change the owner of the curson inside the game
        """
        command = CursorCommand(player=player)
        self._send_command(command)

    def step(self, actions):
        """
        This function takes the actions and returns:
        - observations
        - rewards
        - dones
        - infos
        dicts where each dict looks like {agent_1: item_1, agent_2: item_2}
        """
        # If a user passes in actions with no agents, then just return empty observations, etc.
        if not actions:
            return {}, {}, {}, {}

        # We first execute the actions of all agents
        for i, player in enumerate(self.agents):
            if player in actions:
                if self.human_player:
                    self._act(i + 2, actions[player])
                else:
                    self._act(i + 1, actions[player])

        # rewards for all agents are placed in the rewards dictionary to be returned
        reward = self._get_rewards()
        rewards = {}
        for player in self.agents:
            rewards[player] = reward

        with open(f"./gym_env/log/log{self.display}.txt", "a") as f:
            f.write(f"{reward} \n")
        # check if the game is done
        env_done = self._eval_game_over()
        dones = {}
        dones = {agent: env_done for agent in self.agents}

        # get the screenshot of the env
        self._observe()
        observations = {}
        observations = {agent: self.pixel_array for agent in self.agents}

        # there is no additional info
        infos = {agent: {} for agent in self.agents}

        # if the env is done, delete the agents
        if env_done:
            self.agents = []

        return observations, rewards, dones, infos
