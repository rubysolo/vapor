$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

ENV['AWS_ACCESS_KEY'] = 'fake-access-key'
ENV['AWS_SECRET_KEY'] = 'fake-secret-key'

require 'vapor'
require "rubygems"
require "test/unit"
require 'mocha'
