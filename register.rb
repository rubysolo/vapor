#!/usr/bin/env ruby

require 'rubygems'
require 'simple_record'
require 'ruby-debug'

def parse(string)
  string.split(/\n/).inject({}) do |data, line|
    if line =~ /^\s*(\S+):(.*)$/
      symbol = $1.strip
      value = $2.strip

      data.update({symbol => value})
    end
    data
  end
end

data = %x{/tmp/ec2-metadata}

SimpleRecord.establish_connection(ENV['EC2_ACCESS_KEY'], ENV['EC2_SECRET_KEY'])
SimpleRecord::Base.set_domain_prefix(ENV['EC2_ACCESS_KEY'] + '_' + data['keyname'])

class AppServer < SimpleRecord::Base
  has_attributes :instance_id, :private_ip, :public_ip
  validates_uniqueness_of :instance_id
end

app_server = AppServer.new
app_server.instance_id = data['instance-id']
app_server.private_ip  = data['local-ipv4']
app_server.public_ip   = data['public-ipv4']

app_server.save