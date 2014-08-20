#!/bin/sh

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
		echo "Var:	${ITEM}"
		echo "Path:	$( expandVar ITEM )"
		testFsDirIs "$( expandVar ITEM )" 		&&
			echo "	- Exists"					||
			echo "	- Does not exits"
		testFsDirRead "$( expandVar ITEM )" 	&&
			echo "	- Readable"					||
			echo "	- Not Readable"
		testFsDirWrite "$( expandVar ITEM )" 	&&
			echo "	- Writeable"				||
			echo "	- Not Writeable"
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

