<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

class AdminHousekeepingController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        parent::__construct();
    }

    public function initContent()
    {
        parent::initContent();

        // Pass any initial data or admin ajax URL
        $ajaxUrl = $this->context->link->getAdminLink('AdminHousekeeping'); 
        $this->context->smarty->assign([
            'housekeeping_ajax_url' => $ajaxUrl,
        ]);

        // Add module JS & CSS
        $modulePath = $this->module->getPathUri();
        $this->context->controller->addJS($modulePath . 'views/js/housekeeping.js');
        $this->context->controller->addCSS($modulePath . 'views/css/dashboard.css');

        // Display template
        $this->setTemplate('module:housekeepingmanagement/views/templates/admin/housekeeping.tpl');
    }

    /* ---------- AJAX endpoints ---------- */
    public function ajaxProcessGetSOPs()
    {
        // For demo: return a static list or fetch from DB
        $sops = Db::getInstance()->executeS(array(
            'SELECT id_sop, title, room_type, created_by, date_upd FROM ' . _DB_PREFIX_ . 'hk_sop ORDER BY date_upd DESC'
        )) ?: [];

        // if no DB table exists, return a sample for UI testing:
        if (empty($sops)) {
            $sops = [
                ['id_sop' => 1, 'title' => 'Standard Room Clean', 'room_type' => 'Standard', 'created_by' => 'Admin', 'date_upd' => '2025-08-01 10:00:00'],
                ['id_sop' => 2, 'title' => 'VIP Room SOP', 'room_type' => 'Suite', 'created_by' => 'Manager', 'date_upd' => '2025-07-28 12:34:00'],
            ];
        }

        die(Tools::jsonEncode(['success' => true, 'data' => $sops]));
    }

    public function ajaxProcessCreateSOP()
    {
        $title = Tools::getValue('title');
        $description = Tools::getValue('description');
        $room_type = Tools::getValue('room_type');
        $steps = Tools::getValue('steps'); // JSON array or string

        if (empty($title) || empty($description)) {
            die(Tools::jsonEncode(['success' => false, 'message' => 'Title and description are required.']));
        }

        // Insert sample: adapt to your DB schema
        $res = Db::getInstance()->insert('hk_sop', [
            'title' => pSQL($title),
            'description' => pSQL($description),
            'room_type' => pSQL($room_type),
            'steps' => pSQL(json_encode($steps)),
            'created_by' => pSQL($this->context->employee->email ?? 'admin'),
            'date_add' => pSQL(date('Y-m-d H:i:s')),
            'date_upd' => pSQL(date('Y-m-d H:i:s')),
        ]);

        if ($res) {
            die(Tools::jsonEncode(['success' => true, 'message' => 'SOP created']));
        }

        die(Tools::jsonEncode(['success' => false, 'message' => 'Failed to create SOP']));
    }

    public function ajaxProcessUpdateSOP()
    {
        $id = (int)Tools::getValue('id');
        $title = Tools::getValue('title');
        $description = Tools::getValue('description');
        $room_type = Tools::getValue('room_type');
        $steps = Tools::getValue('steps');

        if (!$id || empty($title)) {
            die(Tools::jsonEncode(['success' => false, 'message' => 'Invalid request']));
        }

        $updated = Db::getInstance()->update('hk_sop', [
            'title' => pSQL($title),
            'description' => pSQL($description),
            'room_type' => pSQL($room_type),
            'steps' => pSQL(json_encode($steps)),
            'date_upd' => pSQL(date('Y-m-d H:i:s')),
        ], 'id_sop = ' . (int)$id);

        if ($updated) {
            die(Tools::jsonEncode(['success' => true, 'message' => 'SOP updated']));
        }
        die(Tools::jsonEncode(['success' => false, 'message' => 'Update failed']));
    }

    public function ajaxProcessDeleteSOP()
    {
        $id = (int)Tools::getValue('id');
        if (!$id) {
            die(Tools::jsonEncode(['success' => false, 'message' => 'Invalid ID']));
        }

        $deleted = Db::getInstance()->delete('hk_sop', 'id_sop = ' . (int)$id);
        if ($deleted) {
            die(Tools::jsonEncode(['success' => true, 'message' => 'SOP deleted']));
        }
        die(Tools::jsonEncode(['success' => false, 'message' => 'Delete failed']));
    }

    public function ajaxProcessGetRooms()
    {
        // Accept filter param: all | cleaned | not_cleaned | failed
        $filter = Tools::getValue('filter', 'all');

        // Example: fetch from DB table hk_rooms (you must create/adjust tables)
        $sql = 'SELECT r.id_room, r.room_number, r.room_type, r.status, r.assigned_staff, r.date_upd
                FROM ' . _DB_PREFIX_ . 'hk_rooms r';

        // Build simple where by status
        if ($filter === 'cleaned') {
            $sql .= " WHERE r.status = 'Cleaned'";
        } elseif ($filter === 'not_cleaned') {
            $sql .= " WHERE r.status = 'Not Cleaned'";
        } elseif ($filter === 'failed') {
            $sql .= " WHERE r.status = 'Failed Inspection'";
        }

        $sql .= ' ORDER BY r.room_number ASC LIMIT 100';

        $rooms = Db::getInstance()->executeS($sql) ?: [];

        // If no DB available - sample data for UI testing:
        if (empty($rooms)) {
            $rooms = [
                ['id_room'=>1,'room_number'=>'101','room_type'=>'Standard','status'=>'Cleaned','assigned_staff'=>'Alice','date_upd'=>'2025-08-10 09:10:00'],
                ['id_room'=>2,'room_number'=>'102','room_type'=>'Standard','status'=>'Not Cleaned','assigned_staff'=>'Bob','date_upd'=>'2025-08-10 08:55:00'],
                ['id_room'=>3,'room_number'=>'201','room_type'=>'Suite','status'=>'Failed Inspection','assigned_staff'=>'Charlie','date_upd'=>'2025-08-09 18:00:00'],
            ];
            // filter sample by $filter
            if ($filter === 'cleaned') {
                $rooms = array_filter($rooms, fn($r) => $r['status'] === 'Cleaned');
            } elseif ($filter === 'not_cleaned') {
                $rooms = array_filter($rooms, fn($r) => $r['status'] === 'Not Cleaned');
            } elseif ($filter === 'failed') {
                $rooms = array_filter($rooms, fn($r) => $r['status'] === 'Failed Inspection');
            }
            $rooms = array_values($rooms);
        }

        // Also compute summary counts
        $counts = [
            'total' => count($rooms), // NOTE: ideally compute across all rooms
            // for demo, set static values if you want more realistic global counts:
        ];

        die(Tools::jsonEncode(['success' => true, 'data' => $rooms, 'counts' => $counts]));
    }
}
