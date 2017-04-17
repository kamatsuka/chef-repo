#
# Cookbook:: pi
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

user 'pi' do
  comment 'default user'
  home '/home/pi'
  shell '/bin/bash'
  password '$1$W5bm6Uqu$hAc0i0jnAVVCtIpyXgeCp1'
end

directory '/home/pi' do
  owner 'pi'
  group 'root'
  mode '0755'
  action :create
end

apt_package 'git' do
  action :install
end

git '/home/pi/Phase1' do
  repository 'https://hkamatsuka:fwih9452@github.com/UBD-AIIT-Global-Project/Phase1.git'
  revision 'master'
  user 'pi'
  action :sync
end

file '/home/pi/Batch.tar.gz' do
  content IO.binread('/home/pi/Phase1/AIIT_PRODUCTS_PI/Batch.tar.gz')
  action  :create
end

execute 'expand_file' do
  command 'cd /home/pi;tar xvzf Batch.tar.gz'
end

cron 'sensor_batch' do
  command '/home/pi/Batch/writer.sh' 
  minute '*/10'
  mailto 'a1521hk@aiit.ac.jp'
  user 'pi'
  action :create
end
