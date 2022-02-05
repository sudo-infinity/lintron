class DeleteDupePRs < ActiveRecord::Migration
  def up
    PullRequest.connection.execute(
      <<-SQL
        DELETE FROM pull_requests
        WHERE id in (
          SELECT id
          FROM pull_requests
          WHERE id not in (
            SELECT max(id)
            FROM pull_requests
            GROUP BY repo, org, pr_number
          )
        );
      SQL
    )
  end

  def down; end
end
