require 'rails_helper'

def pr_with_params(attrs)
  pr = PullRequest.new(org: attrs[:org], repo: attrs[:repo], pr_number: attrs[:pr_number])
  allow(pr).to receive(:to_gh).and_return(attrs[:github_cache])
  pr.update(attrs)
  pr
end

RSpec.describe PullRequestsController, type: :controller do
  let!(:merged_lintron_two_weeks_ago) do
    pr_with_params(
      org: 'revelrylabs',
      repo: 'lintron',
      pr_number: 123,
      github_cache: { created_at: Time.zone.now - 2.week, merged: true },
    )
  end

  let!(:unmerged_lintron_one_week_ago) do
    pr_with_params(
      org: 'revelrylabs',
      repo: 'lintron',
      pr_number: 124,
      github_cache: { created_at: Time.zone.now - 1.week, merged: false },
    )
  end

  let!(:unmerged_lintron_today) do
    pr_with_params(
      org: 'revelrylabs',
      repo: 'lintron',
      pr_number: 125,
      github_cache: { created_at: Time.zone.now, merged: false  },
    )
  end

  let!(:unmerged_other_today) do
    pr_with_params(
      org: 'revelrylabs',
      repo: 'other',
      pr_number: 1,
      github_cache: { created_at: Time.zone.now, merged: false  },
    )
  end

  before :each do
    user = User.create!(email: 'rufus@example.com', password: 'testingly')
    sign_in user
    allow_any_instance_of(PullRequest).to receive(:to_gh).and_return({})
  end

  it 'handles start date param' do
    get :index, start_date: (Time.zone.now - 1.week).beginning_of_day, end_date: Time.zone.now
    expect(assigns(:prs).length).to eq 3
  end

  it 'handles end date param' do
    get :index, start_date: Date.parse('1/1/1901'), end_date: (Time.zone.now - 1.week).end_of_day
    expect(assigns(:prs).length).to eq 2
  end

  it 'handles merged param' do
    get :index, merged: 'true'
    expect(assigns(:prs).length).to eq 1
    expect(assigns(:prs)).to include merged_lintron_two_weeks_ago

    get :index, merged: 'false'
    expect(assigns(:prs).length).to eq 3
    expect(assigns(:prs)).to include unmerged_lintron_one_week_ago
    expect(assigns(:prs)).to include unmerged_lintron_today
    expect(assigns(:prs)).to include unmerged_other_today

    get :index, merged: ''
    expect(assigns(:prs).length).to eq 4
    expect(assigns(:prs)).to include merged_lintron_two_weeks_ago
    expect(assigns(:prs)).to include unmerged_lintron_one_week_ago
    expect(assigns(:prs)).to include unmerged_lintron_today
    expect(assigns(:prs)).to include unmerged_other_today
  end

  it 'handles repo param' do
    get :index, repo: 'revelrylabs/lintron'
    expect(assigns(:prs).length).to eq 3
  end
end
