<?php
/**
* NOTICE OF LICENSE
*
* This source file is subject to the Open Software License version 3.0
* that is bundled with this package in the file LICENSE.md
* It is also available through the world-wide-web at this URL:
* https://opensource.org/license/osl-3-0-php
*/

if (!defined('_PS_VERSION_')) {
    exit;
}

class SOPModel extends ObjectModel
{
    public $id_sop;
    public $title;
    public $description;
    public $room_type;
    public $active;
    public $id_employee;
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
            'room_type' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 50),
            'active' => array('type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => true),
            'id_employee' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId'),
            'deleted' => array('type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => false, 'default' => 0),
            'date_add' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
        ),
    );

    /**
     * Get SOP details as array
     * 
     * @return array
     */
    public function getSOP()
    {
        return array(
            'id_sop' => (int)$this->id_sop,
            'title' => $this->title,
            'description' => $this->description,
            'room_type' => $this->room_type,
            'active' => (bool)$this->active,
            'id_employee' => (int)$this->id_employee,
            'date_add' => $this->date_add,
            'date_upd' => $this->date_upd
        );
    }
    
    /**
     * Get list of SOPs with optional filtering
     * 
     * @param array $filters
     * @return array
     */
    public function getSOPList($filters = array())
    {
        $sql = new DbQuery();
        $sql->select('*')
            ->from(self::$definition['table']);
        
        // Apply filters if provided
        if (isset($filters['room_type']) && !empty($filters['room_type'])) {
            $sql->where('room_type = "'.pSQL($filters['room_type']).'"');
        }
        
        // Order by most recently updated
        $sql->orderBy('date_upd DESC');
        
        $result = Db::getInstance()->executeS($sql);
        
        // Get steps for each SOP
        if ($result && is_array($result)) {
            $sopStepModel = new SOPStepModel();
            foreach ($result as &$sop) {
                $sop['steps'] = $sopStepModel->getStepsBySOP((int)$sop['id_sop']);
            }
        }
        
        return $result ? $result : array();
    }

    /**
     * eoverride add method to make sure employee ID is set
     */
    public function add($autodate = true, $null_values = false)
    {
        if (empty($this->id_employee) && Context::getContext()->employee) {
            $this->id_employee = (int)Context::getContext()->employee->id;
        }
        
        if (empty($this->id_employee)) {
            $this->id_employee = 1; // default to admin if still empty
        }
        
        return parent::add($autodate, $null_values);
    }
    
    /**
     * overrride update method to make sure employee ID is maintained
     */
    public function update($null_values = false)
    {
        if (empty($this->id_employee) && Context::getContext()->employee) {
            $this->id_employee = (int)Context::getContext()->employee->id;
        }
        
        if (empty($this->id_employee)) {
            $this->id_employee = 1; // default to admin if still empty
        }
        
        return parent::update($null_values);
    }
}