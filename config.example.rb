# Example configuration file for 42bot - rename this to config.rb and start editing below this line.

$nick = "42bot" # The nick you want the bot to have
$user = "42bot" # The username you want the bot to have
#$sasl_username = "42bot" # Uncomment this if you want to use SASL
#$sasl_password = "fakepass" # Uncomment this if you want to use SASL
$server = "irc.example" # The IRC server you want the bot to connect to
$ssl = false # Set to true if you want it to use ssl
$port = "6667" # If you set the above to true, change the port here
$channels = ["#chan1","#chan2","#adminchan"] # Channels you want the bot to join
$adminchannel = "#adminchan" # Users opped in this channel will be able to use admin commands (anywhere)

# Set to true to enable a command

$enable_raw = false
$enable_quit = false
$enable_join = false
$enable_part = false
$enable_op = false
$enable_part_chanop = false
$enable_slap = false
$enable_eat = false
