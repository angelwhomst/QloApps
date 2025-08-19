<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(dirname(__FILE__).'/classes/SOPModel.php');
require_once(dirname(__FILE__).'/classes/SOPStepModel.php');
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
            `deleted` tinyint(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id_sop_step`),
            KEY `id_sop` (`id_sop`)
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // create Room Status table
        $sql[] = 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'housekeeping_room_status` (
            `id_room_status` int(11) NOT NULL AUTO_INCREMENT,
            `id_room` int(11) NOT NULL,
            `status` enum("Not Cleaned","Cleaned","Failed Inspection", "To Be Inspected", "Unassigned") NOT NULL DEFAULT "Unassigned",
            `id_employee` int(11) DEFAULT NULL,
            `date_upd` datetime NOT NULL,
            PRIMARY KEY (`id_room_status`),
            UNIQUE KEY `id_room` (`id_room`)
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // create Task Assignments table
        $sql[] = 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'housekeeping_task_assignment` (
            `id_task` int(11) NOT NULL AUTO_INCREMENT,
            `id_room_status` int(11) NOT NULL,
            `id_room` int(11) NOT NULL,
            `id_employee` int(11) NOT NULL,
            `time_slot` varchar(50) NOT NULL,
            `deadline` datetime NOT NULL,
            `priority` enum("High","Medium","Low") NOT NULL DEFAULT "Low",
            `special_notes` text DEFAULT NULL,
            `date_add` datetime NOT NULL,
            `date_upd` datetime NOT NULL,
            `deleted` tinyint(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id_task`),
            KEY `id_room` (`id_room`),
            KEY `id_employee` (`id_employee`),
            KEY `id_room_status` (`id_room_status`),
            CONSTRAINT `fk_task_room_status` FOREIGN KEY (`id_room_status`) 
                REFERENCES `'._DB_PREFIX_.'housekeeping_room_status` (`id_room_status`) 
                ON DELETE CASCADE 
                ON UPDATE CASCADE
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
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_task_assignment`';

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
            'housekeeping_task_assignment' => array(
                'description' => 'Housekeeping Task Assignments',
                'class' => 'TaskAssignmentModel',
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
        //for task assignments
        $specific_management['task_assignments'] = array(
            'class' => 'WebserviceSpecificManagementTaskAssignment',
            'file' => _PS_MODULE_DIR_.'housekeepingmanagement/classes/WebserviceSpecificManagementTaskAssignment.php'
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
        if (
            $controller == 'AdminHousekeepingManagement' || 
            $controller == 'AdminSOPManagement' || 
            $controller == 'SupervisorTasks'
        ) {
            // add SweetAlert2
            $this->context->controller->addJquery();
            $this->context->controller->addJS('https://cdn.jsdelivr.net/npm/sweetalert2@11');
            
            // add module CSS
            $this->context->controller->addCSS($this->_path.'views/css/housekeeping-admin.css');
            $this->context->controller->addCSS($this->_path.'views/css/admin.css');
            $this->context->controller->addJS($this->_path.'views/js/admin.js');

            // add Font Awesome
            $this->context->controller->addCSS('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css');
        }
    }

    public function hookActionAdminControllerSetMedia()
    {
        $controller = Tools::getValue('controller');
        if (
            $controller == 'AdminHousekeepingManagement' || 
            $controller == 'AdminSOPManagement' || 
            $controller == 'SupervisorTasks'
        ) {
            // add SweetAlert2
            $this->context->controller->addJquery();
            $this->context->controller->addJS('https://cdn.jsdelivr.net/npm/sweetalert2@11');
            
            // add module CSS
            $this->context->controller->addCSS($this->_path.'views/css/housekeeping-admin.css');
            $this->context->controller->addCSS($this->_path.'views/css/admin.css');
            $this->context->controller->addJS($this->_path.'views/js/admin.js');

            // add Font Awesome
            $this->context->controller->addCSS('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css');
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
        $mainTab->id_parent = 0; 
        $mainTab->module = $this->name;
        if (property_exists($mainTab, 'icon')) {
            $mainTab->icon = 'icon-broom';
        }
        $mainTab->add();
        $mainTab->updatePosition(0, 6);

        // sub-tab for SOP Management
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

        // sub-tab for Task Assignments
        $taskTab = new Tab();
        $taskTab->active = 1;
        $taskTab->class_name = 'SupervisorTasks';
        $taskTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $taskTab->name[$lang['id_lang']] = 'Housekeeping Task Assignments';
        }
        $taskTab->id_parent = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        $taskTab->module = $this->name;
        $taskTab->add();

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
            (int)Tab::getIdFromClassName('SupervisorTasks')
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
    
}