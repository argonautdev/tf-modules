#!/bin/bash

# export EXCLUDED environment variable which is used to delete individual resources
# this flag is updated each time parsing is done. So when delete action is triggered
# this will contain the list of all the resources in it. All the other resources
# excluding the listed below ones will be deleted
export EXCLUDED='{{ range $key, $value := .TerragruntResourceDir }}{{ if $value }}--terragrunt-exclude-dir {{ $key }} {{ end }}{{ end }}'
# export INCLUDED environment variable which is used to apply on only the resources
# that are currently in the current spec
export INCLUDED='{{ range $key, $value := .TerragruntResourceDir }}{{ if $value }}--terragrunt-include-dir {{ $key }} {{ end }}{{ end }}'
