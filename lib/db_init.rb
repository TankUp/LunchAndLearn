require 'active_record'

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', database: '../database.db'
)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'events'
    create_table :events do |table|
      table.column :week,     :integer
      table.column :video_id, :integer
      table.column :food_id, :integer
      table.column :venue_id, :integer
      table.column :manager_id, :integer, through: 'people'
      table.column :event_datetime, :datetime
      table.column :votes_initiated_at, :datetime
      table.column :time_votes_active, :boolean, default: true
      table.column :monday_votes, :integer, defaut: 0
      table.column :tuesday_votes, :integer, defaut: 0
      table.column :wednesday_votes, :integer, defaut: 0
      table.column :thursday_votes, :integer, defaut: 0
      table.column :friday_votes, :integer, defaut: 0
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'event_participants'
    create_table :event_participants do |table|
      table.column :event_id, :integer
      table.column :person_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'people'
    create_table :people do |table|
      table.column :slack_name, :string
      table.column :slack_id, :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'videos'
    create_table :videos do |table|
      table.column :url, :string, :unique => true
      table.column :total_votes, :integer
      table.column :views, :integer
      table.column :like_ratio, :float
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'event_videos'
    create_table :event_videos do |table|
      table.column :event_id, :integer
      table.column :video_id, :integer
      table.column :votes, :integer
      table.column :consecutive_number, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'event_video_votes'
    create_table :event_video_votes do |table|
      table.column :event_video_id, :integer
      table.column :person_id, :integer
    end
  end

  # The table holding information on which person voted on which time to host the event
  unless ActiveRecord::Base.connection.tables.include? 'event_time_votes'
    create_table :event_time_votes do |table|
      table.column :event_id, :integer
      table.column :person_id, :integer
      table.column :monday_votes, :integer
      table.column :tuesday_votes, :integer
      table.column :wednesday_votes, :integer
      table.column :thursday_votes, :integer
      table.column :friday_votes, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'venues'
    create_table :venues do |table|
      table.column :name, :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'foods'
    create_table :foods do |table|
      table.column :food_type, :string, :unique => true
      table.column :total_votes, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'event_foods'
    create_table :event_foods do |table|
      table.column :event_id, :integer
      table.column :food_id, :integer
      table.column :votes, :integer
      table.column :consecutive_number, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'event_food_votes'
    create_table :event_food_votes do |table|
      table.column :event_food_id, :integer
      table.column :person_id, :integer
    end
  end
end
