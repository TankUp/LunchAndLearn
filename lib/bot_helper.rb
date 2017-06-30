module BotHelper
  # Given the user_id, fetch his username through the Slack API
  def self.fetch_username_by_id(user_id)
    Slack::Web::Client.new.users_info(user: user_id).user.real_name
  end

  def self.fetch_channel_by_user_id(user_id)
    channels = Slack::Web::Client.new.im_list.ims

    channels.detect { |c| c.user == "#{user_id}" }
  end
end
