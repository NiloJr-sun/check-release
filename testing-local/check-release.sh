#!/bin/bash
# Command to run: ./check-release.sh 15142 meetsmore/meetsone

TARGET_USER=https://hooks.slack.com/services/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

PR_LINK=$1
THREAD_TS=$2

PR_NUMBER=$(echo "$PR_LINK" | grep -oE '[0-9]+$')
REPO=$(echo "$PR_LINK" | sed -E 's|https://github.com/([^/]+/[^/]+)/pull/[0-9]+|\1|')

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
if [[ -n "$THREAD_TS" ]]; then
  # Threaded message
  if [[ -n "$LOGINS_WITH_MENTIONS" ]]; then
    curl -X POST -H 'Content-type: application/json' --data "{
      \"channel\": \"D12345678\",
      \"thread_ts\": \"$THREAD_TS\",
      \"text\": \"Following up! 🚀\nKindly add yourselves as reviewers! :usamaru-bow: \n$LOGINS_WITH_MENTIONS\"
    }" "$TARGET_USER"
  else
    curl -X POST -H 'Content-type: application/json' --data "{
      \"channel\": \"D12345678\",
      \"thread_ts\": \"$THREAD_TS\",
      \"text\": \"All contributors have been added as reviewers. :partyface:\"
    }" "$TARGET_USER"
  fi
else
  # Top-level message
  if [[ -n "$LOGINS_WITH_MENTIONS" ]]; then
    curl -X POST -H 'Content-type: application/json' --data "{
      \"channel\": \"D12345678\",
      \"text\": \"Hello! \nThere's a ${PR_HYPERLINK} :point_left::skin-tone-3:\nKindly add yourselves as reviewers! :usamaru-bow: \n$LOGINS_WITH_MENTIONS\"
    }" "$TARGET_USER"
  else
    curl -X POST -H 'Content-type: application/json' --data "{
      \"channel\": \"D12345678\",
      \"text\": \"All contributors have been added as reviewers. :partyface:\"
    }" "$TARGET_USER"
  fi
fi
