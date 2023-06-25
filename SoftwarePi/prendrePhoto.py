import thermique
import cv2
import datetime as dt
import os
import threading
pathPhoto='/home/pi4/sae/2022_KeepSafe/SoftwarePi/photo/'
def takePictureThermique(output_folder):
	thermcam = thermique.pithermalcam(output_folder=output_folder) 
	return thermcam.save_image() 

def process():
    while True:
        command = input('Enter command')

def takePictureNormal(output_folder):

	#cam = cv2.VideoCapture(0)
	#result, image = cam.read()
	#if result:
	#	cv2.imwrite(output_folder+'pic_Normal_' + dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S') + '.jpg', image)
	#else:
	#	print("No image detected. Please! try again")
	fname=output_folder+'pic_Normal_' + dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S') + '.jpg'
	command="libcamera-still -r  --nopreview --autofocus -o"+fname
	os.system(command)
	return fname
	
def customNormalImage(normalImagePath):
	global pathPhoto
	img=cv2.imread(normalImagePath)
	imageRotate = cv2.rotate(img, cv2.ROTATE_180)
	
	croppedImage = imageRotate[635:2360, 714:4010]
	#cv2.imshow('Image',croppedImage)
	#cv2.waitKey(0)
	#cv2.imwrite(pathPhoto+'pic_CroppedNormal.jpg', croppedImage)
	return croppedImage

def customThermiqueImage(thermiqueImagePath):
	img=cv2.imread(thermiqueImagePath)

	croppedImage = img[187:600, 0:800]
	#cv2.imwrite('pic_CroppedThermique.jpg', croppedImage)		
	return croppedImage

def mergePhoto(normalImg,thermiqueImg,alpha):
	h, w = normalImg.shape[:2]

	resizeImag=cv2.resize(thermiqueImg,(w,h))
	
	beta=1.0-alpha
	mergedPhoto=cv2.addWeighted(resizeImag , alpha, normalImg, beta, 0.0)
	return mergedPhoto
	
def mergePhotoFinal(pathPhoto):
	thermiqueImage=takePictureThermique(pathPhoto)
	normalImage=takePictureNormal(pathPhoto)
	#thermiqueImage='/home/pi4/cameraThermique/Algo/photo/pic_Thermic_2022-11-11_20-45-59.jpg'
	#normalImage='/home/pi4/cameraThermique/Algo/photo/pic_Normal_2022-11-11_20-45-59.jpg'

	normalFinalImg=customNormalImage(normalImage)
	thermiqueFinalImg=customThermiqueImage(thermiqueImage)
	mergeImage=mergePhoto(normalFinalImg,thermiqueFinalImg,0.3)
	cv2.imwrite(pathPhoto+'pic_Result.jpg', mergeImage)
	return pathPhoto+'pic_Result.jpg'

	
if __name__ == "__main__":
	testMergePhoto()

