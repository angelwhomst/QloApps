<?php
file_put_contents(__DIR__.'/modules/housekeepingmanagement/logs/error_logs.log', "TEST\n", FILE_APPEND);
error_log("TEST2\n", 3, __DIR__.'/modules/housekeepingmanagement/logs/error_logs.log');