#!/bin/bash

# Varibles that will be used to make the code more visible in the screen
BLUE="\\e[1;34m"
RED="\\e[0;33m"
GREEN="\\e[1;32m"
NC="\\033[0m"



rootRequired() {
    echo -e "${BLUE}------rootRequired $@... ${NC}"

    # -> This function will verify if the user is root.

    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}You must be running as root. Try using sudo.${NC}"
        exit 1
    else
        echo -e "${GREEN}Done${NC}"
    fi
}




configColors(){
    echo -e "${BLUE}------configColors $@... ${NC}"
    # -> This function will copy the colors.txt file and put it inside the pi4
    #    and will add the colors variables within bash.rc

    if cat ~/.bashrc|grep -q "RED=" || cat ~/.bashrc|grep -q "NC=" || cat ~/.bashrc|grep -q "GREEN=" || cat ~/.bashrc|grep -q "BLUE="; then
        echo -e "${GREEN}Colors are already working${NC}"
    else
        cat colors.txt >> ~/.bashrc
        echo -e "${GREEN}Done${NC}"
    fi
}


installationSSH() {
    echo -e "${BLUE}------installationSSH $@... ${NC}"

    # -> This function will install ssh and configure the computer to connect ssh (~/.ssh/authorized_keys)

    if apt install ssh -y; then
        echo -e "${GREEN}SSH installed${NC}"
        chmod 700 ~/.ssh/*
    else
        echo -e "${RED}SSH not installed${NC}"
    fi
}

configurationSSH() {
    echo -e "${BLUE}------configurationPortSSH $@... ${NC}"

    # -> This function will change the port for ssh
    if cat /etc/ssh/sshd_config | grep -e "Port\ 22$"; then
        sed -i -e "s/#Port\ 22/Port 2222/g" /etc/ssh/sshd_config
        echo -e "${GREEN}SSH Configurated port 2222${NC}"
    else
        echo -e "${GREEN}SSH already Configurated${NC}"
    fi
}

installationHOSTAP-DNSMASQ() {
    echo -e "${BLUE}------installationHOSTAP-DNSMASQ $@... ${NC}"

    # -> This function will install dnsMasq and HostAp to transform pi4 in acess point

    if apt install hostapd -y && apt install dnsmasq -y; then
        echo -e "${GREEN}HOSTAP and DNSMASQ installed${NC}"
        chmod 700 ~/.ssh/*
    else
        echo -e "${RED}HOSTAP and DNSMASQ not installed${NC}"
    fi
}

configurationHOSTAP() {
    echo -e "${BLUE}------configurationHOSAP $@... ${NC}"

    # -> This function will configure hostapd.conf
    if printf "interface=wlan0\ndriver=nl80211\nssid=WifiPI4\nhw_mode=g\nchannel=5\n\
country_code=FR\nwpa=2\nauth_algs=1\nwpa_key_mgmt=WPA-PSK\nwpa_passphrase=StopBurningForest\nwpa_pairwise=CCMP" > /etc/hostapd/hostapd.conf ; then
        echo -e "${GREEN}File hostapd configurated${NC}"
    else
        echo -e "${RED}Error: configuration file hostapd failed${NC}"
    fi

    if cat /etc/default/hostapd | grep -q "/etc/hostapd/hostapd.conf"; then
        echo -e "${GREEN}Deamon_OPTS already defined${NC}"
    else
        printf "DAEMON_OPTS=\"/etc/hostapd/hostapd.conf\"\n">> /etc/default/hostapd
        echo -e "${GREEN}Deamon_OPTS defined${NC}"
    fi

}



configurationDNSMASQ(){
    echo -e "${BLUE}------configurationDNSMASQ $@... ${NC}"
    # -> This function will configure DNSMasq.conf

    if printf "interface=wlan0\ndhcp-range=192.168.10.100,192.168.10.254,255.255.255.0,24h\nserver=1.1.1.1\n" > /etc/dnsmasq.conf ; then
        echo -e "${GREEN}File DnsMASQ configurated${NC}"
    else
        echo -e "${RED}Error: configuration file DnsMASQ failed${NC}"
    fi
}

configurationNetworkInterfaces(){
    echo -e "${BLUE}------configurationNetworkInterfaces $@... ${NC}"
    # -> This function will configure the file network/interfaces

    if  printf "auto lo\niface lo inet loopback\nauto eth0 wlan0\niface wlan0 inet static
\taddress 192.168.10.1\n\tnetmask 255.255.255.0\niface eth0 inet dhcp\n" > /etc/network/interfaces; then
        echo -e "${GREEN}File interfaces configurated${NC}"
    else
        echo -e "${RED}Error: configuration file interfaces failed${NC}"
    fi

}

activeRoutage(){
    echo -e "${BLUE}------activeRoutage $@... ${NC}"

    # -> This function will active the route mode

    if cat /etc/sysctl.conf | grep -e "#net.ipv4.ip_forward=1"; then
        sed -i -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
        echo -e "${GREEN}Routage Active${NC}"
    else
        echo -e "${GREEN}Routage already activeted${NC}"
    fi
}

configurationDHCPD(){
    echo -e "${BLUE}------configurationDHCPD $@... ${NC}"

    # -> This function configure DHCPD

    if cat /etc/dhcpcd.conf | grep -e "static ip_address=192.168.0.10/24"; then
        echo -e "${GREEN}DHCPD already Configurated${NC}"
    else
        printf "interface wlan0\nstatic ip_address=192.168.0.10/24\n" >> /etc/dhcpcd.conf
        echo -e "${GREEN}DHCPD Configurated${NC}"
    fi
}

configurationAcessInternet(){
    echo -e "${BLUE}------configurationAccessInternet $@... ${NC}"

    # -> This function enable new users to have a internet acess when connect to PI4 acess point

    if iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE; then
	sh -c "iptables-save > /etc/iptables.ipv4.nat"
        echo -e "${GREEN}Acess internet configurated${NC}"
    else
        echo -e "${RED}Error acess internet${NC}"
    fi
}


#===========Root Verification===========
rootRequired

#===========Colors configuration===========
configColors

#===========SSH===========
installationSSH
configurationSSH

#===========HOSTAP-DNSMASQ===========
installationHOSTAP-DNSMASQ
configurationHOSTAP
configurationDNSMASQ

#===========NetworkInterfaces===========
configurationNetworkInterfaces

#===========ActiverRoutage===========
activeRoutage

#===========DHCPD===========
configurationDHCPD

#===========AcessInternet===========
configurationAcessInternet

systemctl restart NetworkManager
systemctl restart networking.service

echo -e "${GREEN} END of the script DONE Please restart the machine ${NC}"

echo -e "${RED}Pour activer le mode point d'acess tapez la commande 'hostapd /etc/hostapd/hostapd.conf' ${NC}" 

