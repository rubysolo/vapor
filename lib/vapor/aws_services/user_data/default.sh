#!/bin/sh
set -e -x
apt-get update >> /tmp/user_data.log
apt-get autoremove -y >> /tmp/user_data.log
apt-get install -y ruby ruby-dev rdoc ri git-core >> /tmp/user_data.log
cd /tmp >> /tmp/user_data.log
wget -q http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz >> /tmp/user_data.log
tar zxf rubygems-1.3.5.tgz >> /tmp/user_data.log
cd rubygems-1.3.5 >> /tmp/user_data.log
ruby setup.rb >> /tmp/user_data.log
ln -sfv /usr/bin/gem1.8 /usr/bin/gem >> /tmp/user_data.log
gem sources -a http://gems.opscode.com >> /tmp/user_data.log
gem install chef ohai --no-rdoc --no-ri >> /tmp/user_data.log
cd /tmp >> /tmp/user_data.log
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata >> /tmp/user_data.log
chmod +x ec2-metadata >> /tmp/user_data.log
git clone git@github.com:rubysolo/ec2_cookbooks.git
mkdir -p ~/.ssh
echo "<%= key_content %>" > ~/.ssh/<%= key_name %>
git clone <%= chef_repo_url %>
echo "cookbook_path     ['/etc/chef/site-cookbooks', '/etc/chef/cookbooks']
role_path         '/etc/chef/roles'
log_level         :info
" > /etc/chef/solo.rb
chef-solo -j /etc/chef/dna.json -c /etc/chef/solo.rb >> /tmp/user_data.log