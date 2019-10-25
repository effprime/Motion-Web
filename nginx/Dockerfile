FROM nginx:latest

ARG CAMERA_NUMBER
ARG MOTION_URL
ARG API_PORT

ADD conf/default.conf /etc/nginx/conf.d/
COPY web/ /web
COPY scripts/ /scripts

RUN bash /scripts/configure.sh $MOTION_URL $API_PORT $CAMERA_NUMBER
