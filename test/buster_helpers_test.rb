require File.expand_path('../test_helper', __FILE__)

class BusterHelpersTest < UnitTest
  include Sinatra::AssetPack

  test "adds md5 to name for one file" do
    filename = BusterHelpers.add_cache_buster '/css/style.css', asset('css/style.css')
    assert %r{/css/style.[a-f0-9]{32}.css} =~ filename
  end


  test "adds md5 to name for multiple files" do
    filename = BusterHelpers.add_cache_buster '/css/style.css', asset('css/style.css'), asset('css/js2c.css')
    assert %r{\/css\/style.[a-f0-9]{32}.css} =~ filename
  end

  test "doesn't add md5 for non-existent file" do
    assert_equal '/css/style.css', BusterHelpers.add_cache_buster('/css/style.css', 'asdf')
  end

  private

  def asset(file)
    File.expand_path(File.dirname(__FILE__)) + '/app/app/' + file
  end

end
