import matplotlib.pyplot as plt
from matplotlib.legend_handler import HandlerLine2D


# Code used to generate the pareto-front optimal designs 
# comparing the baseline (part one of reserach) to the optimized
# (final version of research) solution.
# Generated graph is used in the technical journal for 
# IEEE Transaction on Computers


#Y-axis - error rate; X-axis - memory requirement
#These numbers were collected using simulation
baselineSolution_y = [0.149, 0.151, 0.2, 0.252, 0.282, 0.502, 0.511, 0.699, 
              0.782, 0.801, 0.849, 0.876, 0.933, 0.935, 0.938, 0.948, 
              0.951, 0.975, 0.98, 0.985, 1]
baselineSolution_x = [515.9, 346.03, 209.72, 132.12, 89.13, 47.71, 34.6, 
              14.68, 12.85, 9.44, 5.9, 4.72, 2.75, 2.13, 1.77, 0.81, 
              0.7, 0.42, 0.33, 0.22, 0.03]
optimizedSolution_y = [0.007, 0.013, 0.022, 0.468, 0.786, 0.991, 1]
optimizedSolution_x = [44.04, 14.68, 1.47, 0.98, 0.72, 0.49, 0.26]




fig = plt.figure()
ax = fig.add_subplot(1,1,1)
#create one line for each solution
line1, = plt.plot(baselineSolution_x, baselineSolution_y, '-ro', label='Th, l') 
line2, = plt.plot(optimizedSolution_x, optimizedSolution_y, '-bo', label='Th, l + XOR')
#specify legend
plt.legend(handler_map={line1: HandlerLine2D(numpoints=2)})
#set scaling to make plots readable
ax.set_xscale('log')
ax.set_xlim(-5, 1000)
ax.set_ylim(-0.1, 1.1)
plt.xlabel("Memory (Mbits)")
plt.ylabel("Error rate")

plt.show()