# wimea-ict-pla
The PLA (predicting link availability) is a novel bash-script application tends to the challenge to deliver data from remote sensor networks to
internet via weak links in the periphery of the available cellular networks.
The application use a statistical mean modal, with received signal strength indicator (RSSI) as link metric, to predict the quality of available cellular links, and ultimately to decide which link to use to send the next packet.
The idea is to investigate if using ad-hoc networking between a couple of intermittently available cellular links will yield a better data delivery rate than using any one of these links.

# setup
The sensor network gateway incorporates a Linux based script (pla_mean_modal.sh), which consists of the proposed statistical mean model as described below.
Cellular modem should be inserted and network ports shoul be notified.

# start-up
To start to collect RSSI values and predict the quality of the available cellular link, the script is executed by
Linux command: "sudo ./pla_mean_modal.sh s1 s2 s3 s4"
This indictes that:
s1 - usb-port eg. ttyUSB0 
s2 - indicates usb-port eg. ttyUSB1
s3 - indicates number of RSSI samples eg. 10
s4 - inducates time-window eg 10secs

For examples: "sudo ./pla_mean_modal.sh ttyUSB0 ttyUSB1, 10 10" 
