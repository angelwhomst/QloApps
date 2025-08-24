<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/TaskStepModel.php');
require_once(_PS_MODULE_DIR_ . 'housekeepingmanagement/classes/RoomStatusModel.php');

/**
 * SupervisorInspectionController
 * 
 * this controller hanfles the inspectopn workflow for supervisors.
 * it allows them to view rooms with "To Be Inspected" status,
 * inspect completed cleaning work, and approve or reject with remarks.
 */
class SupervisorInspectionController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->display = 'view';
        $this->meta_title = $this->l('Room Inspections');

        parent::__construct();

        //only supervisors and admins can access
        if ($this->context->employee->id_profile == 3) {
            Tools::redirectAdmin($this->context->link->getAdminLink('HousekeeperDashboard'));
        }
    }

    public function initContent()
    {
        parent::initContent();

        // handle "View" action for view-only inspection detail
        if (Tools::isSubmit('viewtask') && Tools::getValue('id_task')) {
            $id_task = (int)Tools::getValue('id_task');
            $this->renderInspectionDetail($id_task, true); // pass true for view_only
            return;
        }

        // handle inspection detail view
        if (Tools::isSubmit('inspect_task') && Tools::getValue('id_task')) {
            $id_task = (int)Tools::getValue('id_task');
            $this->renderInspectionDetail($id_task);
            return;
        } else {
            $this->renderInspectionDashboard();
        }
    }

    /**
     * render the inspection dashboard showing all rooms pending inspection
     */
    protected function renderInspectionDashboard()
    {
        // Fetch all rooms to be inspected
        $rooms = [];
        $counts = [
            'Cleaned' => 0,
            'Not Cleaned' => 0,
            'To Be Inspected' => 0,
            'Failed Inspection' => 0,
        ];

        // Query all tasks with their statuses for summary
        $sql = 'SELECT 
                    t.id_task,
                    t.id_room,
                    r.room_num AS room_number,
                    r.floor AS floor_number,
                    p.name AS room_type,
                    s.status,
                    t.date_upd AS completed_time,
                    e.firstname,
                    e.lastname
                FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                LEFT JOIN '._DB_PREFIX_.'htl_room_information r ON t.id_room = r.id
                LEFT JOIN '._DB_PREFIX_.'employee e ON t.id_employee = e.id_employee
                LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s ON t.id_room_status = s.id_room_status
                LEFT JOIN '._DB_PREFIX_.'product_lang p ON r.id_product = p.id_product AND p.id_lang = '.(int)$this->context->language->id.'
                WHERE t.deleted = 0
                ORDER BY t.date_upd DESC';
                
        error_log("[HK] SQL: $sql");
        $allTasks = Db::getInstance()->executeS($sql);

        foreach ($allTasks as $task) {
            $status = $task['status'];
            if (isset($counts[$status])) {
                $counts[$status]++;
            }
            if ($status === 'To Be Inspected') {
                $rooms[] = [
                    'id_task' => $task['id_task'],
                    'id_room' => $task['id_room'],
                    'room_number' => $task['room_number'],
                    'staff_name' => trim($task['firstname'].' '.$task['lastname']),
                    'room_type' => $task['room_type'],
                    'completed_time' => $task['completed_time'],
                    'status' => $status,
                ];
            }
        }

        $this->context->smarty->assign([
            'rooms' => $rooms,
            'counts' => $counts,
            'currentIndex' => $this->context->link->getAdminLink('SupervisorInspection'),
            'token' => Tools::getAdminTokenLite('SupervisorInspection'),
        ]);

        $this->setTemplate('inspection_dashboard.tpl');
    }

    /**
     * render the inspection detail page for a specific task
     */
    protected function renderInspectionDetail($id_task, $view_only = false)
    {
        // get task details
        $task = $this->getTaskDetails($id_task);

        if (!$task) {
            $this->errors[] = $this->l('Task not found or not available for inspection');
            $this->renderInspectionDashboard();
            return;
        }

        if (!$view_only && $task['room_status'] !== RoomStatusModel::STATUS_TO_BE_INSPECTED) {
            $this->context->smarty->assign('error_message', $this->l('This task is not available for inspection.'));
            $this->setTemplate('error.tpl');
            return;
        }

        if ($task['id_employee']) {
            $employee = new Employee($task['id_employee']);
            if (Validate::isLoadedObject($employee)) {
                $task['employee_name'] = $employee->firstname . ' ' . $employee->lastname;
            }
        }

        $module_dir = _MODULE_DIR_ . 'housekeepingmanagement/';

        $this->context->smarty->assign([
            'task' => $task,
            'back_link' => $this->context->link->getAdminLink('SupervisorInspection'),
            'module_dir' => $module_dir,
            'current_token' => Tools::getAdminTokenLite('SupervisorInspection'),
            'current_url' => $this->context->link->getAdminLink('SupervisorInspection'),
            'view_only' => $view_only
        ]);

        $this->setTemplate('inspection_detail.tpl');
    }

    /**
     * get all tasks with "To Be Inspected" status
     */
    protected function getTasksPendingInspection()
    {
        $sql = 'SELECT 
                    t.id_task, 
                    t.date_upd as completed_time,
                    r.room_num,
                    r.floor AS floor_number,  
                    e.firstname AS staff_firstname,
                    e.lastname AS staff_lastname,
                    p.name AS room_type_name,
                    s.status AS room_status
                FROM '._DB_PREFIX_.'housekeeping_task_assignment t
                LEFT JOIN '._DB_PREFIX_.'htl_room_information r 
                    ON t.id_room = r.id
                LEFT JOIN '._DB_PREFIX_.'employee e 
                    ON t.id_employee = e.id_employee
                LEFT JOIN '._DB_PREFIX_.'housekeeping_room_status s
                    ON t.id_room_status = s.id_room_status
                LEFT JOIN '._DB_PREFIX_.'product_lang p
                    ON r.id_product = p.id_product AND p.id_lang = '.(int)$this->context->language->id.'
                WHERE t.deleted = 0 
                AND s.status = "'.RoomStatusModel::STATUS_TO_BE_INSPECTED.'"
                ORDER BY t.date_upd DESC';
        
        error_log("[HK] SQL: $sql");
        return Db::getInstance()->executeS($sql);
    }
    
    /**
     * get detailed task information for inspection
     */
    protected function getTaskDetails($id_task)
    {
        // get basic task info
        $task = TaskAssignmentModel::getTaskWithDetails($id_task);
        
        // add extra info needed for inspection
        if ($task) {
            // calculate completion stats
            $completion = TaskStepModel::getTaskCompletion($id_task);
            $task['completion'] = $completion;
            
            // get step status
            $task['steps'] = TaskStepModel::getStepsByTask($id_task);
        }
        
        return $task;
    }

    /**
     * handle AJAX reqs
     */
    public function postProcess()
    {
        // handle ajax requesrts
        if (Tools::isSubmit('ajax')) {
            // clean any output buffer
            if (ob_get_level()) {
                ob_clean();
            }

            $action = Tools::getValue('action');
            $id_employee = (int)$this->context->employee->id;
            $response = ['success' => false, 'message' => ''];

            // check if user is a supervisor )not a housekeepr)
            if ($this->context->employee->id_profile == 3) {
                $response['message'] = $this->l('Access denied. Only supervisors can perform this action.');
                echo json_encode($response);
                exit;
            }

            try {
                switch ($action) {
                    case 'approveInspection':
                        $id_task = (int)Tools::getValue('id_task');
                        $remarks = Tools::getValue('remarks', '');

                        // process the approval
                        $result = $this->processInspection($id_task, true, $remarks);

                        if ($result) {
                            $response['success'] = true;
                            $response['message'] = $this->l('Inspection approved successfully');
                            $response['tasks'] = $this->getTasksPendingInspection();
                        } else {
                            $response['message'] = $this->l('Failed to approve inspection');
                        }
                        break;
                        
                    case 'rejectInspection':
                        $id_task = (int)Tools::getValue('id_task');
                        $remarks = Tools::getValue('remarks', '');

                        // process thr rejection
                        $result = $this->processInspection($id_task, false, $remarks);
                        
                        if ($result) {
                            $response['success'] = true;
                            $response['message'] = $this->l('Inspection rejected successfully');
                            $response['tasks'] = $this->getTasksPendingInspection();
                        } else {
                            $response['message'] = $this->l('Failed to reject inspection');
                        }
                        break;
                        
                    default:
                        $response['message'] = $this->l('Invalid action');
                        break;
                }
            } catch (Exception $e) {
                $response['message'] = $this->l('Error: ') . $e->getMessage();
                error_log('SupervisorInspection error: ' . $e->getMessage());
            }
            
            echo json_encode($response);
            exit;
        }
    }

    /**
     * process the inspection (approve or reject)
     * 
     * @param int $id_task Task ID
     * @param bool $approved True for approval, false for rejection
     * @param string $remarks Optional remarks
     * @return bool Success
     */
    protected function processInspection($id_task, $approved, $remarks = '')
    {
        // start transaction
        Db::getInstance()->execute('START TRANSACTION');
        try {
            // get the task
            $task = new TaskAssignmentModel($id_task);
            if (!Validate::isLoadedObject($task)) {
                Db::getInstance()->execute('ROLLBACK');
                error_log("[HK] Task not found: $id_task");
                return false;
            }

            // check if task is still in "To Be Inspected" status
            $roomStatus = new RoomStatusModel($task->id_room_status);
            if (!Validate::isLoadedObject($roomStatus) || $roomStatus->status !== RoomStatusModel::STATUS_TO_BE_INSPECTED) {
                Db::getInstance()->execute('ROLLBACK');
                error_log("[HK] Task $id_task not in 'To Be Inspected' status. Current: " . ($roomStatus->status ?? 'N/A'));
                return false;
            }

            // Update task status based on inspection result
            if ($approved) {
                $task->id_room_status = 2; // Cleaned
            } else {
                $task->id_room_status = 1; // Failed Inspection
            }
            $task->date_upd = date('Y-m-d H:i:s');
            if (!$task->update()) {
                Db::getInstance()->execute('ROLLBACK');
                error_log("[HK] Failed to update task record for task $id_task");
                return false;
            }

            // Save inspection history
            $sql = 'INSERT INTO `'._DB_PREFIX_.'housekeeping_inspection_history` 
                    (id_task, id_employee, approved, remarks, date_add) 
                    VALUES ('.(int)$id_task.', '.(int)$this->context->employee->id.', '.($approved ? 1 : 0).', "'.pSQL($remarks).'", NOW())';

            if (!Db::getInstance()->execute($sql)) {
                Db::getInstance()->execute('ROLLBACK');
                error_log("[HK] Failed to insert inspection history for task $id_task");
                return false;
            }

            Db::getInstance()->execute('COMMIT');
            return true;

        } catch (Exception $e) {
            Db::getInstance()->execute('ROLLBACK');
            error_log('[HK] Error processing inspection: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * set template path
     */
    // public function setTemplate($template)
    // {
    //     if (!$this->viewAccess()) {
    //         return;
    //     }
        
    //     $this->template = _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/' . $template;
    //     return $this->template;
    // }
    
    /**
     * render view
     */
    public function renderView()
    {
        $tpl = $this->createTemplate($this->template);

        // Optionally reassign variables if needed (like in HousekeeperDashboardController)
        // For dashboard:
        if (strpos($this->template, 'inspection_dashboard.tpl') !== false) {
            $tasks = $this->getTasksPendingInspection();
            $tpl->assign([
                'tasks' => $tasks,
                'current_link' => $this->context->link->getAdminLink('SupervisorInspection'),
                'token' => Tools::getAdminTokenLite('SupervisorInspection'),
            ]);
        }

        return $tpl->fetch();
    }

    public function createTemplate($tpl_name)
    {
        $tpl_path = _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/' . $tpl_name;
        if (file_exists($tpl_path)) {
            return $this->context->smarty->createTemplate(
                $tpl_path,
                $this->context->smarty
            );
        }
        return parent::createTemplate($tpl_name);
    }
}
