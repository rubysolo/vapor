require File.join(File.dirname(__FILE__), '..', 'test_helper')

class CloudTest < Test::Unit::TestCase
  include Vapor

  def setup
    @test_cloud = Cloud.new(self, 'test_cloud')
  end

  def test_create_cloud
    assert @test_cloud.is_a?(Cloud)
  end

  def test_pools_iterator
    assert @test_cloud.pools.respond_to?(:each)
  end
end