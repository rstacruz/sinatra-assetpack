require File.expand_path('../test_helper', __FILE__)

class BuildTest < UnitTest
  teardown do
    FileUtils.rm_rf File.join(app.root, 'public')
  end

  test "build" do
    Stylus.expects(:compile).returns("body{background:#f00;color:#00f;}")
    app.assets.css_compression = :simple
    app.assets.build!

    assert File.file? File.join(app.root, 'public/js/app.js')
    assert File.mtime(File.join(app.root, 'public/js/app.js')).to_i == app.assets.packages['app.js'].mtime.to_i

    assert Dir[File.join(app.root, 'public/js/app.*.js')].first

    assert File.read(File.join(app.root, 'public/js/app.js')).include?('function(){alert("Hello");')

    assert Dir["#{app.root}/public/images/background.*.jpg"].first
    assert Dir["#{app.root}/public/images/email.*.png"].first

    assert \
      File.mtime(Dir["#{app.root}/public/images/background.*.jpg"].first).to_i ==
      File.mtime(Dir["#{app.root}/public/images/background.jpg"].first).to_i

    assert \
      File.mtime(Dir["#{app.root}/public/images/background.*.jpg"].first).to_i ==
      File.mtime(Dir["#{app.root}/app/images/background.jpg"].first).to_i
  end
end
