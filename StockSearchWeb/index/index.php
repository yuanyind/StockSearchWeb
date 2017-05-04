
<?php

    if(isset($_GET['input']) && $_GET['func'] == "search") {
        $symbol_value = $_GET["input"];
        $quote_url = "http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol=" . $symbol_value;
        $content = file_get_contents($quote_url);
        $myJson = json_decode($content,true);
        if($myJson['Status'] == "SUCCESS") {
            echo json_encode($myJson); 
        } else {
            echo json_encode("");
        }
        
    }
    else if(isset($_GET['input']) && $_GET['func'] == "news") {
        $symbol_value = $_GET["input"];
        $accountKey = 'LpdNA8aZ5vfsIjY7DV1DjPuv14Hg3b9CJGE6QwYHFi8';
        $ServiceRootURL = 'https://api.datamarket.azure.com/Bing/Search/v1/';
        $WebSearchURL = $ServiceRootURL . "News?Query='" . $symbol_value . "'" . '&$format=json';
        $context = stream_context_create(array(
            'http' => array(
                'request_fulluri' => true,
                'header'  => "Authorization: Basic " . base64_encode($accountKey . ":" . $accountKey)
            )
        ));
        $response = file_get_contents($WebSearchURL, 0, $context);
        echo $response;
    }
    else if(isset($_GET['input']) && $_GET['func'] == "auto") {
        $stock = $_GET["input"];
        $search_url = "http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=" . $stock;
        $contentPost = file_get_contents($search_url);
        $myJsonPost = json_decode($contentPost,true);
        echo json_encode($myJsonPost); 
    }
    else if(isset($_GET['input']) && $_GET['func'] == "his") {
        $params = $_GET['input'];
        $obj = '{"Normalized":false,"NumberOfDays":1095,"DataPeriod":"Day","Elements":[{"Symbol":"' . $params . '","Type":"price","Params":["ohlc"]}]}';
        $his_url = "http://dev.markitondemand.com/Api/v2/InteractiveChart/json?parameters=" . $obj;
        $contentHis = file_get_contents($his_url);
        $myHis = json_decode($contentHis,true);
        echo json_encode($myHis);

    }
?>
