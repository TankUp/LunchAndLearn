require 'slack-ruby-bot'
require 'date'
require_relative 'bot_helper'
require 'video_info'


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



  match /Food vote (?<vote>.+)/   do |client, data, match|
    food_vote = match[:vote]

    user = Person.find_by(slack_id: current_user)
    if user.nil?
      user_name = BotHelper.fetch_username_by_id(current_user)
      user = Person.create(slack_id: current_user, slack_name: user_name)
    end
    Event.get_active_event.add_food_vote_by_consecutive_number
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

  # Accept a vote for the time of day of the event
  match /Voting for (?<day>([Mm]onday)|([Tt]uesday)|([Ww]ednesday)|([Tt]hursday)|([Ff]riday))/ do |client, data, match|
    vote_day = match[:day]
    current_user = data.user

    user = Person.find_by(slack_id: current_user)
    if user.nil?
      user_name = BotHelper.fetch_username_by_id(current_user)
      user = Person.create(slack_id: current_user, slack_name: user_name)
    end

    _, message = Event.get_active_event.add_event_time_vote(user, vote_day)

    # PM the user the resulting message
    user_channel = BotHelper.fetch_channel_by_user_id(user.slack_id)
    client.say(channel: user_channel.id, text: message)
  end


  match // do |client, data, _|
    try_announce_event_time_vote(client)
    try_end_event_time_votes(client)
  end


  # Every other match, used to keep the bot active, tracking when
  # it should create a new event and etc
  match /.*/ do |client, data, _|
    try_announce_event_time_vote(client)
    try_end_event_time_votes(client)
    try_create_next_event
  end


  # Creates a new event and initiates a vote for it
  def self.announce_event_vote(client)
    # Don't announce votes more frequently than every 10 seconds
    return if (not @last_vote_time.nil?) && (Time.now - @last_vote_time) < 10

    current_event = Event.get_active_event
    client.say(channel: $main_channel, text: "Accepting votes for Lunch and Learn week #{current_event.week}\n")
    vote_text = current_event.event_videos.all.reduce('') do |vote_text, event_vid|
      vidinf = VideoInfo.new(event_vid.video.url)
      vote_text + "#{event_vid.consecutive_number}) 🎥 *#{vidinf.title}* - #{event_vid.video.url} \n  _#{vidinf.description}_ \n \n #{get_number(event_vid.votes)} votes \n\n\n"

    end
    client.say(channel: $main_channel, text: vote_text)

    @last_vote_time = Time.now
  end

  # Initiates a Vote for the date of the next event if it has not been initiated
  def self.try_announce_event_time_vote(client)
    current_event = Event.get_active_event
    return unless current_event.votes_initiated_at.nil?

    # initiate a new vote for the event
    current_event.votes_initiated_at = DateTime.now
    current_event.time_votes_active = true
    current_event.save!

    # announce in the channel
    client.say(channel: $main_channel, text: "<!channel> Accepting votes for the day of the Lunch and Learn week #{current_event.week} event!")
    voting_options_text = %Q$
    Monday @ 13:00 - 14:00 (#{current_event.monday_votes} votes)
Tuesday @ 13:00 - 14:00 (#{current_event.tuesday_votes} votes)
Wednesday @ 13:00 - 14:00 (#{current_event.wednesday_votes} votes)
Thursday @ 13:00 - 14:00 (#{current_event.thursday_votes} votes)
Friday @ 13:00 - 14:00 (#{current_event.friday_votes} votes)
    $
    client.say(channel: $main_channel, text: voting_options_text)
  end

  # Tries to end the votes for the time of the event and pick the best one
  # @return [Boolean] - if the event ended or not
  def self.try_end_event_time_votes(client)
    current_event = Event.get_active_event
    return false unless current_event.time_votes_active
    hours_from_vote_start = ((Time.now - current_event.votes_initiated_at) / 3600).round
    if hours_from_vote_start >= 0
      # if 3 or more hours have passed since the vote, close it
      current_event.time_votes_active = false
      client.say(channel: $main_channel, text: 'The voting for the date of the event is closed!')
      day, votes = current_event.pick_winning_day
      event_datetime = DateTime.now.next_wday(day).to_date.to_datetime.advance(:hours => 13)  # convert it to 13:00 exactly
      client.say(channel: $main_channel,
                 text: "<!channel> :warning: EVENT TIME - The day the event will be held is next #{day}(#{event_datetime.strftime('%d/%m/%Y')}) @ 13:00 - 14:00 (#{votes} votes)")
      current_event.event_datetime = event_datetime
      current_event.save!
      false
    end
    true
  end

  # Tries to create the new event
  def self.try_create_next_event
    # Create it only a couple of hours after the one ended
    last_event = Event.get_active_event
    return unless DateTime.now > last_event.event_datetime.advance(:hours => 4)

    Event.create!(monday_votes: 0, tuesday_votes: 0, wednesday_votes: 0, thursday_votes: 0, friday_votes: 0, week: last_event.week + 1)
  end

  def self.get_number(num) 
    case num
  when 0
   "0️⃣"
  when 1
   "1️⃣"
  when 2 
   "2️⃣"    
  when 3
 "3️⃣"
  when 4
"4️⃣" 
  when 5
"5️⃣"
  when 6
"6️⃣"
  when 7
"7️⃣"
  when 8
"8️⃣"
  when 9
"9️⃣"
else 
  "no such number"
  end
end
end
