#
# Cookbook:: pi
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

apt_package 'i2c-tools' do
  action :install
end

apt_package 'python-smbus' do
  action :install
end

execute 'change_hostname' do
  command "raspi-config nonint do_hostname #{node['pi']['host']}"
  not_if "cat /etc/hostname | grep #{node['pi']['host']}"
end

execute 'enable_sshd' do
  command "raspi-config nonint do_ssh 0"
  not_if "systemctl list-unit-files -t service | grep ssh.service | grep enable"
end

execute 'enable_camera' do
  command 'raspi-config nonint do_camera 0'
  not_if 'cat /boot/config.txt | grep gpu_mem | grep 128'
end

execute 'enable_i2c' do
  command 'raspi-config nonint do_i2c 0'
  only_if 'cat /boot/config.txt | grep i2c | grep off'
end

execute 'set_timezone' do
  command 'cp -f /usr/share/zoneinfo/Asia/Brunei /etc/localtime'
  not_if 'cat /etc/localtime | grep BNT-8'
end

apt_package 'wpasupplicant' do
  action :install
end

template '/etc/wpa_supplicant/wpa_supplicant.conf' do
  source 'wpa_supplicant.conf'
end

apt_package 'avahi-daemon' do
  action :install
end

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
  notifies :create, "file[/home/pi/Batch.tar.gz]"
end

file '/home/pi/Batch.tar.gz' do
  content IO.binread('/home/pi/Phase1/AIIT_PRODUCTS_PI/Batch.tar.gz')
  action  :nothing
  notifies :create, "execute[expand_file]"
end

execute 'expand_file' do
  command 'cd /home/pi;tar xvzf Batch.tar.gz'
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
