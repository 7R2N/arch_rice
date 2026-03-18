#!/usr/bin/env bash
# Outputs time with a kanji for day (昼) or night (夜).
# 6:00–17:59 → 昼   18:00–5:59 → 夜
hour=$(date +%H)
time=$(date +"%I:%M")
if (( 10#$hour >= 6 && 10#$hour < 18 )); then
  echo "昼  $time"
else
  echo "夜  $time"
fi
