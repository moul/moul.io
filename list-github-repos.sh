#!/bin/bash

# Script to list all GitHub repositories for user 'moul'
# Sorted by creation date (most recent first)
# Shows whether each repo contains Go code, is a fork, and last update
# Usage: ./list-github-repos.sh [limit]
#        limit: number of repositories to show (default: all)

USERNAME="moul"
LIMIT="${1:-}"  # No default limit - show all repos

echo "Fetching repositories for user: $USERNAME"
echo

# Header
printf "%-40s | %-10s | %-10s | %-7s | %-7s | %s\n" "Repository Name" "Created" "Updated" "Is Fork" "Private" "Has Go"
printf "%-40s | %-10s | %-10s | %-7s | %-7s | %s\n" "----------------------------------------" "----------" "----------" "-------" "-------" "------"

# First, fetch ALL repositories to sort by creation date
# gh repo list returns repos sorted by updated date, so we need to fetch all and sort ourselves
ALL_REPOS=$(gh repo list "$USERNAME" --limit 1000 --json name,createdAt,updatedAt,isFork,isPrivate,languages | \
jq -r '.[] | 
    {
        name: .name,
        created: .createdAt,
        updated: .updatedAt,
        isFork: (if .isFork then "yes" else "no" end),
        isPrivate: (if .isPrivate then "yes" else "no" end),
        hasGo: (if .languages | map(.node.name) | contains(["Go"]) then "yes" else "no" end)
    } | 
    [.created, .name, .updated, .isFork, .isPrivate, .hasGo] | @tsv' | \
sort -t$'\t' -k1 -r)

# Now display the requested number of repos (or all if no limit)
if [ -n "$LIMIT" ]; then
    echo "$ALL_REPOS" | head -n "$LIMIT" | \
    while IFS=$'\t' read -r created_at name updated_at is_fork is_private has_go; do
        # Format the dates
        created_date=$(echo "$created_at" | cut -d'T' -f1)
        updated_date=$(echo "$updated_at" | cut -d'T' -f1)
        
        # Output the result
        printf "%-40s | %-10s | %-10s | %-7s | %-7s | %s\n" "$name" "$created_date" "$updated_date" "$is_fork" "$is_private" "$has_go"
    done
    echo
    echo "Showing top $LIMIT repositories sorted by creation date"
else
    echo "$ALL_REPOS" | \
    while IFS=$'\t' read -r created_at name updated_at is_fork is_private has_go; do
        # Format the dates
        created_date=$(echo "$created_at" | cut -d'T' -f1)
        updated_date=$(echo "$updated_at" | cut -d'T' -f1)
        
        # Output the result
        printf "%-40s | %-10s | %-10s | %-7s | %-7s | %s\n" "$name" "$created_date" "$updated_date" "$is_fork" "$is_private" "$has_go"
    done
    echo
    echo "Showing all repositories sorted by creation date"
fi