<?php
define('_PS_ADMIN_DIR_', dirname(__FILE__) . '/../../admin123');
include(dirname(__FILE__) . '/../../config/config.inc.php');
include(dirname(__FILE__) . '/../../init.php');

// Clear cache
Tools::clearSmartyCache();
Tools::clearXMLCache();
Media::clearCache();
Tools::generateIndex();

echo "Cache cleared successfully!\n";