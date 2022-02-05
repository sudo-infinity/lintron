namespace :pr do
  task :lint_and_comment, [:url] => :environment do |task, args|
    if args[:url] && PullRequest::PR_URL_PATTERN =~ args[:url]
      pr = PullRequest.from_url(args[:url])
      pr.lint_and_comment!
    else
      puts "Please provide the URL of a GitHub PR to lint"
    end
  end

  task :lint_to_console, [:url] => :environment do |task, args|
    if args[:url] && PullRequest::PR_URL_PATTERN =~ args[:url]
      pr = PullRequest.from_url(args[:url])
      puts Linters.violations_for_pr(pr).as_json
    else
      puts "Please provide the URL of a GitHub PR to lint"
    end
  end
end
