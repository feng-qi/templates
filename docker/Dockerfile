FROM ubuntu

MAINTAINER fengqi

RUN apt update \
    && apt install zsh

ENV foo /bar

# copy file from context or URL
# ADD <source> <destination>
ADD . $foo

# default command, only last one is effective if multiple 'CMD' given
CMD ["ls", "/bin"]

EXPOSE 80/tcp
EXPOSE 80/udp
