class CreateDiffbotResponses < ActiveRecord::Migration
  def up
    create_table :diffbot_responses, id: false do |t|
      t.string :uuid, limit: 36
      t.string :api
      t.string :resolved_url
      t.text :body, limit: 16777215
      t.text :data

      t.timestamps
    end

    execute 'ALTER TABLE diffbot_responses ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :diffbot_responses
  end
end
