FROM ubuntu:bionic

RUN apt update -y && apt install -y \
motion

COPY ./conf/ /etc/motion/
RUN mkdir /scripts
COPY ./scripts/ /scripts/

CMD bash /scripts/configure.sh; tail -f /var/log/motion/motion.log
