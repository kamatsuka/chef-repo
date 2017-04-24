cd /root/chef-repo
git pull origin master

echo "chef why_run"
echo "----------------------------"
chef-client -z -o role[flood99] -W

if [ $? -eq 0 ];then
  echo "chef runonce"
  echo "----------------------------"
  chef-client -z -o role[flood99]
fi
