#!/bin/bash
# Command to run: ./check-release.sh 15142 meetsmore/meetsone
# Input arguments
PR_NUMBER=$1
REPO=$2
PR_LINK="https://github.com/$REPO/pull/$PR_NUMBER"

# Slack member ID's
declare -A SLACK_USER_IDS=(
  ["LennardUy104"]="U05CFACM0DD"
  ["Francis-Tulang"]="U03N2F6G4J0"
  ["jeraldechavia"]="U02HWN106HH"
  ["jescabillas"]="U0432724NF4"
  ["escbooster12-dev"]="U02AWTP13BM"
  ["rdelrosa"]="U02RP7G12KH"
  ["jstephend-sun"]="U02N5296LE4"
  ["reno-angelo"]="U08003FTP3M"
  ["hieutm-3360"]="U03NJMQHFRD"
  ["mdv-sunasterisk"]="U071NLP7RQB"
)

# Get the list of reviewers (requested + those who have already reviewed)
REVIEWERS=($(gh pr view "$PR_NUMBER" --repo "$REPO" --json reviewRequests,reviews | jq -r '
  ([.reviewRequests[].login] + [.reviews[].author.login]) | unique | .[]'
))

# Get the list of PR authors who are NOT reviewers
NON_REVIEWERS=($(gh pr view "$PR_NUMBER" --repo "$REPO" --json commits | jq -r --argjson reviewers "$(printf '%s\n' "${REVIEWERS[@]}" | jq -R . | jq -s .)" '
  [.commits[].authors[].login]
  | unique
  | map(select(. as $login | $reviewers | index($login) | not))
  | map(select(. | IN(
    "LennardUy104",
    "Francis-Tulang",
    "jeraldechavia",
    "jescabillas",
    "escbooster12-dev",
    "rdelrosa",
    "jstephend-sun",
    "reno-angelo",
    "hieutm-3360",
    "mdv-sunasterisk"
  )))[]'
))

# Construct the Slack mention string
LOGINS_WITH_MENTIONS=""
for login in "${NON_REVIEWERS[@]}"; do
  USER_ID="${SLACK_USER_IDS[$login]}"
  if [[ -n "$USER_ID" ]]; then
    LOGINS_WITH_MENTIONS+="<@$USER_ID>, "
  fi
done

# Trim the trailing comma and space
LOGINS_WITH_MENTIONS="${LOGINS_WITH_MENTIONS%, }"

# Create Slack-formatted hyperlink
PR_HYPERLINK="<${PR_LINK}|new release>"

# If there are non-reviewers to mention, send the Slack message
if [[ -n "$LOGINS_WITH_MENTIONS" ]]; then
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"channel\": \"D12345678\", \"text\": \"Hello! \nThere's a ${PR_HYPERLINK} :point_left::skin-tone-3:\nKindly add yourselves as reviewers! :usamaru-bow: \n$LOGINS_WITH_MENTIONS\"}" \
    https://hooks.slack.com/services/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
    else
  curl -X POST -H 'Content-type: application/json' --data "{
    \"channel\": \"D12345678\",
    \"text\": \"All contributors has been added as reviewers. :partyface:\"
  }" https://hooks.slack.com/services/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
fi
