import time
from mario_env import mari0_env, env
from pettingzoo.test import parallel_api_test, render_test

# File to test the actions of the environment by hand

env = env(3, True)
parallel_api_test(env, num_cycles=1000)
env.close()