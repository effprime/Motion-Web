FROM nginx:latest

# Args layer
ARG CAMERA_NUMBER
ARG MOTION_URL
ARG API_PORT

# Installation layers
COPY conf/ /etc/nginx/conf.d/
COPY web/ /web

# Configuration layers
RUN sed -i "s/URL_VARIABLE/$MOTION_URL/g" /etc/nginx/conf.d/default.conf && \
    sed -i "s/API_PORT_VARIABLE/$API_PORT/g" /etc/nginx/conf.d/default.conf && \
    sed -i "s/URL_VARIABLE/$MOTION_URL/g" /web/camera_functions.js && \
    sed -i "s/API_PORT_VARIABLE/$API_PORT/g" /web/camera_functions.js && \
    sed -i "s/CAMERA_NUMBER_VARIABLE/$CAMERA_NUMBER/g" /web/camera_functions.js