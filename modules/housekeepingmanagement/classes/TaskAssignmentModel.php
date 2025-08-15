<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class TaskAssignmentModel extends ObjectModel
{
    public $id_task;
    public $id_room_status; 
    public $id_room;
    public $id_employee;
    public $time_slot;
    public $deadline;
    public $priority;
    public $special_notes;
    public $date_add;
    public $date_upd;

    // Priority Constants
    const PRIORITY_LOW = 'Low';
    const PRIORITY_MEDIUM = 'Medium';
    const PRIORITY_HIGH = 'High';

    public static $definition = [
        'table' => 'housekeeping_task_assignment',
        'primary' => 'id_task',
        'fields' => [
            'id_room_status' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_room' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_employee' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'time_slot' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'deadline' => ['type' => self::TYPE_DATE, 'validate' => 'isDate', 'required' => true],
            'priority' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'special_notes' => ['type' => self::TYPE_STRING, 'validate' => 'isCleanHtml'],
            'date_add' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
            'date_upd' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
        ],
    ];

    public function add($autodate = true, $null_values = false)
    {
        $this->date_add = date('Y-m-d H:i:s');
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::add($autodate, $null_values);
    }

    public function update($null_values = false)
    {
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::update($null_values);
    }

    public static function createTask($data)
    {
        $task = new self();
        $task->id_room_status = $data['id_room_status'];
        $task->id_room = $data['id_room'];
        $task->id_employee = $data['id_employee'];
        $task->time_slot = $data['time_slot'];
        $task->deadline = $data['deadline'];
        $task->priority = $data['priority'] ?? self::PRIORITY_LOW;
        $task->special_notes = $data['special_notes'] ?? '';
        $task->date_add = date('Y-m-d H:i:s');
        $task->date_upd = date('Y-m-d H:i:s');
        return $task->add();
    }

    public static function updateTask($id_task, $data)
    {
        $task = new self($id_task);
        if (!Validate::isLoadedObject($task)) {
            return false;
        }

        foreach ($data as $key => $value) {
            if (property_exists($task, $key)) {
                $task->{$key} = $value;
            }
        }
        $task->date_upd = date('Y-m-d H:i:s');
        return $task->update();
    }

    public static function deleteTask($id_task)
    {
        $task = new self($id_task);
        if (!Validate::isLoadedObject($task)) {
            return false;
        }
        return $task->delete();
    }

    public static function getTasks($filters = array())
    {
        $sql = new DbQuery();
        $sql->select('*');
        $sql->from('housekeeping_task_assignment');

        $allowedColumns = ['id_task','id_room_status','id_room','id_employee','priority','deadline'];
        foreach ($filters as $key => $value) {
            if (in_array($key, $allowedColumns)) {
                $sql->where(pSQL($key) . ' = "' . pSQL($value) . '"');
            }
        }

        return Db::getInstance()->executeS($sql);
    }
}
