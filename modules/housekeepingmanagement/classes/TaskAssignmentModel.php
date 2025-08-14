<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class TaskAssignmentModel extends ObjectModel
{
    public $id_task;
    public $id_room;
    public $id_employee;
    public $time_slot;
    public $deadline;
    public $priority;
    public $special_notes;
    public $status;
    public $date_add;
    public $date_upd;

    // Priority Constants
    const PRIORITY_LOW = 'Low';
    const PRIORITY_MEDIUM = 'Medium';
    const PRIORITY_HIGH = 'High';

    // Status Constants
    const STATUS_NOT_CLEANED = 'Not Cleaned';
    const STATUS_CLEANED = 'Cleaned';
    const STATUS_FAILED_INSPECTION = 'Failed Inspection';
    const STATUS_TO_BE_INSPECTED = 'To Be Inspected';
    const STATUS_UNASSIGNED = 'Unassigned';

    public static $definition = [
        'table' => 'housekeeping_task_assignment',
        'primary' => 'id_task',
        'fields' => [
            'id_room' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_employee' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'time_slot' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'deadline' => ['type' => self::TYPE_DATE, 'validate' => 'isDate', 'required' => true],
            'priority' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'special_notes' => ['type' => self::TYPE_STRING, 'validate' => 'isCleanHtml'],
            'status' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'date_add' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
            'date_upd' => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
        ],
    ];

    /**
     * Automatically set date_add and date_upd on add
     */
    public function add($autodate = true, $null_values = false)
    {
        $this->date_add = date('Y-m-d H:i:s');
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::add($autodate, $null_values);
    }

    /**
     * Automatically update date_upd on update
     */
    public function update($null_values = false)
    {
        $this->date_upd = date('Y-m-d H:i:s');
        return parent::update($null_values);
    }

    /**
     * Create new task
     */
    public static function createTask($data)
    {
        $task = new self();
        $task->id_room = $data['id_room'];
        $task->id_employee = $data['id_employee'];
        $task->time_slot = $data['time_slot'];
        $task->deadline = $data['deadline'];
        $task->priority = $data['priority'] ?? self::PRIORITY_LOW;
        $task->special_notes = $data['special_notes'] ?? '';
        $task->status = $data['status'] ?? self::STATUS_UNASSIGNED;
        $task->date_add = date('Y-m-d H:i:s');
        $task->date_upd = date('Y-m-d H:i:s');
        return $task->add();
    }

    /**
     * Update task by id
     */
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

    /**
     * Delete task by id
     */
    public static function deleteTask($id_task)
    {
        $task = new self($id_task);
        if (!Validate::isLoadedObject($task)) {
            return false;
        }
        return $task->delete();
    }

    /**
     * Get tasks
     */
    public static function getTasks($filters = array())
    {
        $sql = new DbQuery();
        $sql->select('*');
        $sql->from('housekeeping_task_assignment');

        // Apply filters
        $allowedColumns = ['id_task','id_room','id_employee','status','priority', 'deadline'];
        foreach ($filters as $key => $value) {
            if (in_array($key, $allowedColumns)) {
                $sql->where(pSQL($key) . ' = "' . pSQL($value) . '"');
            }
        }


        return Db::getInstance()->executeS($sql);
    }
}
