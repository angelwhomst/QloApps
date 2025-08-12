<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class SOPStepModel extends ObjectModel
{
    public $id_sop_step;
    public $id_sop;
    public $step_order;
    public $step_description;

    /**
     * @see ObjectModel::$definition
     */
    public static $definition = array(
        'table' => 'housekeeping_sop_step',
        'primary' => 'id_sop_step',
        'fields' => array(
            'id_sop' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'step_order' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true),
            'step_description' => array('type' => self::TYPE_STRING, 'validate' => 'isCleanHtml', 'required' => true),
        ),
    );

    /**
     * GET ALL STEPS FOR A SPECIFIC SOP
     * 
     * @param int $id_sop SOP ID
     * @return array Array of steps
     */
    public static function getStepsBySOP($id_sop)
    {
        $id_sop = (int)$id_sop;
        
        $sql = new DbQuery();
        $sql->select('*');
        $sql->from('housekeeping_sop_step');
        $sql->where('id_sop = '.$id_sop);
        $sql->orderBy('step_order ASC');
        
        return Db::getInstance()->executeS($sql);
    }

    /**
     * DELETE ALL STEPS for a specific sop
     * 
     * @param int $id_sop SOP ID
     * @return bool Success
     */
    public static function deleteStepsBySOP($id_sop)
    {
        $id_sop = (int)$id_sop;
        
        return Db::getInstance()->execute(
            'DELETE FROM `'._DB_PREFIX_.'housekeeping_sop_step` WHERE `id_sop` = '.$id_sop
        );
    }

    /**
     * CREATE MULTIPLE STEPS for a SOP
     * 
     * @param int $id_sop SOP ID
     * @param array $steps Array of step descriptions
     * @return bool Success
     */
    public static function createStepsForSOP($id_sop, $steps)
    {
        $id_sop = (int)$id_sop;
        $success = true;
        
        if (empty($steps) || !is_array($steps)) {
            return false;
        }
        
        // first delete any existing steps
        self::deleteStepsBySOP($id_sop);
        
        // insert new steps
        foreach ($steps as $order => $description) {
            $step = new SOPStepModel();
            $step->id_sop = $id_sop;
            $step->step_order = $order + 1; // start from 1
            $step->step_description = $description;
            $success &= $step->add();
        }
        
        return $success;
    }
}
