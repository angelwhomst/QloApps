<?php
include_once('../../config/config.inc.php');
include_once('../../init.php');
require_once('classes/SOPModel.php');
require_once('classes/SOPStepModel.php');


// Create a test SOP first
$testSop = new SOPModel();
$testSop->title = 'Test SOP ' . date('Y-m-d H:i:s');
$testSop->description = 'This is a test SOP created by test_step_save.php';
$testSop->room_type = '';
$testSop->active = 1;
$testSop->id_employee = 1; // Admin
$testSop->deleted = 0;
$testSop->date_add = date('Y-m-d H:i:s');
$testSop->date_upd = date('Y-m-d H:i:s');

$sopSaved = $testSop->add();

if ($sopSaved) {
    // Now try to save steps
    $steps = ['Test step 1', 'Test step 2', 'Test step 3'];
    
    // Method 1: Using SOPStepModel::createStepsForSOP
    $result = SOPStepModel::createStepsForSOP($testSop->id, $steps);
    
    // Method 2: Direct object creation
    $success = true;
    foreach ($steps as $index => $step) {
        $sopStep = new SOPStepModel();
        $sopStep->id_sop = $testSop->id;
        $sopStep->step_order = $index + 1;
        $sopStep->step_description = $step;
        $sopStep->deleted = 0;
        $addResult = $sopStep->add();
        $success &= $addResult;
    }
    
    // Method 3: Direct SQL
    $db = Db::getInstance();
    $success = true;
    foreach ($steps as $index => $step) {
        $data = [
            'id_sop' => (int)$testSop->id,
            'step_order' => $index + 1,
            'step_description' => $step,
            'deleted' => 0
        ];
        $insertResult = $db->insert('housekeeping_sop_step', $data);
        $success &= $insertResult;
        
    }
    
    // Check if steps were saved
    $savedSteps = SOPStepModel::getStepsBySOP($testSop->id);
}

// echo "Step save tests completed. Check logs/step_save_test.log for results.";
echo "Step save tests completed.";
