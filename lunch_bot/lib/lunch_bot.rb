require 'slack-ruby-bot'



Slack.configure do |config|
  ENV['SLACK_API_TOKEN'] = 'xoxb-205565088373-CbkZFRI2qTT9KXvU0rQ8l2Ym'
  config.token = ENV['SLACK_API_TOKEN']
end
# Run command is
# SLACK_API_TOKEN=xoxb-205565088373-CbkZFRI2qTT9KXvU0rQ8l2Ym bundle exec ruby lunch_bot.rb
class Weather < SlackRubyBot::Bot
  match /^How is the weather in (?<location>\w*)\?$/ do |client, data, match|
    client.say(channel: data.channel, text: "The weather in #{match[:location]} is nice.")
  end
end

Weather.run