---
title: SAE 1.01
author: Nathan Verdier
geometry: margin=2cm
---

# Matériels:
* rasberry Pi 4
* caméra ArduCam 16MP IMX519
* PIR MOTION SENSOR WPSE314
* Camera thermique MLX90640

# PRÉREQUIS

### Fait :

Soudure réalisée sur la caméra thermique pour fixée 5 pins, des câbles permettent de relier la PI4 à la caméra thermique via platine d'essai pour que le 3V, le SDA, le SCL et le GND soient relié. 


# Configuration
## caméra ArduCam 16MP IMX519

### Branchement

<img title="BranchementArduCam" alt="Alt text" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.arcadia-retrogaming.fr%2Fimg%2Fcms%2Fdocs%2520technique%2FRaspberryPi_Model_4B.jpg&f=1&nofb=1&ipt=02f954ec2bd0a16392dfbb1bf8dd77cae1f18ee2a03c9db093c91278e55c03a1&ipo=images">

**Connecter la naps sur le port Camera CSI**

### Configuration

**Pour configurer la camera de la PI4 il suffit de faire ceci dans un terminal :**

```shell
wget -O install_pivariety_pkgs.sh https://github.com/ArduCAM/Arducam-Pivariety-V4L2-Driver/releases/download/install_script/install_pivariety_pkgs.sh
chmod +x install_pivariety_pkgs.sh
./install_pivariety_pkgs.sh -p imx519_kernel_driver_low_speed
```

puis il faut que la pi4 reboot.

**Pour détecter la présence du driver faite ceci:**<br>
dmesg | grep imx519

**Pour détecter la détection de la caméra faite ceci:**<br>
ls /dev/video0

**Installer l'auto focus:**<br>

```shell
wget -O install_pivariety_pkgs.sh https://github.com/ArduCAM/Arducam-Pivariety-V4L2-Driver/releases/download/install_script/install_pivariety_pkgs.sh
chmod +x install_pivariety_pkgs.sh
sudo apt update
./install_pivariety_pkgs.sh -p libcamera_dev
./install_pivariety_pkgs.sh -p libcamera_apps
```

**teste du résultat:**<br>
libcamera-still -t 0 --viewfinder-width 2328 --viewfinder-height 1748 --autofocus

**prendre une photo:**<br>
libcamera-still -r -o test.jpg --viewfinder-width 2328 --viewfinder-height 1748 --autofocus<br>
libcamera-jpeg -o test.jpg -q 80

**prendre une video:**<br>
libcamera-still -r -o test.jpg --viewfinder-width 2328 --viewfinder-height 1748 --autofocus


### Installer `Cheese`
**Utilisation de `cheese`:**<br>

~~~
sudo apt-get install cheese 
~~~

## Camera thermique MLX90640
### Pré-requis
**Dans un premier temps Installer ceci:**[Git pimoroni](https://github.com/pimoroni/mlx90640-library)<br>
sudo apt-get install libi2c-dev<br>
sudo vi /boot/config.txt<br>
ajouter cette ligne : **dtparam=i2c_arm=on**<br>
et celle-ci : **dtparam=i2c1_baudrate=1000000**
sudo apt install libavutil-dev libavcodec-dev libavformat-dev libsdl2-image-dev

make clean<br>
make I2C_MODE=LINUX<br>
make bcm2835<br>

sudo apt-get install libsdl2-dev libavutil-dev libavcodec-dev libavformat-dev<br>
make I2C_MODE=RPI<br>
sudo make install<br>
make examples/test<br>
sudo examples/test<br>
make examples/video<br>
sudo examples/video<br>



## PIR MOTION SENSOR WPSE314
### Branchement
<img title="BranchementMotionSensor" alt="Alt text" src="https://lh6.googleusercontent.com/WMDPzgPBJly2AZgbHtMCRE5Hh8A1X2dlGo7k8UeuJik_1lyHaSf65SbQ2QIa3JatQfYfVVwKHpby01zqeCdNwtNGtYGLc2QWW1xEK7_bDqsKaJ8A-oaSBM85aRA6nhqnWJWgA-GH">

## Explication:
Comme nous pouvons le voir sur l'image il suffit de connecter le **VCC**(cable rouge) au **5v** de la carte, le **OUT**(cable orange) au **GPIO 4** de la carte et pour finir le **GND**(cable noir) au **GND** de la carte.

### Script python

Copier ceci dans un fichier nommer **script.py**

```shell
from gpiozero import LED
from gpiozero import MotionSensor

pir = MotionSensor(4)

while True:
    pir.wait_for_motion()
    print("Motion Detect")
    pir.wait_for_no_motion()
    print("Motion Stopped")
```
**Pour lancer le script :**
python3 script.py