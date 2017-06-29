require 'slack-ruby-client'



Slack.configure do |config|
  print ENV['SLACK_API_TOKEN']
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new

client.auth_test