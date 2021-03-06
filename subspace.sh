#!/bin/bash
#
# allow execution if not yet set
# 	chmod +x subspace.sh
# start the script with the subspace address that starts with st.....
# 	sudo /bin/bash subspace.sh st.......
# choos Install to install node and farmer
# to check logs, start the script again with:
#	sudo /bin/bash subspace.sh
# and choose either the farmer or the node logs
# to disable the node, farmer and remove all data chose the "Disable" option


function installnodefarmer {
echo -e "\e[1m\e[32m1. removing farmer-service \e[0m" && sleep 1
sudo systemctl stop subspace-farmer
sudo systemctl disable subspace-farmer
rm /etc/systemd/system/subspace-farmer.service
sudo systemctl daemon-reload

echo -e "\e[1m\e[32m2. removing node-service \e[0m" && sleep 1
sudo systemctl stop subspace-node
sudo systemctl disable subspace-node
rm /etc/systemd/system/subspace-node.service
sudo systemctl daemon-reload


echo -e "\e[1m\e[32m3. removing old data \e[0m" && sleep 1
rm -r $HOME/.local/share/subspace
rm -r $HOME/.local/share/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05
rm /usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05
rm /usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05
rm -r subspace

mkdir subspace
cd subspace

echo -e "\e[1m\e[32m4. downloading the farmer \e[0m" && sleep 1
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-june-05/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05
echo -e "\e[1m\e[32m5. downloading the node \e[0m" && sleep 1
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-june-05/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05
chmod +x subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05
chmod +x subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05

echo -e "\e[1m\e[32m6. Moving subspace-node to /usr/local/bin/ ... \e[0m" && sleep 1
mv $MYHOME/subspace/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05 /usr/local/bin

echo -e "\e[1m\e[32m7. Moving subspace-farmer to /usr/local/bin/ ... \e[0m" && sleep 1
mv $MYHOME/subspace/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05 /usr/local/bin

echo -e "\e[1m\e[32m8. Pruning old snapshot \e[0m" && sleep 1
/usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05 wipe
/usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05 purge-chain --chain gemini-1

echo -e "\e[1m\e[32m9. Starting the node-service \e[0m" && sleep 1
sudo tee /etc/systemd/system/subspace-node.service > /dev/null <<EOF
[Unit]
  Description=Subspace-node daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=/usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05 \
  --chain gemini-1 \
  --execution wasm \
  --pruning 1024 \
  --keep-blocks 1024 \
  --validator \
  --name $NODENAME
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable subspace-node
sudo systemctl daemon-reload
sudo systemctl restart subspace-node
echo -e "\e[1m\e[32m10. Waiting for the node to start up properly \e[0m" && sleep 30

echo -e "\e[1m\e[32m11. Starting the farmer-service \e[0m" && sleep 1
sudo tee /etc/systemd/system/subspace-farmer.service > /dev/null <<EOF
[Unit]
  Description=Subspace-node daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=/usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05 farm --reward-address $subspaceAddress --plot-size 80G
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable subspace-farmer
sudo systemctl daemon-reload
sudo systemctl restart subspace-farmer
echo -e "\e[1m\e[32m12. You can check the logs by rerunning this bash-script and by choosing the log-options \e[0m" && sleep 1
}

