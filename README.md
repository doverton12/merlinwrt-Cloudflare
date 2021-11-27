# merlinwrt-Cloudflare
# Introduction
This is my Cloudflare script for Dynamic DNS for use with MerlinWRT.

This script tries to do a number of things for you.  You will need to configure it so that the important settings are captured from Cloudflare before you can expect it to function, either autonomously or when called by MerlinWRT firmware for routers.

# Files and locations
The configuration file goes in the same directory as the script and is called .cloudflare. This file contains any A record sites to optionally be explicitly excluded or included. This also contains the API Token and Zone ID for your Cloudflare DNS.

The second file contains the script called by MerlinWRT.  If this script is called with no IP address as a parameter it will use the (curl -s ifconfig.me || curl -s icanhazip.com) to get your externally facing IP address.  It will then iterate through all the sites it finds when it connects to Cloudflare and determine if an update is required. This file should be called ddns-start and should be placed in the /jffs/scripts folder.

A log file is written with everything that is shown on the screen.  The log file will be called the same name as the script with .log appended to the end.  For me this is often found in /tmp/bwdpi/ddns-start.log

# Getting your credentials from Cloudflare
To get your Zone ID, log into Cloudflare and go to the overview page. On the right hand side you will find the Zone ID. Copy this to paste into the configuration file.

To get your API Token, scroll down on the overview page and select "Get your API token". Then select "Create Token", select "Edit Zone DNS" and then "Use Template". Under "Zone Resources" select your domain and then "Continue to Summary". Finally select "Create Token" and copy the token. This also goes into the configuration file.

# Configuration file in detail
The configuration file contains some JSON for the names that you do and do not want to include in the list of A records to be updated as well as a number of configuration variables. 

## Minimum requirements
For the app to work, these variables need to be completed. Case is important!
````
zoneID="ZONE ID GOES HERE"
token="API TOKEN GOES HERE"
url="https://api.cloudflare.com/client/v4/zones"
````
## Controlling which A records are processed
The sitesJSON variable is also manditory. Below is an example of minimum configuration and an expanded configuration
### Minimum sitesJSON requirement
````sitesJSON='{
  "exclusions": [],
  "inclusions": []
}'
````
### Typical sitesJSON requirement
````sitesJSON='{
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
````
In the JSON section, you can put in names that will match the names from Cloudflare.
The tests for the included or excluded sites are controlled by these variables:
processExcludes=true
processIncludes=false

This table explains the impact of the settings on which A records are processed
processExcludes|processIncludes|Action
-----------------|-----------------|----------------------------------------------------
true|true|Only the sites listed in the Inclusions will be processed, providing the same site does not exist in the Exclusions list
true|false|All sites will be processed, except sites listed in the Exclusions list
false|true|Only the sites listed in the Inclusions will be processed, it does not matter if they are in the Exclusions list
false|false|All sites will be processed

## Other variables 
### skipUpdate
Next we have the skipUpdate variable.  If you want the script to simulate an update, but not actually execute it, set the variable skipUpdate=true. Anyother value will cause the update to be carried out.

### isRequiredCheck
The next variable is isRequiredCheck.  This, if set to true, will check if the DNS entry needs changing and if not, it will skip the update.  If this is set to false, then if a DNS record matches for a change, it will be updated, even if the IP address has not changed.

### ignoreIP
Finally, if the router's external IP address is wrong, such as with a double NAT situation, you can tell the script to ignore a specific address. If it see's this as the suggested address, it will make the outbound call to get the real external address.
ignoreIP="192.168.1.1"
