<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

// Add the missing require for RoomStatusModel
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/RoomStatusModel.php');

class TaskAssignmentModel extends ObjectModel
{
    public $id_task;
    public $id_room_status; 
    public $id_room;
    public $id_sop;
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
    const STATUS_TO_DO = 'to_do';
    const STATUS_IN_PROGRESS = 'in_progress';
    const STATUS_DONE = 'done';

    public static $definition = [
        'table' => 'housekeeping_task_assignment',
        'primary' => 'id_task',
        'fields' => [
            'id_room_status' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_room' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'id_sop' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt'], 
            'id_employee' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'time_slot' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'deadline' => ['type' => self::TYPE_DATE, 'validate' => 'isDate', 'required' => true],
            'priority' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
            'status' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true],
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
        $task->id_sop = isset($data['id_sop']) ? (int)$data['id_sop'] : null; 
        $task->id_employee = $data['id_employee'];
        $task->time_slot = $data['time_slot'];
        $task->deadline = $data['deadline'];
        $task->priority = $data['priority'] ?? self::PRIORITY_LOW;
        $task->status = $data['status'] ?? self::STATUS_TO_DO;
        $task->special_notes = $data['special_notes'] ?? '';
        $task->date_add = date('Y-m-d H:i:s');
        $task->date_upd = date('Y-m-d H:i:s');
        
        if ($task->add() && $task->id_sop) {
            // initialize task steps from SOP steps
            return TaskStepModel::initializeTaskSteps($task->id, $task->id_sop);
        }
        
        return false;
    }

    // get tasks by employee with status grouping
    public static function getEmployeeTasks($id_employee, $filters = array())
    {
        $sql = new DbQuery();
        $sql->select('t.*, r.room_num, s.title as sop_title, p.name as room_type_name');
        $sql->from('housekeeping_task_assignment', 't');
        $sql->leftJoin('htl_room_information', 'r', 't.id_room = r.id');
        $sql->leftJoin('housekeeping_sop', 's', 't.id_sop = s.id_sop');
        $sql->leftJoin('product_lang', 'p', 'r.id_product = p.id_product AND p.id_lang = '.(int)Context::getContext()->language->id);
        $sql->where('t.id_employee = '.(int)$id_employee);
        
        // Apply filters
        if (isset($filters['search']) && $filters['search']) {
            $search = pSQL($filters['search']);
            $sql->where('(r.room_num LIKE "%'.$search.'%" OR p.name LIKE "%'.$search.'%")');
        }
        
        if (isset($filters['priority']) && $filters['priority']) {
            $sql->where('t.priority = "'.pSQL($filters['priority']).'"');
        }
        
        if (isset($filters['date_from']) && $filters['date_from']) {
            $sql->where('t.deadline >= "'.pSQL($filters['date_from']).' 00:00:00"');
        }
        
        if (isset($filters['date_to']) && $filters['date_to']) {
            $sql->where('t.deadline <= "'.pSQL($filters['date_to']).' 23:59:59"');
        }
        
        $tasks = Db::getInstance()->executeS($sql);
        
        // group tasks by status
        $groupedTasks = [
            'to_do' => [],
            'in_progress' => [],
            'done' => []
        ];
        
        $taskCount = [
            'total' => 0,
            'completed' => 0
        ];
        
        if ($tasks) {
            foreach ($tasks as &$task) {
                // get step completion stats
                $completion = TaskStepModel::getTaskCompletion($task['id_task']);
                $task['completion'] = $completion;
                
                // group by status
                $status = isset($task['status']) ? $task['status'] : self::STATUS_TO_DO;
                $groupedTasks[$status][] = $task;
                
                $taskCount['total']++;
                if ($status == self::STATUS_DONE) {
                    $taskCount['completed']++;
                }
            }
        }
        
        return [
            'tasks' => $groupedTasks,
            'count' => $taskCount
        ];
    }

    // get a single task with all details
    public static function getTaskWithDetails($id_task, $id_employee = null)
    {
        $sql = new DbQuery();
        $sql->select('t.*, r.room_num, s.title as sop_title, p.name as room_type_name');
        $sql->from('housekeeping_task_assignment', 't');
        $sql->leftJoin('htl_room_information', 'r', 't.id_room = r.id');
        $sql->leftJoin('housekeeping_sop', 's', 't.id_sop = s.id_sop');
        $sql->leftJoin('product_lang', 'p', 'r.id_product = p.id_product AND p.id_lang = '.(int)Context::getContext()->language->id);
        $sql->where('t.id_task = '.(int)$id_task);
        
        // security check - only allow access to employee's own tasks
        if ($id_employee) {
            $sql->where('t.id_employee = '.(int)$id_employee);
        }
        
        $task = Db::getInstance()->getRow($sql);
        
        if ($task) {
            // get all steps for this task
            $task['steps'] = TaskStepModel::getStepsByTask($task['id_task']);

            // get completion statistics
            $task['completion'] = TaskStepModel::getTaskCompletion($task['id_task']);
        }
        
        return $task;
    }

    // mark task as in progress
    public static function markTaskInProgress($id_task, $id_employee)
    {
        $task = new self($id_task);
        if (!Validate::isLoadedObject($task) || $task->id_employee != $id_employee) {
            return false;
        }
        
        $task->status = self::STATUS_IN_PROGRESS;
        $task->date_upd = date('Y-m-d H:i:s');
        
        return $task->update();
    }

    // mark task as done
    public static function markTaskDone($id_task, $id_employee)
    {
        try {
            // Start transaction
            Db::getInstance()->execute('START TRANSACTION');
            
            $task = new self($id_task);
            if (!Validate::isLoadedObject($task) || $task->id_employee != $id_employee) {
                Db::getInstance()->execute('ROLLBACK');
                return false;
            }
            
            $task->status = self::STATUS_DONE;
            $task->date_upd = date('Y-m-d H:i:s');
            
            $result = $task->update();
            
            if ($result) {
                // Try to update room status - but don't fail if there's an issue
                try {
                    if (class_exists('RoomStatusModel') && $task->id_room) {
                        RoomStatusModel::updateRoomStatus($task->id_room, RoomStatusModel::STATUS_CLEANED, $id_employee);
                    }
                } catch (Exception $e) {
                    // Log the error but don't fail the task completion
                    error_log('RoomStatusModel update failed: ' . $e->getMessage());
                }
                
                // Commit transaction
                Db::getInstance()->execute('COMMIT');
                return true;
            } else {
                // Rollback transaction
                Db::getInstance()->execute('ROLLBACK');
                return false;
            }
        } catch (Exception $e) {
            // Rollback transaction on any error
            Db::getInstance()->execute('ROLLBACK');
            error_log('TaskAssignmentModel::markTaskDone error: ' . $e->getMessage());
            return false;
        }
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