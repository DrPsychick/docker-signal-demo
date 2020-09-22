FROM ubuntu:bionic

RUN apt-get update \
  && apt-get install -y tmux screen

COPY demo-entrypoint.sh \
  void_trap.sh \
  /
RUN chmod +x /*.sh

# https://tasdikrahman.me/2019/04/24/handling-singals-for-applications-in-kubernetes-docker/
#RUN curl -O /my_init https://raw.githubusercontent.com/phusion/baseimage-docker/rel-0.9.19/image/bin/my_init

ENV EXEC_DEMO=""
ENTRYPOINT ["/demo-entrypoint.sh"]
