Github.configure do |c|
  c.basic_auth = "prehnra:#{ ENV['GITHUB_TOKEN'] }"
end
