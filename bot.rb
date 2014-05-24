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

  BOLD = ""

  helpers do
    def is_admin?(user)
      true if Channel($adminchannel).opped?(user)
    end
  end

  ### COMMANDS

  on :message, /^!(help|commands)( .*)?$/ do |m|
    m.user.notice("#{BOLD}-- Commands available to you --#{BOLD}")
    m.user.notice("!help")
    if is_admin?(m.user)
      if $enable_raw; m.user.notice("!raw") end
      if $enable_eval; m.user.notice("!eval") end
      if $enable_quit; m.user.notice("!quit") end
      if $enable_join; m.user.notice("!join") end
    end
    if $enable_part_chanop; m.user.notice("!part")
    elsif $enable_part && is_admin?(m.user); m.user.notice("!part")
    end
    if $enable_nick && is_admin?(m.user); m.user.notice("!nick") end
    if $enable_op && is_admin?(m.user); m.user.notice("!op") end
    if $enable_slap; m.user.notice("!slap") end
    if $enable_eat; m.user.notice("!eat") end
    m.user.notice("#{BOLD}--    End of command list    --#{BOLD}")
  end


  ## admin

  on :message, /^!raw .*$/ do |m|
    if $enable_raw
      if is_admin?(m.user)
        rawcmd = m.message.gsub(/^!raw /, "")
        bot.irc.send(rawcmd)
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!eval .*$/ do |m|
    if $enable_eval
      if is_admin?(m.user)
        eval(m.message.gsub(/^!eval /, ""))
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!quit( .*)?$/ do |m|
    if $enable_quit
      if is_admin?(m.user)
        exit
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!join .*$/ do |m|
    if $enable_join
      if is_admin?(m.user)
        bot.irc.send("JOIN " + m.message.gsub(/^!join /, ""))
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!part .*$/ do |m|
    if $enable_part
      if is_admin?(m.user)
        bot.irc.send("PART " + m.message.gsub(/^!part /, ""))
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!nick .*$/ do |m|
    if $enable_nick
      if is_admin?(m.user)
        bot.irc.send("NICK " + m.message.gsub(/^!nick /, ""))
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :channel, /^!op( .*)?$/ do |m|
    if $enable_op
	  if is_admin?(m.user)
	    if m.channel.opped?(bot.nick)
          m.channel.op(m.user)
        else
          m.reply "I am not opped in #{m.channel}.", prefix = true
        end
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  ## user

  on :channel, /^!part?$/ do |m|
    if $enable_part_chanop
      if is_admin?(m.user) || m.channel.opped?(m.user)
        bot.irc.send("PART #{m.channel}")									
      else
        m.reply "You are not opped in #{m.channel}.", prefix = true
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
