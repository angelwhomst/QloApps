<?php
class AdminHousekeepingManagementController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        parent::__construct();
    }

    //render housekeeping tpl
    public function renderList()
    {
        return $this->context->smarty->fetch(_PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/housekeeping.tpl');
    }

}
