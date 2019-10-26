#!/bin/bash

sed -i "s/URL_VARIABLE/$1/g" /etc/nginx/conf.d/default.conf
sed -i "s/API_PORT_VARIABLE/$2/g" /etc/nginx/conf.d/default.conf
sed -i "s/URL_VARIABLE/$1/g" /web/camera_functions.js
sed -i "s/API_PORT_VARIABLE/$2/g" /web/camera_functions.js
sed -i "s/CAMERA_NUMBER_VARIABLE/$3/g" /web/camera_functions.js
