import matplotlib.pyplot as plt
import numpy as np
import glob

if __name__=="__main__":
    fnames = glob.glob("./filters/*")
    filters = []
    fig, ax = plt.subplots()
    for fname,band,color in zip(fnames,["U","G","R","I"],['b','g','r','m']):
        arr = np.loadtxt(fname)
        filters.append(arr)
        ax.plot(arr[:,0], arr[:,1], color=color, label=band)
    fig.savefig("filters.png")
    #plt.show()
