require File.expand_path('../test_helper', __FILE__)

class BusterHelpersTest < UnitTest
  include Sinatra::AssetPack

  test "adds md5 to name for one file" do
    filename = BusterHelpers.add_cache_buster '/css/style.css', asset('css/style.css')
    assert_equal '/css/style.7a1b92c3f56ab5cfa73c1aa8222961cf.css', filename
  end


  test "adds md5 to name for multiple files" do
    filename = BusterHelpers.add_cache_buster '/css/style.css', asset('css/style.css'), asset('css/js2c.css')
    assert_equal '/css/style.4400cb67aeffa49b8fe18bc4e0187f86.css', filename
  end

  test "doesn't add md5 for non-existent file" do
    assert_equal '/css/style.css', BusterHelpers.add_cache_buster('/css/style.css', 'asdf')
  end

  private

  def asset(file)
    File.expand_path(File.dirname(__FILE__)) + '/app/app/' + file
  end

end
