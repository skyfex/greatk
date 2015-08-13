Gem::Specification.new do |s|
  s.name        = 'greatk'
  s.version     = '0.1.0'
  s.date        = '2015-07-13'
  s.summary     = "A Gtk2 DSL for Ruby"
  s.description = "A Gtk2 DSL for Ruby"
  s.authors     = ["Audun Wilhelmsen"]
  s.email       = 'audun@awil.no'
  s.files       = ["lib/greatk.rb"]
  s.homepage    = 'https://github.com/skyfex/greatk'
  s.license     = 'MIT'
  s.add_runtime_dependency "gtk2", ["> 2.0.0"]
end