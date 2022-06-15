
from stable_baselines3.ppo import CnnPolicy
from stable_baselines3 import PPO
import supersuit as ss
from mario_env import mari0_env

env_base = mari0_env(2)
env = ss.color_reduction_v0(env_base, mode="B")
env = ss.resize_v1(env, x_size=84, y_size=84)
env = ss.frame_stack_v1(env, 3)
env = ss.pettingzoo_env_to_vec_env_v1(env)
env = ss.concat_vec_envs_v1(
    env, num_vec_envs=2, num_cpus=2, base_class="stable_baselines3")

model = PPO(CnnPolicy, env, verbose=2, n_steps=16)
model.learn(total_timesteps=100000)
model.save("policy-2")

env_base.close()
env.close()
print("press control C to stop the process, everything is ok")