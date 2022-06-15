from stable_baselines3.common.env_checker import check_env
from mario_env import env
from pettingzoo.test import parallel_api_test

# File to do a testing of the enviroment using pettingzoo test

env = env(4)
parallel_api_test(env, num_cycles=1000)
env.close()
