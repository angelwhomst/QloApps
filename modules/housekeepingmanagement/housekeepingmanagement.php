<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class HousekeepingManagement extends Module
{
    // Module constructor
    public function __construct()
    {
        $this->name = 'housekeepingmanagement';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Group 5';
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Housekeeping Management');
        $this->description = $this->l('Manage housekeeping tasks in your hotel.');
    }

    // Module installation method
    public function install()
    {
        if (!parent::install()) {
            return false;
        }

        
        $tab = new Tab();
        $tab->class_name = 'AdminHousekeepingManagement'; 
        $tab->module = $this->name;
        $tab->id_parent = Tab::getIdFromClassName('AdminCatalog'); 
        foreach (Language::getLanguages() as $lang) {
            $tab->name[$lang['id_lang']] = $this->l('Housekeeping');
        }
        $tab->add();

        return true;
    }

    // Module uninstall method
    public function uninstall()
    {
        
        $id_tab = Tab::getIdFromClassName('AdminHousekeepingManagement'); 
        if ($id_tab) {
            $tab = new Tab($id_tab);
            $tab->delete();
        }

        return parent::uninstall();
    }

}
