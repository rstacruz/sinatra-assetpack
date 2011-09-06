require File.expand_path('../test_helper', __FILE__)

class BuildTest < UnitTest
  teardown do
    FileUtils.rm_rf app.public
  end

  test "build" do
    Stylus.expects(:compile).returns("body{background:#f00;color:#00f;}")
    app.assets.css_compression = :simple
    app.assets.build!

    assert File.file? File.join(app.root, 'public/js/app.js')
    assert Dir[File.join(app.root, 'public/js/app.*.js')].first

    assert File.read(File.join(app.root, 'public/js/app.js')).include?('function(){alert("Hello");')

    assert Dir["#{app.root}/public/images/background.*.jpg"].first
    assert Dir["#{app.root}/public/images/email.*.png"].first
  end
end
