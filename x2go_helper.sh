#!/bin/bash

print_main_menu() {
	menu=$(zenity --list  --width=500 --height=400 --title="x2go Helper" \
    --text="Select operation:" \
    --column="available commands" \
    --column="operation for" \
	"Installation" "client / server" \
	"List of connected USB devices" "client / server" \
	"List of already shared devices" "client / server" \
	"Bind usb device" "server" \
	"Unbind usb device" "server" \
	"Attach usb device" "client" \
	"Detach usb device" "client" \
	"Systemd scripts" "client / server")
}

print_installation_menu() {
	install_menu=$(zenity --list  --width=500 --height=400 --title="x2go Helper" \
    --text="Select tools to install:" \
    --column="" \
    --column="operation for" \
    "⮪ Back" "" \
    "usbip" "client / server" \
	"x2goserver        " "server" \
	"x2goclient        " "client")
}

print_scripts_menu() {
	scripts_menu=$(zenity --list  --width=500 --height=400 --title="x2go Helper" \
    --text="Select operation:" \
    --column="available commands" \
    --column="operation for" \
    "⮪ Back" "" \
	"Create systemd script for share USB device" "server" \
	"Delete systemd script for share USB device" "server" \
	"Create systemd script for attach USB device" "client" \
	"Delete systemd script for attach USB device" "client")
}

if [ "$EUID" -ne 0 ]
	then echo "Please run as root!"
	exit
fi

