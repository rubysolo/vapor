require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PoolTest < Test::Unit::TestCase
  include Vapor

  def setup
    @test_cloud = Cloud.new(self, 'test_cloud')
    @test_cloud.pool :test_pool do
      instances 1
    end
    @test_pool = @test_cloud.pools[:test_pool]
  end

  def test_new_pool
    assert @test_pool.is_a?(Pool)
  end

  def test_instances_accessor
    assert_equal 1, @test_pool.minimum_instances
    assert_equal 1, @test_pool.maximum_instances
  end
end
