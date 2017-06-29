class Video < ActiveRecord::Base
  has_many :event_videos
  has_many :events, :through => :event_videos
end

class Person < ActiveRecord::Base
  has_many :event_participants
  has_many :events, :through => :event_participants
end

class Event < ActiveRecord::Base
  has_many :event_participants
  has_many :event_videos
  has_many :people, :through => :event_participants
  has_many :videos, :through => :event_videos
end

class EventParticipant < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
end

class Venue < ActiveRecord::Base
end