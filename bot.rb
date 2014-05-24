require 'cinch'
require_relative 'config'

bot = Cinch::Bot.new do
  if $nick && $user && $server && $port && $channels && $adminchannel
    configure do |c|
      c.nick = $nick
      c.user = $user
      c.realname = "https://github.com/SuperMiron/42bot"
      if ( $sasl_username && $sasl_password )
        c.sasl.username = $sasl_username
        c.sasl.password = $sasl_password
      end
      c.server = $server
      c.ssl.use = $ssl
      c.port = $port
      c.channels = $channels
    end
  else
    puts "The bot was not configured correctly."
    exit
  end

  adminchannel = $adminchannel

  BOLD = ""

  on :message, /^!(help|commands)( .*)?$/ do |m|
    m.user.notice("#{BOLD}-- Commands available to you --#{BOLD}")
    m.user.notice("!help")
    if Channel(adminchannel).opped?(m.user)
      if $enable_raw; m.user.notice("!raw") end
      if $enable_quit; m.user.notice("!quit") end
      if $enable_join; m.user.notice("!join") end
    end
    if $enable_part_chanop; m.user.notice("!part")
    elsif $enable_part && Channel(adminchannel).opped?(m.user); m.user.notice("!part")
    end
    if $enable_op && Channel(adminchannel).opped?(m.user); m.user.notice("!op") end
    if $enable_slap; m.user.notice("!slap") end
    if $enable_eat; m.user.notice("!eat") end
    m.user.notice("#{BOLD}--    End of command list    --#{BOLD}")
  end


  ### ADMIN COMMANDS

  on :message, /^!raw .*$/ do |m|
    if $enable_raw
      if Channel(adminchannel).opped?(m.user)
        rawcmd = m.message.gsub(/^!raw /, "")
        bot.irc.send(rawcmd)
        m.reply "#{m.user}: Done."
      else
        m.reply "#{m.user}: You are not an admin."
      end
    end
  end

  on :message, /^!quit( .*)?$/ do |m|
    if $enable_quit
      if Channel(adminchannel).opped?(m.user)
        exit
      else
        m.reply "#{m.user}: You are not an admin."
      end
    end
  end

  on :message, /^!join .*$/ do |m|
    if $enable_join
      if Channel(adminchannel).opped?(m.user)
        bot.irc.send("JOIN " + m.message.gsub(/^!join /, ""))
        m.reply "#{m.user}: Done."
      else
        m.reply "#{m.user}: You are not an admin."
      end
    end
  end

  on :message, /^!part .*$/ do |m|
    if $enable_part
      if Channel(adminchannel).opped?(m.user)
        bot.irc.send("PART " + m.message.gsub(/^!part /, ""))
        m.reply "#{m.user}: Done."
      else
        m.reply "#{m.user}: You are not an admin."
      end
    end
  end

  on :channel, /^!op( .*)?$/ do |m|
    if $enable_op
	  if Channel(adminchannel).opped?(m.user)
	    if m.channel.opped?(bot.nick)
          m.channel.op(m.user)
        else
          m.reply "#{m.user}: I am not opped in #{m.channel}."
        end
      else
        m.reply "#{m.user}: You are not an admin."
      end
    end
  end

  ### USER COMMANDS

  on :channel, /^!part?$/ do |m|
    if $enable_part_chanop
      if Channel(adminchannel).opped?(m.user) || m.channel.opped?(m.user)
        bot.irc.send("PART #{m.channel}")									
      else
        m.reply "#{m.user}: You are not opped in #{m.channel}."
      end
    end
  end

  on :message, /^!slap( .*)?$/ do |m|
    if $enable_slap
      m.action_reply "slaps #{m.user} with a 1989 Macintosh"
    end
  end

  on :message, /^!eat( .*)?$/ do |m|
    if $enable_eat
      m.action_reply "eats" + m.message.gsub(/^!eat/, "")
    end
  end
end

bot.start
