<?php
if (!defined('_PS_VERSION_')) {
    exit; 
}

require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskAssignmentModel.php');


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
            // Fetch the Smarty template for the supervisor tasks list
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
            $staffList = [
                ['id_employee' => 1, 'name' => 'John Doe'],
                ['id_employee' => 2, 'name' => 'Jane Smith'],
                ['id_employee' => 3, 'name' => 'Mary Johnson'],
            ];

            $roomList = [
                ['id_room' => 101, 'room_number' => '101'],
                ['id_room' => 102, 'room_number' => '102'],
                ['id_room' => 103, 'room_number' => '103'],
                ['id_room' => 104, 'room_number' => '104'],
            ];

            $this->context->smarty->assign([
                'staffList' => $staffList,
                'roomList' => $roomList,
                'currentIndex' => self::$currentIndex,
                'token' => Tools::getAdminTokenLite('SupervisorTasks'),
            ]);

            $this->content = $this->context->smarty->fetch(
                _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/task_assign_form.tpl'
            );

            parent::initContent();
        } else {
            parent::initContent();
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
                    'status' => TaskAssignmentModel::STATUS_UNASSIGNED,
                ];

                $created = TaskAssignmentModel::createTask($data);
                if (!$created) {
                    $errors[] = $this->l('Failed to create task for room ') . $room_id;
                }
            }

            if (empty($errors)) {
                $this->confirmations[] = $this->l('Tasks successfully created!');
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
