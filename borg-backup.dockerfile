FROM alpine
RUN apk update && apk add bash openssh borgbackup

# Add crontab file in the cron directory
RUN echo "0 3 * * * /root/borg-backup.sh > /proc/1/fd/1 2>/proc/1/fd/2 \n" >> /etc/crontabs/root

ADD borg-backup.sh /root/borg-backup.sh

# Run the command on container startup
CMD ["crond","-f","-d","8"]
