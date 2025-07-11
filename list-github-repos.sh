#!/bin/bash

# Script to list all GitHub repositories for user 'moul'
# Sorted by creation date (most recent first)
# Shows whether each repo contains Go code, is a fork, and last update
# Usage: ./list-github-repos.sh [limit]
#        limit: number of repositories to show (default: all, use 50 for top 50)

USERNAME="moul"
LIMIT="${1:-50}"  # Default to 50

echo "Fetching repositories for user: $USERNAME"
echo

# Header
printf "%-40s | %-10s | %-10s | %-7s | %s\n" "Repository Name" "Created" "Updated" "Is Fork" "Has Go"
printf "%-40s | %-10s | %-10s | %-7s | %s\n" "----------------------------------------" "----------" "----------" "-------" "------"

# First, fetch ALL repositories to sort by creation date
# gh repo list returns repos sorted by updated date, so we need to fetch all and sort ourselves
ALL_REPOS=$(gh repo list "$USERNAME" --limit 1000 --json name,createdAt,updatedAt,isFork,languages | \
jq -r '.[] | 
    {
        name: .name,
        created: .createdAt,
        updated: .updatedAt,
        isFork: (if .isFork then "yes" else "no" end),
        hasGo: (if .languages | map(.node.name) | contains(["Go"]) then "yes" else "no" end)
    } | 
    [.created, .name, .updated, .isFork, .hasGo] | @tsv' | \
sort -t$'\t' -k1 -r)

# Now display only the requested number of repos
echo "$ALL_REPOS" | head -n "$LIMIT" | \
while IFS=$'\t' read -r created_at name updated_at is_fork has_go; do
    # Format the dates
    created_date=$(echo "$created_at" | cut -d'T' -f1)
    updated_date=$(echo "$updated_at" | cut -d'T' -f1)
    
    # Output the result
    printf "%-40s | %-10s | %-10s | %-7s | %s\n" "$name" "$created_date" "$updated_date" "$is_fork" "$has_go"
done

echo
echo "Showing top $LIMIT repositories sorted by creation date"