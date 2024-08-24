import pandas as pd
import matplotlib.pyplot as plt

# Read the CSV data
data = pd.read_csv('performance_node2@0.0.0.0_log.csv')


# Extract the columns
itt = data['itt']
dur = data['dur']
rslc = data['rslc']
rt = data['rt']
mt = data['mt']

print(data)

# Plot the graph

fig, ax1 = plt.subplots(figsize=(12, 8))

# Plot the first dataset on the primary y-axis
ax1.plot(itt, dur, 'b-', label='duration (ms)')
ax1.set_xlabel('Iteration number')
ax1.set_ylabel('duration (ms)', color='b')
ax1.tick_params('y', colors='b')

# Create a secondary y-axis
ax2 = ax1.twinx()
ax2.plot(itt, mt, 'go', label='memory used')
ax2.set_ylabel('memory (mb)', color='g')
ax2.tick_params('y', colors='g')

# Add labels and title
#plt.xlabel('Itteration number')
#plt.ylabel('memory MB')
plt.title('Memory Metrics')
plt.legend()

# Save the plot to a file
plt.savefig('dura_mt.png', dpi=300)

# Show the plot
#plt.show()
