import requests
import datetime as dt
import base64

def sendPicture(imagePath):
	url = "http://192.168.214.206/receivePhoto"
	emailUtilisateur = "toto@toto"

	with open(imagePath,'rb') as image_file:
 		im_bytes = image_file.read()
	im_bytes64 = base64.b64encode(im_bytes).decode('utf-8')
	data = {"email": emailUtilisateur,"nameFile" : 'pic_' + dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S') + '.jpg',"image": im_bytes64}
	response = requests.post(url,data=data)
	print(response.status_code)





