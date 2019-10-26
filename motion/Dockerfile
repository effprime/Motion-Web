FROM ubuntu:bionic

ARG IP_LIST

RUN apt update -y \
&& apt install -y \
motion

COPY scripts/ /scripts

RUN /scripts/configure.sh $IP_LIST

CMD motion && tail -f /var/log/motion/motion.log
