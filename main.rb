require './db_init'
require './models'
require './slack_token'
require './commands_help.rb'
require 'slack-ruby-bot'

Slack.configure do |config|
  ENV['SLACK_API_TOKEN'] = $slack_token
  config.token = ENV['SLACK_API_TOKEN']
end
# Read the main channel where the poll will be held
# main_channel_name = gets.chomp
main_channel_name = 'nobodies'
client = Slack::Web::Client.new
channels = client.channels_list.channels
$main_channel = channels.detect { |c| c.name == main_channel_name }.id

# run the slackbot
require './lunch_bot/lib/lunch_bot'

LunchAndLearnBot.run
