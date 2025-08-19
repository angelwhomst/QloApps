<?php
if (!defined('_PS_VERSION_')) {
    exit; 
}

require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');

/**
 * SupervisorTasksController
 * 
 * This controller manages the admin interface for assigning housekeeping staff to rooms.
 * It extends ModuleAdminController, which gives it PrestaShop's admin functionality,
 * including toolbar, page header, templates, and list rendering.
 */
class SupervisorTasksController extends ModuleAdminController
{
    /**
     * Constructor
     * 
     * Initializes the controller, enables bootstrap styling,
     * and sets up the toolbar button for adding a new task.
     */
    public function __construct()
    {
        $this->bootstrap = true; 
        parent::__construct(); 



        $this->page_header_toolbar_btn['new_task'] = [
            'href' => $this->context->link->getAdminLink('SupervisorTasks') . '&addnewtask=1', 
            'desc' => $this->l('Assign Staff'), 
            'icon' => 'process-icon-new', 
        ];
    }


    /**
     * initPageHeaderToolbar
     * 
     * Override the default toolbar behavior to hide the assign task button
     * when the user is adding a new task.
     */
    public function initPageHeaderToolbar()
    {
        // Call parent to initialize toolbar first
        parent::initPageHeaderToolbar();

        // Hide only the "new_task" button if we're adding a new task
        if (Tools::isSubmit('addnewtask') && isset($this->page_header_toolbar_btn['new_task'])) {
            unset($this->page_header_toolbar_btn['new_task']);
        }
    }


    /**
     * render List
     * This method is responsible for rendering the task list table.
     */
    public function renderList()
    {
        if (!Tools::isSubmit('addnewtask')) {

            // Fetch data for table for supervisor dashboard
            $sql = 'SELECT 
                        r.room_num AS room_number,
                        r.floor AS floor_number,  
                        e.firstname AS staff_firstname,
                        e.lastname AS staff_lastname,
                        t.deadline,
                        t.priority,
                        s.status AS room_status
                    FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                    LEFT JOIN '._DB_PREFIX_.'htl_room_information r 
                        ON t.id_room = r.id
                    LEFT JOIN '._DB_PREFIX_.'employee e 
                        ON t.id_employee = e.id_employee
                    LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s
                        ON t.id_room_status = s.id_room_status
                    ORDER BY t.deadline ASC';

            $tasks = Db::getInstance()->executeS($sql);

            $this->context->smarty->assign([
                'tasks' => $tasks
            ]);

            return $this->context->smarty->fetch(
                _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/supervisor_tasks.tpl'
            );
        }
        return '';
    }


    /**
     * initContent
     * 
     * Main content rendering method.
     * This handles both the task list view and the "assign task" form view.
     */
    public function initContent()
    {
        if (Tools::isSubmit('addnewtask')) {
            // Fetch staff
            $staffList = Db::getInstance()->executeS('
                SELECT id_employee, CONCAT(firstname, " ", lastname) AS name
                FROM '._DB_PREFIX_.'employee
                WHERE active = 1
                AND id_profile = 3
                ORDER BY firstname ASC
            ');

            // Fetch room list
            $roomList = Db::getInstance()->executeS('
                SELECT id AS id_room, room_num AS room_number
                FROM '._DB_PREFIX_.'htl_room_information
                ORDER BY room_num ASC
            ');

            $this->context->smarty->assign([
                'staffList' => $staffList,
                'roomList' => $roomList,
                'currentIndex' => self::$currentIndex,
                'token' => Tools::getAdminTokenLite('SupervisorTasks'),
            ]);

            $this->content = $this->context->smarty->fetch(
                _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/task_assign_form.tpl'
            );
        }

        // Successful alert message
        $showSuccess = (Tools::getIsset('conf') && (int)Tools::getValue('conf') === 3);
        $this->context->smarty->assign([
            'showSuccess' => $showSuccess
        ]);

        parent::initContent();

        // Inject JS to fade out alert & remove conf=3 from URL
        if ($showSuccess) {
            $this->context->controller->addJS(
                'data:text/javascript,' . rawurlencode("
                    document.addEventListener('DOMContentLoaded', function() {
                        setTimeout(function() {
                            var alertBox = document.querySelector('.alert-success');
                            if (alertBox) {
                                alertBox.style.transition = 'opacity 0.5s ease';
                                alertBox.style.opacity = '0';
                                setTimeout(function() { alertBox.remove(); }, 500);
                            }
                        }, 10000);

                        if (window.history.replaceState) {
                            var url = new URL(window.location.href);
                            url.searchParams.delete('conf');
                            window.history.replaceState({}, document.title, url.toString());
                        }
                    });
                ")
            );
        }
    }

    // Inspection-related backend intentionally omitted for now (placeholder UI only)

    // Inspection-related backend intentionally omitted for now (placeholder UI only)

    /**
     * Process creating a new housekeeping task
     */
    protected function processCreateTask()
    {
        $time_slot = Tools::getValue('time_slot');
        $deadline = Tools::getValue('deadline');
        $room_numbers = Tools::getValue('room_number'); 
        $assigned_staff = Tools::getValue('assigned_staff');
        $priority = Tools::getValue('priority') ?? TaskAssignmentModel::PRIORITY_LOW;
        $special_notes = Tools::getValue('special_notes');

        $errors = [];

        // Basic validation
        if (empty($time_slot)) $errors[] = $this->l('Time slot is required.');
        if (empty($deadline)) $errors[] = $this->l('Deadline is required.');
        if (empty($room_numbers) || !is_array($room_numbers)) $errors[] = $this->l('At least one room must be selected.');
        if (empty($assigned_staff)) $errors[] = $this->l('Please assign a staff member.');

        if (empty($errors)) {
            foreach ($room_numbers as $room_id) {
                $data = [
                    'id_room' => (int)$room_id,
                    'id_employee' => (int)$assigned_staff, 
                    'time_slot' => $time_slot,
                    'deadline' => $deadline,
                    'priority' => $priority,
                    'special_notes' => $special_notes,
                    'id_room_status' => 5,
                ];

                $created = TaskAssignmentModel::createTask($data);
                if (!$created) {
                    $errors[] = $this->l('Failed to create task for room ') . $room_id;
                }
            }

            if (empty($errors)) {
                Tools::redirectAdmin(
                    $this->context->link->getAdminLink('SupervisorTasks') . '&conf=3'
                );
            }
        }

        if (!empty($errors)) {
            foreach ($errors as $err) {
                $this->errors[] = $err;
            }
        }
    }

    public function postProcess()
    {
        if (Tools::isSubmit('submit_task')) {
            $this->processCreateTask();
        }
    }

}
