# merlinwrt-Cloudflare
This is my Cloudflare script for Dynamic DNS for use with MerlinWRT.

This script tries to do a number of things for you.  You will need to configure it so that the important settings are captured from Cloudflare before you can expect it to function, either autonomously or when called by MerlinWRT firmware for routers.

The configuration file goes in the same directory as the script and is called .cloudflare. This file contains any A record sites to optionally be explicitly excluded or included. This also contains the API Token and Zone ID for your Cloudflare DNS.

The second file contains the script called by MerlinWRT.  If this script is called with no IP address as a parameter it will use the (curl -s ifconfig.me || curl -s icanhazip.com) to get your externally facing IP address.  It will then iterate through all the sites it finds when it connects to Cloudflare and determine if an update is required.

To get your Zone ID, log into Cloudflare and go to the overview page. On the right hand side you will find the Zone ID. Copy this to paste into the configuration file.

To get your API Token, scroll down on the overview page and select "Get your API token". Then select "Create Token", select "Edit Zone DNS" and then "Use Template". Under "Zone Resources" select your domain and then "Continue to Summary". Finally select "Create Token" and copy the token. This also goes into the configuration file.

Also in the configuration file is a piece of JSON for the names that you do and do not want to include in the list to be updated. 
