<?php
if (!defined('_PS_VERSION_')) {
    exit; 
}

require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskStepModel.php');

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

        // Only show assign button for non-housekeepers
        if ($this->context->employee->id_profile != 3) {
            $this->page_header_toolbar_btn['new_task'] = [
                'href' => $this->context->link->getAdminLink('SupervisorTasks') . '&addnewtask=1', 
                'desc' => $this->l('Assign Staff'), 
                'icon' => 'process-icon-new', 
            ];
        }
    }

    /**
     * initPageHeaderToolbar
     * 
     * Override the default toolbar behavior to hide the assign task button
     * when the user is adding a new task.
     */
    public function initPageHeaderToolbar()
    {
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
            $id_employee = (int)$this->context->employee->id;
            $id_profile = (int)$this->context->employee->id_profile;

            // if housekeeper, only show their own tasks
            $where = '';
            $is_housekeeper = false;
            if ($id_profile == 3) { // 3 = housekeeper profile (ADJUST IF PROFILE ID IS DIFFERENT)
                $where = ' AND t.id_employee = '.(int)$id_employee;
                $is_housekeeper = true;
            }

            $sql = 'SELECT 
                        t.*, 
                        r.room_num AS room_number,
                        r.floor AS floor_number,  
                        e.firstname AS staff_firstname,
                        e.lastname AS staff_lastname,
                        s.status AS room_status
                    FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                    LEFT JOIN '._DB_PREFIX_.'htl_room_information r 
                        ON t.id_room = r.id
                    LEFT JOIN '._DB_PREFIX_.'employee e 
                        ON t.id_employee = e.id_employee
                    LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s
                        ON t.id_room_status = s.id_room_status
                    WHERE 1 '.$where.'
                    ORDER BY t.deadline ASC';

            $tasks = Db::getInstance()->executeS($sql);

            // Fetch SOP steps for each task
            foreach ($tasks as &$task) {
                $task['sop_title'] = '';
                $task['sop_steps'] = [];
                if (!empty($task['id_sop'])) {
                    $sop = Db::getInstance()->getRow('SELECT title FROM '._DB_PREFIX_.'housekeeping_sop WHERE id_sop = '.(int)$task['id_sop']);
                    $steps = Db::getInstance()->executeS('SELECT step_order, step_description FROM '._DB_PREFIX_.'housekeeping_sop_step WHERE id_sop = '.(int)$task['id_sop'].' AND deleted = 0 ORDER BY step_order ASC');
                    $task['sop_title'] = $sop ? $sop['title'] : '';
                    $task['sop_steps'] = $steps;
                }
            }

            $this->context->smarty->assign([
                'tasks' => $tasks,
                'is_housekeeper' => $is_housekeeper
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
        // Only allow non-housekeepers to access the assign form
        if (Tools::isSubmit('addnewtask') && $this->context->employee->id_profile != 3) {
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

            // Fetch SOP list
            $sopList = Db::getInstance()->executeS('
                SELECT id_sop, title
                FROM '._DB_PREFIX_.'housekeeping_sop
                WHERE active = 1 AND deleted = 0
                ORDER BY title ASC
            ');

            $this->context->smarty->assign([
                'staffList' => $staffList,
                'roomList' => $roomList,
                'sopList' => $sopList,
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
        $id_sop = Tools::getValue('id_sop'); 

        $errors = [];

        // Basic validation
        if (empty($time_slot)) $errors[] = $this->l('Time slot is required.');
        if (empty($deadline)) $errors[] = $this->l('Deadline is required.');
        if (empty($room_numbers) || !is_array($room_numbers)) $errors[] = $this->l('At least one room must be selected.');
        if (empty($assigned_staff)) $errors[] = $this->l('Please assign a staff member.');
        if (empty($id_sop)) $errors[] = $this->l('Please select a SOP.'); 

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
                    'id_sop' => (int)$id_sop,
                    'status' => TaskAssignmentModel::STATUS_TO_DO
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