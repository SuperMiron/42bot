# Example configuration file for 42bot - rename this to config.rb and start editing below this line.

$nick = "42bot" # The nick you want the bot to have
$user = "42bot" # The username you want the bot to have
#$sasl_username = "42bot" # Uncomment this if you want to use SASL
#$sasl_password = "fakepass" # Uncomment this if you want to use SASL
$server = "irc.example" # The IRC server you want the bot to connect to
$ssl = false # Set to true if you want it to use ssl
$port = "6667" # If you set the above to true, change the port here
$channels = ["#chan1", "#chan2", "#adminchan"] # Channels you want the bot to join
$adminchannel = "#adminchan" # Users opped in this channel will be able to use admin commands (anywhere)
$as_channels = [] # If you leave this as it is, artificial stupidity will be disabled. If you want to enable it,
                  # just add the channels to the array (syntax same as in $channels). If you want to enable it for
                  # all channels:  $as_channels = "all"
$no_as_channels = [] # Channels to disable artificial stupidity in. Overrides $as_channels, same syntax.
$prefix = "!"

# Set to true to enable a command

$cmd_raw = false
$cmd_eval = false
$cmd_quit = false
$cmd_join = false
$cmd_part = false
$cmd_part_chanop = false
$cmd_nick = false
$cmd_ignore = false
$cmd_gignore = false
$cmd_op = false
$cmd_slap = false
$cmd_eat = false
