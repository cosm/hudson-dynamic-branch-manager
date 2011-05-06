#!/bin/bash
set -e
set -u
project_name=$1 #e.g. pachweb
simple_name=$2 #this should be a simple name (like hotfix-1.3.1 or rc-1.2, never prefixed with origin/)
job_name=${project_name}_$simple_name
java -jar /var/run/hudson/war/WEB-INF/hudson-cli.jar -s http://localhost:8080 delete-job $job_name

