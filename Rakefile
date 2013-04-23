desc "Invokes the test suite in multiple RVM environments"
task :'test!' do
  # Override this by adding RVM_TEST_ENVS=".." in .rvmrc
  envs = ENV['RVM_TEST_ENVS'] || '1.9.2@sinatra,1.8.7@sinatra'
  puts "* Testing in the following RVM environments: #{envs.gsub(',', ', ')}"
  system "rvm #{envs} rake test" or abort
end

desc "Runs tests"
task :test do
  Dir['test/*_test.rb'].each { |f| load f }
end

task :default => :test

gh = "rstacruz/sinatra-assetpack"
namespace :doc do
  desc "Builds the documentation into doc/"
  task :build do
    system "curl -X POST
      -d name=sinatra-assetpack
      -d google_analytics=UA-20473929-1
      -d travis=1
      -d color=#777799
      --data-urlencode content@README.md
      http://documentup.com/compiled > doc/index.html".gsub!(/\s+/, ' ')
  end

  # http://github.com/rstacruz/git-update-ghpages
  desc "Posts documentation to GitHub pages"
  task :deploy => :build do
    system "git update-ghpages #{gh} -i doc/"
  end
end

task :doc => :'doc:build'
