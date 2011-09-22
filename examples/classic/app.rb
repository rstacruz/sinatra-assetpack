$:.unshift File.expand_path('../../../lib', __FILE__)

require 'sinatra'
require 'sinatra/assetpack'

assets do
  # By default, Sinatra::AssetPack looks at ./app/css/, ./app/js/ and
  # ./app/images. Let's change this to look at ./css.
  serve '/css', from: 'css'

  css :main, [
    '/css/*.css'
  ]
end

get "/" do
  css :main
end

__END__

@@ index
<%= css :main %>
<h1>Hello!</h1>
