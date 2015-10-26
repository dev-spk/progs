#!/usr/bin/env bash

FOO=' test test test '
echo -e "FOO='${FOO}'"

FOO_NO_WHITESPACE="$(echo -e "${FOO}" | tr -d '[[:space:]]')"
echo -e "FOO_NO_WHITESPACE='${FOO_NO_WHITESPACE}'"
