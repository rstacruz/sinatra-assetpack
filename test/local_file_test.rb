require File.expand_path('../test_helper', __FILE__)

class LocalFileTest < UnitTest

  class App < Main

    ABS_FONTS_PATH = File.join(File.expand_path('../', __FILE__), 'app', 'app', 'fonts')

    assets {
      css :application, [ '/css/*.css' ]
      serve '/fonts', :from => 'app/fonts'
      serve '/abs_fonts', :from => ABS_FONTS_PATH
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

  test "local file for (in existing files, custom absolute serve path)" do
    fn = App.assets.local_file_for '/abs_fonts/cantarell-regular-webfont.ttf'
    assert_equal "#{App::ABS_FONTS_PATH}/cantarell-regular-webfont.ttf", fn
  end

  test "local file for (in nonexisting files)" do
    fn = App.assets.local_file_for '/images/404.jpg'
    assert fn.nil?
  end

  test "local file for (with remote url)" do
    url  = 'http://example.com/images/200.jpg'
    copy = url.dup
    fn   = App.assets.local_file_for copy
    assert fn.nil?
    assert_equal url, copy
  end

end
