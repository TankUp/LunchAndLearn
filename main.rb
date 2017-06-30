require './lib/db_init'
require './lib/models'
require './slack_token'
require './lib/commands_help.rb'
require 'slack-ruby-bot'
require 'date'
class DateTime
  def next_week
    self + (7 - self.wday)
  end

  def next_wday (n)
    if n.is_a?(String) || n.is_a?(Symbol)
      puts 'ash'
      n = case n
            when /[Mm]onday/
              1
            when /[Tt]uesday/
              2
            when /[Ww]ednesday/
              3
            when /[Tt]hursday/
              4
            when /[Ff]riday/
              5
            else
              0
          end
    end
    n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
  end
end

class Time
  def get_hour_difference_from(other_time)
    raise Exception.new('Expected a Time object!') unless other_time.is_a?(Time)
    if other_time > self
      ((self - other_time) / 3600).round
    else
      ((other_time - self) / 3600).round
    end
  end
end


Slack.configure do |config|
  ENV['SLACK_API_TOKEN'] = $slack_token
  config.token = ENV['SLACK_API_TOKEN']
end
# Read the main channel where the poll will be held
# main_channel_name = gets.chomp
main_channel_name = 'testing'
client = Slack::Web::Client.new
channels = client.channels_list.channels
$main_channel = channels.detect { |c| c.name == main_channel_name }.id


if Event.get_active_event.nil?
  # Seed a new event
  Event.create!(monday_votes: 0, tuesday_votes: 0, wednesday_votes: 0, thursday_votes: 0, friday_votes: 0)
end

# run the slackbot
require './lib/lunch_bot'

LunchAndLearnBot.run
