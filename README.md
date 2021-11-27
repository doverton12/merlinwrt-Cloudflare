# merlinwrt-Cloudflare
This is my Cloudflare script for Dynamic DNS for use with MerlinWRT.

This script tries to do a number of things for you.  You will need to configure it so that the important settings are captured from Cloudflare before you can expect it to function, either autonomously or when called by MerlinWRT firmware for routers.

The configuration file goes in the same directory as the script and is called .cloudflare. This file contains any A record sites to optionally be explicitly excluded or included. This also contains the API Token and Zone ID for your Cloudflare DNS.

The second file contains the script called by MerlinWRT.  If this script is called with no IP address as a parameter it will use the (curl -s ifconfig.me || curl -s icanhazip.com) to get your externally facing IP address.  It will then iterate through all the sites it finds when it connects to Cloudflare and determine if an update is required. This file should be called ddns-start and should be placed in the /jffs/scripts folder.

To get your Zone ID, log into Cloudflare and go to the overview page. On the right hand side you will find the Zone ID. Copy this to paste into the configuration file.

To get your API Token, scroll down on the overview page and select "Get your API token". Then select "Create Token", select "Edit Zone DNS" and then "Use Template". Under "Zone Resources" select your domain and then "Continue to Summary". Finally select "Create Token" and copy the token. This also goes into the configuration file.

Also in the configuration file is a piece of JSON for the names that you do and do not want to include in the list to be updated. 

A log file is written with everything that is shown on the screen.  The log file will be called the same name as the script with .log appended to the end.

A more detailed breakdown of the configuration file is as follows:
For the app to work, these variables need to be completed. Case is important!
zoneID="ZONE ID GOES HERE"
token="API TOKEN GOES HERE"
url="https://api.cloudflare.com/client/v4/zones"

sitesJSON='{
  "exclusions": [
    {
      "name": "name1.domain.com"
    },
    {
      "name": "name2.domain.com"
    }],
  "inclusions": [
    {
      "name": "domain.com"
    },
    {
      "name": "*.domain.com"
    },
    {
      "name": "name3.domain.com"
    }]
}'

in the JSON section, you can put in names that will match the names from Cloudflare.
The tests for the included or excluded sites are controlled by these variables:
processExcludes=true
processIncludes=false

This table explains the impact of the settings
processExcludes processIncludes Action
true            true            Only the sites listed in the Inclusions will be processed, providing the same site does not exist in the Exclusions list
true            false           All sites will be processed, except sites listed in the Exclusions list
false           true            Only the sites listed in the Inclusions will be processed, it does not matter if they are in the Exclusions list
false           false           All sites will be processed

Next we have the skipUpdate variable.  If you want the script to simulate an update, but not actually execute it, set the variable skipUpdate=true. Anyother value will cause the update to be carried out.

The next variable is isRequiredCheck.  This, if set to true, will check if the DNS entry needs changing and if not, it will skip the update.  If this is set to false, then if a DNS record matches for a change, it will be updated, even if the IP address has not changed.

Finally, if the router's external IP address is wrong, such as with a double NAT situation, you can tell the script to ignore a specific address. If it see's this as the suggested address, it will make the outbound call to get the real external address.
ignoreIP="192.168.1.1"
