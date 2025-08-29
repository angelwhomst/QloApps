<?php
if (!defined('_PS_VERSION_')) {
    exit;
}
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskStepModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/RoomStatusModel.php');

class HousekeeperTaskDetailController extends ModuleAdminController
{
    public function __construct()
    {
        parent::__construct();
        $this->bootstrap = true;
        $this->display = 'view';
        $this->meta_title = $this->l('Task Detail');
        
        // Check if the employee is a housekeeper
        if ($this->context->employee->id_profile != 3) { // profile ID 3 is for housekeepers
            // Redirect non-housekeepers to another page
            Tools::redirectAdmin($this->context->link->getAdminLink('AdminSOPManagement'));
        }
    }
    
    // Override to make sure of housekeeper access
    public function checkAccess()
    {
        // always return true if employee is a housekeeper (profile 3)
        if($this->context->employee->id_profile == 3) {
            return true;
        }
        return parent::checkAccess();
    }

    // Override to make usre of view access 
    public function viewAccess($disable = false)
    {
        // Always return true if employee is a housekeeper (profile 3)
        if ($this->context->employee->id_profile == 3) {
            return true;
        }
        return parent::viewAccess($disable);
    }

    public function initContent()
    {
        parent::initContent();

        $id_employee = (int)$this->context->employee->id;
        $id_task = (int)Tools::getValue('id_task');

        if (!$id_task) {
            Tools::redirectAdmin($this->context->link->getAdminLink('HousekeeperDashboard'));
        }

        // gett task details including steps
        $task = TaskAssignmentModel::getTaskWithDetails($id_task, $id_employee);

        if (!$task) {
            Tools::redirectAdmin($this->context->link->getAdminLink('HousekeeperDashboard'));
        }

        // get employee full name directly from the current employee context
        $employee_name = $this->context->employee->firstname . ' ' . $this->context->employee->lastname;
        $task['employee_name'] = $employee_name;

        // add module directory path for CSS references
        $module_dir = _MODULE_DIR_ . 'housekeepingmanagement/';
        
        $this->context->smarty->assign([
            'task' => $task,
            'current_token' => Tools::getAdminTokenLite('HousekeeperTaskDetail'),
            'back_link' => $this->context->link->getAdminLink('HousekeeperDashboard'),
            'module_dir' => $module_dir,
            'current_url' => $this->context->link->getAdminLink('HousekeeperTaskDetail')
        ]);

        $this->setTemplate('task_detail.tpl');
    }

    public function setTemplate($template)
    {
        if (!$this->viewAccess()) {
            return;
        }
        
        $this->template = _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/' . $template;
        return $this->template;
    }

    public function postProcess()
    {
        // handle AJAX requests for this page
        if (Tools::isSubmit('ajax')) {
            // Clean output buffer to prevent any HTML from being sent
            if (ob_get_level()) {
                ob_clean();
            }
            
            $action = Tools::getValue('action');
            $id_employee = (int)$this->context->employee->id;

            $response = ['success' => false, 'message' => ''];

            try {
                switch ($action) {
                    case 'updateStepStatus':
                        $id_task_step = (int)Tools::getValue('id_task_step');
                        $status = Tools::getValue('status');
                        $id_task = (int)Tools::getValue('id_task');

                        // verify the task belongs to this employee
                        $task = TaskAssignmentModel::getTaskWithDetails($id_task, $id_employee);
                        if (!$task) {
                            $response['message'] = 'Task not found or you do not have permission to access it';
                            break;
                        }

                        // validate status values
                        $validStatuses = [TaskStepModel::STATUS_NOT_STARTED, TaskStepModel::STATUS_PASSED, TaskStepModel::STATUS_FAILED];
                        if (in_array($status, $validStatuses)) {
                            if (TaskStepModel::updateStepStatus($id_task_step, $status)) {
                                $response['success'] = true;
                                $response['completion'] = TaskStepModel::getTaskCompletion($id_task);
                                $response['message'] = 'Step status updated successfully';
                                
                                // if a step is marked as passed or failed, update task status to in progress
                                if ($status != TaskStepModel::STATUS_NOT_STARTED) {
                                    TaskAssignmentModel::markTaskInProgress($id_task, $id_employee);
                                }
                            } else {
                                $response['message'] = 'Failed to update step status';
                            }
                        } else {
                            $response['message'] = 'Invalid status value: ' . $status . '. Valid values are: ' . implode(', ', $validStatuses);
                        }
                        break;

                    case 'markTaskDone':
                        $id_task = (int)Tools::getValue('id_task');
                        
                        // verify the task belongs to this employee
                        $task = TaskAssignmentModel::getTaskWithDetails($id_task, $id_employee);
                        if (!$task) {
                            $response['message'] = 'Task not found or you do not have permission to access it';
                            break;
                        }
                        
                        // check if task is already done
                        if ($task['status'] === TaskAssignmentModel::STATUS_DONE) {
                            $response['success'] = true;
                            $response['message'] = 'Task is already marked as done';
                            break;
                        }
                        
                        // mark the task as done
                        if (TaskAssignmentModel::markTaskDone($id_task, $id_employee)) {
                            $response['success'] = true;
                            $response['message'] = 'Task successfully marked as done';
                        } else {
                            $response['message'] = 'Failed to mark task as done';
                        }
                        break;
                        
                    default:
                        $response['message'] = 'Invalid action: ' . $action;
                        break;
                }
            } catch (Exception $e) {
                $response['message'] = 'Error: ' . $e->getMessage();
                error_log('HousekeeperTaskDetail error: ' . $e->getMessage());
            }

            // send JSON response
            header('Content-Type: application/json');
            header('Cache-Control: no-cache, must-revalidate');
            echo json_encode($response);
            exit;
        }
    }
    
    public function renderView()
    {
        // use the module's template path and correctly fetch the template
        $tpl = $this->createTemplate($this->template);
        
        // Rrassign task data if needed
        $id_employee = (int)$this->context->employee->id;
        $id_task = (int)Tools::getValue('id_task');
        $task = TaskAssignmentModel::getTaskWithDetails($id_task, $id_employee);
        
        // get employee full name directly from the current employee context
        $employee_name = $this->context->employee->firstname . ' ' . $this->context->employee->lastname;
        $task['employee_name'] = $employee_name;
        
        // add module directory path for CSS references
        $module_dir = _MODULE_DIR_ . 'housekeepingmanagement/';
        
        $tpl->assign([
            'task' => $task,
            'current_token' => Tools::getAdminTokenLite('HousekeeperTaskDetail'),
            'back_link' => $this->context->link->getAdminLink('HousekeeperDashboard'),
            'module_dir' => $module_dir,
            'current_url' => $this->context->link->getAdminLink('HousekeeperTaskDetail')
        ]);
        
        return $tpl->fetch();
    }
    
    public function createTemplate($tpl_name)
    {
        if (file_exists($tpl_name)) {
            return $this->context->smarty->createTemplate($tpl_name, $this->context->smarty);
        }
        return parent::createTemplate($tpl_name);
    }
}