<?php
// Simple debugging tool for AJAX requests

// Define the log file path - make sure this is an absolute path
$logFile = __DIR__ . '/logs/ajax_debug.log';

// Function to log AJAX request/response data
function logAjaxRequest($data) {
    global $logFile;
    
    // Check if the log file path is valid
    if (empty($logFile)) {
        return false;
    }
    
    // Create the logs directory if it doesn't exist
    $logsDir = dirname($logFile);
    if (!is_dir($logsDir)) {
        mkdir($logsDir, 0755, true);
    }
    
    // Format the log entry
    $timestamp = date('Y-m-d H:i:s');
    $logData = "[{$timestamp}] " . print_r($data, true) . "\n---\n";
    
    // Write to the log file
    return file_put_contents($logFile, $logData, FILE_APPEND);
}