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

  $ignorelist = Hash.new
  $gignorelist = []

  helpers do

    def is_admin?(user)
      if Channel($adminchannel).opped?(user); true else false end
    end

    def ignored?(m, user)
      if is_admin?(user) || !$cmd_ignore
        false
      elsif $ignorelist[m.channel]
        if ( ( $gignorelist.include?("#{user.nick}") || $gignorelist.include?("host #{user.host}") ) || ( $ignorelist[m.channel].include?("#{user.nick}") || $ignorelist[m.channel].include?("host #{user.host}") ) ) && !is_admin?(user) && $cmd_ignore
          true else false
        end
      else
        if ( $gignorelist.include?("#{user.nick}") || $gignorelist.include?("host #{user.host}") )
          true else false
        end
      end
    end

    def reply(m, message)
      m.reply message, prefix = true
    end

    def action(m, message)
      m.action_reply message
    end

    def done(m)
      reply m, "Done."
    end

    def noadmin(m)
      reply m, "You are not an admin."
    end

  end

  ### ARTIFICIAL STUPIDITY

  on :channel, /^.+ .*$/ do |m|
    if !ignored?(m, m.user) && ( m.message.gsub(/^#{bot.nick}.? .*$/, "") != m.message && ( ( $as_channels.include?(m.channel) || $as_channels == "all" ) && !$no_as_channels.include?(m.channel) && $no_as_channels != "all") )
      msg = m.message.gsub(/^#{bot.nick}.? /, "")
      if msg.gsub(/\?$/, "") != msg # messages ending with a question mark
        if msg.gsub(/^[Ww]ho are you\?$/, "") != msg
          replies = ["I am your father."]
        elsif msg.gsub(/^[Ww]ho('s | is | are | am I\?$)/, "") != msg
          replies = [
            "an elephant",
            "a potato",
            "a cucumber",
            "a walrus",
            "UrD4D",
            "UrM0M",
            "no idea"
          ]
        elsif msg.gsub(/^([Dd]o|[Dd]oes|[Dd]id|[Cc]an|[Cc]ould|[Mm]ay|[Ss]hould|[Ss]hall|[Ww]ould|[Ww]ill|[Ii]s|[Aa]re|[Ww]as|[Ww]ere|[Aa]m I) /, "") != msg
          replies = [
            "yes",
            "no",
            "idk",
            "otay",
            "...MOM! IT'S ALIVE!!!",
            "no u smell weird go away"
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
        reply m, replies.sample
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
          "danced in",
          "lived in"
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
        reply m, w1.sample + " " + w2.sample + " " + w3.sample + " " + w4.sample + " " + w5.sample + " " + w6.sample + " " + w7.sample + "."
      end
    end
  end

  ### COMMANDS

  on :message, /^!(help|commands)( .*)?$/ do |m|
    if !ignored?(m, m.user)
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
      if is_admin?(m.user) && $cmd_nick; m.user.notice("!nick") end
      if $cmd_ignore
        m.user.notice("!ignore")
        m.user.notice("!unignore")
      end
      if is_admin?(m.user)
        if $cmd_gignore
          m.user.notice("!gignore")
          m.user.notice("!ungignore")
        end
        if $cmd_op; m.user.notice("!op") end
      end
      if $cmd_slap; m.user.notice("!slap") end
      if $cmd_eat; m.user.notice("!eat") end
      m.user.notice("#{BOLD}--    End of command list    --#{BOLD}")
    end
  end


  ## admin

  on :message, /^!raw .*$/ do |m|
    if $cmd_raw && !ignored?(m, m.user)
      if is_admin?(m.user)
        bot.irc.send m.message.gsub(/^!raw /, "")
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^!eval .*$/ do |m|
    if $cmd_eval && !ignored?(m, m.user)
      if is_admin?(m.user)
        eval m.message.gsub(/^!eval /, "")
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^!quit( .*)?$/ do |m|
    if $cmd_quit && !ignored?(m, m.user)
      if is_admin?(m.user)
        reply m, "Disconnecting..."
        sleep(3)
        exit
      else
        noadmin m
      end
    end
  end

  on :message, /^!join .*$/ do |m|
    if $cmd_join && !ignored?(m, m.user)
      if is_admin?(m.user)
        Channel(m.message.gsub(/^!join /, "")).join
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^!part .*$/ do |m|
    if $cmd_part && !ignored?(m, m.user)
      if is_admin?(m.user)
        Channel(m.message.gsub(/^!part /, "")).part
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^!nick .*$/ do |m|
    if $cmd_nick && !ignored?(m, m.user)
      if is_admin?(m.user)
        bot.nick = m.message.gsub(/^!nick /, "")
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^!gignore .*$/ do |m|
    if $cmd_gignore && !ignored?(m, m.user)
      if is_admin?(m.user)
        if !$gignorelist.include?(m.message.gsub(/^!gignore /, ""))
          $gignorelist += [m.message.gsub(/^!gignore /, "")]
          done m
        else
          reply m, "#{m.message.gsub(/^!gignore /, "")} is already on the global ignore list!"
        end
      else
        noadmin m
      end
    end
  end

  on :message, /^!ungignore .*$/ do |m|
    if $cmd_gignore && !ignored?(m, m.user)
      if is_admin?(m.user)
        if $gignorelist.include?(m.message.gsub(/^!ungignore /, ""))
          $gignorelist -= [m.message.gsub(/^!ungignore /, "")]
          done m
        else
          reply m, "#{m.message.gsub(/^!ungignore /, "")} is not on the global ignore list!"
        end
      else
        noadmin m
      end
    end
  end

  on :channel, /^!op( .*)?$/ do |m|
    if $cmd_op && !ignored?(m, m.user)
	  if is_admin?(m.user)
	    if m.channel.opped?(bot.nick)
          m.channel.op m.user
        else
          reply m, "I am not opped in #{m.channel}."
        end
      else
        noadmin m
      end
    end
  end

  ## user

  on :message, /^!ignore .*$/ do |m|
    if $cmd_ignore && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        if m.message.gsub(/^!ignore #{bot.nick}$/, "") != m.message
          reply m, "ಠ_ಠ"
        elsif $ignorelist[m.channel]
          if !$ignorelist[m.channel].include?(m.message.gsub(/^!ignore /, ""))
            $ignorelist[m.channel] += [m.message.gsub(/^!ignore /, "")]
            done m
          else
            reply m, "#{m.message.gsub(/^!ignore /, "")} is already on the #{m.channel} ignore list!"
          end
        else
          $ignorelist[m.channel] = [m.message.gsub(/^!ignore /, "")]
          done m
        end
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :message, /^!unignore .*$/ do |m|
    if $cmd_ignore && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        if m.message.gsub(/^!unignore #{bot.nick}$/, "") != m.message
          reply m, "ಠ_ಠ"
        elsif $ignorelist[m.channel]
          if $ignorelist[m.channel].include?(m.message.gsub(/^!unignore /, ""))
            $ignorelist[m.channel] -= [m.message.gsub(/^!unignore /, "")]
            done m
          else
            reply m, "#{m.message.gsub(/^!unignore /, "")} is not on the #{m.channel} ignore list!"
          end
        else
          reply m, "#{m.message.gsub(/^!unignore /, "")} is not on the #{m.channel} ignore list!"
        end
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :channel, /^!part$/ do |m|
    if $cmd_part_chanop && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        m.channel.part
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :message, /^!slap( .*)?$/ do |m|
    if $cmd_slap && !ignored?(m, m.user)
      action m, "slaps #{m.user} with a 1989 Macintosh"
    end
  end

  on :message, /^!eat( .*)?$/ do |m|
    if $cmd_eat && !ignored?(m, m.user)
      action m, "eats" + m.message.gsub(/^!eat/, "")
    end
  end
end

bot.start
