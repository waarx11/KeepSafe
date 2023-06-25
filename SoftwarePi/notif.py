import threading
import pyinotify
import os
import multiprocessing
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import signal
import re
from algoDetectionDeMouvement import *
from envoisPhoto import *
from prendrePhoto import *
from web_server import *


# class EventHandler(pyinotify.ProcessEvent):
#     def process_IN_MODIFY(self, event):
#         if event.pathname == "/home/UCA/enjolys/TÃ©lÃ©chargements/file.txt":
#             with open(event.pathname, r) as f:
#                 content = f.read()
#                 if "blue" in content:
#                     semaphore.acquire()
#                     threading.Thread(target=blue_function).start()
#                 elif "red" in content:
#                     semaphore.acquire()
#                     threading.Thread(target=red_function).start()
#                 print("chaged")
fileName='/home/pi4/sae/2022_KeepSafe/SoftwarePi/configFile/file.txt'
pathFile="/home/pi4/sae/2022_KeepSafe/SoftwarePi/configFile/"
pathPhoto='/home/pi4/sae/2022_KeepSafe/SoftwarePi/photo/'
class MyHandler(FileSystemEventHandler):
    def on_modified(self, event):
    	global fileName
    	if event.src_path == fileName:
    		manager()


exOperation=""
def live():
	start_server()
	semaphore.release()

def detect():
	print("detect")
	detectMouvement()
	semaphore.release()

def photoTh():
	sendPicture(takePictureThermique(pathPhoto))
	returnDetectAuto()
	deletePhoto()
	semaphore.release()
def photoFu():
	sendPicture(mergePhotoFinal(pathPhoto))
	returnDetectAuto()
	deletePhoto()
	semaphore.release()
	
def returnDetectAuto():
	command="echo detect > "+fileName
	os.system(command)
def deletePhoto():
	command="rm -rf "+pathPhoto+"*"
	os.system(command)
def photoNo():
	 sendPicture(takePictureNormal(pathPhoto))
	 returnDetectAuto()
	 semaphore.release()
    
def getContent(path):
    with open(path, 'r') as f:
        contents = f.read()
        
    contents= re.sub(r'\s', '', contents)
    return contents


def manager():
    global p,exOperation,fileName
    contents= getContent(fileName)
    if (exOperation == contents and exOperation != "photoTh" and exOperation != "photoNo") :
    	return
    
    if p.pid is not None:
        os.kill(p.pid, signal.SIGTERM)
    if contents=="detect" :
        p=multiprocessing.Process(target=detect)
    elif contents == "live" :
        p=multiprocessing.Process(target=live)
        #args=(arg1, arg2)
    elif contents == "photoTh" :
        p=multiprocessing.Process(target=photoTh)
    elif contents == "photoNo" :
        p=multiprocessing.Process(target=photoNo)
    elif contents=="photoFu" :
        p=multiprocessing.Process(target=photoFu)
    else :
    	return
    exOperation=contents
    p.start()

semaphore = threading.Semaphore(0)   
p = multiprocessing.Process()
manager()  

# wm = pyinotify.WatchManager()
# notifier = pyinotify.Notifier(wm, EventHandler())
# wm.add_watch(os.getcwd(), pyinotify.IN_MODIFY)
# notifier.loop()


event_handler = MyHandler()
observer = Observer()
observer.schedule(event_handler, path=pathFile, recursive=False)
observer.start()
while(True):
    time.sleep(1)
