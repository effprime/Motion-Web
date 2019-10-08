#!/bin/sh

sed -i 's/daemon off/daemon on/g' /etc/motion/motion.conf
echo "start_motion_daemon=yes" > /etc/default/motion

sed -i 's/stream_localhost on/stream_localhost off/g' /etc/motion/motion.conf
sed -i 's/webcontrol_localhost on/webcontrol_localhost off/g' /etc/motion/motion.conf
sed -i 's/webcontrol_html_output on/webcontrol_html_output off/g' /etc/motion/motion.conf
sed -i 's/framerate 2/framerate 10/g' /etc/motion/motion.conf
sed -i 's/stream_maxrate 1/stream_maxrate 10/g' /etc/motion/motion.conf

echo "camera /etc/motion/camera1.conf" >> /etc/motion/motion.conf
echo "camera /etc/motion/camera2.conf" >> /etc/motion/motion.conf

motion
