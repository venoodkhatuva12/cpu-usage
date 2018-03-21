limit=2
email_destination=user@domain.com
email_body="WARNING the CPU usage on server `hostname` exceeded the limit"
email_subject="WARNING cpu usage"
usage=`grep 'cpu' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' | bc`
test(){
if echo $usage $limit | awk '{exit $1>$2?0:1}'
then
  echo -e $email_body | mail -s "$email_subject" $email_destination
fi
}
test