function upgradenodefarmer {
sudo systemctl stop subspace-farmer
sudo systemctl disable subspace-farmer
sudo rm /etc/systemd/system/subspace-farmer.service
sudo systemctl daemon-reload
sudo systemctl stop subspace-node
sudo systemctl disable subspace-node
sudo rm /etc/systemd/system/subspace-node.service
sudo systemctl daemon-reload
rm /usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05
rm /usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05

mkdir subspace
cd subspace

echo -e "\e[1m\e[32m4. downloading the farmer \e[0m" && sleep 1
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-10/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-10
echo -e "\e[1m\e[32m5. downloading the node \e[0m" && sleep 1
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-10/subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-10
chmod +x subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-10
chmod +x subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-10

echo -e "\e[1m\e[32m6. Moving subspace-node to /usr/local/bin/ ... \e[0m" && sleep 1
mv $MYHOME/subspace/subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-10 /usr/local/bin

echo -e "\e[1m\e[32m7. Moving subspace-farmer to /usr/local/bin/ ... \e[0m" && sleep 1
mv $MYHOME/subspace/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-10 /usr/local/bin

echo -e "\e[1m\e[32m9. Starting the node-service \e[0m" && sleep 1
sudo tee /etc/systemd/system/subspace-node.service > /dev/null <<EOF
[Unit]
  Description=Subspace-node daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=/usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-10 \
  --chain gemini-1 \
  --execution wasm \
  --pruning 1024 \
  --keep-blocks 1024 \
  --validator \
  --name $NODENAME
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable subspace-node
sudo systemctl daemon-reload
sudo systemctl restart subspace-node
echo -e "\e[1m\e[32m10. Waiting for the node to start up properly \e[0m" && sleep 30

echo -e "\e[1m\e[32m11. Starting the farmer-service \e[0m" && sleep 1
sudo tee /etc/systemd/system/subspace-farmer.service > /dev/null <<EOF
[Unit]
  Description=Subspace-node daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=/usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-10 farm --reward-address $subspaceAddress --plot-size 80G
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable subspace-farmer
sudo systemctl daemon-reload
sudo systemctl restart subspace-farmer
}

function disable {
echo -e "\e[1m\e[31m1. disable farmer \e[0m" && sleep 1
sudo systemctl stop subspace-farmer
sudo systemctl disable subspace-farmer
rm /etc/systemd/system/subspace-farmer.service
sudo systemctl daemon-reload
echo -e "\e[1m\e[31m2. disable node \e[0m" && sleep 1
sudo systemctl stop subspace-node
sudo systemctl disable subspace-node
rm /etc/systemd/system/subspace-node.service
sudo systemctl daemon-reload
echo -e "\e[1m\e[31m3. pruning old snapshot \e[0m" && sleep 1
/usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05 wipe
/usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05 purge-chain --chain gemini-1
echo -e "\e[1m\e[31m4. remove databases \e[0m" && sleep 1
rm -r $HOME/.local/share/subspace
rm -r $HOME/.local/share/subspace-node-ubuntu-x86_64-snapshot-2022-may-05
rm /usr/local/bin/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-05
rm /usr/local/bin/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-05
rm -r subspace
}

function displayNodeLogs {
journalctl -u subspace-node.service -o cat -f
}


function displayFarmerLogs {
journalctl -u subspace-farmer.service -o cat -f
}

MYHOME=$(pwd)
arr=(${MYHOME//// })
NODENAME="${arr[1]}_node"
PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Update" "NodeLogs"  "FarmerLogs" "Disable" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            if [ ! $1 ]; 
            then
            echo -e '\n\e[42mYou please provide a subspace address (starts with "st....") \e[0m\n'
            break
	        fi
	        subspaceAddress=$1
            echo -e "\n\e[42mYou choose install with subspace address: $subspaceAddress, and node-name: $NODENAME\e[0m\n" && sleep 1
			installnodefarmer
			break
            ;;
	    "Update")
	        subspaceAddress=$1
	        echo -e '\n\e[42mUpdating\e[0m\n'
			upgradenodefarmer
			break
			;;
        "NodeLogs")
            echo -e '\n\e[42mdisplaying Logs (press ctrl + c to exit Logs)\e[0m\n'
			displayNodeLogs
			break
            ;;
        "FarmerLogs")
            echo -e '\n\e[42mdisplaying Logs (press ctrl + c to exit Logs)\e[0m\n'
			displayFarmerLogs
			break
            ;;
	    "Disable")
            echo -e '\n\e[31mYou choose disable...\e[0m\n' && sleep 1
			disable
			echo -e '\n\e[31msubspace-node and subspace-farmer were disabled; databases were removed!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done
