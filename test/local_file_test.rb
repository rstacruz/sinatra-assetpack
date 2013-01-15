require File.expand_path('../test_helper', __FILE__)

class LocalFileTest < UnitTest
  class App < UnitTest::App
    register Sinatra::AssetPack

    assets {
      css :application, [ '/css/*.css' ]
      serve '/fonts',    :from => 'app/fonts'
    }
  end

  test "local file for (in existing files)" do
    fn = App.assets.local_file_for '/images/background.jpg'
    assert_equal r('app/images/background.jpg'), fn
  end

  test "local file for (in existing files, custom serve path)" do
    fn = App.assets.local_file_for '/fonts/cantarell-regular-webfont.ttf'
    assert_equal r('app/fonts/cantarell-regular-webfont.ttf'), fn
  end

  test "local file for (in nonexisting files)" do
    fn = App.assets.local_file_for '/images/404.jpg'
    assert fn.nil?
  end
end
