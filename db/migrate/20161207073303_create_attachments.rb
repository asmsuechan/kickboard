class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.text :file_data
      t.string :message, null: false

      t.timestamps
    end
  end
end
