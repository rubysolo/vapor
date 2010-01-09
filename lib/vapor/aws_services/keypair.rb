module Vapor
  class Keypair < AwsService
    property :name

    def initialize(name)
      self.name = name
    end

    def local_path
      File.join(ENV['HOME'], '.ssh', name)
    end

    def exists?
      File.exists? local_path
    end

    def create
    end
  end
end