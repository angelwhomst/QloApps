<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(dirname(__FILE__).'/classes/SOPModel.php');
require_once(dirname(__FILE__).'/classes/SOPStepModel.php');
require_once(dirname(__FILE__).'/classes/RoomStatusModel.php');
require_once(dirname(__FILE__).'/classes/WebserviceSpecificManagementSOP.php');

class HousekeepingManagement extends Module
{
    public function __construct()
    {
        $this->name = 'housekeepingmanagement';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Cabaylo, Kimberly Nicole C. 
                        Mier, Elisha Reign
                        Olivarez, Angel E.
                        Perez, Yesha M. 
                        Sinday, Ellen Grace';
        $this->need_instance = 0;
        $this->bootstrap = true;
        
        parent::__construct();
        
        $this->displayName = $this->l('Housekeeping Management');
        $this->description = $this->l('Manage housekeeping operations and standard operating procedures');
        $this->confirmUninstall = $this->l('Are you sure you want to uninstall this module?');
    }

    public function install()
    {
        if (!parent::install() 
            || !$this->registerHook('displayBackOfficeHeader')
            || !$this->registerHook('actionAdminControllerSetMedia')
            || !$this->registerHook('addWebserviceResources') 
            || !$this->installDb()
            || !$this->installTab()
            || !$this->registerSpecificManagementClass()) {
            return false;
        }
        return true;
    }

    public function uninstall()
    {
        if (!parent::uninstall() 
            || !$this->uninstallDb()
            || !$this->uninstallTab()
            || !$this->unregisterWebservice()) {
            return false;
        }
        return true;
    }

    /**
     * create database tables for the module
     */
    public function installDb()
    {
        $return = true;
        $sql = array();

        // create SOP table
        $sql[] = 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'housekeeping_sop` (
            `id_sop` int(11) NOT NULL AUTO_INCREMENT,
            `title` varchar(255) NOT NULL,
            `description` text NOT NULL,
            `room_type` varchar(255) DEFAULT NULL,
            `id_employee` int(11) NOT NULL,
            `active` tinyint(1) NOT NULL DEFAULT 1,
            `deleted` tinyint(1) NOT NULL DEFAULT 0,
            `date_add` datetime NOT NULL,
            `date_upd` datetime NOT NULL,
            PRIMARY KEY (`id_sop`)
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // create SOP Steps table
        $sql[] = 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'housekeeping_sop_step` (
            `id_sop_step` int(11) NOT NULL AUTO_INCREMENT,
            `id_sop` int(11) NOT NULL,
            `step_order` int(11) NOT NULL,
            `step_description` text NOT NULL,
            PRIMARY KEY (`id_sop_step`),
            KEY `id_sop` (`id_sop`)
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // create Room Status table
        $sql[] = 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'housekeeping_room_status` (
            `id_room_status` int(11) NOT NULL AUTO_INCREMENT,
            `id_room` int(11) NOT NULL,
            `status` enum("CLEANED","NOT_CLEANED","FAILED_INSPECTION") NOT NULL DEFAULT "NOT_CLEANED",
            `id_employee` int(11) DEFAULT NULL,
            `date_upd` datetime NOT NULL,
            PRIMARY KEY (`id_room_status`),
            UNIQUE KEY `id_room` (`id_room`)
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // execute all sql queries
        foreach ($sql as $query) {
            $return &= Db::getInstance()->execute($query);
        }

        return $return;
    }

