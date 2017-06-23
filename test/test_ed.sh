#!/bin/sh

print_usage() {
	echo "ed_test <verify-reference|verify-streaming|sign> data_size"
}

TMP=$(mktemp -d)
CODE=0
case $1 in
"verify-reference"*)
	head -c $2 /dev/urandom > ${TMP}/data
	PAIR=$(./genpair)
	PRIVATE=$(echo ${PAIR} | cut -d : -f1)
	PUBLIC=$(echo ${PAIR} | cut -d : -f2)
	SIGNATURE=$(./sign_reference ${PUBLIC} ${PRIVATE} ${TMP}/data)
	VALID=$(./verify_reference ${PUBLIC} ${SIGNATURE} ${TMP}/data)
	if [ ${VALID} = "Valid" ]; then
		echo "Signature is valid"
	else
		echo "Signature is invalid"
		CODE=1
	fi
;;
"verify-streaming"*)
	head -c $2 /dev/urandom > ${TMP}/data
	PAIR=$(./genpair)
	PRIVATE=$(echo ${PAIR} | cut -d : -f1)
	PUBLIC=$(echo ${PAIR} | cut -d : -f2)
	SIGNATURE=$(./sign_reference ${PUBLIC} ${PRIVATE} ${TMP}/data)
	VALID=$(./verify_streaming ${PUBLIC} ${SIGNATURE} ${TMP}/data)
	if [ ${VALID} = "Valid" ]; then
		echo "Signature is valid"
	else
		echo "Signature is invalid"
		CODE=1
	fi

;;
"sign"*)
	head -c $2 /dev/urandom > ${TMP}/data
	PAIR=$(./genpair)
	PRIVATE=$(echo ${PAIR} | cut -d : -f1)
	PUBLIC=$(echo ${PAIR} | cut -d : -f2)
	SIGNATURE_REFERENCE=$(./sign_reference ${PUBLIC} ${PRIVATE} ${TMP}/data)
	SIGNATURE_STREAMING=$(./sign_streaming ${PUBLIC} ${PRIVATE} ${TMP}/data)
	if [ "${SIGNATURE_REFERENCE}" = "${SIGNATURE_STREAMING}" ]; then
		echo "Signatures match"
	else
		echo "Signatures don't match"
		CODE=1
	fi

;;

*)
	echo "Unknown command: $1"
	CODE=1
esac

rm -r ${TMP}

exit ${CODE}
