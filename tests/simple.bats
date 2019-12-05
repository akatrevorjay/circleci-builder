#!/usr/bin/env bats
set -eo pipefail
shopt -s nullglob

: ${IMAGE:?}

save-retval() {
	local -n rv_ref=$1; shift
	"$@" && rv_ref=0 || rv_ref=$?
	return $rv_ref
}

run-in-image() {
	local dargs=()

	local arg
	for arg in "$@"; do
		shift
		[[ "$arg" != "--" ]] || break
		dargs+=("$arg")
	done

	local cmd=(
		docker run
		--rm
		"${dargs[@]}"
		"${IMAGE:?}"
		"$@"
	)

	save-retval rv "${cmd[@]}"
}

@test "[python2] print hello world" {
	expected="hello world"
	result=$(run-in-image -- bash -c $'python2 -c "print(\'hello world\')"')
	[[ "$result" == "$expected" ]]
}

@test "[python3] print hello world" {
	expected="hello world"
	result=$(run-in-image -- bash -c $'python3 -c "print(\'hello world\')"')
	[[ "$result" == "$expected" ]]
}

