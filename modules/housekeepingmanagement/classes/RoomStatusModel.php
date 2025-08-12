<?php
<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class RoomStatusModel extends ObjectModel
{
    public $id_room_status;
    public $id_room;
    public $status;
    public $id_employee;
    public $date_upd;

    const STATUS_CLEANED = 'CLEANED';
    const STATUS_NOT_CLEANED = 'NOT_CLEANED';
    const STATUS_FAILED_INSPECTION = 'FAILED_INSPECTION';

    /**
     * @see ObjectModel::$definition
     */
    public static $definition = array(
        'table' => 'housekeeping_room_status',
        'primary' => 'id_room_status',
        'fields' => array(
            'id_room' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'status' => array('type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true),
            'id_employee' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId'),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate', 'required' => true),
        ),
    );

    /**
     * GET ROOM STATUS with details 
     * 
     * @param int|null $id_room Room ID (optional)
     * @param string|null $status Filter by status (optional)
     * @return array Room status records
     */
    public static function getRoomStatuses($id_room = null, $status = null)
    {
        $sql = new DbQuery();
        $sql->select('rs.*, r.room_num, r.id_hotel, r.id_status, rt.room_type, e.firstname, e.lastname');
        $sql->from('housekeeping_room_status', 'rs');
        $sql->leftJoin('htl_rooms_info', 'r', 'r.id = rs.id_room');
        $sql->leftJoin('htl_room_type', 'rt', 'rt.id = r.id_product');
        $sql->leftJoin('employee', 'e', 'e.id_employee = rs.id_employee');

        if ($id_room) {
            $sql->where('rs.id_room = '.(int)$id_room);
        }
        
        if ($status) {
            $sql->where('rs.status = "'.pSQL($status).'"');
        }
        
        $sql->orderBy('rs.date_upd DESC');
        
        return Db::getInstance()->executeS($sql);
    }

    /**
     * GET SUMMARY OF ROOM STATUSES
     * 
     * @return array Summary counts
     */
    public static function getRoomStatusSummary()
    {
        $summary = array(
            'total' => 0,
            'cleaned' => 0,
            'not_cleaned' => 0,
            'failed_inspection' => 0
        );
        
        // GET TOTAL ROOMS
        $sql = new DbQuery();
        $sql->select('COUNT(*)');
        $sql->from('htl_rooms_info');
        $summary['total'] = (int)Db::getInstance()->getValue($sql);
        
        // GET CLEANED ROOMS
        $sql = new DbQuery();
        $sql->select('COUNT(*)');
        $sql->from('housekeeping_room_status');
        $sql->where('status = "'.self::STATUS_CLEANED.'"');
        $summary['cleaned'] = (int)Db::getInstance()->getValue($sql);
        
        // GET NOT CLEANED ROOMS
        $sql = new DbQuery();
        $sql->select('COUNT(*)');
        $sql->from('housekeeping_room_status');
        $sql->where('status = "'.self::STATUS_NOT_CLEANED.'"');
        $summary['not_cleaned'] = (int)Db::getInstance()->getValue($sql);
        
        // GET FAILED INSPECTION ROOMS
        $sql = new DbQuery();
        $sql->select('COUNT(*)');
        $sql->from('housekeeping_room_status');
        $sql->where('status = "'.self::STATUS_FAILED_INSPECTION.'"');
        $summary['failed_inspection'] = (int)Db::getInstance()->getValue($sql);
        
        return $summary;
    }

    /**
     * UPDATE ROOM STATUS
     * 
     * @param int $id_room Room ID
     * @param string $status New status
     * @param int $id_employee Employee ID
     * @return bool Success
     */
    public static function updateRoomStatus($id_room, $status, $id_employee)
    {
        $id_room = (int)$id_room;
        $id_employee = (int)$id_employee;

        //validate status
        $valid_statuses = array(
            self::STATUS_CLEANED,
            self::STATUS_NOT_CLEANED,
            self::STATUS_FAILED_INSPECTION
        );
        
        if (!in_array($status, $valid_statuses)) {
            return false;
        }

        // check if record exists
        $id_room_status = self::getRoomStatusId($id_room);
        
        if ($id_room_status) {
            // update existing record
            $room_status = new RoomStatusModel($id_room_status);
        } else {
            // create new record
            $room_status = new RoomStatusModel();
            $room_status->id_room = $id_room;
        }
        
        $room_status->status = $status;
        $room_status->id_employee = $id_employee;
        $room_status->date_upd = date('Y-m-d H:i:s');
        
        return $room_status->save();
    }

    /**
     * GET ROOM STATUS ID BY ROOM ID
     * 
     * @param int $id_room Room ID
     * @return int|false Room status ID or false if not found
     */
    public static function getRoomStatusId($id_room)
    {
        $sql = new DbQuery();
        $sql->select('id_room_status');
        $sql->from('housekeeping_room_status');
        $sql->where('id_room = '.(int)$id_room);
        
        return Db::getInstance()->getValue($sql);
    }
    
    /**
     * add method override to set update date
     */
    public function add($auto_date = true, $null_values = false)
    {
        if ($auto_date && property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }
        
        return parent::add($auto_date, $null_values);
    }

    /**
     * update method override to set update date
     */
    public function update($null_values = false)
    {
        if (property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }
        
        return parent::update($null_values);
    }
}
