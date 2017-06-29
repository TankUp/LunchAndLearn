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

  # Returns the currently active Event object
  def self.get_active_event
    Event.last
  end

  # Picks the Video that is going to be watched at the Event
  def pick_final_video
    event_videos.all.max.video
  end

  def add_video_suggestion(video)
    contains_video = event_videos.all.any? do |ev_v|
      ev_v.video.url == video.url
    end

    unless contains_video
      # create new event video
      latest_consecutive_number = EventVideo.where(:event_id => self.id).count + 1

      event_video = EventVideo.create!(video: video, event: self, consecutive_number: latest_consecutive_number)
      event_video.save!
      event_videos << event_video
    end
  end

  # Adds a vote to the Video if such a video is registered for this Event
  def add_video_vote_by_url(user, video_url)
    wanted_video = Video.find_by(url: video_url)
    contains_video = event_videos.all.any? do |ev_v|
      ev_v.video.url == video.url
    end

    if contains_video
      # get the EventVideo object
      event_video = EventVideo.find_by(:event_id => self.id, :video_id => wanted_video.id)
      # vote for it from the user's name
      begin
        EventVideoVote.create!(event_video: event_video, person: user)
      rescue ActiveRecord::RecordInvalid => e
        # the user has already voted for this
      end
    end
  end

  def add_video_vote_by_consecutive_number(user, video_cons_number)
    # get the EventVideo object
    event_video = EventVideo.find_by(:event_id => self.id, :consecutive_number => video_cons_number)
    if event_video.nil?
      return
    end
    # vote for it from the user's name
    begin
      EventVideoVote.create!(event_video: event_video, person: user)
    rescue ActiveRecord::RecordInvalid => e
      # the user has already voted for this
    end
  end
end

# The middle table between Events and Videos, denoting which videos are selected for
# which event
class EventVideo < ActiveRecord::Base
  belongs_to :event
  belongs_to :video
  has_many :event_video_votes

  # returns the number of votes this video has accumulated
  def votes
    event_video_votes.all.count
  end

  def <=>(other_vid)
    self.votes <=> other_vid.votes
  end
end

class EventVideoVote < ActiveRecord::Base
  validates :person_id, uniqueness: {scope: :event_video_id}

  belongs_to :event_video
  belongs_to :person
end

class EventParticipant < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
end

class Venue < ActiveRecord::Base
end