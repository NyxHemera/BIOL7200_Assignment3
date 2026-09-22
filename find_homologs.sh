#!/bin/bash
# usage: find_homologs.sh <query file> <subject file> <output file>

query_file="$1"
subject_file="$2"
output_file="$3"

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

blastx -query "$query_file" -subject "$subject_file" \
    -outfmt '6 qseqid sseqid pident length qlen evalue bitscore' \
    > "$tmp_file"

awk -F '\t' 'BEGIN { OFS = "\t" }
    $3 > 30 && ($4 / $5) > 0.90 { print }' "$tmp_file" > "$output_file"

match_count=$(wc -l < "$output_file" | tr -d '[:space:]')
if [[ -z "$match_count" ]]; then
    match_count=0
fi

printf '%s\n' "$match_count"
