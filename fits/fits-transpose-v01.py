import matplotlib
import numpy as np
import matplotlib.pyplot  as plt
from astropy.io import fits
halpha = fits.open("ha.fits")
data = halpha[0].data
m,n = data.shape
print (m,n)
tdata = np.array([n,m])
tdata = data.T
m1,n1 = tdata.shape
print ('Min:', np.min(data))
print ('Max:', np.max(data))
print ('Mean:', np.mean(data))
print ('Stdev:', np.std(data))
plt.figure(1)
#plt.subplot(211)
plt.imshow(data, cmap='gray')
#plt.colorbar()
#plt.show()
#plt.subplot(212)
plt.figure(2)
print (m1,n1)
print ('Min:', np.min(tdata))
print ('Max:', np.max(tdata))
print ('Mean:', np.mean(tdata))
print ('Stdev:', np.std(tdata))
plt.imshow(tdata, cmap='gray')


hdr=halpha[0].header
print(hdr['NAXIS'])
print(hdr['NAXIS2'])
print(hdr['NAXIS1'])
thdr=hdr
thdr['NAXIS1']=n
thdr['NAXIS2']=m
fits.writeto("test.fits",tdata,thdr,overwrite=True)

test = fits.open("test.fits")
testdata = test[0].data
m2,n2 = testdata.shape
print (m2,n2)
hdr1=test[0].header
print(hdr1['NAXIS'])
print(hdr1['NAXIS2'])
print(hdr1['NAXIS1'])
print ('Min:', np.min(testdata))
print ('Max:', np.max(testdata))
print ('Mean:', np.mean(testdata))
print ('Stdev:', np.std(testdata))
plt.figure(3)
plt.imshow(testdata,cmap='gray')

plt.colorbar()
plt.show()