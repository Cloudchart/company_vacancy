$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cloud_profile/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cloud_profile"
  s.version     = CloudProfile::VERSION
  s.authors     = ["Eugene Kovalev"]
  s.email       = ["seanchas@gmail.com"]
  s.homepage    = "http://cloudirgchart.com"
  s.summary     = "Summary of CloudProfile."
  s.description = "Description of CloudProfile."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
end
