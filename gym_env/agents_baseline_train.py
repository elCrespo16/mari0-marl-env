from stable_baselines3.ppo import CnnPolicy
from stable_baselines3 import PPO
import supersuit as ss
from mario_env import env

env = env(2)
env = ss.color_reduction_v0(env, mode="B")
env = ss.resize_v1(env, x_size=84, y_size=84)
env = ss.frame_stack_v1(env, 3)
# env = ss.black_death_v3(env)
# env = ss.pad_observations_v0(env)
env = ss.pettingzoo_env_to_vec_env_v1(env)
env = ss.concat_vec_envs_v1(env, 1, num_cpus=0, base_class="stable_baselines3")

model = PPO(CnnPolicy, env, verbose=2, n_steps=16)
model.learn(total_timesteps=2000000)
model.save("policy")


# from stable_baselines3 import PPO
# from pettingzoo.butterfly import pistonball_v6
# import supersuit as ss
# env = pistonball_v6.parallel_env()
# env = ss.color_reduction_v0(env, mode='B')
# env = ss.resize_v1(env, x_size=84, y_size=84)
# env = ss.frame_stack_v1(env, 3)
# env = ss.pettingzoo_env_to_vec_env_v1(env)
# env = ss.concat_vec_envs_v1(env, 1, num_cpus=0, base_class='stable_baselines3')
# model = PPO('CnnPolicy', env, verbose=3, n_steps=16)
# model.learn(total_timesteps=2000000)