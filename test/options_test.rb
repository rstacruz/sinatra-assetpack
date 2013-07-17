require File.expand_path('../test_helper', __FILE__)

class OptionsTest < UnitTest
  class App < Main
    assets {
      css :application, [ '/css/*.css' ]
      js_compression :closure
    }
  end

  def app
    App
  end

  test "options" do
    assert App.assets.js_compression == :closure
    assert App.assets.packages['application.css'].path == "/assets/application.css"
  end

  test "serve requires :from parameter" do
    err = assert_raise ArgumentError do
      App.assets.serve "/foo"
    end
    assert_equal "Parameter :from is required", err.message
  end

  test "serve requires :from to be directory" do
    e = assert_raise Errno::ENOTDIR do
      App.assets.serve "/foo", :from => "/does/not/exist"
    end
  end


end
