import matplotlib.pyplot as plt

# Data setup
libraries = ['rhttp', 'http\n(IOClient)', 'dio\n(HttpClient)']
colors = ['orange', 'darkblue', 'darkblue']  # Color configuration

title = '10 MB x 100 Downloads\n(lower is better)'
times = [2394, 12527, 13091]

#title = '1 KB x 10000 Downloads\n(lower is better)'
#times = [1010, 2174, 2758]

# maximum value
max_value = max(times)


# Creating a horizontal bar chart
plt.figure(figsize=(5, 3))
bars = plt.barh(libraries, times, color=colors)
plt.title(title)
plt.xlabel('Response Time (ms)')
plt.xlim(0, max(times) + max_value * 0.3)  # Set the x-axis limit to give some padding

# Customizing the spines (frame)
ax = plt.gca()  # Get current axes
ax.spines['top'].set_visible(False)   # Hide the top spine
ax.spines['right'].set_visible(False) # Hide the right spine

# Adding the text for each bar
for bar in bars:
    xval = bar.get_width()
    plt.text(xval + max_value * 0.05, bar.get_y() + bar.get_height()/2, f'{xval} ms', va='center')

# Ensure the grid is off
plt.grid(False)

# Save the figure as a PNG file
plt.tight_layout()
plt.savefig('generated.png')
