#!/bin/sh

logandlocal()
{
   ts=$(date +"%d-%m-%Y %H:%M:%S")
   echo "$ts    $1      $2" >> $log
   echo "$ts    $1      $2"
}

config=$(dirname $0)/.cloudflare
log=$(basename $0).log

if [ -r $config ]; then
    logandlocal "Executing $config to load settings"
    . $config
else
    ( >&2 logandlocal "Missing or unreadable $config" )
fi

#GET all A records
recordsA=$(curl -s -X GET "${url}/${zoneID}/dns_records?type=A" -H "Authorization: Bearer ${token}" -H "Content-Type: application/json"|jq .)
recordCount=$(echo $recordsA | jq .result_info.count)
index=0

logandlocal "$recordCount A records found on Cloudflare"

#get current IP address
if [ -z "$1" ]; then
    current=\"`echo $(curl -s ifconfig.me || curl -s icanhazip.com)`\"
else
    current="$1"
fi
logandlocal "This will set the IP address to $current"

#loop through all A records
while [[ $index -lt $recordCount ]]; do
    indexp1=`expr $index + 1`
    recordID=$(echo $recordsA | jq -r .result[$index].id )
    recordName=$(echo $recordsA | jq -r .result[$index].name )
    logandlocal "$indexp1 Name:$recordName ID:$recordID"

    # get the record information
    record=$(curl -s -X GET "${url}/${zoneID}/dns_records/${recordID}" -H "Authorization: Bearer ${token}" -H "Content-Type: application/json")

    if [ "$processExcludes" == "true" ];then
        #check if excluded - will skip if name matches the excluded list
        check=`echo $sitesJSON | jq -r '.exclusions[0:][].name' | grep -i "^$recordName$" | wc -l`
    else
        check="0"
    fi
    if [ $check -eq "0" ];then
        if [ "$processIncludes" == "true" ];then
            check2==`echo $sitesJSON | jq -r '.inclusions[0:][].name' | grep -i "^$recordName$" | wc -l`
        else
            check2=1
        fi
        if [ $check2 -eq 0 ]; then
            logandlocal "$indexp1 site is not on the inclusion list"
        else
            #populate variables
            registered=$(echo ${record}|jq '.result.content')
            name=$(echo ${record}|jq '.result.name')
            type=$(echo ${record}|jq '.result.type')
            ttl=$(echo ${record}|jq '.result.ttl')
            proxied=$(echo ${record}|jq '.result.proxied')
            oldIP=$(echo ${record}|jq '.result.content')

            if [ $oldIP == $current ] ;then
                logandlocal "$indexp1 The IP address for $name is already set to $current, so no change required"
            else
                # update record ip (other values remain the same)
                logandlocal "$indexp1 Name:$name  ID:$recordID  Type:$type  TTL:$ttl  Proxied:$proxied  Old IP:$oldIP  New IP:$current"
                data='{"type":'"$type"',"name":'"$name"',"content":'"$current"',"ttl":'"$ttl"',"proxied":'"$proxied"'}'
                response=$(curl -s -X PUT "${url}/${zoneID}/dns_records/${recordID}" --data $data -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" | jq .)
                success=$(echo ${response} | jq -r .success)
                if [ "$success" == "true" ];then
                    logandlocal "$indexp1 Update was successful"
                else
                    logandlocal "$indexp1 Update failed"
                    logandlocal "Full response was: $response"
                    logandlocal "$response | jq ."
                fi
            fi
        fi
    else
        logandlocal "$indexp1 $recordName is on exclusion list, no further action taken"
    fi

    #increment the number
    index=$indexp1

done
logandlocal "Finished Script"
