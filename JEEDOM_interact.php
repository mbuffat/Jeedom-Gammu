<?php

$URL_JEEDOM="http://adresse IP du raspberry/jeedom";
$API_KEY="cle API";

require 'jsonrpcClient.class.php';

// recherche JEEDOM
if (strncmp($argv[1],"JEEDOM ",7)==0) {
  $jsonrpc = new jsonrpcClient($URL_JEEDOM.'/core/api/jeeApi.php', $API_KEY);
  $message= substr($argv[1],7);
  if($jsonrpc->sendRequest('interact::tryToReply', array('query'=>$message))){
    print_r($jsonrpc->getResult());
  }else{
    echo $jsonrpc->getError();
  }
} else {
   echo "-1";
}

?>
