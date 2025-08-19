<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class TaskStepStatusModel extends ObjectModel
{
    public $id_task_step_status;
    public $id_task;
    public $id_sop_step;
    public $status; // Not Executed | In Progress | Completed
    public $date_upd;

    public static $definition = array(
        'table' => 'housekeeping_task_step_status',
        'primary' => 'id_task_step_status',
        'fields' => array(
            'id_task' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'id_sop_step' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'status' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 32),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
        ),
    );

    public function add($autodate = true, $null_values = false)
    {
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::add($autodate, $null_values);
    }

    public function update($null_values = false)
    {
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::update($null_values);
    }

    public static function getStatusesByTask($idTask)
    {
        $sql = new DbQuery();
        $sql->select('id_sop_step, status');
        $sql->from('housekeeping_task_step_status');
        $sql->where('id_task = '.(int)$idTask);
        $rows = Db::getInstance()->executeS($sql);
        $map = array();
        foreach ($rows as $row) {
            $map[(int)$row['id_sop_step']] = $row['status'];
        }
        return $map;
    }

    public static function upsertStatus($idTask, $idSopStep, $status)
    {
        $idTask = (int)$idTask;
        $idSopStep = (int)$idSopStep;
        $allowed = array('Not Executed', 'In Progress', 'Completed');
        if (!in_array($status, $allowed)) {
            $status = 'Not Executed';
        }

        $existingId = (int)Db::getInstance()->getValue(
            'SELECT `id_task_step_status` FROM `'._DB_PREFIX_.'housekeeping_task_step_status` WHERE `id_task`='.(int)$idTask.' AND `id_sop_step`='.(int)$idSopStep
        );

        if ($existingId) {
            return Db::getInstance()->update(
                'housekeeping_task_step_status',
                array('status' => pSQL($status), 'date_upd' => date('Y-m-d H:i:s')),
                'id_task_step_status='.(int)$existingId
            );
        } else {
            return Db::getInstance()->insert('housekeeping_task_step_status', array(
                'id_task' => $idTask,
                'id_sop_step' => $idSopStep,
                'status' => pSQL($status),
                'date_upd' => date('Y-m-d H:i:s'),
            ));
        }
    }
}


