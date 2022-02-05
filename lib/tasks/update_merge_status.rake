namespace :update do
  task :merge_status => :environment do
    PullRequest.unmerged.after(Time.zone.now - 14.days).find_each do |pr|
      pr.save!
    end
  end
end
