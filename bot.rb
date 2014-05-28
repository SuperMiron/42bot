require 'cinch'
require_relative 'config'

bot = Cinch::Bot.new do
  if $nick && $user && $server && $port && $channels && $adminchannel && $as_channels && $no_as_channels
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

  ### ARTIFICIAL STUPIDITY

  on :channel, /^.+ .*$/ do |m|
    if m.message.gsub(/^#{bot.nick}.? .*$/, "") != m.message && (( $as_channels.include?(m.channel) || $as_channels == "all" ) && !$no_as_channels.include?(m.channel) && $no_as_channels != "all")
      msg = m.message.gsub(/^#{bot.nick}.? /, "")
      if msg.gsub(/\?$/, "") != msg # messages ending with a question mark
        if msg.gsub(/^[Ww]ho are you\?$/, "") != msg
          replies = ["I am your father."]
        elsif msg.gsub(/^[Ww]ho is /, "") != msg || msg.gsub(/^[Ww]ho are /, "") != msg || msg.gsub(/^[Ww]ho am I\?$/, "") != msg
          replies = [
            "an elephant",
            "a potato",
            "a cucumber",
            "a walrus",
            "UrD4D",
            "UrM0M",
            "no idea"
          ]
        else
          replies = [
            "how much wood would a woodchuck chuck if a woodchuck could chuck wood?",
            "ok *explodes*",
            "wow, rude.",
            "yea k whatever",
            "go eat an elephant.",
            "05y04a07y 08r09a03i11n10b12o02w06s13!",
            "fascinating.",
            "Ukrainian plane went Chinese while trying to be American.",
            "Latvian potato turned Egyptian after dancing Russian."
          ]
        end
        m.reply replies.sample, prefix = true
      else
        w1 = [
          "Pie",
          "I",
          "He",
          "She",
          "We",
          "Potatoes",
          "Tomatoes",
          "06R13a05i04n07b08o09w03s"
        ]
        w2 = [
          "went to",
          "sat on",
          "played with",
          "ate",
          "drank",
          "smelled",
          "danced in"
        ]
        w3 = [
          "the Kremlin",
          "Indonesia",
          "Donald Tusk",
          "school",
          "the library",
          "Bill Gates's cat",
          "the White House"
        ]
        w4 = [
          "while",
          "before",
          "after"
        ]
        w5 = [
          "sleeping in",
          "translating",
          "learning",
          "flying to",
          "staring at"
        ]
        w6 = [
          "Angela Merkel's",
          "Chuck Norris's",
          "Conchita Wurst's",
          "her",
          "my",
          "your"
        ]
        w7 = [
          "house",
          "head",
          "face",
          "cheese",
          "language",
          "mustache"
        ]
        m.reply w1.sample + " " + w2.sample + " " + w3.sample + " " + w4.sample + " " + w5.sample + " " + w6.sample + " " + w7.sample + ".", prefix = true
      end
    end
  end

  ### COMMANDS

  on :message, /^!(help|commands)( .*)?$/ do |m|
    m.user.notice("#{BOLD}-- Commands available to you --#{BOLD}")
    m.user.notice("!help")
    if is_admin?(m.user)
      if $cmd_raw; m.user.notice("!raw") end
      if $cmd_eval; m.user.notice("!eval") end
      if $cmd_quit; m.user.notice("!quit") end
      if $cmd_join; m.user.notice("!join") end
    end
    if $cmd_part_chanop; m.user.notice("!part")
    elsif $cmd_part && is_admin?(m.user); m.user.notice("!part")
    end
    if $cmd_nick && is_admin?(m.user); m.user.notice("!nick") end
    if $cmd_op && is_admin?(m.user); m.user.notice("!op") end
    if $cmd_slap; m.user.notice("!slap") end
    if $cmd_eat; m.user.notice("!eat") end
    m.user.notice("#{BOLD}--    End of command list    --#{BOLD}")
  end


  ## admin

  on :message, /^!raw .*$/ do |m|
    if $cmd_raw
      if is_admin?(m.user)
        bot.irc.send m.message.gsub(/^!raw /, "")
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!eval .*$/ do |m|
    if $cmd_eval
      if is_admin?(m.user)
        eval(m.message.gsub(/^!eval /, ""))
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!quit( .*)?$/ do |m|
    if $cmd_quit
      if is_admin?(m.user)
        m.reply "Disconnecting...", prefix = true
        sleep(3)
        exit
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!join .*$/ do |m|
    if $cmd_join
      if is_admin?(m.user)
        Channel(m.message.gsub(/^!join /, "")).join
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!part .*$/ do |m|
    if $cmd_part
      if is_admin?(m.user)
        Channel(m.message.gsub(/^!part /, "")).part
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :message, /^!nick .*$/ do |m|
    if $cmd_nick
      if is_admin?(m.user)
        bot.nick = m.message.gsub(/^!nick /, "")
        m.reply "Done.", prefix = true
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  on :channel, /^!op( .*)?$/ do |m|
    if $cmd_op
	  if is_admin?(m.user)
	    if m.channel.opped?(bot.nick)
          m.channel.op m.user
        else
          m.reply "I am not opped in #{m.channel}.", prefix = true
        end
      else
        m.reply "You are not an admin.", prefix = true
      end
    end
  end

  ## user

  on :channel, /^!part$/ do |m|
    if $cmd_part_chanop
      if is_admin?(m.user) || m.channel.opped?(m.user)
        m.channel.part								
      else
        m.reply "You are not opped in #{m.channel}.", prefix = true
      end
    end
  end

  on :message, /^!slap( .*)?$/ do |m|
    if $cmd_slap
      m.action_reply "slaps #{m.user} with a 1989 Macintosh"
    end
  end

  on :message, /^!eat( .*)?$/ do |m|
    if $cmd_eat
      m.action_reply "eats" + m.message.gsub(/^!eat/, "")
    end
  end
end

bot.start
