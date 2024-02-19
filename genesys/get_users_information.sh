#!/usr/bin/env zsh
echo "nombre;email;userid;lastlogin;division" > users_2.txt

URL_SEARCH="https://apps.mypurecloud.de/platform/api/v2/users/search"

json_body=$(curl -X POST "$URL_SEARCH" -H 'Authorization: Bearer *****'' -H 'Content-Type: application/json' --data '{
  "pageSize": 100,
  "pageNumber": 1,
  "query": [
    {
      "type": "EXACT",
      "fields": [
        "state"
      ],
      "values": [
        "active",
        "inactive"
      ]
    }
  ],
  "sortOrder": "DESC",
  "sortBy": "name",
  "enforcePermissions": true
}') 

results=$(echo -E "$json_body" | jq -r '.results')
next_page=$(echo -E "$json_body" | jq -r '.nextPage')

echo $next_page

while [ "$next_page" != null ]
do
  for result in $(echo "${results}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${result} | base64 --decode | jq -r ${1}
    }
    name=$(_jq '.name')
    email=$(_jq '.email')
    id=$(_jq '.id')
    division=$(_jq '.division.name')

    json_body=$(curl -X GET "https://apps.mypurecloud.de/directory/api/v2/users/bulk/$id?personIds=true" -H 'Authorization: Bearer *****' -H 'Content-Type: application/json')

    timestamp=$(echo "$json_body" | jq -r '.res | .[] | .lastLogin')

    echo "$name;$email;$id;$timestamp;$division" >> users_2.txt
  done

  json_body=$(curl -X GET "https://apps.mypurecloud.de/platform/$next_page" -H 'Authorization: Bearer *****'' -H 'Content-Type: application/json')
  results=$(echo -E "$json_body" | jq -r '.results')
  next_page=$(echo -E "$json_body" | jq -r '.nextPage')
  echo $next_page
  
done

echo "DONE"