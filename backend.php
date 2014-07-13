<?php

header("Access-Control-Allow-Origin: *");

switch($_SERVER['QUERY_STRING']) {
  case 'all':
    echo json_encode([
      ["id"=>1, "description" => "First"],
      ["id"=>2, "description" => "Second"],
    ]);
  break;
}

echo json_encode(
  ["id"=>1, "text" => "Footer from backend ".rand()]
);
