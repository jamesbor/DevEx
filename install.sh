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
	echo
	for ITEM in $@
	do
		PATH_TO_REPORT="$( expandVar "${ITEM}" )"
		echo "${COL_GREEN}Var${COL_BOLD_WHITE}:${COL_BOLD_BLUE}	${ITEM}${COL_RESET}"
		echo "${COL_GREEN}Path${COL_BOLD_WHITE}:${COL_BOLD_BLUE}	${PATH_TO_REPORT}${COL_RESET}"
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
	echo
}

preparePath()
{
	# In case the path contains '~' symbols, or other variables, lets expand it as we assign...
	local PROCESS_PATH="${1}"
	testFsDirIs "${PROCESS_PATH}" && echo "${COL_GREEN}Path already exists:	${COL_BOLD_PURPLE}${PROCESS_PATH}${COL_RESET}" || 
	{
		echo "${COL_GREEN}Creating Path:	${COL_BOLD_PURPLE}${PROCESS_PATH}${COL_RESET}"
		mkdir -p -v "${PROCESS_PATH}"
	}
}

verifyDependencyExecutable()
{
	local CHECK="${1}"
	which "${CHECK}" 2>/dev/null											&& 
		echo "Dependency Verified: '${CHECK}', Found executable in path." 	||
		{
			echo "Dependency Verificiation Failed! '${CHECK}' was not found in the path."
			return 1
		}
}

gitTagLATEST()
{
	git tag ${1} | sort --version-sort
}

# Verify any dependancys
verifyDependencyExecutable "git"
verifyDependencyExecutable "sed"
verifyDependencyExecutable "awk"
verifyDependencyExecutable "rvm"
verifyDependencyExecutable "gem"
verifyDependencyExecutable "ruby"
verifyDependencyExecutable "curl"

# Declare any variables
USER_PREFIX="${HOME}/DevEx"
USER_VERSIONS_PREFIX="${HOME}/.DevEx/versions"
SYSTEM_PREFIX="/DevEx"
SYSTEM_VERSIONS_PREFIX="/usr/local/DevEx/versions"
INSTALL_TYPE="USER"
INSTALL_SOURCE="https://github.com/jamesbor/DevEx.git"
INSTALL_DIR="$( expandVar "${INSTALL_TYPE}_VERSIONS_PREFIX" )/HEAD"
DEVEX_HOME="$( expandVar "${INSTALL_TYPE}_PREFIX" )"

echo
echo "${COL_BOLD_PURPLE}Report of System State in FS locations${COL_RESET}"
reportPathVars 	USER_PREFIX 			\
				USER_VERSIONS_PREFIX 	\
				SYSTEM_PREFIX 			\
				SYSTEM_VERSIONS_PREFIX
echo "${COL_GREEN}Install Type:	${COL_BOLD_PURPLE}${INSTALL_TYPE}${COL_RESET}"
preparePath		"${INSTALL_DIR}"
reportPathVars 	USER_PREFIX 			\
				USER_VERSIONS_PREFIX 	\
				SYSTEM_PREFIX 			\
				SYSTEM_VERSIONS_PREFIX

if testFsDirIs "${INSTALL_DIR}"
then
	if testFsDirIs "${INSTALL_DIR}/.git"
	then
		echo "Path: '${INSTALL_DIR}' already exists, and is a git repo, so lets update it..."
	else
		echo "Path: '${INSTALL_DIR}' exists but is not a git repo, so moving to the side so we can make it one..."
		mv -v "${INSTALL_DIR}" "${INSTALL_DIR}-install-backup-$( date "+%Y-%m-%d-%T" )"
		echo "Path '${INSTALL_DIR}' is being re-baselined to use git, so going to clone HEAD..."
		git clone --quiet --verbose "${INSTALL_SOURCE}" "${INSTALL_DIR}"
	fi
	cd "${INSTALL_DIR}"
	git pull --quiet --verbose
	cd - >/dev/null
else
	echo "Path '${INSTALL_DIR}' does not exist, so going to clone HEAD..."
	git clone --quiet --verbose "${INSTALL_SOURCE}" "${INSTALL_DIR}"
fi

if testFsDirIs "${DEVEX_HOME}"
then
	echo "Path '${DEVEX_HOME}' exists, nothing to do but report it's state:"
	ls -l "${DEVEX_HOME}"
else
	echo "Path: '${DEVEX_HOME}' does not exits, so going to link it to: '${INSTALL_DIR}'..."
	ln -s -v "${INSTALL_DIR}" "${DEVEX_HOME}"
fi

#preparePath		"$( expandVar "${INSTALL_TYPE}_PREFIX" )"
#echo
#echo "Returning to previous state:"
#echo "Deleting..."
#rm -r -f -v "$( expandVar "${INSTALL_TYPE}_PREFIX" )"
#rm -r -f -v "$( expandVar "${INSTALL_TYPE}_VERSIONS_PREFIX" )"
echo
