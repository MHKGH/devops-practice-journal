#!/bin/bash

LOG_DIR="/home/hemanth/Documents/tech_world_with_nana/logs"
ERROR_PATTERNS=("ERROR" "FATAL" "CRITICAL")
REPORT_FILE="/home/hemanth/Documents/tech_world_with_nana/logs/log_analysis_report.txt"

echo "Analysing log files" > "$REPORT_FILE"
echo "=====================" >> "$REPORT_FILE"


echo -e "\n============================================================================================" >> $REPORT_FILE
echo "==== Analysing log files in $LOG_DIR directory ====" >> $REPORT_FILE
echo "============================================================================================" >> $REPORT_FILE

echo -e "\nList of log files updated in last 24 hours" >> $REPORT_FILE
LOG_FILES=$(find $LOG_DIR -name "*.log" -mtime -1) #Command Subtitution
echo "$LOG_FILES" >> $REPORT_FILE

for LOG_FILE in $LOG_FILES; do

    echo "=================================================================================" >> $REPORT_FILE
    echo "======== $LOG_FILE ======" >> $REPORT_FILE
    echo "=================================================================================" >> $REPORT_FILE

    for PATTERN in "${ERROR_PATTERNS[@]}"; do

    echo -e "\nsearching "$PATTERN" logs in $LOG_FILE file" >> $REPORT_FILE
    grep "$PATTERN" "$LOG_FILE" >> $REPORT_FILE

    echo -e "\nNumber of "$PATTERN" logs found in $LOG_FILE">> $REPORT_FILE
    ERROR_COUNT=$(grep -c "$PATTERN" "$LOG_FILE")
    echo $ERROR_COUNT >> $REPORT_FILE

    if [ "$ERROR_COUNT" -gt 10 ]; then #The number 10 is called the threshold, Threshold = A cutoff point.
        echo -e "\n⚠️ Action Required: There are more than 10 "$PATTERN" logs in $LOG_FILE. Please investigate and take appropriate action."
    fi

    done

done

echo -e "\n Analysing log files completed and stored in the $REPORT_FILE path "