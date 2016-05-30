#!/bin/bash

#  Created by Richardson Lima - contato@richardsonlima.com.br

# set -x

echo -e "\033[1;34m [+] Install GIT Client \033[m";
sudo apt-get update &&  sudo apt-get install git-core lynx -y

echo -e "\033[1;34m [+] Checking if chef  exists \033[m";
if [ ! -f "/usr/bin/chef-solo" ]; then
echo -e "\033[1;31m [+] Chef Solo not found \033[m";
echo -e "\033[1;34m [+] Installing Chef Solo \033[m";
curl -L https://www.opscode.com/chef/install.sh | sudo bash
>> ~/.bash_profile && source ~/.bash_profile
sudo chef-solo -v
else
  echo -e "\033[1;34m [+] Chef OK \033[m";

fi

echo -e "\033[1;34m [+] Download and configure CHEF-REPO structure \033[m";
wget http://github.com/opscode/chef-repo/tarball/master
tar -zxvf master
sudo mkdir -p /opt/chef-repo
sudo mv chef-chef-repo-*/ /opt/chef-repo/
sudo mkdir /opt/chef-repo/.chef && sudo mkdir /opt/chef-repo/cookbooks 
echo "cookbook_path [ '/opt/chef-repo/cookbooks' ]" > /opt/chef-repo/.chef/knife.rb
echo -e "\033[1;34m [+] Creating PHPAPP cookbooks \033[m";
cd /opt/chef-repo/cookbooks/ && sudo knife cookbook create phpapp
echo -e "\033[1;34m [+] Downloading cookbooks \033[m";
sudo knife cookbook site download apache2
sudo tar zxf apache2* && sudo rm apache2*.tar.gz
sudo knife cookbook site download apt
sudo tar zxf apt* && sudo rm apt*.tar.gz
sudo knife cookbook site download iptables
sudo tar zxf iptables* && sudo rm iptables*.tar.gz
sudo knife cookbook site download logrotate
sudo tar zxf logrotate* &&  sudo rm logrotate*.tar.gz
sudo knife cookbook site download pacman
sudo tar zxf pacman* && sudo rm pacman*.tar.gz

sudo chown `whoami`: /opt/chef-repo/cookbooks/phpapp/metadata.rb
sudo cat << EOF > /opt/chef-repo/cookbooks/phpapp/metadata.rb
name             'phpapp'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures phpapp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apache2"
EOF

sudo chown `whoami`: /opt/chef-repo/cookbooks/apache2/recipes/default.rb
sudo cat << EOF >  /opt/chef-repo/cookbooks/apache2/recipes/default.rb
#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"

apache_site "default" do
  enable true
end
EOF

echo -e "\033[1;34m [+] Configure solo.rb \033[m";
sudo touch /opt/chef-repo/solo.rb
sudo chown `whoami`: /opt/chef-repo/solo.rb
sudo cat << EOF > /opt/chef-repo/solo.rb
file_cache_path "/opt/chef-solo"
cookbook_path "/opt/chef-repo/cookbooks"
EOF

echo -e "\033[1;34m [+] Creating your json\033[m";
sudo touch /opt/chef-repo/web.json
sudo chown `whoami`: /opt/chef-repo/web.json
sudo cat << EOF > /opt/chef-repo/web.json
{
  "run_list": [ "recipe[apt]", "recipe[phpapp]" ]
}
EOF
sudo chown root:  /opt/chef-repo/lamp.json

cd /opt/chef-repo/ && sudo chef-solo -c solo.rb -j web.json

echo -e "\033[1;34m [+] Accessing Apache Web Interface \033[m";
lynx http://localhost
