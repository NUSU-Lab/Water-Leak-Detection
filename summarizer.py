import pandas as pd

df = pd.read_csv(f'final.csv')

for value in range(4):
    selected_rows = df[df['value'] == value]
    average_values = selected_rows[['sensor1', 'sensor2', 'sensor3', 'sensor4']].mean()
    
    average_values_str = str(average_values).split('\n')
    del average_values_str[4]
    average_values = '\n'.join(average_values_str)
    
    print(f"<Average of value : {value}>")
    print(f"{average_values}")
    print(f"Number of rows with value {value} : {len(selected_rows)}", end='\n\n')