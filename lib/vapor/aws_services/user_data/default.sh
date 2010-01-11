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
user_data << %Q{mkdir /root/bin
cd /root/bin
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata >> /tmp/user_data.log
chmod +x ec2-metadata
mkdir /root/.aws
echo "#{rds_data}" > /root/.aws/rds_data.yml
echo "#{load_balancer_data}" > /root/.aws/load_balancer.yml
echo "#{access_key}" > /root/.aws/access_key
echo "#{secret_key}" > /root/.aws/secret_key
}
# SSH config
user_data << "mkdir -p /root/.ssh\n"
# TODO : which key gets us into github?
[:id_rsa, :github_rsa, :known_hosts, :authorized_keys].each do |keyname|
  user_data << %Q{echo "#{readfile(keyname)}" >> /root/.ssh/#{keyname}\n}
end
user_data << "chmod 0600 /root/.ssh/*\n"
# use the rubysolo amazon-ec2, since it has extra ELB juice
user_data << %Q{cd /tmp
git clone git://github.com/rubysolo/amazon-ec2.git >> /tmp/user_data.log
cd amazon-ec2
echo "+ gem install pkg/amazon-ec2-0.7.9.gem" >> /tmp/user_data.log
gem install pkg/amazon-ec2-0.7.9.gem 2>&1 >> /tmp/user_data.log
}
# Rails config files
user_data << "mkdir /root/rails_config\n"
['facebook.yml', 's3_assets.yml'].each do |config_file|
  user_data << %Q{echo "#{readfile(config_file)}" >> /root/rails_config/#{config_file}\n}
end
# clone the cookbooks, merge dynamic data, and run chef solo to finalize setup
user_data << %Q{git clone #{chef_repo} /etc/chef >> /tmp/user_data.log
ruby /etc/chef/bin/chef_runner.rb 2>&1 >> /tmp/user_data.log
echo "0/5 * * * * root ruby /etc/chef/bin/chef_runner.rb" > /etc/cron.d/chef_runner
