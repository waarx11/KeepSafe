from gpiozero import MotionSensor
from prendrePhoto import *
from notif import *
pathPhoto='/home/pi4/sae/2022_KeepSafe/SoftwarePi/photo/'
def detectMouvement():
	global pathPhoto
	print("detect")	
	pir = MotionSensor(16)
	pir.wait_for_no_motion()
	print("MotionStopped")
	while True:
   	 pir.wait_for_motion()
   	 print("Motion Stopped")
   	 mergePhotoFinal(pathPhoto)
   	 deletePhoto()
   	 pir.wait_for_no_motion()
   	 print("Motion Detect")
