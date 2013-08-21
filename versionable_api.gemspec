$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "versionable_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "versionable_api"
  s.version     = VersionableApi::VERSION
  s.authors     = ["Chris TenHarmsel"]
  s.email       = ["chris.tenharmsel@centro.net"]
  s.homepage    = "http://www.github.com/centro/versionable_api"
  s.summary     = "Versionable API Rails Engine"
  s.description = "Simple Rails Engine that provides the framework for sane versionable APIs"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"

  s.add_development_dependency "sqlite3"
end
