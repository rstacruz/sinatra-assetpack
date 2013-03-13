require File.expand_path('../test_helper', __FILE__)

class BuildTest < UnitTest
  setup do
    app.assets.css_compression = :simple
    @source_path = File.join(app.root, 'app/js/hello.js')
    @source_tmp = File.read(@source_path)
  end

  teardown do
    FileUtils.rm_rf File.join(app.root, 'public')
    File.open(@source_path, 'wb') { |f| f.write @source_tmp }
  end

  test "build" do
    Stylus.expects(:compile).returns("body{background:#f00;color:#00f;}")
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

  test "rebuilding" do
    source_path = File.join(app.root, 'app/js/hello.js')
    build_path = File.join(app.root, 'public/js/app.js')

    app.assets.build!
    assert File.read(build_path).include?('function(){alert("Hello");')

    File.open(source_path, 'wb') { |f| f.write 'function(){alert("New");' }

    app.assets.build!
    assert File.read(build_path).include?('function(){alert("New");')
  end

end
