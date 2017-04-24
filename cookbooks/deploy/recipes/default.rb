#
# Cookbook:: pi
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

apt_package 'git' do
  action :install
end

git '/home/pi/Phase1' do
  repository 'https://hkamatsuka:fwih9452@github.com/UBD-AIIT-Global-Project/Phase1.git'
  revision 'master'
  user 'pi'
  action :sync
  notifies :run, "execute[expand_file]"
end

execute 'expand_file' do
  command 'cd /home/pi;tar xvzf /home/pi/Phase1/AIIT_PRODUCTS_PI/Batch.tar.gz'
  action :nothing
  notifies :create, "cron[sensor_batch]"
end

cron 'sensor_batch' do
  command '/home/pi/Batch/writer.sh' 
  minute '*/10'
  mailto 'a1521hk@aiit.ac.jp'
  user 'pi'
  action :create
end
