$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "statux/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "statux"
  s.version     = Statux::VERSION
  s.authors     = ["Elias Baixas"]
  s.email       = ["elias.baixas@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Statux."
  s.description = "TODO: Description of Statux."
  s.license     = "none"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "pg"
end
