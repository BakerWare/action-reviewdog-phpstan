#!/bin/sh

github_action_path=$(dirname "$0")

cd "${GITHUB_WORKSPACE}" || exit 1
TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group::🐶 Setting Up Phpstan config'
if [ ! -f "${GITHUB_WORKSPACE}/phpstan.dist.neon" ]; then
    cp "${github_action_path}/.github/phpstan.dist.neon" "${GITHUB_WORKSPACE}/phpstan.dist.neon"
fi
echo '::endgroup::'

echo '::group:: Running phpstan with reviewdog 🐶 ...'

reviewdog --version

vendor/bin/phpstan analyse --memory-limit 1G --error-format=raw | reviewdog -tee -name=PHPStan -f=phpstan -reporter="${INPUT_REPORTER:-github-pr-review}" -level="${INPUT_LEVEL}" -fail-level="${INPUT_FAIL_LEVEL}" -filter-mode="${INPUT_DIFF_CONTEXT}"

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc
