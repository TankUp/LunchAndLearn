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

  # Picks the Video that is going to be watched at the Event
  def pick_final_video
    event_videos.all.max.video
  end

  def add_video_suggestion(video)
    contains_video = event_videos.all.any? do |ev_v|
      ev_v.video == video
    end

    unless contains_video
      # create new event video
      event_video = EventVideo.new(video: video, event: self)
      event_video.save!
      event_videos << event_video
    end
  end
end

# The middle table between Events and Videos, denoting which videos are selected for
# which event
class EventVideo < ActiveRecord::Base
  belongs_to :event
  belongs_to :video

  def <=>(other_vid)
    self.votes <=> other_vid.votes
  end
end

class EventParticipant < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
end

class Venue < ActiveRecord::Base
end