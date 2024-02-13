#!/usr/bin/env zsh
echo "name_queue;name_script" > queue_script.txt

URL_QUEUE_1="https://api.mypurecloud.de/api/v2/routing/queues?pageSize=500&pageNumber=1"
URL_QUEUE_2="https://api.mypurecloud.de/api/v2/routing/queues?pageSize=500&pageNumber=2"

json_body=$(curl -X GET "$URL_QUEUE_1" -H 'Authorization: Bearer *******' -H 'Content-Type: application/json')

queues=$(echo "$json_body" | jq -r '.entities')

  for queue in $(echo "${queues}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${queue} | base64 --decode | jq -r ${1}
    }
    name_queue=$(_jq '.name')
    id_queue=$(_jq '.id')
    id_script=$(_jq '.defaultScripts.CALL.id')
    echo $name_queue "-" $id_script
    if [[ -n "$id_script" ]] || [[ "$id_script" != null ]]; then
      json_body=$(curl -X GET "https://api.mypurecloud.de/api/v2/scripts/published/$id_script" -H 'Authorization: Bearer *******' -H 'Content-Type: application/json')
      name_script=$(echo -E "$json_body" | jq -r '.name')
    else
      name_script="NO_SCRIPT"
    fi
    echo "$name_queue;$name_script" >> queue_script.txt
  done

json_body=$(curl -X GET "$URL_QUEUE_2" -H 'Authorization: Bearer *******' -H 'Content-Type: application/json')

queues=$(echo "$json_body" | jq -r '.entities')

  for queue in $(echo "${queues}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${queue} | base64 --decode | jq -r ${1}
    }
    name_queue=$(_jq '.name')
    id_queue=$(_jq '.id')
    id_script=$(_jq '.defaultScripts.CALL.id')
    if [[ -n "$id_script" ]] || [[ "$id_script" != null ]]; then
      json_body=$(curl -X GET "https://api.mypurecloud.de/api/v2/scripts/published/$id_script" -H 'Authorization: Bearer *******' -H 'Content-Type: application/json')
      name_script=$(echo -E "$json_body" | jq -r '.name')
    else
      name_script="NO_SCRIPT"
    fi
    echo "$name_queue;$name_script" >> queue_script.txt
  done

echo "Done"