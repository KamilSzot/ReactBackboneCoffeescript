<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Request-Method: GET");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS')
    exit;

    switch($_SERVER['PATH_INFO']) {
  case '/task':
    echo json_encode([
      ["id"=>1, "description" => "First from backend"],
      ["id"=>2, "description" => "Second from backend"],
    ]);

  break;
}
/*
echo json_encode(
  ["id"=>1, "text" => "Footer from backend ".rand()]
);*/
