Gem::Specification.new do |s|
  s.name        = 'lintron'
  s.version     = '1.0.1'
  s.licenses    = ['MIT']
  s.summary     = "A CLI for running lintron against your changes."
  s.description = "A command line tool for using the lintron service against local changes (requires a lintron server)."
  s.authors     = ["Robert Prehn", "Revelry Labs"]
  s.email       = 'robert@revelry.co'
  s.files       = [
    'bin/lintron',
    'lib/lintron.rb',
    Dir['lib/lintron/**/*'],
    'app/models/local_pr_alike.rb',
    'app/models/patch.rb',
    'app/models/stub_file.rb',
    'app/models/file_like.rb',
  ].flatten
  s.homepage    = 'https://github.com/prehnra/lintron'
  s.executables << 'lintron'

  s.add_dependency 'activesupport', '>= 4.2.1'
  s.add_dependency 'git_diff_parser', '~> 2.3.0'
  s.add_dependency 'httparty', '~> 0.14.0'
  s.add_dependency 'colorize', '~> 0.8.1'
  s.add_dependency 'ruby-terminfo', '~> 0.1.1'
  s.add_dependency 'filewatcher', '~> 0.5.3'
end
