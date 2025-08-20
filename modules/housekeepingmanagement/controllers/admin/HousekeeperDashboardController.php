<?php
if (!defined('_PS_VERSION_')) {
    exit;
}
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskStepModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/SOPStepModel.php');

class HousekeeperDashboardController extends ModuleAdminController
{
    public function __construct()
    {
        parent::__construct();
        $this->bootstrap = true;
        $this->display = 'view';
        $this->meta_title = $this->l('Housekeeper Dashboard');
        
        // Check if the employee is a housekeeper
        if ($this->context->employee->id_profile != 3) { // profile ID 3 is for housekeepers
            // redirect non-housekeepers to another page
            Tools::redirectAdmin($this->context->link->getAdminLink('AdminSOPManagement'));
        }
    }

    public function initContent()
    {
        parent::initContent();

        $id_employee = (int)$this->context->employee->id;

        // get filters
        $filters = [
            'search' => Tools::getValue('search', ''),
            'priority' => Tools::getValue('priority', ''),
            'date_from' => Tools::getValue('date_from', ''),
            'date_to' => Tools::getValue('date_to', '')
        ];

        // get tasks for this employee
        $tasksData = TaskAssignmentModel::getEmployeeTasks($id_employee, $filters);
        
        // Add steps to each task
        foreach ($tasksData['tasks'] as $status => &$statusTasks) {
            foreach ($statusTasks as &$task) {
                $task['steps'] = TaskStepModel::getStepsByTask($task['id_task']);
            }
        }

        $this->context->smarty->assign([
            'tasks' => $tasksData['tasks'],
            'taskCount' => $tasksData['count'],
            'filters' => $filters,
            'token' => Tools::getAdminTokenLite('HousekeeperDashboard'),
            'detail_token' => Tools::getAdminTokenLite('HousekeeperTaskDetail')
        ]);

        $this->setTemplate('housekeeper_dashboard.tpl');
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
        // Handle AJAX requests
        if (Tools::isSubmit('ajax')) {
            $action = Tools::getValue('action');
            $id_employee = (int)$this->context->employee->id;

            $response = ['success' => false];

            switch ($action) {
                case 'updateStepStatus':
                    $id_task_step = (int)Tools::getValue('id_task_step');
                    $status = Tools::getValue('status');

                    if (in_array($status, [TaskStepModel::STATUS_NOT_STARTED, TaskStepModel::STATUS_PASSED, TaskStepModel::STATUS_FAILED])) {
                        if (TaskStepModel::updateStepStatus($id_task_step, $status)) {
                            $response['success'] = true;
                            $id_task = (int)Tools::getValue('id_task');
                            $response['completion'] = TaskStepModel::getTaskCompletion($id_task);
                            if ($status != TaskStepModel::STATUS_NOT_STARTED) {
                                TaskAssignmentModel::markTaskInProgress($id_task, $id_employee);
                            }
                        }
                    }
                    break;

                case 'markTaskDone':
                    $id_task = (int)Tools::getValue('id_task');
                    if (TaskAssignmentModel::markTaskDone($id_task, $id_employee)) {
                        $response['success'] = true;
                    }
                    break;
            }

            header('Content-Type: application/json');
            die(json_encode($response));
        }
    }
    
    public function renderView()
    {
        // use the module's template path and correctly fetch the template
        $tpl = $this->createTemplate($this->template);
        
        // add teh assigned variables to the template if needed
        // For example, if context variables were lost:
        $id_employee = (int)$this->context->employee->id;
        $filters = [
            'search' => Tools::getValue('search', ''),
            'priority' => Tools::getValue('priority', ''),
            'date_from' => Tools::getValue('date_from', ''),
            'date_to' => Tools::getValue('date_to', '')
        ];
        
        $tasksData = TaskAssignmentModel::getEmployeeTasks($id_employee, $filters);
        
        // add steps to each task
        foreach ($tasksData['tasks'] as $status => &$statusTasks) {
            foreach ($statusTasks as &$task) {
                $task['steps'] = TaskStepModel::getStepsByTask($task['id_task']);
            }
        }
        
        $tpl->assign([
            'tasks' => $tasksData['tasks'],
            'taskCount' => $tasksData['count'],
            'filters' => $filters,
            'token' => Tools::getAdminTokenLite('HousekeeperDashboard'),
            'detail_token' => Tools::getAdminTokenLite('HousekeeperTaskDetail')
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