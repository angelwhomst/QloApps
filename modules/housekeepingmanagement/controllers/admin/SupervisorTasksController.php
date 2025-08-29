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
 * 
 * Features:
 * - Role-based access (Supervisors can create/edit/delete, Housekeepers can only view their tasks)
 * - Task assignment with SOP integration
 * - Edit and delete functionality
 * - Housekeeper dashboard for assigned tasks
 */
class SupervisorTasksController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        parent::__construct();

        // Only show assign button for non-housekeepers (supervisors/admins)
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
     * when the user is adding/editing a task.
     */
    public function initPageHeaderToolbar()
    {
        parent::initPageHeaderToolbar();

        // Hide the "new_task" button if we're adding or editing a task
        if ((Tools::isSubmit('addnewtask') || Tools::isSubmit('edit_task')) && isset($this->page_header_toolbar_btn['new_task'])) {
            unset($this->page_header_toolbar_btn['new_task']);
        }
    }

    /**
     * initContent
     * 
     * Main content rendering method.
     * Handles different views based on user role and action.
     */
    public function initContent()
    {
        $id_profile = (int)$this->context->employee->id_profile;
        $is_housekeeper = ($id_profile == 3);

        // Handle different actions based on user role
        if (!$is_housekeeper && Tools::isSubmit('edit_task')) {
            $this->renderTaskForm(true); // edit mode for supervisors only
        } elseif (!$is_housekeeper && Tools::isSubmit('addnewtask')) {
            $this->renderTaskForm(false); // create mode for supervisors only
        } else {
            // Render dashboard (task list) for both roles with different data
            $this->content = $this->renderDashboard();
        }

        // Show success alert
        $showSuccess = (Tools::getIsset('conf') && (int)Tools::getValue('conf') === 3);
        $this->context->smarty->assign(['showSuccess' => $showSuccess]);

        parent::initContent();

        // Add JS and CSS for enhanced functionality
        if ($showSuccess) {
            $this->context->controller->addJS(_PS_MODULE_DIR_.'housekeepingmanagement/views/js/success_fade.js');
        }
        
        // Add supervisor dashboard assets
        $this->context->controller->addJS($this->module->getPathUri().'views/js/supervisor-dashboard.js');
        $this->context->controller->addCSS($this->module->getPathUri().'views/css/supervisor-dashboard.css');
    }

    /**
     * Render the create/edit form (supervisors only)
     * @param bool $editMode
     */
    protected function renderTaskForm($editMode = false)
    {
        // Security check - only non-housekeepers can access forms
        if ($this->context->employee->id_profile == 3) {
            $this->errors[] = $this->l('Access denied');
            return;
        }

        $task = [];
        $assignedRoomIds = [];

        if ($editMode) {
            $taskId = (int)Tools::getValue('id_task');
            if (!$taskId || !($task = TaskAssignmentModel::getTaskById($taskId))) {
                $this->errors[] = $this->l('Invalid or missing task');
                return;
            }

            // Format deadline for form input
            if (!empty($task['deadline'])) {
                $task['deadline'] = date('Y-m-d', strtotime($task['deadline']));
            }

            // Get assigned rooms for this task
            $assignedRooms = Db::getInstance()->executeS('
                SELECT id_room
                FROM '._DB_PREFIX_.'housekeeping_task_assignment
                WHERE id_task = '.(int)$taskId
            );

            if ($assignedRooms) {
                foreach ($assignedRooms as $r) {
                    $assignedRoomIds[] = (int)$r['id_room'];
                }
            }
            $task['rooms'] = $assignedRoomIds;
        }

        // Fetch staff (housekeepers only)
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

        // Fetch SOP list
        $sopList = Db::getInstance()->executeS('
            SELECT id_sop, title
            FROM '._DB_PREFIX_.'housekeeping_sop
            WHERE active = 1 AND deleted = 0
            ORDER BY title ASC
        ');

        $this->context->smarty->assign([
            'task' => $task,
            'staffList' => $staffList,
            'roomList' => $roomList,
            'sopList' => $sopList,
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
     * Different views based on user role
     */
    protected function renderDashboard()
    {
        $id_employee = (int)$this->context->employee->id;
        $id_profile = (int)$this->context->employee->id_profile;
        $is_housekeeper = ($id_profile == 3);

        // Build query based on user role
        $where = '';
        if ($is_housekeeper) {
            // Housekeepers only see their own tasks
            $where = ' AND t.id_employee = '.(int)$id_employee;
        }

        // Base query for tasks
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
                WHERE t.deleted = 0 '.$where.'
                ORDER BY t.deadline ASC';

        $tasks = Db::getInstance()->executeS($sql);

        // Fetch SOP information for ALL tasks (both supervisors and housekeepers)
        if ($tasks) {
            foreach ($tasks as &$task) {
                $task['sop_title'] = '';
                $task['sop_steps'] = [];
                
                if (!empty($task['id_sop'])) {
                    // Get SOP title
                    $sop = Db::getInstance()->getRow('
                        SELECT title 
                        FROM '._DB_PREFIX_.'housekeeping_sop 
                        WHERE id_sop = '.(int)$task['id_sop'].' AND active = 1 AND deleted = 0'
                    );
                    
                    // Get SOP steps
                    $steps = Db::getInstance()->executeS('
                        SELECT step_order, step_description 
                        FROM '._DB_PREFIX_.'housekeeping_sop_step 
                        WHERE id_sop = '.(int)$task['id_sop'].' AND deleted = 0 
                        ORDER BY step_order ASC'
                    );
                    
                    // Truncate SOP title to 8 characters with ellipsis if longer
                    $fullTitle = $sop ? $sop['title'] : '';
                    $task['sop_title'] = strlen($fullTitle) > 8 ? substr($fullTitle, 0, 10) . '...' : $fullTitle;
                    $task['sop_full_title'] = $fullTitle;
                    $task['sop_steps'] = $steps ? $steps : [];
                }
            }
        }

        // Get summary statistics (for supervisors)
        $summary = [];
        if (!$is_housekeeper) {
            $summary = Db::getInstance()->getRow('
                SELECT 
                    SUM(CASE WHEN s.status = "Cleaned" THEN 1 ELSE 0 END) AS cleaned,
                    SUM(CASE WHEN s.status = "Not Cleaned" THEN 1 ELSE 0 END) AS not_cleaned,
                    SUM(CASE WHEN s.status = "To Be Inspected" THEN 1 ELSE 0 END) AS to_be_inspected,
                    SUM(CASE WHEN s.status = "Failed Inspection" THEN 1 ELSE 0 END) AS failed_inspections
                FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s ON t.id_room_status = s.id_room_status
                WHERE t.deleted = 0
            ');
        }

        $this->context->smarty->assign([
            'tasks' => $tasks,
            'summary' => $summary,
            'is_housekeeper' => $is_housekeeper,
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
        // Security check - only supervisors can create tasks
        if ($this->context->employee->id_profile == 3) {
            $this->errors[] = $this->l('Access denied');
            return;
        }

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
                    'id_room_status' => 4, // Initial status ("NOT CLEANED")
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

    /**
     * Process editing a housekeeping task
     */
    protected function processEditTask()
    {
        // Security check - only supervisors can edit tasks
        if ($this->context->employee->id_profile == 3) {
            $this->errors[] = $this->l('Access denied');
            return;
        }

        $taskId = (int)Tools::getValue('id_task');
        $time_slot = Tools::getValue('time_slot');
        $deadline = Tools::getValue('deadline');
        $room_numbers = Tools::getValue('room_number'); 
        $assigned_staff = Tools::getValue('assigned_staff');
        $priority = Tools::getValue('priority') ?? TaskAssignmentModel::PRIORITY_LOW;
        $special_notes = Tools::getValue('special_notes');
        $id_sop = Tools::getValue('id_sop');

        $errors = [];

        if (!$taskId) $errors[] = $this->l('Invalid Task ID');
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
                    'id_sop' => (int)$id_sop,
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

    /**
     * Handle form submissions
     */
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
     * AJAX: Soft delete task (supervisors only)
     */
    public function displayAjaxDeleteTask()
    {
        // Security check - only supervisors can delete tasks
        if ($this->context->employee->id_profile == 3) {
            die(json_encode(['success' => false, 'message' => $this->l('Access denied')]));
        }

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