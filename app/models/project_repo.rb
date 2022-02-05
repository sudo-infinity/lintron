class ProjectRepo < ActiveRecord::Base
  default_scope -> { by_slug }
  scope :by_slug, -> { order("lower(org_name || '/' || repo_name)") }

  def slug
    "#{org_name}/#{repo_name}"
  end
end
