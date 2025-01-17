#!/usr/bin/env bash
# this script checks the status of a quality gate for a particular analysisID
# approach taken from https://docs.sonarqube.org/display/SONARQUBE53/Breaking+the+CI+Build
# When SonarScanner executes, the compute engine task is given an id
# The status of this task, and analysisId for the task can be checked at
# /api/ce/task?id=taskid
# When the status is SUCCESS, the quality gate status can be checked at
# /api/qualitygates/project_status?analysisId=analysisId


# in newer versions of sonar scanner the default report-task.txt location may be different
# REPORT_PATH=".scannerwork/report-task.txt"
REPORT_PATH="target/sonar/report-task.txt"
CE_TASK_ID_KEY="ceTaskId="

SONAR_INSTANCE="${1}"
SONAR_ACCESS_TOKEN="${2}"
SLEEP_TIME=5

echo "QG Script --> Using SonarQube instance ${SONAR_INSTANCE}"
echo "QG Script --> Using SonarQube access token ${SONAR_ACCESS_TOKEN}"

# get the compute engine task id
ce_task_id=$(cat $REPORT_PATH | grep $CE_TASK_ID_KEY | cut -d'=' -f2)
echo "QG Script --> Using task id of ${ce_task_id}"

if [ -z "$ce_task_id" ]; then
   echo "QG Script --> No task id found"
   exit 1
fi

# grab the status of the task
# if CANCELLED or FAILED, fail the Build
# if SUCCESS, stop waiting and grab the analysisId
wait_for_success=true

while [ "${wait_for_success}" = "true" ]
do 
echo "curl -s -u "${SONAR_ACCESS_TOKEN}": "${SONAR_INSTANCE}"/api/ce/task?id=${ce_task_id} | jq -r .task.status"
echo "$(curl -s -u ${SONAR_ACCESS_TOKEN}: ${SONAR_INSTANCE}/api/ce/task?id=${ce_task_id}"
  ce_status=$(curl -s -u "${SONAR_ACCESS_TOKEN}": "${SONAR_INSTANCE}"/api/ce/task?id=${ce_task_id} | jq -r .task.status)

  echo "QG Script --> Status of SonarQube task is ${ce_status}"

  if [ "${ce_status}" = "CANCELLED" ]; then
    echo "QG Script --> SonarQube Compute job has been cancelled - exiting with error"
    exit 1
  fi

  if [ "${ce_status}" = "FAILED" ]; then
    echo "QG Script --> SonarQube Compute job has failed - exiting with error"
    exit 1
  fi

  if [ "${ce_status}" = "SUCCESS" ]; then
    wait_for_success=false
  fi

  sleep "${SLEEP_TIME}"

done

ce_analysis_id=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/ce/task?id=$ce_task_id | jq -r .task.analysisId)
echo "QG Script --> Using analysis id of ${ce_analysis_id}"

# get the status of the quality gate for this analysisId
qg_status=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/qualitygates/project_status?analysisId="${ce_analysis_id}" | jq -r .projectStatus.status)
echo "QG Script --> Quality Gate status is ${qg_status}"

if [ "${qg_status}" != "OK" ]; then
  echo "QG Script --> Quality gate is not OK - exiting with error"
  exit 1
fi
