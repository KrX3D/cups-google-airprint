From phusion/baseimage:master
MAINTAINER yaurora

ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" DEBIAN_FRONTEND="noninteractive" TERM="xterm"
ENV CUPS_USER_ADMIN admin
ENV CUPS_USER_PASSWORD password

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN apt-get update -qy \
&& apt-get upgrade -qy \
&& apt-get install --no-install-recommends -qy \
        avahi-daemon \
        avahi-utils \
        bzr \
        cups \
        cups-pdf \
        cups-filters \
        google-cloud-print-connector \
        inotify-tools \
        libcups2 \
        libavahi-client3 \
        libnss-mdns \
        libsnmp35 \
        hplip \
        lsb-core \
        lsb \
        printer-driver-escpr \
        printer-driver-fujixerox \
        python3-cups \
        python \
        whois \
        nano \
&& apt-get -qq -y autoclean \
&& apt-get -qq -y autoremove \
&& apt-get -qq -y clean

COPY init.sh airprint-generate.py /tmp/
RUN rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh /var/lib/apt/lists/* /var/tmp/* || true \
&& mv -f /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/ || true \
&& mv -f /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/ || true \
&& chmod +x /tmp/init.sh \
&& chmod +x /tmp/airprint-generate.py \
&& /tmp/init.sh

#RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
#RUN mkdir /root/.ssh

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

#CMD ["/usr/sbin/sshd", "-D"]

# Export volumes
VOLUME /config /etc/cups/ /var/log/cups /var/spool/cups /var/cache/cups /root/.ssh
EXPOSE 631 5353 22

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
