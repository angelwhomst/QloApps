<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class TaskStepModel extends ObjectModel
{
    public $id_task_step;
    public $id_task;
    public $id_sop_step;
    public $status;
    public $notes;
    public $date_add;
    public $date_upd;

    // status Constants
    const STATUS_NOT_STARTED = 'not_started';
    const STATUS_PASSED = 'passed';
    const STATUS_FAILED = 'failed';

    public static $definition = [
        'table' => 'housekeeping_task_step',
        'primary' => 'id_task_step',
        'fields' => [
            'id_task' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_sop_step' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'status' => ['type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true],
            'notes' => ['type' => self::TYPE_STRING, 'validate' => 'isCleanHtml'],
            'date_add' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
            'date_upd' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
        ],
    ];

    // methods to initialize task steps when a task is created
    public static function initializeTaskSteps($id_task, $id_sop)
    {
        // get all steps for the SOP
        $sopSteps = SOPStepModel::getStepsBySOP($id_sop);
        
        if (!$sopSteps) {
            return false;
        }
        
        $success = true;
        foreach ($sopSteps as $step) {
            $taskStep = new TaskStepModel();
            $taskStep->id_task = (int)$id_task;
            $taskStep->id_sop_step = (int)$step['id_sop_step'];
            $taskStep->status = self::STATUS_NOT_STARTED;
            $taskStep->date_add = date('Y-m-d H:i:s');
            $taskStep->date_upd = date('Y-m-d H:i:s');
            $success &= $taskStep->add();
        }
        
        return $success;
    }
    
    // get steps for a specific task
    public static function getStepsByTask($id_task)
    {
        $sql = new DbQuery();
        $sql->select('ts.*, ss.step_description, ss.step_order');
        $sql->from('housekeeping_task_step', 'ts');
        $sql->leftJoin('housekeeping_sop_step', 'ss', 'ts.id_sop_step = ss.id_sop_step');
        $sql->where('ts.id_task = '.(int)$id_task);
        $sql->orderBy('ss.step_order ASC');
        
        return Db::getInstance()->executeS($sql);
    }
    
    // update the status of a step
    public static function updateStepStatus($id_task_step, $status)
    {
        $taskStep = new TaskStepModel($id_task_step);
        if (!Validate::isLoadedObject($taskStep)) {
            return false;
        }
        
        $taskStep->status = $status;
        $taskStep->date_upd = date('Y-m-d H:i:s');
        
        return $taskStep->update();
    }
    
    // get completion statistics for a task
    public static function getTaskCompletion($id_task)
    {
        $sql = new DbQuery();
        $sql->select('COUNT(*) as total, 
                     SUM(CASE WHEN status = "'.self::STATUS_PASSED.'" THEN 1 ELSE 0 END) as passed,
                     SUM(CASE WHEN status = "'.self::STATUS_FAILED.'" THEN 1 ELSE 0 END) as failed');
        $sql->from('housekeeping_task_step');
        $sql->where('id_task = '.(int)$id_task);
        
        $result = Db::getInstance()->getRow($sql);
        
        return [
            'total' => (int)$result['total'],
            'completed' => (int)$result['passed'] + (int)$result['failed'],
            'passed' => (int)$result['passed'],
            'failed' => (int)$result['failed']
        ];
    }
}