import time
from mario_env import mari0_env
import supersuit as ss
from stable_baselines3 import PPO

env = mari0_env(2)
env = ss.color_reduction_v0(env, mode='B')
env = ss.resize_v1(env, x_size=84, y_size=84)
env = ss.frame_stack_v1(env, 3)
model = PPO.load("policy-2")

obs = env.reset()
done = False

for i in range(500):
    for agent in env.agents:
        act = model.predict(obs[agent], deterministic=True)[
            0] if not done or not done[agent] else None
        sample = {agent: act for agent in env.agents}
        obs, _, done, _ = env.step(sample)
        env.render()
        break


print("close")
env.close()
