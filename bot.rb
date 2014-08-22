# encoding: utf-8

require 'yaml'
require 'cinch'

bot = Cinch::Bot.new do
  config = YAML.load_file('config.yml')

  if config["nick"] && config["user"] && config["server"] && config["port"] && config["channels"] && config["adminchannel"] && config["prefix"] && config["commands"]
    configure do |c|
      c.nick = config["nick"]
      c.user = config["user"]
      c.realname = "https://github.com/SuperMiron/42bot"
      if config["serverpass"]; c.password = config["serverpass"] end
      if config["sasl"]["username"] && config["sasl"]["password"]
        c.sasl.username = config["sasl"]["username"]
        c.sasl.password = config["sasl"]["password"]
      end
      c.server = config["server"]
      c.ssl.use = config["ssl"]
      c.port = config["port"].to_s
      c.channels = config["channels"]
    end
  else
    puts "The bot was not configured correctly."
    exit
  end

  $cmd = config["commands"]

  $prefix = config["prefix"]
  $p = Regexp.quote($prefix)

  $ignorelist = Hash.new
  $gignorelist = []

  helpers do

    def is_admin?(user)
      if Channel(config["adminchannel"]).opped?(user); true else false end
    end

    def ignored?(m, user)
      if is_admin?(user) || !$cmd["ignore"]
        false
      elsif $ignorelist[m.channel]
        if ( ( $gignorelist.include?("#{user.nick}") || $gignorelist.include?("host #{user.host}") ) || ( $ignorelist[m.channel].include?("#{user.nick}") || $ignorelist[m.channel].include?("host #{user.host}") ) ) && !is_admin?(user) && $cmd["ignore"]
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
    if !ignored?(m, m.user) && ( m.message.gsub(/^#{bot.nick}.? .*$/, "") != m.message && ( ( config["as"]["enablechans"].include?(m.channel) || config["as"]["enablechans"] == "all" ) && !config["as"]["disablechans"].include?(m.channel) && config["as"]["disablechans"] != "all") )
      msg = m.message.gsub(/^#{bot.nick}.? /, "")
      if msg.gsub(/\?$/, "") != msg # messages ending with a question mark
        if msg.gsub(/^[Ww]ho are you\?$/, "") != msg
          replies = ["I am your father."]
        elsif msg.gsub(/^([Tt]hen |[Bb]ut (then)? )?[Ww]ho('s | is | are | am I\?$)/, "") != msg
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

  on :message, /^#{$p}(help|commands)( .*)?$/ do |m|
    if !ignored?(m, m.user)
      $helptext = "Commands available to you are #{$prefix}help, #{$prefix}commands"
      def addhelp(s)
        $helptext += ", " + $prefix + s
      end
      if is_admin?(m.user)
        if $cmd["raw"]; addhelp "raw" end
        if $cmd["eval"]; addhelp "eval" end
        if $cmd["quit"]; addhelp "quit" end
        if $cmd["join"]; addhelp "join" end
      end
      if $cmd["part_chanop"]; addhelp "part"
      elsif $cmd["part"] && is_admin?(m.user); addhelp "part"
      end
      if is_admin?(m.user) && $cmd["nick"]; addhelp "nick" end
      if $cmd["ignore"]
        addhelp "ignore"
        addhelp "unignore"
      end
      if $cmd["ignore"] || $cmd["gignore"]; addhelp "ignorelist" end
      if is_admin?(m.user)
        if $cmd["gignore"]
          addhelp "gignore"
          addhelp "ungignore"
        end
        if $cmd["op"]; addhelp "op" end
      end
      if $cmd["randuser"]; addhelp "randuser" end
      if $cmd["slap"]; addhelp "slap" end
      if $cmd["eat"]; addhelp "eat" end
      reply m, $helptext
    end
  end


  ## admin

  on :message, /^#{$p}raw .*$/ do |m|
    if $cmd["raw"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        bot.irc.send m.message.gsub(/^#{$p}raw /, "")
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}eval .*$/ do |m|
    if $cmd["eval"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        eval m.message.gsub(/^#{$p}eval /, "")
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}quit( .*)?$/ do |m|
    if $cmd["quit"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        reply m, "Disconnecting..."
        sleep(3)
        exit
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}join .*$/ do |m|
    if $cmd["join"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        Channel(m.message.gsub(/^#{$p}join /, "")).join
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}part .*$/ do |m|
    if $cmd["part"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        Channel(m.message.gsub(/^#{$p}part /, "")).part
        done m
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}nick .*$/ do |m|
    if $cmd["nick"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        bot.nick = m.message.gsub(/^#{$p}nick /, "")
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}gignore .*$/ do |m|
    if $cmd["gignore"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        if !$gignorelist.include?(m.message.gsub(/^#{$p}gignore /, ""))
          $gignorelist += [m.message.gsub(/^#{$p}gignore /, "")]
          done m
        else
          reply m, "#{m.message.gsub(/^#{$p}gignore /, "")} is already on the global ignore list!"
        end
      else
        noadmin m
      end
    end
  end

  on :message, /^#{$p}ungignore .*$/ do |m|
    if $cmd["gignore"] && !ignored?(m, m.user)
      if is_admin?(m.user)
        if $gignorelist.include?(m.message.gsub(/^#{$p}ungignore /, ""))
          $gignorelist -= [m.message.gsub(/^#{$p}ungignore /, "")]
          done m
        else
          reply m, "#{m.message.gsub(/^#{$p}ungignore /, "")} is not on the global ignore list!"
        end
      else
        noadmin m
      end
    end
  end

  on :channel, /^#{$p}op( .*)?$/ do |m|
    if $cmd["op"] && !ignored?(m, m.user)
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

  on :message, /^#{$p}ignore .*$/ do |m|
    if $cmd["ignore"] && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        if m.message.gsub(/^#{$p}ignore #{bot.nick}$/, "") != m.message
          reply m, "ಠ_ಠ"
        elsif $ignorelist[m.channel]
          if !$ignorelist[m.channel].include?(m.message.gsub(/^#{$p}ignore /, ""))
            $ignorelist[m.channel] += [m.message.gsub(/^#{$p}ignore /, "")]
            done m
          else
            reply m, "#{m.message.gsub(/^#{$p}ignore /, "")} is already on the #{m.channel} ignore list!"
          end
        else
          $ignorelist[m.channel] = [m.message.gsub(/^#{$p}ignore /, "")]
          done m
        end
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :message, /^#{$p}unignore .*$/ do |m|
    if $cmd["ignore"] && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        if m.message.gsub(/^#{$p}unignore #{bot.nick}$/, "") != m.message
          reply m, "ಠ_ಠ"
        elsif $ignorelist[m.channel]
          if $ignorelist[m.channel].include?(m.message.gsub(/^#{$p}unignore /, ""))
            $ignorelist[m.channel] -= [m.message.gsub(/^#{$p}unignore /, "")]
            done m
          else
            reply m, "#{m.message.gsub(/^#{$p}unignore /, "")} is not on the #{m.channel} ignore list."
          end
        else
          reply m, "#{m.message.gsub(/^#{$p}unignore /, "")} is not on the #{m.channel} ignore list."
        end
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :message, /^#{$p}ignorelist global( .*)?$/ do |m|
    if $cmd["gignore"] && !ignored?(m, m.user)
      if $gignorelist != []
        reply m, "Global ignore list: " + "#{$gignorelist}".gsub(/^\[|\]$|"/, "").gsub(/host /, "[host] ")
      else
        reply m, "Global ignore list: (empty)"
      end
    end
  end

  on :message, /^#{$p}ignorelist #.*$/ do |m|
    if $cmd["ignore"] && !ignored?(m, m.user)
      channel = Channel(m.message.gsub(/(^#{$p}ignorelist | .*$)/, ""))
      if $ignorelist[channel] && $ignorelist[channel] != []
        reply m, "#{channel} ignore list: " + "#{$ignorelist[channel]}".gsub(/(^\[|\]$|")/, "").gsub(/host /, "[host] ")
      else
        reply m, "#{channel} ignore list: (empty)"
      end
    end
  end

  on :channel, /^#{$p}part$/ do |m|
    if $cmd["part_chanop"] && !ignored?(m, m.user)
      if is_admin?(m.user) || m.channel.opped?(m.user)
        m.channel.part
      else
        reply m, "You are not opped in #{m.channel}."
      end
    end
  end

  on :channel, /^#{$p}randuser( .*)?$/ do |m|
    if $cmd["randuser"] && !ignored?(m, m.user)
      users = "#{m.channel.users}"
      users.gsub!(/(^{|}$)/, "")
      users.gsub!(/(\#<Bot nick="#{bot.nick}">=>\[("."(, "."(, "."(, "."(, ".")?)?)?)?)?\], |, \#<Bot nick="#{bot.nick}">=>\[("."(, "."(, "."(, "."(, ".")?)?)?)?)?\])/, "")
      users.gsub!(/(\#<User nick="#{m.user}">=>\[("."(, "."(, "."(, "."(, ".")?)?)?)?)?\], |, \#<User nick="#{m.user}">=>\[("."(, "."(, "."(, "."(, ".")?)?)?)?)?\])/, "")
      users.gsub!(/((^| )\#<User nick="|">=>\[("."(, "."(, "."(, "."(, ".")?)?)?)?)?\])/, "")
      users = users.split(",")
      reply m, users.sample
    end
  end

  on :message, /^#{$p}slap( .*)?$/ do |m|
    if $cmd["slap"] && !ignored?(m, m.user)
      action m, "slaps #{m.user} with a 1989 Macintosh"
    end
  end

  on :message, /^#{$p}eat( .*)?$/ do |m|
    if $cmd["eat"] && !ignored?(m, m.user)
      action m, "eats" + m.message.gsub(/^#{$p}eat/, "")
    end
  end
end

bot.start
