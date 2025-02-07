#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
    cd "${GITHUB_WORKSPACE}" || exit
    git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "${GITHUB_WORKSPACE}/phpstan.dist.neon" ]; then
    cp /config/phpstan.dist.neon "${GITHUB_WORKSPACE}/phpstan.dist.neon"
fi

OPTION_LEVEL=""
TARGET_DIRECTORY=""

if [ -n "${INPUT_PHPSTAN_LEVEL}" ]; then
    OPTION_LEVEL="--level=${INPUT_PHPSTAN_LEVEL}"
fi

if [ -n "${INPUT_TARGET_DIRECTORY}" ]; then
    TARGET_DIRECTORY="${INPUT_TARGET_DIRECTORY}"
fi

phpstan analyse ${TARGET_DIRECTORY} ${OPTION_LEVEL} --memory-limit 1G --error-format=raw ${INPUT_ARGS} |
    reviewdog -tee -name=PHPStan -f=phpstan -reporter=${INPUT_REPORTER} -fail-on-error=${INPUT_FAIL_ON_ERROR} -level=${INPUT_LEVEL} -diff='git diff'
