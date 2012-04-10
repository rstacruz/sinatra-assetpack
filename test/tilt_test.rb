require File.expand_path('../test_helper', __FILE__)

class OptionsTest < UnitTest
  test "tilt mappings" do
    @formats = Sinatra::AssetPack.tilt_formats
    assert @formats['sass'] == 'css'
    assert @formats['scss'] == 'css'
    assert @formats['less'] == 'css'
    assert @formats['coffee'] == 'js'
  end
end

