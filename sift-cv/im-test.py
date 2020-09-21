import os,sys

def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

images = get_image_paths('d:\\fso-data\\ha')
arrayImg=[]
for image in images:
    arrayImg.append(image)
    print (image)
print(len(arrayImg))