#!/bin/bash

#edited by JC
#j.kwon@f5.com

set -e

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

for i in bigip1-0 bigip2-0
do
##for bigip1-0
    TARGET="$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)"
  if [ $i == bigip1-0 ]
  then
    CREDS="$name:$password"
    TARGET_RPM="$dir/blueprint_f5bigip_transit/scripts/f5-appsvcs-3.16.0-6.noarch.rpm"
    RPM_NAME=$(basename $TARGET_RPM)
    CURL_FLAGS="--silent --write-out \n --insecure -u $CREDS"
  
    poll_task () {
        STATUS="STARTED"
        while [ $STATUS != "FINISHED" ]; do
            sleep 1
            RESULT=$(curl ${CURL_FLAGS} "https://$TARGET:8443/mgmt/shared/iapp/package-management-tasks/$1")
            STATUS=$(echo $RESULT | jq -r .status)
            if [ $STATUS = "FAILED" ]; then
                echo "Failed to" $(echo $RESULT | jq -r .operation) "package:" \
                    $(echo $RESULT | jq -r .errorMessage)
                exit 1
            fi
        done
    }
  
    #Get list of existing f5-appsvcs packages on target
    TASK=$(curl $CURL_FLAGS -H "Content-Type: application/json" \
        -X POST https://$TARGET:8443/mgmt/shared/iapp/package-management-tasks -d "{operation: 'QUERY'}")
    poll_task $(echo $TASK | jq -r .id)
    AS3RPMS=$(echo $RESULT | jq -r '.queryResponse[].packageName | select(. | startswith("f5-appsvcs"))')
  
    #Uninstall existing f5-appsvcs packages on target
    for PKG in $AS3RPMS; do
        echo "Uninstalling $PKG on $TARGET"
        DATA="{\"operation\":\"UNINSTALL\",\"packageName\":\"$PKG\"}"
        TASK=$(curl ${CURL_FLAGS} "https://$TARGET:8443/mgmt/shared/iapp/package-management-tasks" \
            --data $DATA -H "Origin: https://$TARGET:8443" -H "Content-Type: application/json;charset=UTF-8")
        poll_task $(echo $TASK | jq -r .id)
    done
  
    #Upload new f5-appsvcs RPM to target
    #echo "Uploading RPM to https://$TARGET:8443/mgmt/shared/file-transfer/uploads/$RPM_NAME"
    echo -e "\033[32m.Uploading RPM to https://$TARGET:8443/mgmt/shared/file-transfer/uploads/$RPM_NAME \033[0m "
    LEN=$(wc -c $TARGET_RPM | awk 'NR==1{print $1}')
    RANGE_SIZE=5000000
    CHUNKS=$(( $LEN / $RANGE_SIZE))
    for i in $(seq 0 $CHUNKS); do
        START=$(( $i * $RANGE_SIZE))
        END=$(( $START + $RANGE_SIZE))
        END=$(( $LEN < $END ? $LEN : $END))
        OFFSET=$(( $START + 1))
        curl ${CURL_FLAGS} -o /dev/null --write-out "" \
            https://$TARGET:8443/mgmt/shared/file-transfer/uploads/$RPM_NAME \
            --data-binary @<(tail -c +$OFFSET $TARGET_RPM) \
            -H "Content-Type: application/octet-stream" \
            -H "Content-Range: $START-$(( $END - 1))/$LEN" \
            -H "Content-Length: $(( $END - $START ))" \
            -H "Connection: keep-alive"
    done
  
    #Install f5-appsvcs on target
    #echo "Installing $RPM_NAME on $TARGET"
    echo -e "\033[32m.Installing $RPM_NAME on $TARGET.. \033[0m "
    DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$RPM_NAME\"}"
    TASK=$(curl ${CURL_FLAGS} "https://$TARGET:8443/mgmt/shared/iapp/package-management-tasks" \
        --data $DATA -H "Origin: https://$TARGET:8443" -H "Content-Type: application/json;charset=UTF-8")
    poll_task $(echo $TASK | jq -r .id)
  
    #echo "Waiting for /info endpoint to be available"
    echo -e "\033[32m.Waiting for /info endpoint to be available... \033[0m "
    until curl ${CURL_FLAGS} -o /dev/null --write-out "" --fail --silent \
        "https://$TARGET:8443/mgmt/shared/appsvcs/info"; do
        sleep 1
    done
##for bigip2-0
  else
    CREDS="$name:$password"
    TARGET_RPM="$dir/blueprint_f5bigip_transit/scripts/f5-appsvcs-3.16.0-6.noarch.rpm"
    RPM_NAME=$(basename $TARGET_RPM)
    CURL_FLAGS="--silent --write-out \n --insecure -u $CREDS"
  
    poll_task () {
        STATUS="STARTED"
        while [ $STATUS != "FINISHED" ]; do
            sleep 1
            RESULT=$(curl ${CURL_FLAGS} "https://$TARGET:9443/mgmt/shared/iapp/package-management-tasks/$1")
            STATUS=$(echo $RESULT | jq -r .status)
            if [ $STATUS = "FAILED" ]; then
                echo "Failed to" $(echo $RESULT | jq -r .operation) "package:" \
                    $(echo $RESULT | jq -r .errorMessage)
                exit 1
            fi
        done
    }
  
    #Get list of existing f5-appsvcs packages on target
    TASK=$(curl $CURL_FLAGS -H "Content-Type: application/json" \
        -X POST https://$TARGET:9443/mgmt/shared/iapp/package-management-tasks -d "{operation: 'QUERY'}")
    poll_task $(echo $TASK | jq -r .id)
    AS3RPMS=$(echo $RESULT | jq -r '.queryResponse[].packageName | select(. | startswith("f5-appsvcs"))')
  
    #Uninstall existing f5-appsvcs packages on target
    for PKG in $AS3RPMS; do
        echo "Uninstalling $PKG on $TARGET"
        DATA="{\"operation\":\"UNINSTALL\",\"packageName\":\"$PKG\"}"
        TASK=$(curl ${CURL_FLAGS} "https://$TARGET:9443/mgmt/shared/iapp/package-management-tasks" \
            --data $DATA -H "Origin: https://$TARGET:9443" -H "Content-Type: application/json;charset=UTF-8")
        poll_task $(echo $TASK | jq -r .id)
    done
  
    #Upload new f5-appsvcs RPM to target
    #echo "Uploading RPM to https://$TARGET:9443/mgmt/shared/file-transfer/uploads/$RPM_NAME"
    echo -e "\033[32m.Uploading RPM to https://$TARGET:9443/mgmt/shared/file-transfer/uploads/$RPM_NAME \033[0m "
    LEN=$(wc -c $TARGET_RPM | awk 'NR==1{print $1}')
    RANGE_SIZE=5000000
    CHUNKS=$(( $LEN / $RANGE_SIZE))
    for i in $(seq 0 $CHUNKS); do
        START=$(( $i * $RANGE_SIZE))
        END=$(( $START + $RANGE_SIZE))
        END=$(( $LEN < $END ? $LEN : $END))
        OFFSET=$(( $START + 1))
        curl ${CURL_FLAGS} -o /dev/null --write-out "" \
            https://$TARGET:9443/mgmt/shared/file-transfer/uploads/$RPM_NAME \
            --data-binary @<(tail -c +$OFFSET $TARGET_RPM) \
            -H "Content-Type: application/octet-stream" \
            -H "Content-Range: $START-$(( $END - 1))/$LEN" \
            -H "Content-Length: $(( $END - $START ))" \
            -H "Connection: keep-alive"
    done
  
    #Install f5-appsvcs on target
    #echo "Installing $RPM_NAME on $TARGET"
    echo -e "\033[32m.Installing $RPM_NAME on $TARGET.. \033[0m "
    DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$RPM_NAME\"}"
    TASK=$(curl ${CURL_FLAGS} "https://$TARGET:9443/mgmt/shared/iapp/package-management-tasks" \
        --data $DATA -H "Origin: https://$TARGET:9443" -H "Content-Type: application/json;charset=UTF-8")
    poll_task $(echo $TASK | jq -r .id)
  
    #echo "Waiting for /info endpoint to be available"
    echo -e "\033[32m.Waiting for /info endpoint to be available... \033[0m "
    until curl ${CURL_FLAGS} -o /dev/null --write-out "" --fail --silent \
        "https://$TARGET:9443/mgmt/shared/appsvcs/info"; do
        sleep 1
    done
  fi
done

echo -e "\033[32m.Installed $RPM_NAME on $TARGET. \033[0m "
exit 0
