require 'slack-ruby-bot'
require 'date'
require_relative 'bot_helper'


class LunchAndLearnBot < SlackRubyBot::Bot

  # Add video suggestion
  match /(?<link>http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?)/ do |client, data, match|
    return unless data.channel[0] == 'D'  # if its not a private message, don't count the video
    youtube_link = match[:link]
    current_user = data.user

    user = Person.find_by(slack_id: current_user)
    if user.nil?
      user_name = BotHelper.fetch_username_by_id(current_user)
      user = Person.create(slack_id: current_user, slack_name: user_name)
    end

    client.say(channel: data.channel, text: 'Thanks for the video, I will add it as a suggestion for the event :)')
    # TODO: Query YT API for views, likes and etc
    vid = Video.new(url: youtube_link)
    Event.get_active_event.add_video_suggestion(vid)

    # TODO: Initiate event vote in main channel :)
    announce_event_vote(client)
  end

  # Accept a vote via a number (i.e vote for video 3)
  match /Voting for (?<vote_number>\d+)/ do |client, data, match|
    vote_num = match[:vote_number].to_i
    current_user = data.user

    user = Person.find_by(slack_id: current_user)
    if user.nil?
      user_name = BotHelper.fetch_username_by_id(current_user)
      user = Person.create(slack_id: current_user, slack_name: user_name)
    end

    _, message = Event.get_active_event.add_video_vote_by_consecutive_number(user, vote_num)

    # PM the user the resulting message
    user_channel = BotHelper.fetch_channel_by_user_id(user.slack_id)
    client.say(channel: user_channel.id, text: message)
  end

  # Creates a new event and initiates a vote for it
  def self.announce_event_vote(client)
    # Don't announce votes more frequently than every 10 seconds
    return if (not @last_vote_time.nil?) && (Time.now - @last_vote_time) < 10

    current_event = Event.get_active_event
    client.say(channel: $main_channel, text: 'Accepting votes for videos!')
    intro_text = "Accepting votes for Lunch and Learn week #{current_event.week}\n"
    vote_text = current_event.event_videos.all.reduce(intro_text) do |vote_text, event_vid|
      vote_text + "#{event_vid.consecutive_number} (#{event_vid.votes} votes)- #{event_vid.video.url}\n"
    end
    client.say(channel: $main_channel, text: vote_text)

    @last_vote_time = Time.now
  end
end
