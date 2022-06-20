from numpy import mean
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('/home/camilo/tfg/mari0-marl-env/gym_env/log/progress.csv')
# df["train/value_loss"] = df["train/value_loss"].fillna(0)
# value_loss = df["train/value_loss"]

# # print(mean(value_loss))

# epochs = range(1,100000, 256)
# plt.plot(epochs[0:75], value_loss[0:75], 'g', label='Value loss')
# plt.title('Value loss')
# plt.xlabel('Steps')
# plt.ylabel('Value loss')
# plt.legend()
# plt.savefig('tfg_documentation/img/value_loss.png')


# df["train/entropy_loss"] = df["train/entropy_loss"].fillna(0)
# value_loss = df["train/entropy_loss"]

# # print(mean(value_loss))
# plt.clf()

# epochs = range(1,100000, 256)
# plt.plot(epochs, value_loss, 'g', label='Entropy loss')
# plt.title('Entropy loss')
# plt.xlabel('Steps')
# plt.ylabel('Entropy loss')
# plt.legend()
# plt.savefig('tfg_documentation/img/entropy_loss.png')


# df["train/clip_fraction"] = df["train/clip_fraction"].fillna(0)
# value_loss = df["train/clip_fraction"]

# plt.clf()

# epochs = range(1,100000, 256)
# plt.plot(epochs, value_loss, 'g', label='Entropy loss')
# plt.title('Entropy loss')
# plt.xlabel('Steps')
# plt.ylabel('Entropy loss')
# plt.legend()
# plt.savefig('tfg_documentation/img/clip_fraction.png')


# df["train/explained_variance"] = df["train/explained_variance"].fillna(0)
# value_loss = df["train/explained_variance"]

# plt.clf()

# epochs = range(1,100000, 256)
# plt.plot(epochs, value_loss, 'g', label='Entropy loss')
# plt.title('Entropy loss')
# plt.xlabel('Steps')
# plt.ylabel('Entropy loss')
# plt.legend()
# plt.savefig('tfg_documentation/img/explained_variance.png')




plt.clf()

df["train/loss"] = df["train/loss"].fillna(0)
value_loss = df["train/loss"]

epochs = range(1,50000, 256)
plt.plot(epochs[0:75], value_loss[0:75], 'g', label='Loss')
plt.title('Loss')
plt.xlabel('Steps')
plt.ylabel('Loss')
plt.legend()
plt.savefig('tfg_documentation/img/loss.png')


plt.clf()

df["train/approx_kl"] = df["train/approx_kl"].fillna(0)
value_loss = df["train/approx_kl"]


epochs = range(1,50000, 256)
plt.plot(epochs, value_loss, 'g', label='Approximated kl')
plt.title('Approximated kl')
plt.xlabel('Steps')
plt.ylabel('Approximated kl')
plt.legend()
plt.savefig('tfg_documentation/img/approx_kl.png')

plt.clf()

df = pd.read_csv('/home/camilo/tfg/mari0-marl-env/gym_env/log/log371094083.csv')

df["cum_rewards"] = df["reward"].cumsum()
value_loss = df["cum_rewards"]
# print(df["cum_rewards"][0:200])

epochs = range(1,len(df) + 1)
plt.plot(epochs, value_loss, 'g', label='Accumulated rewards')
plt.title('Accumulated rewards')
plt.xlabel('Steps')
plt.ylabel('Accumulated rewards')
plt.legend()
plt.savefig('tfg_documentation/img/rewards_cum.png')