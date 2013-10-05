# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "fms-admin-api/version"

Gem::Specification.new do |s|
  s.name        = "fms-admin-api"
  s.version     = FMS::VERSION
  s.authors     = ["Igor Sobreira, Xavier MORTELETTE"]
  s.email       = ["igor@igorsobreira.com, reivaxm@gmail.com"]
  s.homepage    = "http://github.com/reivaxm/fms-admin-api"
  s.summary     = %q{Ruby client and command line interface to Flash Media Server Administration API}
  s.description = %q{Ruby client and command line interface to Flash Media Server Administration API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activesupport", "> 3.0"
  s.add_runtime_dependency "nokogiri", "> 1.5.9"
  s.add_runtime_dependency "colorize"
  #s.add_development_dependency "webmock"
  #s.add_development_dependency "rake"
  #s.add_development_dependency "mocha"
end
