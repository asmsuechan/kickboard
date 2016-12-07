class AddRepoNameToAttachment < ActiveRecord::Migration[5.0]
  def up
    add_column :attachments, :repo_name, :string
    change_column :attachments, :repo_name, :string, :null => false
  end

  def down
    remove_column :attachments, :repo_name
  end
end
