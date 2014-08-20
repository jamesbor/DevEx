#!/bin/sh

# Comon Local Functions
function testFsDirIs()
{
	[ -d "${1}" ]
}

function testFsDirRead()
{
	[ -r "${1}" ]
}

function testFsDirWrite()
{
	[ -w "${1}" ]
}

function reportPathVars()
{
	echo
	for ITEM in $@
	do
		echo "Var:	${ITEM}"
		echo "Path:	${!ITEM}"
		testFsDirIs "${!ITEM}" 		&&
			echo "	- Exists"		||
			echo "	- Does not exits"
		testFsDirRead "${!ITEM}" 	&&
			echo "	- Readable"		||
			echo "	- Not Readable"
		testFsDirWrite "${!ITEM}" 	&&
			echo "	- Writeable"	||
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

