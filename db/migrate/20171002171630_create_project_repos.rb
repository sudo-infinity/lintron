class CreateProjectRepos < ActiveRecord::Migration
  def change
    create_table :project_repos do |t|
      t.string   "org_name",   null: false, index: true
      t.string   "repo_name",  null: false, index: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
