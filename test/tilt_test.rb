require File.expand_path('../test_helper', __FILE__)

class OptionsTest < UnitTest
  test "tilt mappings" do
    # @todo Remove when fix is merged in tilt
    # https://github.com/rtomayko/tilt/pull/206
    # trigger Tilt issue 206 then reset formats
    assert_nil Tilt["hello.world"]		
    Sinatra::AssetPack.instance_variable_set :@formats, nil
    # extract formats
    @formats = Sinatra::AssetPack.tilt_formats
    assert @formats['sass'] == 'css'
    assert @formats['scss'] == 'css'
    assert @formats['less'] == 'css'
    assert @formats['coffee'] == 'js'
  end
end

