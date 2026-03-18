#!/usr/bin/env bash
# Outputs time with Arabic word for day (نهار) or night (ليل).
# 6:00–17:59 → نهار   18:00–5:59 → ليل

hour=$(date +%H)
time=$(date +"%I:%M")
if (( 10#$hour >= 6 && 10#$hour < 18 )); then
    echo "نهار  $time"
else
    echo "ليل  $time"
fi
