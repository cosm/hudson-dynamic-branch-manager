#!/bin/bash
set -e
set -u
#the env var CI_TYPE is expected to be hudson or jenkins, and controls location and name of the cli jar.

project_name=$1 #e.g. pachweb
simple_name=$2 #this should be a simple name (like hotfix-1.3.1 or rc-1.2, never prefixed with origin/)
job_name=${project_name}_$simple_name
java -jar /var/run/${CI_TYPE}/war/WEB-INF/${CI_TYPE}-cli.jar -s http://localhost:8080 delete-job $job_name
