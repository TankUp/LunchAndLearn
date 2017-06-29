require 'slack-ruby-bot'

Slack.configure do |config|
  ENV['SLACK_API_TOKEN'] = 'xoxb-205565088373-CbkZFRI2qTT9KXvU0rQ8l2Ym'
  config.token = ENV['SLACK_API_TOKEN']
end
# Run command is
# SLACK_API_TOKEN=xoxb-205565088373-CbkZFRI2qTT9KXvU0rQ8l2Ym bundle exec ruby lunch_bot.rb

class LunchAndLearnBot < SlackRubyBot::Bot
  match /(?<link>http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?)/ do |client, data, match|
    youtube_link = match[:link]
    group_is_dm = data.channel[0] == 'D'
    if group_is_dm
      client.say(channel: data.channel, text: "Thanks for the video, I will add it as a suggestion for the next event :)")
    end
  end

end

LunchAndLearnBot.run