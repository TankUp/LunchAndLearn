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
  has_many :event_time_votes
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
      return false, "Video number #{video_cons_number} does not exist!"
    end
    # vote for it from the user's name
    begin
      EventVideoVote.create!(event_video: event_video, person: user)
      return true, "Your vote for video #{video_cons_number} was accepted!"
    rescue ActiveRecord::RecordInvalid => e
      # the user has already voted for this
      return false, "You have already voted for video #{video_cons_number}"
    end
  end

  # Adds a vote for the day the event should be hosted on
  def add_event_time_vote(user, day)
    # TODO: Check if event vote is initialized
    # TODO: Check if event vote has expired
    begin
      person_vote = event_time_votes.find_by!(:person_id => user.id)
    rescue ActiveRecord::RecordNotFound
      person_vote = EventTimeVote.create(person: user, event: self)
    end

    is_new_vote = false
    case day
      when /[Mm]onday/
        is_new_vote = EventTimeVote.is_new_vote(person_vote.monday_votes)
        self.monday_votes += 1 if is_new_vote
        person_vote.monday_votes = 1
      when /[Tt]uesday/
        is_new_vote = EventTimeVote.is_new_vote(person_vote.tuesday_votes)
        self.tuesday_votes += 1 if is_new_vote
        person_vote.tuesday_votes = 1
      when /[Ww]ednesday/
        is_new_vote = EventTimeVote.is_new_vote(person_vote.wednesday_votes)
        self.wednesday_votes += 1 if is_new_vote
        person_vote.wednesday_votes = 1
      when /[Tt]hursday/
        is_new_vote = EventTimeVote.is_new_vote(person_vote.thursday_votes)
        self.thursday_votes += 1 if is_new_vote
        person_vote.thursday_votes = 1
      when /[Ff]riday/
        is_new_vote = EventTimeVote.is_new_vote(person_vote.friday_votes)
        self.friday_votes += 1 if is_new_vote
        person_vote.friday_votes = 1
      else
        raise Exception.new("#{day} is not a valid day for the Event Time!")
    end

    person_vote.save!
    self.save!

    if is_new_vote
      return true, "Your vote for hosting the event on #{day.capitalize} was accepted!"
    else
      return false, "You have already voted for hosting the event on #{day.capitalize}"
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

class EventTimeVote < ActiveRecord::Base
  validates :person_id, uniqueness: {scope: :event_id}

  belongs_to :person
  belongs_to :event

  # Returns a boolean indicating if the given day (e.g monday_votes) was voted for
  def self.is_new_vote(old_vote)
    return old_vote != 1
  end
end

class EventParticipant < ActiveRecord::Base
  validates :person_id, uniqueness: {scope: :event_id}

  belongs_to :person
  belongs_to :event
end

class Venue < ActiveRecord::Base
end