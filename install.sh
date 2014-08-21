#!/bin/sh

# Lets source any external libs/files
. ./colours.inc.properties

# Comon Local Functions
expandVar ()
{
	eval echo \""\$${1}"\"
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

preparePath()
{
	# In case the path contains '~' symbols, or other variables, lets expand it as we assign...
	local PROCESS_PATH="$( expandVar "${1}" )"
	testFsDirIs "${PROCESS_PATH}" && echo "${COL_GREEN}Path already exists:	${COL_BOLD_PURPLE}${PROCESS_PATH}${COL_RESET}" || 
	{
		echo "${COL_GREEN}Creating Path:	${COL_BOLD_PURPLE}${PROCESS_PATH}${COL_RESET}"
		mkdir -p -v "${PROCESS_PATH}"
	}
}

USER_PREFIX="~/DevEx"
USER_VERSIONS_PREFIX="~/.DevEx/versions"
SYSTEM_PREFIX="/DevEx"
SYSTEM_VERSIONS_PREFIX="/usr/local/DevEx/versions"
INSTALL_TYPE="USER"

echo "${COL_BOLD_PURPLE}Report of System State in FS locations${COL_RESET}"
echo
reportPathVars 	USER_PREFIX 			\
				USER_VERSIONS_PREFIX 	\
				SYSTEM_PREFIX 			\
				SYSTEM_VERSIONS_PREFIX
echo "${COL_GREEN}Install Type: ${COL_BOLD_PURPLE}${INSTALL_TYPE}${COL_RESET}"
echo preparePath		"$( expandVar "${INSTALL_TYPE}_PREFIX" )"
echo preparePath		"$( expandVar "${INSTALL_TYPE}_VERSIONS_PREFIX" )"

