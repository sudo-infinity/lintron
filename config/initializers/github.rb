Github.configure do |c|
  c.basic_auth = "#{ ENV['GITHUB_USERNAME'] }:#{ ENV['GITHUB_TOKEN'] }"
end