    /**
     * remove database tables on module uninstall
     */
    public function uninstallDb()
    {
        $sql = array();
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_sop`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_sop_step`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_room_status`';

        $return = true;
        foreach ($sql as $query) {
            $return &= Db::getInstance()->execute($query);
        }
        return $return;
    }

    /**
     * Hook to add webservice resources
     */
    public function hookAddWebserviceResources()
    {
        return array(
            'housekeeping_sop' => array(
                'description' => 'Standard Operating Procedures',
                'class' => 'SOPModel',
                'forbidden_method' => array('HEAD')
            ),
            'housekeeping_room_status' => array(
                'description' => 'Room Status Management',
                'class' => 'RoomStatusModel',
                'forbidden_method' => array('HEAD')
            )
        );
    }

    /**
     * register specific management class for webservice
     */
    public function registerSpecificManagementClass()
    {
        // get current value for specific management
        $specific_management = json_decode(Configuration::get('PS_WEBSERVICE_SPECIFIC_MANAGEMENT'), true);
        
        if (!is_array($specific_management)) {
            $specific_management = array();
        }
        
        // add our specific management class
        $specific_management['sops'] = array(
            'class' => 'WebserviceSpecificManagementSOP',
            'file' => _PS_MODULE_DIR_.'housekeepingmanagement/classes/WebserviceSpecificManagementSOP.php'
        );
        
        // update configuration
        return Configuration::updateValue('PS_WEBSERVICE_SPECIFIC_MANAGEMENT', json_encode($specific_management));
    }
    
    /**
     * unregister webservice resources
     */
    public function unregisterWebservice()
    {
        // remove our specific management class
        $specific_management = json_decode(Configuration::get('PS_WEBSERVICE_SPECIFIC_MANAGEMENT'), true);
        
        if (is_array($specific_management) && isset($specific_management['sops'])) {
            unset($specific_management['sops']);
            return Configuration::updateValue('PS_WEBSERVICE_SPECIFIC_MANAGEMENT', json_encode($specific_management));
        }
        
        return true;
    }
    
    public function hookDisplayBackOfficeHeader()
    {
        $controller = Tools::getValue('controller');
        if ($controller == 'AdminHousekeepingManagement' || $controller == 'AdminSOPManagement') {
            $this->context->controller->addCSS($this->_path.'views/css/admin.css');
            $this->context->controller->addJS($this->_path.'views/js/admin.js');
        }
    }
    
    public function hookActionAdminControllerSetMedia()
    {
        $controller = Tools::getValue('controller');
        if ($controller == 'AdminHousekeepingManagement' || $controller == 'AdminSOPManagement') {
            $this->context->controller->addCSS($this->_path.'views/css/admin.css');
            $this->context->controller->addJS($this->_path.'views/js/admin.js');
        }
    }

    /**
     * install tab in the back office menu
     */
    public function installTab()
    {
        // create main tab (parent)
        $mainTab = new Tab();
        $mainTab->active = 1;
        $mainTab->class_name = 'AdminHousekeepingManagement';
        $mainTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $mainTab->name[$lang['id_lang']] = 'Housekeeping Management';
        }
        $mainTab->id_parent = 0; // top level menu item
        $mainTab->module = $this->name;
        if (property_exists($mainTab, 'icon')) {
            $mainTab->icon = 'icon-broom'; // use a built-in icon
        }

        $mainTab->add();

        // Position after Hotel Reservation System (assuming it's at position 5)
        $mainTab->updatePosition(0, 6);
        
        // create sub-tab for SOP Management
        $sopTab = new Tab();
        $sopTab->active = 1;
        $sopTab->class_name = 'AdminSOPManagement';
        $sopTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $sopTab->name[$lang['id_lang']] = 'SOP Management';
        }
        $sopTab->id_parent = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        $sopTab->module = $this->name;
        $sopTab->add();
        
        // sub-tab for Room Status 
        $roomStatusTab = new Tab();
        $roomStatusTab->active = 1;
        $roomStatusTab->class_name = 'AdminRoomStatusManagement';
        $roomStatusTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $roomStatusTab->name[$lang['id_lang']] = 'Room Status';
        }
        $roomStatusTab->id_parent = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        $roomStatusTab->module = $this->name;
        $roomStatusTab->add();
        
        // Set the default controller shown when clicking the main tab
        Configuration::updateValue('PS_DEFAULT_ADMIN_HOUSEKEEPING_TAB', 'AdminSOPManagement');
        
        return true;
    }

    /**
     * uninstall all tabs created by this module
     */
    public function uninstallTab()
    {
        // uninstall child tabs first
        $childTabIds = array(
            (int)Tab::getIdFromClassName('AdminSOPManagement'),
            (int)Tab::getIdFromClassName('AdminRoomStatusManagement') 
        );
        
        foreach ($childTabIds as $id_tab) {
            if ($id_tab) {
                $tab = new Tab($id_tab);
                $tab->delete();
            }
        }
        
        // then uninstall parent tab
        $id_parent_tab = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        if ($id_parent_tab) {
            $tab = new Tab($id_parent_tab);
            $tab->delete();
        }
        
        return true;
    }
    
    /**
     * Initialize Room Status for newly added rooms
     * This method can be called from the hotelreservationsystem module
     * when a new room is created
     * 
     * @param int $id_room Room ID
     * @return bool Success
     */
    public function initializeRoomStatus($id_room)
    {
        return RoomStatusModel::updateRoomStatus(
            $id_room, 
            RoomStatusModel::STATUS_NOT_CLEANED, 
            $this->context->employee->id
        );
    }
}