<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskStepModel.php');

class HousekeeperTaskDetailController extends ModuleAdminController
{
    public function __construct()
    {
        parent::__construct();
        $this->bootstrap = true;
    }

    public function initContent()
    {
        parent::initContent();

        $id_employee = (int)$this->context->employee->id;
        $id_task = (int)Tools::getValue('id_task');

        if (!$id_task) {
            Tools::redirectAdmin($this->context->link->getAdminLink('HousekeeperTaskDetail'));
        }

        // Get task details including steps
        $task = TaskAssignmentModel::getTaskWithDetails($id_task, $id_employee);

        if (!$task) {
            Tools::redirectAdmin($this->context->link->getAdminLink('HousekeeperTaskDetail'));
        }

        $this->context->smarty->assign([
            'task' => $task
        ]);

        // $this->setTemplate('module:housekeepingmanagement/views/templates/admin/task_detail.tpl');
    }

    public function postProcess()
    {
        // Handle AJAX requests for this page
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
}