#!/bin/bash

function main {
	touch test.txt

	echo 'cat' > test.txt
}

main ${@}