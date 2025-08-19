<?php
if (!defined('_PS_VERSION_')) {
    exit; 
}

require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/SOPModel.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/SOPStepModel.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskStepStatusModel.php');

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
                        t.id_task,
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
                'tasks' => $tasks,
                'link' => $this->context->link
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

        // AJAX: Fetch tasks for board
        if (Tools::getIsset('ajax') && Tools::getValue('action') === 'fetchTasks') {
            $this->ajaxDie(json_encode($this->buildTaskBoardData()));
        }

        // AJAX: Toggle step status
        if (Tools::getIsset('ajax') && Tools::getValue('action') === 'toggleStep') {
            $idTask = (int)Tools::getValue('id_task');
            $idSopStep = (int)Tools::getValue('id_sop_step');
            $statusParam = Tools::getValue('status');
            $allowed = ['Not Executed','In Progress','Completed'];
            if ($statusParam !== null && in_array($statusParam, $allowed)) {
                $newStatus = $statusParam;
            } else {
                $checked = (bool)Tools::getValue('checked');
                $newStatus = $checked ? 'Completed' : 'Not Executed';
            }
            $ok = TaskStepStatusModel::upsertStatus($idTask, $idSopStep, $newStatus);
            $this->ajaxDie(json_encode(['success' => (bool)$ok]));
        }

        // AJAX: Get task detail
        if (Tools::getIsset('ajax') && Tools::getValue('action') === 'getTaskDetail') {
            $idTask = (int)Tools::getValue('id_task');
            $detail = $this->getTaskDetail($idTask);
            $this->ajaxDie(json_encode($detail));
        }

        // AJAX: Submit full checklist for a task
        if (Tools::getIsset('ajax') && Tools::getValue('action') === 'submitChecklist') {
            $idTask = (int)Tools::getValue('id_task');
            $rawItems = Tools::getValue('items');
            $items = [];
            if ($rawItems) {
                $decoded = json_decode($rawItems, true);
                if (is_array($decoded)) {
                    $items = $decoded;
                }
            }

            $updated = 0; $total = 0; $done = 0;
            foreach ($items as $it) {
                if (!isset($it['id_sop_step'])) { continue; }
                $total++;
                $idSopStep = (int)$it['id_sop_step'];
                $passed = !empty($it['passed']);
                $status = $passed ? 'Completed' : 'Not Executed';
                if (TaskStepStatusModel::upsertStatus($idTask, $idSopStep, $status)) {
                    $updated++;
                    if ($passed) { $done++; }
                }
            }

            $this->ajaxDie(json_encode([
                'success' => true,
                'updated' => $updated,
                'done' => $done,
                'total' => $total,
            ]));
        }
    }

    protected function buildTaskBoardData()
    {
        $search = trim(Tools::getValue('q'));
        $status = Tools::getValue('status');
        $priority = Tools::getValue('priority');
        $date = Tools::getValue('date');

        $where = [];
        if ($priority) {
            $where[] = 't.priority = "'.pSQL($priority).'"';
        }
        if ($date) {
            $where[] = 'DATE(t.deadline) = "'.pSQL($date).'"';
        }
        if ($search) {
            $where[] = '(r.room_num LIKE "%'.pSQL($search).'%" OR pl.name LIKE "%'.pSQL($search).'%")';
        }

        $sql = 'SELECT 
                    t.id_task,
                    t.priority,
                    t.deadline,
                    t.special_notes,
                    r.id as id_room,
                    r.room_num,
                    pl.name as room_type,
                    s.status as room_status
                FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                INNER JOIN '._DB_PREFIX_.'htl_room_information r ON r.id = t.id_room
                INNER JOIN '._DB_PREFIX_.'product_lang pl ON (pl.id_product = r.id_product AND pl.id_lang = '.(int)$this->context->language->id.')
                INNER JOIN '._DB_PREFIX_.'housekeeping_room_status s ON s.id_room_status = t.id_room_status
                '.(count($where)?' WHERE '.implode(' AND ', $where):'').'
                ORDER BY t.deadline ASC';

        $rows = Db::getInstance()->executeS($sql);

        // attach steps for each task via SOP of room type if available
        $result = [
            'todo' => [],
            'inprogress' => [],
            'done' => [],
            'summary' => ['done' => 0, 'total' => 0],
        ];

        foreach ($rows as $row) {
            $steps = $this->getStepsForRoomType((int)$row['id_task'], (int)$row['id_room']);
            $completed = 0; $inProgress = 0; $totalSteps = count($steps);
            foreach ($steps as $st) {
                if ($st['status'] === 'Completed') { $completed++; }
                elseif ($st['status'] === 'In Progress') { $inProgress++; }
            }
            $statusKey = 'todo';
            if ($totalSteps > 0 && $completed === $totalSteps) {
                $statusKey = 'done';
            } elseif ($inProgress > 0 || ($completed > 0 && $completed < $totalSteps)) {
                $statusKey = 'inprogress';
            }

            if ($status) {
                // filter by desired column status if provided
                $statusMap = ['To Do' => 'todo', 'In Progress' => 'inprogress', 'Done' => 'done'];
                if (isset($statusMap[$status]) && $statusMap[$status] !== $statusKey) {
                    continue;
                }
            }

            // parse external links from special_notes if any
            $links = [];
            if (!empty($row['special_notes'])) {
                if (preg_match_all('/https?:\\/\\/[^\s]*/', $row['special_notes'], $matches)) {
                    foreach ($matches[0] as $u) { $links[] = ['href' => $u, 'label' => 'Open Link']; }
                }
            }

            $card = [
                'id_task' => (int)$row['id_task'],
                'room' => [
                    'number' => $row['room_num'],
                    'type' => $row['room_type'],
                ],
                'priority' => $row['priority'],
                'deadline' => $row['deadline'],
                'steps' => $steps,
                'links' => $links,
            ];
            $result[$statusKey][] = $card;
            $result['summary']['total']++;
            if ($statusKey === 'done') $result['summary']['done']++;
        }

        return $result;
    }

    protected function getStepsForRoomType($idTask, $idRoom)
    {
        // derive room type from room id
        $room = new HotelRoomInformation((int)$idRoom);
        $idProduct = (int)$room->id_product;
        // find latest active sop for room_type (product)
        $sopId = (int)Db::getInstance()->getValue('SELECT `id_sop` FROM `'._DB_PREFIX_.'housekeeping_sop` WHERE `active`=1 AND (`room_type`="" OR `room_type`='.(int)$idProduct.') ORDER BY `date_upd` DESC');
        $steps = [];
        if ($sopId) {
            $rows = SOPStepModel::getStepsBySOP($sopId);
            $statuses = TaskStepStatusModel::getStatusesByTask((int)$idTask);
            foreach ($rows as $row) {
                $idStep = (int)$row['id_sop_step'];
                $steps[] = [
                    'id_sop_step' => $idStep,
                    'label' => $row['step_description'],
                    'status' => isset($statuses[$idStep]) ? $statuses[$idStep] : 'Not Executed',
                ];
            }
        }
        return $steps;
    }

    protected function getTaskDetail($idTask)
    {
        $task = Db::getInstance()->getRow('SELECT t.*, r.room_num, pl.name as room_type FROM `'._DB_PREFIX_.'housekeeping_task_assignment` t INNER JOIN `'._DB_PREFIX_.'htl_room_information` r ON r.id=t.id_room INNER JOIN `'._DB_PREFIX_.'product_lang` pl ON (pl.id_product=r.id_product AND pl.id_lang='.(int)$this->context->language->id.') WHERE t.id_task='.(int)$idTask);
        if (!$task) return ['success' => false];
        $steps = $this->getStepsForRoomType((int)$task['id_task'], (int)$task['id_room']);
        $completed = 0; $total = count($steps);
        foreach ($steps as $st) { if ($st['status'] === 'Completed') { $completed++; } }
        return [
            'success' => true,
            'task' => [
                'id_task' => (int)$task['id_task'],
                'room' => ['number' => $task['room_num'], 'type' => $task['room_type']],
                'priority' => $task['priority'],
                'deadline' => $task['deadline'],
                'start' => isset($task['date_add']) ? $task['date_add'] : null,
                'notes' => isset($task['special_notes']) ? $task['special_notes'] : '',
                'steps' => $steps,
                'progress' => ['done' => $completed, 'total' => $total],
            ]
        ];
    }

}
