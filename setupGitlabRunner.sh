#!/bin/bash

set -e

printUsage()
{
	echo "Usage: $(basename $0) [-j N][-t token1][-t token2]"
	echo "      -j N: handle N jobs in parallel"
	echo "      -t token : found on gitlab project's \"runners\" page or the admin section's \"runners\" page"
}

printWarning()
{
    echo -e "${BYellow}${1}${ColorOff}"
}

./setupDocker.sh

if ! dpkg -s gitlab-ci-multi-runner &>/dev/null
then
	printWarning "Installing gitlab-ci-multi-runner..."
	curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | os=debian dist=jessie bash
	cat > /etc/apt/preferences.d/pin-gitlab-runner.pref <<EOF
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-ci-multi-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF

	apt-get install gitlab-ci-multi-runner
else
	printWarning "skipping gitlab-ci-multi-runner install"
fi


registerRunner()
{
	token=$1

	gitlab-runner register \
	--non-interactive \
	--url=http://gitlab.sonatest.net/ci \
	--registration-token=$token \
	--tags=docker \
	--executor=docker \
	--docker-image=alpine \

}

setConcurrentJobs()
{
	jobQty=$1
	# single digit only... otherwise more than 9 jobs... are you crazy!!
	echo $jobQty | grep -q "^[0-9]\$"

	sed -i "s/^concurrent = [0-9]\$/concurrent = ${jobQty}/" /etc/gitlab-runner/config.toml
	echo printWarning "Successfully changed parallel job quantity to $jobQty"
	echo printWarning "you'll need to \"service gitlab-runner restart\" for the value to take effect"
	# ... at least, I think.
}

while getopts "ht:j:" n; do
	case ${n} in
		h)
			printUsage
			exit 0
			;;
		t)
			token="${OPTARG}"
			printWarning "registering using token $token"
			registerRunner $token
			;;
		j)
			setConcurrentJobs ${OPTARG}
			;;
		*)
			echo "Unknown option given" >&2
			printUsage
			exit 1
			;;
	esac
done

shift $(($OPTIND - 1))
if [[ -n "$@" ]]
then
	echo "Trailing argument(s) given: $@" >&2
	exit 1
fi

