require './lib/db_init'
require './lib/models'
require './slack_token'
require './lib/commands_help.rb'
require 'slack-ruby-bot'

Slack.configure do |config|
  ENV['SLACK_API_TOKEN'] = $slack_token
  config.token = ENV['SLACK_API_TOKEN']
end
# Read the main channel where the poll will be held
# main_channel_name = gets.chomp
main_channel_name = 'testing'
client = Slack::Web::Client.new
channels = client.channels_list.channels
puts channels
$main_channel = channels.detect { |c| c.name == main_channel_name }.id


if Event.get_active_event.nil?
  # Seed a new event
  Event.create!
end
# run the slackbot
require './lib/lunch_bot'

LunchAndLearnBot.run
