<?php 
   require './vendor/autoload.php';
   $client = new GuzzleHttp\Client();
   $headers = array();
   $headers['User-Agent'] = $_SERVER['HTTP_USER_AGENT'];
    if(isset($_SERVER['HTTP_X_API_KEY'])){
        $headers['x-api-key'] = $_SERVER['HTTP_X_API_KEY']; // only add the header if it exists
    }

  $res = $client->request('GET', 'http://movies:8080/ui', [
       'headers' => $headers
  ]);
   
   // Convert JSON string to Array
  $data = json_decode($res->getBody(), true);
   //echo $data[0]["director"]; // Access Array data
   //echo $data[0]["name"];
   //echo  var_dump($_SERVER['HTTP_USER_AGENT']);
   
       ?>
<!DOCTYPE html>
<head>
   <meta charset="utf-8" />
   <meta name="viewport" content="width=device-width, initial-scale=1.0" />
   <title>Istio Demo</title>
   <link rel="shortcut icon" href="favicon.ico">
   <link href="assets/css/bootstrap.css" rel="stylesheet" />
   <link href="assets/css/font-awesome.css" rel="stylesheet" />
   <link href="assets/css/custom.css" rel="stylesheet" />
   <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
</head>
<body>
   <div id="wrapper">
      <nav class="navbar navbar-default navbar-cls-top " role="navigation" style="margin-bottom: 0">
         <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".sidebar-collapse">
            <span class="sr-only">Toggle navigation</span>
            </button>
            <a class="navbar-brand" href="index.html">ISTIO OPENSHIFT APIGEE DEMO </a>
         </div>
         <div style="color: white;
            padding: 15px 50px 5px 50px;
            float: right;
            font-size: 25px;">
               Client  &#8644;  Istio [Proxy] &#8644;  Apigee [Security + Analytics]  &#8644;  Openshift [SpringBoot (Movies) &#8644; SpringBoot (Booking) &#8644;  NodeJS (Payment)] </div>
      </nav>
      <!-- /. NAV TOP  -->
      <nav class="navbar-default navbar-side" role="navigation">
         <div class="sidebar-collapse">
            <ul class="nav" id="main-menu">
               <li class="text-center">
                  <img src="<?php echo  $data[0]["poster"] ?>" class="user-image img-responsive" />
               </li>
               <li>
                  <a class="active-menu" href="index.html"><i class="fa fa-home fa-3x"></i>Mashup</a>
               </li>
               <li>
                  <a href="http://docs.apigee.com/api-services/content/what-apigee-edge"><i class="fa fa-rocket fa-3x"></i>Apigee</a>
               </li>
               <li>
                  <a href="https://istio.io/docs"><i class="fa fa-life-ring fa-3x"></i>Istio</a>
               </li>
               <li>
                  <a href="https://docs.openshift.com/"><i class="fa fa-thumbs-up fa-3x"></i>Openshift</a>
               </li>
               <li>
                  <a href="https://github.com/sidd-harth"><i class="fa fa-check-square fa-3x"></i>Github</a>
               </li>
            </ul>
         </div>
      </nav>
      <!-- /. NAV SIDE  -->
      <div id="page-wrapper">
         <div id="page-inner" style="<?php echo  $data[0]["bg-color"] ?>">
            <div class="row">
            </div>
            <div class="row">
               <div class="<col-md-12 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-blue">
                     <div class="panel-body">
                        <h1> <strong>  Movies Service - Version - <?php echo  $data[0]["VERSION"] ?>   </strong><br> </h1>
                     </div>
                     <div class="panel-footer back-footer-royal">
                        <h3 style="color: yellow"><strong>Spring Boot - 2.1.2.RELEASE</h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-blue">
                     <div class="panel-body">
                        <h3> <strong> <?php echo  $data[0]["name"] ?> </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Name</h3>
                     </div>
                     <div class="panel-footer back-footer-royal">
                        <h3 style="color: yellow"><strong>Writer</h3>
                        <h3> <strong> <?php echo  $data[0]["written"] ?>    </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-red">
                     <div class="panel-body">
                        <h3> <strong><?php echo  $data[0]["director"] ?>    </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Director</h3>
                     </div>
                     <div class="panel-footer back-footer-royal">
                        <h3 style="color: yellow"><strong>Producer</h3>
                        <h3> <strong> <?php echo  $data[0]["producer"] ?>      </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-red">
                     <div class="panel-body">
                        <h3> <strong>    <?php echo  $data[0]["production"] ?>    </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Production</h3>
                     </div>
                     <div class="panel-footer back-footer-royal">
                        <h3 style="color: yellow"><strong>Distribution</h3>
                        <h3> <strong>   <?php echo  $data[0]["distributed"] ?>     </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-red">
                     <div class="panel-body">
                        <h3> <strong>   <?php echo  $data[0]["date"] ?>      </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Date</h3>
                     </div>
                     <div class="panel-footer back-footer-royal">
                        <h3 style="color: yellow"><strong>Year</h3>
                        <h3> <strong> <?php echo  $data[0]["year"] ?>      </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-green">
                     <div class="panel-body">
                        <h3> <strong>    <?php echo  $data[1]["booked_seats"] ?>     </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Booked Seats</h3>
                     </div>
                     <div class="panel-footer back-footer-green">
                        <h3 style="color: yellow"><strong>Price</h3>
                        <h3> <strong>     <?php echo  $data[1]["price"] ?>     </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-green">
                     <div class="panel-body">
                        <h3> <strong>     <?php echo  $data[1]["movie_date"] ?>    </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Movie Time</h3>
                     </div>
                     <div class="panel-footer back-footer-green">
                        <h3 style="color: yellow"><strong>Screen Type</h3>
                        <h3> <strong>     <?php echo  $data[1]["screen"] ?>    </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-reddark">
                     <div class="panel-body">
                        <h3> <strong>     <?php echo  $data[2]["payment_mode"] ?>    </strong><br> </h3>
                        <h3 style="color: yellow"><strong>Payment Mode</h3>
                     </div>
                     <div class="panel-footer back-footer-royalred">
                        <h3 style="color: yellow"><strong>Discount</h3>
                        <h3> <strong>     <?php echo  $data[2]["discount"] ?>     </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="col-md-3 col-sm-12 col-xs-12">
                  <div class="panel panel-primary text-center no-boder bg-color-reddark">
                     <div class="panel-body">
                        <h3> <strong>    <?php echo  $data[2]["pod_id"] ?>  </strong><br> </h3>
                        <h3 style="color: yellow"><strong>POD Name<strong></h3>
                     </div>
                     <div class="panel-footer back-footer-royalred">
                        <h3 style="color: yellow"><strong>Hit Count</h3>
                        <h3> <strong>   <?php echo  $data[2]["count"] ?>      </strong><br> </h3>
                     </div>
                  </div>
               </div>
               <div class="<col-md-6 col-sm-6 col-xs-6">
                  <div class="panel panel-primary text-center no-boder bg-color-green">
                     <div class="panel-body">
                        <h1> <strong>     Booking Service  - Version - <?php echo  $data[1]["VERSION"]  ?> </strong><br> </h1>
                     </div>
                     <div class="panel-footer back-footer-green">
                        <h3 style="color: yellow"><strong>Spring Boot - 2.1.2.RELEASE</h3>
                     </div>
                  </div>
               </div>
               <div class="<col-md-6 col-sm-6 col-xs-6">
                  <div class="panel panel-primary text-center no-boder bg-color-reddark">
                     <div class="panel-body">
                        <h1> <strong>     Payment Service - Version - <?php echo  $data[2]["VERSION"]  ?>  </strong><br> </h1>
                     </div>
                     <div class="panel-footer back-footer-royalred">
                        <h3 style="color: yellow"><strong>Node JS - 8.4.0</h3>
                     </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
   </div>
   </div>
</body>
</html>