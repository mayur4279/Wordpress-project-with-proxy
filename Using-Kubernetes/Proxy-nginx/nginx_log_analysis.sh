#!/bin/bash
LOG_FILE="/var/log/nginx/access.log"
REPORT_FILE="/var/log/nginx/report.log"

echo "Nginx Log Analysis Report" > $REPORT_FILE
echo "=========================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Top 10 IP addresses:" >> $REPORT_FILE
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Top 10 requested URLs:" >> $REPORT_FILE
awk '{print $7}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Top 10 user agents:" >> $REPORT_FILE
awk -F\" '{print $6}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Response codes summary:" >> $REPORT_FILE
awk '{print $9}' $LOG_FILE | grep -Eo '^[0-9]{3}' | sort | uniq -c | sort -nr >> $REPORT_FILE

echo "Report generated at $(date)" >> $REPORT_FILE

