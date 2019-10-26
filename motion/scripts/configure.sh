#!/bin/bash

# Add static configuration for motion
sed -i 's/daemon off/daemon on/g' /etc/motion/motion.conf
echo "start_motion_daemon=yes" > /etc/default/motion
sed -i 's/stream_localhost on/stream_localhost off/g' /etc/motion/motion.conf
sed -i 's/webcontrol_localhost on/webcontrol_localhost off/g' /etc/motion/motion.conf
sed -i 's/webcontrol_html_output on/webcontrol_html_output off/g' /etc/motion/motion.conf
sed -i 's/framerate 2/framerate 10/g' /etc/motion/motion.conf
sed -i 's/stream_maxrate 1/stream_maxrate 10/g' /etc/motion/motion.conf

# Loop through IP list and make camera file for each
CAM=1
IP_LIST=$(echo "$1" | tr -d '"')
IFS=',' read -ra ADDR <<< "$IP_LIST"
for IP in "${ADDR[@]}"; do
    CAMERA_FILE="/etc/motion/camera$CAM.conf"
    echo "Adding Camera file $CAMERA_FILE"
    echo "netcam_url rtsp://$IP:554" >> $CAMERA_FILE
    echo "target_dir /etc/motion/footage/$CAM/" >> $CAMERA_FILE
    echo "stream_port 808$CAM" >> $CAMERA_FILE
    echo "height 1080" >> $CAMERA_FILE
    echo "width 1920" >> $CAMERA_FILE
    echo "camera $CAMERA_FILE" >> /etc/motion/motion.conf
    CAM=$(expr $CAM + 1)
done
