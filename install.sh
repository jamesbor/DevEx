#!/bin/sh

# Lets source any external libs/files
. ./colours.inc.properties

# Comon Local Functions
expandVar ()
{
	eval echo \""\$${1}"\"
	echo "${ITEM}"
	echo "${USER_PREFIX}"
	echo "${SYSTEM_PREFIX}"
	echo "${USER_VERSIONS_PREFIX}"
	echo "${SYSTEM_VERSIONS_PREFIX}"
}

testFsDirIs ()
{
	[ -d "${1}" ]
}

testFsDirRead ()
{
	[ -r "${1}" ]
}

testFsDirWrite ()
{
	[ -w "${1}" ]
}

reportPathVars ()
{
	echo
	for ITEM in $@
	do
		PATH_TO_REPORT="$( expandVar "${ITEM}" )"
		echo "${COL_GREEN}Var${COL_BOLD_WHITE}:${COL_BLUE}	${ITEM}${COL_RESET}"
		echo "${COL_GREEN}Path${COL_BOLD_WHITE}:${COL_BLUE}	${PATH_TO_REPORT}${COL_RESET}"
		testFsDirIs "${PATH_TO_REPORT}" 								&&
			echo "	${COL_YELLOW}-${COL_BLUE} Exists${COL_RESET}"		||
			echo "	${COL_YELLOW}-${COL_RED} Does not exits${COL_RESET}"
		testFsDirRead "${PATH_TO_REPORT}" 								&&
			echo "	${COL_YELLOW}-${COL_BLUE} Readable${COL_RESET}"		||
			echo "	${COL_YELLOW}-${COL_RED} Not Readable${COL_RESET}"
		testFsDirWrite "${PATH_TO_REPORT}" 								&&
			echo "	${COL_YELLOW}-${COL_BLUE} Writeable${COL_RESET}"	||
			echo "	${COL_YELLOW}-${COL_RED} Not Writeable${COL_RESET}"
	done
}

USER_PREFIX="~/DevEx"
SYSTEM_PREFIX="/DevEx"
USER_VERSIONS_PREFIX="~/.DevEx/versions"
SYSTEM_VERSIONS_PREFIX="/usr/local/DevEx/versions"

echo "Report of System State in FS locations"
reportPathVars 	USER_PREFIX 			\
				USER_VERSIONS_PREFIX 	\
				SYSTEM_PREFIX 			\
				SYSTEM_VERSIONS_PREFIX

