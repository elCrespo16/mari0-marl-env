from mario_env import env
from pettingzoo.test import parallel_api_test

# File to test the actions of the environment by hand

env = env(2)
parallel_api_test(env, num_cycles=1000)
env.close()

env = env(3, True)
parallel_api_test(env, num_cycles=1000)
env.close()