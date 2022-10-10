#!/bin/bash
set -euo pipefail

echo "# Generated environment variables from tf output"

jq -r '
    [
        {
            "path": "rg_name",
            "env_var": "RESOURCE_GROUP_NAME"
        }
    ]
        as $env_vars_to_extract
    |
    with_entries(
        select (
            .key as $a
            |
            any( $env_vars_to_extract[]; .path == $a)
        )
        |
        .key |= . as $old_key | ($env_vars_to_extract[] | select (.path == $old_key) | .env_var)
    )
    |
    to_entries
    |
    map("\(.key)=\(.value.value)")
    |
    .[]
    ' | sed "s/\"/'/g" # replace double quote with single quote to handle special chars
