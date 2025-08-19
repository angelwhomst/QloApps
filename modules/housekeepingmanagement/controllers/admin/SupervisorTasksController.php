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

    public function initPageHeaderToolbar()
    {
        parent::initPageHeaderToolbar();

        if ((Tools::isSubmit('addnewtask') || Tools::isSubmit('edit_task')) && isset($this->page_header_toolbar_btn['new_task'])) {
            unset($this->page_header_toolbar_btn['new_task']);
        }
    }

    /**
     * Decide which content to render(create/edit)
     */
    public function initContent()
    {
        if (Tools::isSubmit('edit_task')) {
            $this->renderTaskForm(true); // edit mode
        } elseif (Tools::isSubmit('addnewtask')) {
            $this->renderTaskForm(false); // create mode
        } else {
            $this->content = $this->renderDashboard();
        }

        // Show success alert
        $showSuccess = (Tools::getIsset('conf') && (int)Tools::getValue('conf') === 3);
        $this->context->smarty->assign(['showSuccess' => $showSuccess]);

        parent::initContent();

        // JS to fade out alert and remove conf=3
        if ($showSuccess) {
            $this->context->controller->addJS(_PS_MODULE_DIR_.'housekeepingmanagement/views/js/success_fade.js');
        }
        // Call supervisor-dashboard js and css
        $this->context->controller->addJS($this->module->getPathUri().'views/js/supervisor-dashboard.js');
        $this->context->controller->addCSS($this->module->getPathUri().'views/css/supervisor-dashboard.css');
    }

    /**
     * Render the create/edit form
     * @param bool $editMode
     */
    protected function renderTaskForm($editMode = false)
    {
        $task = [];
        $assignedRoomIds = [];

        if ($editMode) {
            $taskId = (int)Tools::getValue('id_task');
            if (!$taskId || !($task = TaskAssignmentModel::getTaskById($taskId))) {
                $this->errors[] = $this->l('Invalid or missing task');
                return;
            }

            if (!empty($task['deadline'])) {
                $task['deadline'] = date('Y-m-d', strtotime($task['deadline']));
            }

            $assignedRooms = Db::getInstance()->executeS('
                SELECT id_room
                FROM '._DB_PREFIX_.'housekeeping_task_assignment
                WHERE id_task = '.(int)$taskId
            );

            $assignedRoomIds = [];
            if ($assignedRooms) {
                foreach ($assignedRooms as $r) {
                    $assignedRoomIds[] = (int)$r['id_room'];
                }
            }
            $task['rooms'] = $assignedRoomIds;
        }

        // Fetch staff
        $staffList = Db::getInstance()->executeS('
            SELECT id_employee, CONCAT(firstname, " ", lastname) AS name
            FROM '._DB_PREFIX_.'employee
            WHERE active = 1 AND id_profile = 3
            ORDER BY firstname ASC
        ');

        // Fetch rooms
        $roomList = Db::getInstance()->executeS('
            SELECT id AS id_room, room_num AS room_number
            FROM '._DB_PREFIX_.'htl_room_information
            ORDER BY room_num ASC
        ');

        $this->context->smarty->assign([
            'task' => $task,
            'staffList' => $staffList,
            'roomList' => $roomList,
            'currentIndex' => self::$currentIndex,
            'token' => Tools::getAdminTokenLite('SupervisorTasks'),
            'editMode' => $editMode,
        ]);

        $this->content = $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/task_assign_form.tpl'
        );
    }

    /**
     * Render the dashboard (task list)
     */
    protected function renderDashboard()
    {
        $tasks = Db::getInstance()->executeS('
            SELECT t.id_task, r.room_num AS room_number, r.floor AS floor_number, 
                   e.firstname AS staff_firstname, e.lastname AS staff_lastname, 
                   t.deadline, t.priority, s.status AS room_status
            FROM '._DB_PREFIX_.'housekeeping_task_assignment t
            LEFT JOIN '._DB_PREFIX_.'htl_room_information r ON t.id_room = r.id
            LEFT JOIN '._DB_PREFIX_.'employee e ON t.id_employee = e.id_employee
            LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s ON t.id_room_status = s.id_room_status
            WHERE t.deleted = 0
            ORDER BY t.deadline DESC
        ');

        $summary = Db::getInstance()->getRow('
            SELECT 
                SUM(CASE WHEN s.status = "Cleaned" THEN 1 ELSE 0 END) AS cleaned,
                SUM(CASE WHEN s.status = "Not Cleaned" THEN 1 ELSE 0 END) AS not_cleaned,
                SUM(CASE WHEN s.status = "To Be Inspected" THEN 1 ELSE 0 END) AS to_be_inspected,
                SUM(CASE WHEN s.status = "Failed Inspection" THEN 1 ELSE 0 END) AS failed_inspections
            FROM '._DB_PREFIX_.'housekeeping_task_assignment t
            LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s ON t.id_room_status = s.id_room_status
        ');

        $this->context->smarty->assign([
            'tasks' => $tasks,
            'summary' => $summary,
        ]);

        return $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/supervisor_tasks.tpl'
        );
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
                    'id_room_status' => 1,
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

    /**
     * Process Editing a new housekeeping task
     */

    protected function processEditTask()
    {
        $taskId = (int)Tools::getValue('id_task');
        $time_slot = Tools::getValue('time_slot');
        $deadline = Tools::getValue('deadline');
        $room_numbers = Tools::getValue('room_number'); 
        $assigned_staff = Tools::getValue('assigned_staff');
        $priority = Tools::getValue('priority') ?? TaskAssignmentModel::PRIORITY_LOW;
        $special_notes = Tools::getValue('special_notes');

        $errors = [];

        if (!$taskId) $errors[] = $this->l('Invalid Task ID');
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
                ];

                $updated = TaskAssignmentModel::updateTask($taskId, $data);
                if (!$updated) {
                    $errors[] = $this->l('Failed to update task for room ') . $room_id;
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
            if (Tools::isSubmit('edit_task')) {
                $this->processEditTask();
            } else {
                $this->processCreateTask();
            }
        }
    }

    /**
     * Soft delete task
     */

    public function displayAjaxDeleteTask()
    {
        $taskId = (int)Tools::getValue('id_task');

        if (!$taskId) {
            die(json_encode(['success' => false, 'message' => $this->l('Invalid Task ID')]));
        }

        $deleted = TaskAssignmentModel::deleteTask($taskId);

        if ($deleted) {
            die(json_encode(['success' => true, 'message' => $this->l('Task deleted successfully')]));
        } else {
            die(json_encode(['success' => false, 'message' => $this->l('Failed to delete task')]));
        }
    }
}
