require 'rubygems'
require 'AWS'
require 'ruby-debug'
require 'getset'

module Vapor
  class Base
    extend Getset
    property :parent, :name

    def self.load_config(filename)
      @vapor = self.new(nil, 'vapor')
      @vapor.instance_eval(IO.read(filename))
      @vapor
    end

    def initialize(parent, name)
      self.parent = parent
      self.name = name
      after_initialize
    end

    def after_initialize
      # subclasses can implement an after_initialize hook
      @cloud = parent
    end

    def cloud(name, &block)
      @cloud = Cloud.new(self, name)
      @cloud.instance_eval(&block)
    end

    # COMMANDS : TODO : refactor

    def start
      AwsService.verify_environment

      # subclasses should handle start for themselves
      raise ":start not implemented by #{self.class}!" unless self.class == Vapor::Base
      puts "--- starting cloud #{@cloud.name}..."
      @cloud.start
    end

    def show
      AwsService.verify_environment
      raise ":show not implemented by #{self.class}!" unless self.class == Vapor::Base
      @cloud.show
    end

    def stop
      AwsService.verify_environment
      raise ":stop not implemented by #{self.class}!" unless self.class == Vapor::Base
      @cloud.stop
    end

    def ssh
      AwsService.verify_environment
      # TODO : specify pool / instance
      n, p = @cloud.pools.first
      @instance = 0
      p.ssh(@instance)
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'vapor', '*.rb')].each do |vapor_file|
  require vapor_file
end