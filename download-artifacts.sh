#!/bin/sh

# http://redsymbol.net/articles/unofficial-bash-strict-mode/                                                                                                                                                     
set -euo pipefail                                                                                                                                                                                                
IFS=$'\n\t'

groupId=$1
artifactId=$2
version=$3

# optional                                                                                                                                                                                                       
#classifier=${4:-}                                                                                                                                                                                                
#type=${5:-war}                                                                                                                                                                                                   
type=${4:-war}                                                                                                                                                                                                   
#repo=${6:-snapshots}                                                                                                                                                                                             
repo=${5:-snapshots}                                                                                                                                                                                             
                                                                                                                                                                                                                 
base=${6:-"http://13.56.58.128:8081/repository/devops-test-repo-snapshot"}                                                                                                                                                                                             
classifier=${7:-}                                                                                                                                                                                                
#base="http://13.56.58.128:8081/repository/devops-test-repo-snapshot"

# Nexus 2                                                                                                                                                                                                        
#base="http://nexus.example.com/service/local/repositories/${repo}/content"                                                                                                                                                   
# Nexus 3                                                                                                                                                                                                        
#base="http://nexus.example.com/repository/${repo}"                                                                                                                                                                         
                                                                                                                                                                                                                 
if [[ $classifier != "" ]]; then                                                                                                                                                                                 
  classifier="-${classifier}"                                                                                                                                                                                    
fi                                                                                                                                                                                                               
                                                                                                                                                                                                                 
groupIdUrl="${groupId//.//}"                                                                                                                                                                                     
filename="${artifactId}-${version}${classifier}.${type}"                                                                                                                                                         
                                                                                                                                                                                                                 
if [[ "${version}" == "LATEST" || "${version}" == *SNAPSHOT* ]] ; then                                                                                                                                           
  if [[ "${version}" == "LATEST" ]] ; then                                                                                                                                                                       
    version=$(xmllint --xpath "string(//latest)" <(curl -s "${base}/${groupIdUrl}/${artifactId}/maven-metadata.xml"))                                                                                            

  fi                                                                                                                                                                                                             
  echo "version is $version";

  timestamp=`curl -s "${base}/${groupIdUrl}/${artifactId}/${version}/maven-metadata.xml" | xmllint --xpath "string(//timestamp)" -`
  buildnumber=`curl -s "${base}/${groupIdUrl}/${artifactId}/${version}/maven-metadata.xml" | xmllint --xpath "string(//buildNumber)" -`

  echo "buildnumber is $buildnumber";

  curl -s -o ${filename} "${base}/${groupIdUrl}/${artifactId}/${version}/${artifactId}-${version%-SNAPSHOT}-${timestamp}-${buildnumber}${classifier}.${type}"                                                    
else                                                                                                                                                                                                             
  curl -s -o ${filename} "${base}/${groupIdUrl}/${artifactId}/${version}/${artifactId}-${version}${classifier}.${type}"                                                                                          
fi

