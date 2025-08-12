<?php
<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class HousekeepingManagement extends Module
{
    public function __construct()
    {
        $this->name = 'housekeepingmanagement';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Your Name';
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
            || !$this->installDb()
            || !$this->installTab()) {
            return false;
        }
        return true;
    }

    public function uninstall()
    {
        if (!parent::uninstall() 
            || !$this->uninstallDb()
            || !$this->uninstallTab()) {
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
     * install tab in the back office menu
     */
    public function installTab()
    {
        $tab = new Tab();
        $tab->active = 1;
        $tab->class_name = 'AdminHousekeepingManagement';
        $tab->name = array();
        foreach (Language::getLanguages(true) as $lang) {
            $tab->name[$lang['id_lang']] = 'Housekeeping Management';
        }
        $tab->id_parent = (int)Tab::getIdFromClassName('AdminAdmin');
        $tab->module = $this->name;
        return $tab->add();
    }

    /**
     * uninstall tab from back office menu
     */
    public function uninstallTab()
    {
        $id_tab = (int)Tab::getIdFromClassName('AdminHousekeepingManagement');
        if ($id_tab) {
            $tab = new Tab($id_tab);
            return $tab->delete();
        }
        return true;
    }
}