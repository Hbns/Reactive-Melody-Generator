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

#data['dur'] = pd.to_numeric(data['dur'], errors='coerce')
#data['rslc'] = pd.to_numeric(data['rslc'], errors='coerce')
#data['rt'] = pd.to_numeric(data['rt'], errors='coerce')
#data['mt'] = pd.to_numeric(data['mt'], errors='coerce')

# Round the columns to 2 decimal places
#data['dur'] = data['dur'].round(2)
#data['rslc'] = data['rslc'].round(2)
#data['rt'] = data['rt'].round(2)
#data['mt'] = data['mt'].round(2)

print(data)

# Plot the graph

#fig, ax1 = plt.subplots()

# Plot the first dataset on the primary y-axis
#ax1.plot(itt, dur, 'b-', label='duration (ms)')
#ax1.set_xlabel('itterations')
#ax1.set_ylabel('duration (ms)', color='b')
#ax1.tick_params('y', colors='b')

# Create a secondary y-axis
#ax2 = ax1.twinx()
#ax2.plot(itt, rslc, 'r-', label='reductions slc')
#ax2.set_ylabel('reductions slc', color='r')
#ax2.tick_params('y', colors='r')

plt.figure(figsize=(10, 6))

#plt.plot(itt, dur_scaled, label='dur', color='blue', marker='o')
#plt.plot(itt, rslc_scaled, label='rslc', color='green', marker='o')
#plt.plot(itt, rt, label='rt', color='red', marker='o')
plt.plot(itt, mt, label='mt', color='purple', marker='o')

# Add labels and title
plt.xlabel('itterations')
plt.ylabel('memory MB')
plt.title('Memory Metrics')
plt.legend()

# Save the plot to a file
plt.savefig('memory.png')

# Show the plot
#plt.show()
