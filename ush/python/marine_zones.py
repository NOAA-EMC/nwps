#!/usr/bin/env python
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

plt.figure()
map=Basemap(projection='mill',llcrnrlon=-83.5,urcrnrlon=-78.5,
                              llcrnrlat=24,urcrnrlat=28,
							  resolution='h')
map.drawcoastlines()
map.readshapefile('marine_zones','marine_zones')
map.drawparallels(np.arange(-90,91,2),labels=[1,0,0,0])
map.drawmeridians(np.arange(-180,181,5),labels=[0,0,0,1])
map.drawcoastlines()
map.fillcontinents()
map.drawcounties()
plt.title('Marine Zones from shapefile')
plt.savefig('florida_marine_zones.png') 
