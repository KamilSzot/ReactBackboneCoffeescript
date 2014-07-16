<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET,PUT");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS')
    exit;

    switch($_SERVER['PATH_INFO']) {
  case '/task':
    echo json_encode([
      ["id"=>1, "description" => "First from backend", "important" => true],
      ["id"=>2, "description" => "Second from backend", "important" => false],
    ]);

  break;
}
/*
echo json_encode(
  ["id"=>1, "text" => "Footer from backend ".rand()]
);*/
