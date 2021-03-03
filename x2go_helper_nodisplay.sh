#!/bin/bash

print_menu() {
	echo "-----------------------------------------"
	echo -e "i.Install usbip \033[04m[both]\033[0m"
	echo -e "0.1)Create systemd script for share USB device  \033[04m[server]\033[0m"
	echo -e "0.2)Delete systemd script for share USB device  \033[04m[server]\033[0m"
	echo -e "0.3)Create systemd script for attach USB device \033[04m[client]\033[0m"
	echo -e "0.4)Delete systemd script for attach USB device \033[04m[client]\033[0m"
	echo -e "\033[33m  1)List of connected USB devices         \t \033[04m[both]\033[0m"; 
	echo -e "\033[33m  2)List of already shared devices        \t \033[04m[both]\033[0m";
	echo -e "\033[33m  3)Bind usb device                          \t\033[04m[server]\033[0m";
	echo -e "\033[33m  4)Unbind usb device                        \t\033[04m[server]\033[0m";
	echo -e "\033[33m  5)Attach usb device                        \t\033[04m[client]\033[0m";
	echo -e "\033[33m  6)Detach usb device                        \t\033[04m[client]\033[0m";
	echo -e "\033[33m  0)Exit\033[0m";
	echo "-----------------------------------------"
}

print_menu
read choose;

while [ $choose != "0" ]
do
	if [ $choose == "i" ]
	then
		sudo apt-get install linux-tools-`uname -r`

		{
  			echo "usbip-core"
  			echo "usbip-host"
  			echo "vhci-hcd"
		} > /etc/modules

		sudo usbipd -D
	fi

	if [ $choose == "0.1" ]
	then

		{
  			echo "[Unit]"
  			echo "Description=USBIPd"
  			echo "[Service]"
  			echo "ExecStart=/scripts/usbipd"
  			echo "Type=oneshot"
  			echo "RemainAfterExit=yes"
  			echo "[Install]"
  			echo "WantedBy=multi-user.target"
		} > /etc/systemd/system/usbipd.service		
		systemctl daemon-reload
		systemctl enable usbipd

		if ! [ -d /scripts ]; then
			sudo mkdir /scripts
		fi

		echo -e "\033[32m"
		sudo usbip list -l
		echo -e "\033[0m"
		echo -e "\033[07mEnter a USB id to automatically bind(share) at system startup:\033[0m"
		read id;
		{
			echo "#!/bin/sh"
			echo "PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
			echo "usbipd -D"
			echo "usbip bind -b $id"
			echo "usbip attach --remote=localhost --busid=$id"
			echo "sleep 2"
			echo "usbip detach --port=00"
		} > /scripts/usbipd
		
		sudo chmod +x /scripts/usbipd

		systemctl start usbipd
		systemctl status usbipd
	fi

	if [ $choose == "0.2" ]
	then
		systemctl stop usbipd
		systemctl disable usbipd
		sudo rm /scripts/usbipd
		sudo rm /etc/systemd/system/usbipd.service
		systemctl daemon-reload
	fi

	if [ $choose == "0.3" ]
	then
		{
  			echo "[Unit]"
  			echo "Description=USBIPdclient"
  			echo "[Service]"
  			echo "ExecStart=/scripts/usbipdclient"
  			echo "Type=oneshot"
  			echo "RemainAfterExit=yes"
  			echo "[Install]"
  			echo "WantedBy=multi-user.target"
		} > /etc/systemd/system/usbipdclient.service

		systemctl daemon-reload
		systemctl enable usbipdclient

		if ! [ -d /scripts ]; then
			sudo mkdir /scripts
		fi

		echo -e "\033[32mEnter server IP:\033[0m"
		read ip;
		echo -e "\033[32mEnter a USB id to automatically attach at system startup:\033[0m"
		read id;

		echo -e "\033[0m"
		{
			echo "#!/bin/sh"
			echo "PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
			echo "usbipd -D"
			echo "sudo usbip attach -r $ip -b $id"
		} > /scripts/usbipdclient

		sudo chmod +x /scripts/usbipdclient

		systemctl start usbipdclient
		systemctl status usbipdclient
	fi

	if [ $choose == "0.4" ]
	then
		systemctl stop usbipdclient
		systemctl disable usbipdclient
		sudo rm /scripts/usbipdclient
		sudo rm /etc/systemd/system/usbipdclient.service
		systemctl daemon-reload
	fi


	if [ $choose == "1" ]
	then
		echo -e "\033[07m usbip list -l \033[0m"
		echo -e "\033[32m"
		sudo usbip list -l
		echo -e "\033[0m"
	fi


	if [ $choose == "2" ]
	then
		echo -e "\033[32mEnter server IP:\033[0m"
		read ip;
		echo -e "\033[07m sudo usbip list -r $ip \033[0m\033[32m"
		sudo usbip list -r $ip
		echo -e "\033[0m"
	fi

	if [ $choose == "3" ]
	then
		echo -e "\033[32mEnter usb busID:\033[0m"
		read id;
		echo -e "\033[07m usbip bind -b $id \033[0m"
		sudo usbip bind -b $id
		echo -e "\033[0m"
	fi

	if [ $choose == "4" ]
	then
		echo -e "\033[32mEnter usb busID:\033[0m"
		read id;
		echo -e "\033[07m usbip unbind --busid=$id \033[0m"
		sudo usbip unbind --busid=$id
		echo -e "\033[0m"
	fi

	if [ $choose == "5" ]
	then
		echo -e "\033[32mEnter server IP:\033[0m"
		read IP;
		echo -e "\033[32mEnter usb busID:\033[0m"
		read ID;
		echo -e "\033[07m sudo usbip attach -r $IP -b $ID \033[0m"
		sudo usbip attach -r $IP -b $ID
		echo -e "\033[0m"
	fi

	if [ $choose == "6" ]
	then
		echo -e "\033[07m usbip port\033[0m"
		sudo usbip port
		echo -e "Enter port:"
		read port
		echo -e "\033[07m sudo usbip detach --port=$port \033[0m"
		sudo usbip detach --port=$port
		echo -e "\033[0m"
	fi

	print_menu
	read choose;
done