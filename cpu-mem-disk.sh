#!/bin/bash
sudo yum install bc mailx postfix -y
#CPU USAGE Alerts
echo '#!/bin/bash
SUBJECT="`hostname` server load is high"
TO=user@domain.com

uptime > /tmp/load
if [ `uptime | awk { print$10 } | cut -d. -f1` -gt 15 ];
then
echo "============================================" >> /tmp/load
`ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10 >> /tmp/load `
mail -s "$SUBJECT" $TO < /tmp/load 
exit
fi' > /opt/cpu.sh

sed -i "s/{/'{/g" /opt/cpu.sh
sed -i "s/}/}'/g" /opt/cpu.sh
chmod 755 /opt/cpu.sh

#MEMORY USAGE Alert
echo 'subject="Server Memory Status Alert"
to="user@domain.com"

Free=$(free | grep Mem | awk {print $4/$2 * 100.0})
if [[ "$Free" < 30.0  ]]; then
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head >/tmp/top_proccesses_consuming_memory.txt
file=/tmp/top_proccesses_consuming_memory.txt
## send email if system memory is running low
echo -e "Warning, server memory is running low!\n\nFree memory: $Free MB" | mailx -A "$file" -s "$subject" $to 
fi' > /opt/mem.sh

sed -i "s/{/'{/g" /opt/mem.sh
sed -i "s/}/}'/g" /opt/mem.sh
chmod 755 /opt/mem.sh

#DISK USAGE ALERT
echo 'CURRENT=$(df / | grep / | awk { print $5} | sed "s/%//g")
THRESHOLD=90


if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    mail -s "Critical Disk Space Alert" user@domain.com << EOF
Your root partition remaining free space is critically low. Used: $CURRENT%
EOF
fi' > /opt/disk.sh

sed -i "s/{/'{/g" /opt/disk.sh
sed -i "s/}/}'/g" /opt/disk.sh
chmod 755 /opt/disk.sh

cd /etc
(crontab -l; echo "*/15 * * * * /bin/bash /opt/disk.sh") | crontab -
(crontab -l; echo "*/15 * * * * /bin/bash /opt/mem.sh") | crontab -
(crontab -l; echo "*/15 * * * * /bin/bash /opt/cpu.sh") | crontab -

sudo service crond restart
