import pandas as pd

set_num = 4

df = pd.read_csv(f'set{set_num}_data.csv')

df[df.columns[1:5]] = df[df.columns[1:5]].map(lambda x: '{:08X}'.format(int(x, 16)))
df.to_csv(f'set{set_num}_data.csv', index=False)

df[df.columns[1:5]] = df[df.columns[1:5]].map(lambda x: int(x[:4], 16))
df.to_csv(f'set{set_num}_data_converted.csv', index=False)

# df[df.columns[1:5]] = df[df.columns[1:5]].map(lambda x: int('{:08X}'.format(int(x, 16))[:4], 16))