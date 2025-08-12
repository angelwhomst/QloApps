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
        $this->author = 'YourName';
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Housekeeping Management');
        $this->description = $this->l('Manage housekeeping tasks in your hotel.');
    }

    public function install()
    {
        if (!parent::install()) {
            return false;
        }

        // Add admin tab/menu entry
        $tab = new Tab();
        $tab->class_name = 'AdminHousekeepingManagement'; // controller class name
        $tab->module = $this->name;
        $tab->id_parent = Tab::getIdFromClassName('AdminCatalog'); // or 0 for root menu
        foreach (Language::getLanguages() as $lang) {
            $tab->name[$lang['id_lang']] = $this->l('Housekeeping');
        }
        $tab->add();

        return true;
    }

    public function uninstall()
    {
        // Remove tab on uninstall
        $id_tab = Tab::getIdFromClassName('AdminHousekeepingManagement');
        if ($id_tab) {
            $tab = new Tab($id_tab);
            $tab->delete();
        }

        return parent::uninstall();
    }
}
