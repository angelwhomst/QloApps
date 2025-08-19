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
            || !$this->registerHook('displayEmployeeMenu') 
            || !$this->installDb()
            || !$this->installTab()
            || !$this->registerSpecificManagementClass()
            || !$this->insertDefaultRoomStatuses()
        ) {
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
            `id_sop` int(11) DEFAULT NULL, /* SOP binding */
            `id_employee` int(11) NOT NULL,
            `time_slot` varchar(50) NOT NULL,
            `deadline` datetime NOT NULL,
            `priority` enum("High","Medium","Low") NOT NULL DEFAULT "Low",
            `special_notes` text DEFAULT NULL,
            `date_add` datetime NOT NULL,
            `date_upd` datetime NOT NULL,
            PRIMARY KEY (`id_task`),
            KEY `id_room` (`id_room`),
            KEY `id_employee` (`id_employee`),
            KEY `id_room_status` (`id_room_status`),
            KEY `id_sop` (`id_sop`),
            CONSTRAINT `fk_task_room_status` FOREIGN KEY (`id_room_status`) 
                REFERENCES `'._DB_PREFIX_.'housekeeping_room_status` (`id_room_status`) 
                ON DELETE CASCADE 
                ON UPDATE CASCADE,
            CONSTRAINT `fk_task_sop` FOREIGN KEY (`id_sop`)
                REFERENCES `'._DB_PREFIX_.'housekeeping_sop` (`id_sop`)
                ON DELETE SET NULL
                ON UPDATE CASCADE
        ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';

        // create tracj step status within tasks
        $sql[] = "CREATE TABLE IF NOT EXISTS `"._DB_PREFIX_."housekeeping_task_step` (
            `id_task_step` int(11) NOT NULL AUTO_INCREMENT,
            `id_task` int(11) NOT NULL,
            `id_sop_step` int(11) NOT NULL,
            `status` enum('not_started','passed','failed') NOT NULL DEFAULT 'not_started',
            `notes` text,
            `date_add` datetime NOT NULL,
            `date_upd` datetime NOT NULL,
            PRIMARY KEY (`id_task_step`),
            KEY `id_task` (`id_task`),
            KEY `id_sop_step` (`id_sop_step`),
            CONSTRAINT `fk_task_step_task` FOREIGN KEY (`id_task`) 
                REFERENCES `"._DB_PREFIX_."housekeeping_task_assignment` (`id_task`)
                ON DELETE CASCADE,
            CONSTRAINT `fk_task_step_sop_step` FOREIGN KEY (`id_sop_step`) 
                REFERENCES `"._DB_PREFIX_."housekeeping_sop_step` (`id_sop_step`)
                ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8";

        $sql[] = 'ALTER TABLE `qlo_housekeeping_task_assignment` 
        ADD COLUMN `status` enum(\'to_do\',\'in_progress\',\'done\') NOT NULL DEFAULT \'to_do\' AFTER `priority`';
        
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
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_task_step`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_task_assignment`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_room_status`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_sop_step`';
        $sql[] = 'DROP TABLE IF EXISTS `'._DB_PREFIX_.'housekeeping_sop`';

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
            $controller == 'SupervisorTasks' ||
            $controller == 'HousekeeperDashboard' ||
            $controller == 'HousekeeperTaskDetail'
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
            $controller == 'SupervisorTasks' ||
            $controller == 'HousekeeperDashboard' ||
            $controller == 'HousekeeperTaskDetail'
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

        // sub-tab for Housekeeper Dashboard
        $hkDashboardTab = new Tab();
        $hkDashboardTab->active = 1;
        $hkDashboardTab->class_name = 'HousekeeperDashboard';
        $hkDashboardTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $hkDashboardTab->name[$lang['id_lang']] = 'Housekeeper Dashboard';
        }
        $hkDashboardTab->id_parent = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        $hkDashboardTab->module = $this->name;
        $hkDashboardTab->add();
        // Assign to housekeeper profile
        // Db::getInstance()->execute('
        //     INSERT IGNORE INTO '._DB_PREFIX_.'access (id_profile, id_tab, view, `add`, `edit`, `delete`)
        //     VALUES (3, '.(int)$hkDashboardTab->id.', 1, 0, 0, 0)
        // ');

        // sub-tab for Housekeeper Task Detail
        $hkTaskDetailTab = new Tab();
        $hkTaskDetailTab->active = 1;
        $hkTaskDetailTab->class_name = 'HousekeeperTaskDetail'; 
        $hkTaskDetailTab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $hkTaskDetailTab->name[$lang['id_lang']] = 'Task Detail';
        }
        $hkTaskDetailTab->id_parent = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        $hkTaskDetailTab->module = $this->name;
        $hkTaskDetailTab->add();
        // Assign to housekeeper profile
        // Db::getInstance()->execute('
        //     INSERT IGNORE INTO '._DB_PREFIX_.'access (id_profile, id_tab, view, `add`, `edit`, `delete`)
        //     VALUES (3, '.(int)$hkTaskDetailTab->id.', 1, 0, 0, 0)
        // ');

        // set the default controller shown when clicking the main tab
        // show Housekeeper Dashboard for housekeeper profile, SOP Management for others
        if ($this->context && $this->context->employee && (int)$this->context->employee->id_profile === 3) {
            Configuration::updateValue('PS_DEFAULT_ADMIN_HOUSEKEEPING_TAB', 'HousekeeperDashboard');
        } else {
            Configuration::updateValue('PS_DEFAULT_ADMIN_HOUSEKEEPING_TAB', 'AdminSOPManagement');
        }

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

    /**
     * insert default room statuses for id_room_status 1-5 (one row each, id_room = id_room_status)
     */
    public function insertDefaultRoomStatuses()
    {
        $statuses = [
            1 => 'Failed Inspection',
            2 => 'Cleaned',
            3 => 'Unassigned',
            4 => 'Not Cleaned',
            5 => 'To Be Inspected'
        ];

        $now = date('Y-m-d H:i:s');
        $db = Db::getInstance();

        foreach ($statuses as $id_room => $status) {
            // Check if already exists to avoid duplicates
            $exists = $db->getValue('
                SELECT COUNT(*) FROM `'._DB_PREFIX_.'housekeeping_room_status`
                WHERE `id_room` = '.(int)$id_room.' AND `status` = "'.pSQL($status).'"
            ');
            if (!$exists) {
                $db->insert('housekeeping_room_status', [
                    'id_room' => (int)$id_room,
                    'status' => pSQL($status),
                    'id_employee' => null,
                    'date_upd' => $now,
                ]);
            }
        }
        return true;
    }
    
}