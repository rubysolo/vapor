#!/bin/sh
set -e -x
# install ruby, gems, and chef
apt-get update >> /tmp/user_data.log
apt-get autoremove -y >> /tmp/user_data.log
apt-get install -y ruby ruby-dev rdoc ri git-core >> /tmp/user_data.log
cd /tmp >> /tmp/user_data.log
wget -q http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz >> /tmp/user_data.log
tar zxf rubygems-1.3.5.tgz >> /tmp/user_data.log
cd rubygems-1.3.5
ruby setup.rb >> /tmp/user_data.log
ln -sfv /usr/bin/gem1.8 /usr/bin/gem
ln -sfv /usr/bin/irb1.8 /usr/bin/irb
gem sources -a http://gems.opscode.com >> /tmp/user_data.log
gem install chef ohai rake --no-rdoc --no-ri >> /tmp/user_data.log
# add AWS credentials and tools
cd /usr/local/bin
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata >> /tmp/user_data.log
chmod +x ec2-metadata
mkdir /root/.aws