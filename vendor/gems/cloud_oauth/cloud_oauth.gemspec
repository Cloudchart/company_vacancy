$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cloud_oauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cloud_oauth"
  s.version     = CloudOAuth::VERSION
  s.authors     = ["Eugene Kovalev"]
  s.email       = ["seanchas@gmail.com"]
  s.homepage    = "http://cloudorgchart.com"
  s.summary     = "Summary of CloudOAuth."
  s.description = "Description of CloudOAuth."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "oauth2"

end
