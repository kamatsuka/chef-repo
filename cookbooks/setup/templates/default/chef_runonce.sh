#!/bin/sh
error=0
cd /root/chef-repo
git pull origin master

echo "chef why_run"
echo "----------------------------"
chef-client -z -o role[flood99] -W | tee /root/tmp.log

if [ $? -eq 0 ];then
  echo "chef runonce"
  echo "----------------------------"
  chef-client -z -o role[flood99] | tee /root/tmp.log
  if [ $? -ne 0 ]; then
    error=1
  fi
else
  error=1
fi

if [ $error -eq 1 ];then
  message=`cat /root/tmp.log`
  echo $message
  curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "${message}", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
fi
