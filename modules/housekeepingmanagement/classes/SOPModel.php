<?php
if (!defined('_PS_VERSION')) {
    exit;
}

class SOPModel extends ObjectModel
{
    public $id_sop;
    public $title;
    public $description;
    public $room_type;
    public $id_employee;
    public $active;
    public $deleted;
    public $date_add;
    public $date_upd;

    /**
     * @see ObjectModel::$definition
     */
    public static $definition = array(
        'table' => 'housekeeping_sop',
        'primary' => 'id_sop',
        'fields' => array(
            'title' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 255),
            'description' => array('type' => self::TYPE_HTML, 'validate' => 'isCleanHtml', 'required' => true),
            'room_type' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 255),
            'id_employee' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'active' => array('type' => self::TYPE_BOOL, 'validate' => 'isBool'),
            'deleted' => array('type' => self::TYPE_BOOL, 'validate' => 'isBool'), 
            'date_add' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
        ),
    );

    /**
     * GET ALL SOPS WITH OPTIONAL FILTERING
     * 
     * @param string|null $room_type Filter by room type
     * @param bool $active Get only active SOPs
     * @param int $limit Limit number of results
     * @param int $offset Offset for pagination
     * @param bool $includeDeleted Whether to include soft-deleted SOPs
     * @return array Array of SOPs
     */
    public static function getSOPs($room_type = null, $active = true, $limit = 0, $offset = 0, $includeDeleted = false)
    {
        $sql = new DbQuery();
        $sql->select('s.*');
        $sql->from('housekeeping_sop', 's');
        
        if ($active) {
            $sql->where('s.active = 1');
        }

        // exclude soft deleted sops unless explicitly requested
        if (!$includeDeleted) {
            $sql->where('s.deleted = 0');
        }
        
        if ($room_type) {
            $sql->where('s.room_type = "'.pSQL($room_type).'"');
        }
        
        $sql->orderBy('s.date_upd DESC');
        
        if ($limit > 0) {
            $sql->limit($limit, $offset);
        }
        
        $result = Db::getInstance()->executeS($sql);
        
        return $result;
    }

    /** 
     * GET A SINGLE SOP WITH ITS STEPS
     * 
     * @param int $id_sop SOP ID
     * @param bool $includeDeleted Whether to include soft-deleted SOPs
     * @return array|false SOP with steps or false if not found
     */
    public static function getSOPWithSteps($id_sopm $includeDeleted = false)
    {
        $id_sop = (int)$id_sop;
        if (!$id_sop) {
            return false;
        }

        // get SOP details
        $sql = new DbQuery();
        $sql->select('s.*');
        $sql->from('housekeeping_sop', 's');
        $sql->where('s.id_sop = '.$id_sop);

        if (!$includeDeleted) {
            $sql->where('s.deleted = 0');
        }
        
        $sop = Db::getInstance()->getRow($sql);
        
        if (!$sop) {
            return false;
        }

        // get SOP steps
        $sql = new DbQuery();
        $sql->select('ss.*');
        $sql->from('housekeeping_sop_step', 'ss');
        $sql->where('ss.id_sop = '.$id_sop);
        $sql->orderBy('ss.step_order ASC');
        
        $steps = Db::getInstance()->executeS($sql);
        
        $sop['steps'] = $steps ?: array();
        
        return $sop;
    }

    /**
     * SOFT DELETE AN SOP
     * 
     * @return bool Success
     */
    public function delete()
    {
        //instead of actual deletion, mark as deleted
        $this->deleted = 1;
        $this->active = 0; // also deactivate it
        $this->date_upd = date('Y-m-d H:i:s');
        
        return $this->update();
    }

    /** 
     * RESTORE A SOFT-DELETED SOP
     * 
     * @return bool Success
     */
    public function restore()
    {
        $this->deleted = 0;
        $this->date_upd = date('Y-m-d H:i:s');
        
        return $this->update();
    }

    /**
     * HARD DELETE AN SOP (for superadmin use only)
     * @return bool Success
     */
    public function forceDelete()
    {
        // delete related steps first
        SOPStepModel::deleteStepsBySOP($this->id_sop);

        // then delete the sop itself
        return parent::delete();
    }

    /**
     * override add method to set creation and update dates
     */
    public function add($auto_date = true, $null_values = false)
    {
        if ($auto_date && property_exists($this, 'date_add')) {
            $this->date_add = date('Y-m-d H:i:s');
        }
        if ($auto_date && property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }

        // initialize deleted status
        $this->deleted = 0;
        
        return parent::add($auto_date, $null_values);
    }
    
    /** 
     * ovverride updte method to set update date
     */
    public function update($null_values = false)
    {
        if (property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }
        
        return parent::update($null_values);
    }
}
