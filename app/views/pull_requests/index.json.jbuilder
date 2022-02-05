@prs.each do |pr|
  json.child! do
    json.(pr, :org, :repo, :pr_number, :tests?)
    json.merged pr.github_cache['merged']
    json.author pr.github_cache['user']['login']
    json.created_at pr.github_cache['created_at'].to_date.strftime('%Y-%m-%d')
  end
end
