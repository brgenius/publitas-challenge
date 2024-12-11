require 'minitest/autorun'
require './application/byte_utils'

class ByteUtilsTest < Minitest::Test
  def test_to_megabytes
    assert_equal 1, Application::ByteUtils.to_megabytes(1048576)
    assert_equal 0.5, Application::ByteUtils.to_megabytes(524288)
  end

  def test_is_lower_than_batch_size
    assert Application::ByteUtils.is_lower_than_batch_size?(1048576, 2)
    refute Application::ByteUtils.is_lower_than_batch_size?(2097152, 1)
  end
end