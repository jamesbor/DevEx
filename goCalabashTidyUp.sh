#!/bin/bash -e

# Local Functions
function testOutputContains() { grep -v grep | grep "$@" 2>&1 >/dev/null ; }  # Silent Tester

# Variable Setup
RETRY_ATTEMPTS=5
RUN_AS="$( whoami )"
DEFAULT_DEVICE_ID="f11f5afe-dbbc-4875-bf70-e443f53e4a22" # "Nexus 4 - 4.3 - API 18 - 768x1280"
[ -z "${DEVICE_ID}" ] &&
  echo "DEVICE_ID does not appear to be set, defaulting to DEFAULT_DEVICE_ID" &&
  DEVICE_ID="${DEFAULT_DEVICE_ID}"
ATTEMPTS_TO_STOP="${RETRY_ATTEMPTS}"
ATTEMPTS_TO_KILL="${RETRY_ATTEMPTS}"
ATTEMPTS_TO_START="${RETRY_ATTEMPTS}"
ATTEMPT_TO_STOP=0
ATTEMPT_TO_KILL=0
ATTEMPT_TO_START=0

# Welcome & Debug Splash
echo "Genymotion Execution Script"
echo "==========================="
echo "RUN_AS:             '${RUN_AS}'"
echo "DEVICE_NAME:        '${DEVICE_NAME}'"
echo "DEFAULT_DEVICE_ID:  '${DEFAULT_DEVICE_ID}'"
echo "DEVICE_ID:          '${DEVICE_ID}'"
echo "RETRY_ATTEMPTS:     '${RETRY_ATTEMPTS}'"
echo "ATTEMPTS_TO_STOP:   '${ATTEMPTS_TO_STOP}'"
echo "ATTEMPTS_TO_KILL:   '${ATTEMPTS_TO_KILL}'"
echo "ATTEMPTS_TO_START:  '${ATTEMPTS_TO_START}'"
echo

# Start Execution by reporting what devices are there
adb devices || true

echo -n "Testing DEVICE_NAME: "
case "${DEVICE_NAME}" in
  genymotion)
    echo "Found a DEVICE_NAME of 'genymotion'"
    echo -n "Testing if DEVICE_ID is installed on this host: "
    if VBoxManage list vms | testOutputContains "${DEVICE_ID}"
    then
      echo "DEVICE_ID is installed on this host"

      # Attempt to KILL the VM if it IS STILL running
      while ps | testOutputContains "${DEVICE_ID}" &&
        [ "${ATTEMPT_TO_STOP}" -lt "${ATTEMPTS_TO_STOP}" ]
      do
        ((ATTEMPT_TO_KILL++))
        echo "[${ATTEMPT_TO_KILL}/${ATTEMPTS_TO_KILL}] Attempting to kill DEVICE_ID: ${DEVICE_ID}"
        ps | grep "${DEVICE_ID}" | grep -v grep | awk '{print $1}' | xargs kill
        sleep 10
        if ps | testOutputContains "${DEVICE_ID}"
        then
          echo "Process is still running, Killing a bit more forcefully..."
          ps | grep "${DEVICE_ID}" | grep -v grep | awk '{print $1}' | xargs kill -9
          sleep 10
        fi
      done

      # Attempt to STOP the VM if it IS running
      while VBoxManage list runningvms | testOutputContains "${DEVICE_ID}" &&
        [ "${ATTEMPT_TO_STOP}" -lt "${ATTEMPTS_TO_STOP}" ]
      do
        ((ATTEMPT_TO_STOP++))
        echo "[${ATTEMPT_TO_STOP}/${ATTEMPTS_TO_STOP}] Attempting to stop DEVICE_ID: ${DEVICE_ID}"
        VBoxManage controlvm "${DEVICE_ID}" poweroff
      done

      #echo "Killing ADB Server"
      #adb kill-server && echo "Succeeded in Killing ADB Server." || echo "Failed to kill ADB Server."         1>&2

      adb devices || true

      #check adb can find device
      if [[ `adb devices | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'` == "List of devices attached" ]]
      then
        echo "ADB cannot find device"
        exit 1
      fi
    else
      echo "DEVICE_ID is NOT installed on this host, therefore unable to perform tests..."
    fi
    ;;
  *)
    # We DO NOT have a DEVICE_NAME of 'genymotion'
    echo "This agent '$( hostname )' does not have the DEVICE_NAME environment variable set to 'genymotion'."  1>&2
    echo "Unable to execute Genymotion tasks, continuing..."                                                   1>&2
    exit 0
    ;;
esac
