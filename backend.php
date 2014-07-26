<?php
// run with:
//
//   php -S localhost:8081 backend.php
//

function l($val) {
  file_put_contents("php://stdout", print_r($val, 1)."\n");
}

session_start();    

header("Access-Control-Allow-Origin: http://localhost:8080");
header("Access-Control-Allow-Methods: GET,PUT,DELETE,POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS')
    exit;

if(!isset($_SESSION['tasks'])) {
  $_SESSION['tasks'] = [
          ["id"=>1, "description" => "First from backend", "important" => true],
          ["id"=>2, "description" => "Second from backend", "important" => false],
        ];  
}  
$tasks =& $_SESSION['tasks'];
$url = $_SERVER['PATH_INFO'];
preg_match('`(^/[^/]+)(.*)`', $url, $m);
$route = $m[1];
$url = $m[2];

    
switch($route) {
  case '/clear':
    $tasks = [];
    echo json_encode(["status" => "ok"]);
  break;
  case '/task':
    switch($_SERVER['REQUEST_METHOD']) {
      case 'GET':
        echo json_encode($tasks);
      break;
      case 'PUT':
        $taskChanged = json_decode(file_get_contents("php://input"), true);
        $id = 0+substr($url, 1);
        foreach($tasks as $i => &$task) {
          if($task['id'] == $id) {
            $task = $taskChanged;
            break;
          }
        }
        echo json_encode($tasks);
      break;
      case 'DELETE':
        $id = 0+substr($url, 1);
        foreach($tasks as $i => $task) {
          if($task['id'] == $id) {
            array_splice($tasks, $i, 1);
            l("Deleted id: $id, pos: $i");
            break;
          }
        }
        echo json_encode($tasks);
      break;
      case 'POST':
        $task = json_decode(file_get_contents("php://input"), true);
        $task['id'] = count($tasks) + 1;
        $tasks[] = $task;
//         l($tasks);
        echo json_encode($task);
      break;
    }
  break;
}
/*
echo json_encode(
  ["id"=>1, "text" => "Footer from backend ".rand()]
);*/
