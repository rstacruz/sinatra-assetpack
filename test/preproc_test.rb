require File.expand_path('../test_helper', __FILE__)

class PreprocTest < UnitTest
  test "preproc" do
    get '/css/screen.css'
    assert body =~ %r{email.[0-9]+.png}
  end

  test "preproc static files" do
    get '/css/style.css'
    assert body =~ %r{background.[0-9]+.jpg}
  end
  
  test "preproc static files should not fail with images at a different path" do
    get '/css/style.css'
    assert_no_match %r{url\(url\(}, body, "Error in CSS preprocessor! Invalid syntax in image reference."
    assert body.include?("background: url(/images2/background.jpg)"), "CSS images that aren't in the main images directory shouldn't get a cache-buster filename"
  end

  test "preproc on minify" do
    get '/css/application.css'
    assert body =~ %r{email.[0-9]+.png}
  end

  test "embed" do
    get '/css/screen.css'
    assert body =~ %r{data:image/png;base64,[A-Za-z0-9=/]{100,}}
  end
end
