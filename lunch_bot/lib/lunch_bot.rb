require 'slack-ruby-bot'
require 'date'
# Run command is

class LunchAndLearnBot < SlackRubyBot::Bot

  match /(?<link>http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?)/ do |client, data, match|
    youtube_link = match[:link]
    group_is_dm = data.channel[0] == 'D'
    current_user = data.user
    user = Person.find_by(slack_name: current_user)
    if user.nil?
      user = Person.create(slack_name: current_user)
    end

    if group_is_dm
      client.say(channel: data.channel, text: 'Thanks for the video, I will add it as a suggestion for the event :)')
      # TODO: Query YT API for views, likes and etc
      vid = Video.new(url: youtube_link)
      Event.get_active_event.add_video_suggestion(vid)
    end

    # TODO: Initiate event vote in main channel :)
    announce_event_vote(client)
  end

  match /Voting for (?<vote_number>\d+)/ do |client, data, match|
    vote_num = match[:vote_number].to_i
    current_user = data.user
    user = Person.find_by(slack_name: current_user)
    if user.nil?
      user = Person.create(slack_name: current_user)
    end

    Event.get_active_event.add_video_vote_by_consecutive_number(user, vote_num)
  end

  # creates a new event and initiates a vote for it
  def self.announce_event_vote(client)
    # Don't announce votes more frequently than every 10 seconds
    return if (not @last_vote_time.nil?) && (Time.now - @last_vote_time) < 10

    current_event = Event.get_active_event
    client.say(channel: $main_channel, text: 'Accepting votes for videos!')
    # get the videos by URL
    vote_text = ''
    current_event.event_videos.all.each do |event_vid|
      vote_text += "#{event_vid.consecutive_number} (#{event_vid.votes} votes)- #{event_vid.video.url}\n"
    end
    client.say(channel: $main_channel, text: vote_text)
    @last_vote_time = Time.now
  end
end

# LunchAndLearnBot.run
