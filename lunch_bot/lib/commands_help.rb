require 'slack-ruby-bot'

class LunchAndLearnBot < SlackRubyBot::Bot
  help do
    title 'Lunch-and-Learn Bot'
    desc 'This bot helps you organize lunch and learn sessions, yay!'

    command 'vote' do
      desc 'helps you vote'
    end
  end

  # commands implementation
end
