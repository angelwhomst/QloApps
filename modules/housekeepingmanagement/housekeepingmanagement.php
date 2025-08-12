<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class Housekeepingmanagement extends Module
{
    public function __construct()
    {
        $this->name = 'housekeepingmanagement';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Your Name';
        $this->need_instance = 0;

        parent::__construct();

        $this->displayName = $this->l('Housekeeping Management');
        $this->description = $this->l('Manage SOPs and monitor room cleaning status for housekeeping executives.');
    }

    public function install()
    {
        return parent::install();
    }

    public function uninstall()
    {
        return parent::uninstall();
    }

    public function getContent()
    {
        $summary = [
            'total_rooms' => 100,
            'cleaned_rooms' => 70,
            'not_cleaned_rooms' => 20,
            'failed_inspections' => 10,
        ];

        $sops = [
            ['title' => 'Standard Room Cleaning', 'room_type' => 'Standard', 'created_by' => 'Admin', 'last_updated' => '2025-08-01'],
            ['title' => 'Suite Deep Clean', 'room_type' => 'Suite', 'created_by' => 'Supervisor', 'last_updated' => '2025-07-28']
        ];

        $rooms = [
            ['number' => '101', 'type' => 'Standard', 'status' => 'Cleaned', 'staff' => 'John Doe', 'last_updated' => '2025-08-10'],
            ['number' => '102', 'type' => 'Standard', 'status' => 'Not Cleaned', 'staff' => 'Jane Smith', 'last_updated' => '2025-08-09'],
            ['number' => '201', 'type' => 'Suite', 'status' => 'Failed Inspection', 'staff' => 'Mike Johnson', 'last_updated' => '2025-08-08'],
        ];

        $this->context->smarty->assign([
            'summary' => $summary,
            'sops' => $sops,
            'rooms' => $rooms
        ]);

        $this->context->controller->addCSS($this->_path . 'views/css/housekeeping.css');
        $this->context->controller->addJS($this->_path . 'views/js/housekeeping.js');

        return $this->display(__FILE__, 'views/templates/admin/dashboard.tpl');
    }
}