while true; do
	print_main_menu
	selected_item=$( echo $menu | awk -F ',' '{print $1}' )

	case "${selected_item}" in
		"Installation"	)
			system=$(lsb_release -d) 
			while true; do
				print_installation_menu
				selected_install_list=$( echo $install_menu | awk -F ',' '{print $1}' )
				case "${selected_install_list}" in
					"usbip" )
						apt-get update -y 
						apt-get dist-upgrade -y 
						progress=$(apt-get install linux-tools-`uname -r` -y)
						{
							echo "usbip-core"
							echo "usbip-host"
							echo "vhci-hcd"
						} > /etc/modules
 	
						sudo usbipd -D

						if [[ "$progress" == *"is already the newest version"* || \
						      "$progress" == *"Уже установлен пакет"* ]]; then
							zenity --info --width=200 --height=100 --text "usbip already installed"
						elif [[ "$progress" == *"Setting up linux-tools"* ||
						        "$progress" == *"Настраивается пакет linux-tools"* ]]; then
							zenity --info --width=200 --height=100 --text "usbip succesfully installed"
							clear
						fi
					;;
					"x2goserver" )
						if [[ "$system" == *"Ubuntu"* ]]; then
							apt-get install python-software-properties -y
							apt-get install software-properties-common -y
							add-apt-repository ppa:x2go/stable -y
							apt-get update -y
							ubuntu_progress=$(apt-get install x2goserver x2goserver-xsession -y)

							if [[ "$ubuntu_progress" == *"is already the newest version"* || \
						          "$ubuntu_progress" == *"Уже установлен пакет"* ]]; then
								zenity --info --width=200 --height=100 --text "x2goserver already installed"
							elif [[ "$ubuntu_progress" == *"Setting up "* ||
						    	    "$ubuntu_progress" == *"Настраивается пакет "* ]]; then
								zenity --info --width=200 --height=100 --text "x2goserver succesfully installed"
								clear
							fi
						elif [[ "$system" == *"Debian"* || "$system" == *"Raspbian"* ]]; then
							apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E -y
							{
								echo "# X2Go Repository (release builds)"
								echo "deb http://packages.x2go.org/debian buster extras main"
								echo "# X2Go Repository (sources of release builds)"
								echo "deb-src http://packages.x2go.org/debian buster extras main"
							} > /etc/apt/sources.list.d/x2go.list

							apt-get install x2go-keyring -y && apt-get update -y

							apt-get install x2goserver x2goserver-xsession libnss-ldap ldap-utils -y

							# debian_progress=$(apt-get install x2goserver x2goserver-xsession -y)
							# if [[ "$debian_progress" == *"is already the newest version"* || \
						 #      "$debian_progress" == *"Уже установлен пакет"* ]]; then
							# zenity --info --width=200 --height=100 --text "x2goserver already installed"
							# elif [[ "$debian_progress" == *"Setting up "* ||
						 #    	    "$debian_progress" == *"Настраивается пакет "* ]]; then
							# 	zenity --info --width=200 --height=100 --text "x2goserver succesfully installed"
							# 	clear 
							# fi
						fi
					;;
					"x2goclient" )
						if [[ "$system" == *"Ubuntu"* ]]; then
							apt-get install python-software-properties -y
							apt-get install software-properties-common -y
							add-apt-repository ppa:x2go/stable -y
							apt-get update -y

							ubuntu_progress=$(apt-get install x2goclient -y)
							if [[ "$ubuntu_progress" == *"is already the newest version"* || \
						      	  "$ubuntu_progress" == *"Уже установлен пакет"* ]]; then
								zenity --info --width=200 --height=100 --text "x2goclient already installed"
							elif [[ "$ubuntu_progress" == *"Setting up "* ||
						    	    "$ubuntu_progress" == *"Настраивается пакет "* ]]; then
								zenity --info --width=200 --height=100 --text "x2goclient succesfully installed"
								clear
							fi
						elif [[ "$system" == *"Debian"* || "$system" == *"Raspbian"* ]]; then
							apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E -y
							{
								echo "# X2Go Repository (release builds)"
								echo "deb http://packages.x2go.org/debian buster extras main"
								echo "# X2Go Repository (sources of release builds)"
								echo "deb-src http://packages.x2go.org/debian buster extras main"
							} > /etc/apt/sources.list.d/x2go.list

							apt-get install x2go-keyring -y && apt-get update -y
							apt-get install x2goclient -y

							# debian_progress=$(apt-get install x2goclient -y)
							# if [[ "$debian_progress" == *"is already the newest version"* || \
						 #          "$debian_progress" == *"Уже установлен пакет"* ]]; then
							# 	zenity --info --width=200 --height=100 --text "x2goclient already installed"
							# elif [[ "$debian_progress" == *"Setting up "* ||
						 #    	    "$debian_progress" == *"Настраивается пакет "* ]]; then
							# 	zenity --info --width=200 --height=100 --text "x2goclient succesfully installed"
							# 	clear 
							# fi
						fi

					;;

					"⮪ Back" )
						break;
					;;

					"")
						break;
					;;
				esac
			done
		;;

		"List of connected USB devices" )

			list_connection=$(usbip list -l)
			zenity --info --width=450 --height=250 --text "<b>usbip list -l</b> \n $list_connection "

		;;

		"List of already shared devices" )
			ip=$(zenity --entry \
				--title="" \
				--text="Enter server IP:" \
				--entry-text "localhost")

			list_shared=$(usbip list -r $ip)

			if [[ length=${#list_shared} -eq 0 ]]; then
				zenity --warning --width=450 --height=150 --text "<b>usbip list -r $ip </b> \nno exportable devices found on $ip "
			else
				zenity --info --width=450 --height=250 --text "<b>usbip list -r $ip </b> \n$list_shared "
			fi
		;;

		"Bind usb device" )
			bind_ID=$(zenity --entry \
				--title="" \
				--text="Enter usb busID:" \
				--entry-text "2-1")

			usbip bind -b $bind_ID > /dev/null 2>&1
			list_bind="$?"

			if [[ list_bind -eq 0 ]]; then
				zenity --info --width=450 --height=150 --text "<b> usbip bind -b $bind_ID</b>\nbind device on busid $bind_ID: complete"
			elif [[ list_bind -eq 1 ]]; then
				zenity --error --width=450 --height=150 --text "<b>usbip bind -b $bind_ID</b>\ndevice on busid $bind_ID is already bound to usbip-host or no exist"
			fi
		;;

		"Unbind usb device" )
			unbind_ID=$(zenity --entry \
				--title="" \
				--text="Enter usb busID:" \
				--entry-text "2-1")

			usbip unbind -b $unbind_ID > /dev/null 2>&1
			list_unbind="$?"

			if [[ list_unbind -eq 0 ]]; then
				zenity --info --width=450 --height=150 --text "<b>usbip unbind -b $unbind_ID</b>\nunbind device on busid $unbind_ID: complete"
			elif [[ list_unbind -eq 1 ]]; then
				zenity --error --width=450 --height=150 --text "<b>usbip unbind -b $unbind_ID</b>\ndevice is not bound to usbip-host driver or no exist"
			fi
		;;

		"Attach usb device" )
			IP=$(zenity --entry \
				--title="" \
				--text="Enter server IP:" \
				--entry-text "localhost")
			ID=$(zenity --entry \
				--title="" \
				--text="Enter usb busID:" \
				--entry-text "2-1")

			sudo usbip attach -r $IP -b $ID /dev/null 2>&1
			list_attach="$?"

			if [[ list_attach -eq 0 ]]; then
				zenity --info --width=450 --height=150 --text "<b>sudo usbip attach -r $IP -b $ID</b>\nAttach Request successfully completed"
			elif [[ list_attach -eq 1 ]]; then
				zenity --info --width=450 --height=150 --text "<b>sudo usbip attach -r $IP -b $ID</b>\nAttach Request for $ID failed - Device not found"
			fi
		;;

		"Detach usb device" )
			list_ports=$(sudo usbip port)

			port=$(zenity --entry \
				--title="Enter usb port:" \
				--width=450 --height=150 \
				--text="$list_ports" \
				--entry-text "00")
			
			list_detach=$(sudo usbip detach --port=$port)

			if [[ list_detach -eq 0 ]]; then
				zenity --info --width=450 --height=150 --text "<b>sudo usbip detach --port=$port</b>\n$port is now detached or already detached\n"
			elif [[ list_detach -eq 1 ]]; then
				zenity --error --width=450 --height=150 --text "<b>sudo usbip detach --port=$port</b>Error while detaching device\n"
			fi
		;;

		"Systemd scripts" )
			while true; do
				print_scripts_menu
				selected_script=$( echo $scripts_menu | awk -F ',' '{print $1}' )

				case "${selected_script}" in
					"Create systemd script for share USB device" )
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

						list_auto=$(sudo usbip list -l)

						auto_usbID=$(zenity --entry \
						--title="Enter a USB id to automatically bind(share) at system startup:" \
						--width=500 --height=150 \
						--text="$list_auto" \
						--entry-text "2-1")

						if [[ $auto_usbID -eq "" ]]; then
							break;
						fi

						{
							echo "#!/bin/sh"
							echo "PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
							echo "usbipd -D"
							echo "usbip bind -b $auto_usbID"
							echo "usbip attach --remote=localhost --busid=$auto_usbID"
							echo "sleep 2"
							echo "usbip detach --port=00"
						} > /scripts/usbipd
						
						sudo chmod +x /scripts/usbipd

						systemctl start usbipd
						systemctl status usbipd > /dev/null 2>&1

						usbipd_status="$?"

						if [[ usbipd_status -eq 0 ]]; then
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nusbipd.service activated!"
						elif [[ usbipd_status -eq 1 ]]; then
							zenity --error --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nError while starting usbipd.service"
						fi
					;;

					"Delete systemd script for share USB device" )
						systemctl stop usbipd
						systemctl disable usbipd

						systemctl status usbipd > /dev/null 2>&1
						delete_status="$?"

						sudo rm /scripts/usbipd
						sudo rm /etc/systemd/system/usbipd.service
						systemctl daemon-reload

						if [[ delete_status -eq 4 ]]; then
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nusbipd.service already deleted"
						else
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nusbipd.service succesfully deleted"
						fi
					;;

					"Create systemd script for attach USB device" )
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

						auto_ip=$(zenity --entry \
						--title="" \
						--text="Enter server IP to automatically attach at system startup:" \
						--entry-text "localhost")

						auto_id=$(zenity --entry \
						--title="" \
						--text="Enter a USB id to automatically attach at system startup:" \
						--entry-text "2-1")
						
						{
							echo "#!/bin/sh"
							echo "PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
							echo "usbipd -D"
							echo "sudo usbip attach -r $auto_ip -b $auto_id"
						} > /scripts/usbipdclient

						sudo chmod +x /scripts/usbipdclient

						systemctl start usbipdclient
						systemctl status usbipdclient > /dev/null 2>&1
						usbipcl_status="$?"

						if [[ usbipd_status -eq 0 ]]; then
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nusbipclient.service activated!"
						elif [[ usbipd_status -eq 1 ]]; then
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipd </b>\nError while starting usbipclient.service"
						fi

					;;

					"Delete systemd script for attach USB device" )
						systemctl stop usbipdclient
						systemctl disable usbipdclient

						systemctl status usbipdclient > /dev/null 2>&1
						delete="$?"

						sudo rm /scripts/usbipdclient
						sudo rm /etc/systemd/system/usbipdclient.service
						systemctl daemon-reload

						if [[ delete -eq 4 ]]; then
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipdclient </b>\nusbipdclient.service already deleted"
						else
							zenity --info --width=450 --height=150 --text "<b>systemctl status usbipdclient </b>\nusbipdclient.service succesfully deleted"
						fi
					;;

					"⮪ Back" )
						break;
					;;

					"")
						break;
					;;
				esac
			done
		;;

		"")
			exit;
		;;

		*)
			zenity --warning --text "Operation was not selected" --width=300
		;;
	esac
done