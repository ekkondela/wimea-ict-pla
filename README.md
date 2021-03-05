# Introduction
The PLA (predicting link availability) is a novel algorithm tends to the challenge to deliver data from remote sensor networks to
internet via weak links in the periphery of the available cellular networks.
The PLA is based on statistical mean modal, with received signal strength indicator (RSSI) as link metric, to predict the quality of available cellular links, and ultimately to decide which link to use to send the next packet.
The idea is to investigate if using ad-hoc networking between a couple of intermittently available cellular links will yield a better data delivery rate than using any one of these links.

# Emulator
Emulator is a bash-script version in which the modems are replaced by random number generators providing readings following the probability distribution. To start with, download a script emulator.sh then in your directory create a folder called "Emulator". Then run it as:
sudo ./emulator.sh s1 s2, where s1 represents sampling numbers and s2 represents time window.

For example: sudo ./emulator.sh 10 10

RSSI values are collected and the quality of available links are predicted.

# Modems
Likewise, in order to use cellular modems you can also download a file "pla_mean_modal.sh" which incorporates statistical mean modal and keep it in the directory of your choice. Then in your directory create a folder called "PLA". Before starting up, first insert at least two cellular modems to detect the network ports and notify them.
To start to collect RSSI values and predict the quality of the available cellular link, the script is executed by
Linux command: "sudo ./pla_mean_modal.sh s1 s2 s3 s4"
This indictes that:
s1 - usb-port eg. ttyUSB0 
s2 - indicates usb-port eg. ttyUSB1
s3 - indicates number of RSSI samples eg. 10
s4 - inducates time-window eg 10secs

For examples: sudo ./pla_mean_modal.sh ttyUSB0 ttyUSB1 10 10 

# Results
You can find results generated in the folder Emulator
