module Vapor
  class SecurityGroup < AwsService
    property :name

    def initialize(name)
      self.name = name
    end

    def exists?
    end

    def create
    end
  end
end