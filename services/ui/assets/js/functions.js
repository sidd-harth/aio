/**
  **
   DashBoard Data
  **
**/
function dashBoard() {


	
	$.ajax({
        url: "http://customer-tutorial.2886795282-80-kitek03.environments.katacoda.com",

        type: 'GET',


        success: function(data) {
            console.log(JSON.stringify(data));

//**************************** Name & Speed********************************************************

            var name2 = "";
            //for(var i=0;i<=Entities.length-1;i++){

            name2 += 
            '<div class="<col-md-12 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-blue">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
                //'<i class="fa fa-cog fa-spin fa-5x fa-fw"></i>'+
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h1> <strong>' + 'Movies Service' + '</strong><br> </h1>' +
                
                '</div> ' +
                
                '<div class="panel-footer back-footer-royal">' +
                '<h3 style="color: yellow"><strong>SpringBoot Application</h3>' +
                
                '</div>' +
                '</div>' +
                '</div>'
            //}

            $("#name2").html("");
            $("#name2").append(name2);


            //**************************** Name & Speed********************************************************

            var name = "";
            //for(var i=0;i<=Entities.length-1;i++){

            name += 
            '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-blue">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
                //'<i class="fa fa-cog fa-spin fa-5x fa-fw"></i>'+
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[0].name + ' EndGame</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Name</h3>' +
                '</div> ' +
                
				'<div class="panel-footer back-footer-royal">' +
                '<h3 style="color: yellow"><strong>Writer</h3>' +
                '<h3> <strong>' + data[0].written + '</strong><br> </h3>' +
                //'<i class="fa fa-wifi fa-5x"></i>' +
                //'<i class="fa fa-refresh fa-spin fa-5x fa-fw"></i>'+
                '</div>' +
                '</div>' +
                '</div>'
            //}

            $("#name").html("");
            $("#name").append(name);
        
          
            //**************************** Name  ********************************************************
            //**************************** Name & Speed********************************************************

            var location = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-red">' +
                '<div class="panel-body">' +
               
          
                '<h3> <strong>' + data[0].director + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Director</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-royal">' +
                

                '<h3 style="color: yellow"><strong>Producer</h3>' +
                '<h3> <strong>' + data[0].producer + '</strong><br> </h3>' +
               
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location").html("");
            $("#location").append(location);
            //**************************** Name  *******************************************************
         //**************************** Name  ********************************************************
            //**************************** Name & Speed********************************************************

            var location2 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location2 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-red">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
               // '<i class="fa fa-bank fa-5x"></i>' +
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[0].production + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Production</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-royal">' +
                //'<i class="fa fa-wifi fa-5x"></i>' +

                '<h3 style="color: yellow"><strong>Distribution</h3>' +
                '<h3> <strong>' + data[0].distributed  + '</strong><br> </h3>' +
               // '<i class="fa fa-barcode fa-5x"></i>' +
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location2").html("");
            $("#location2").append(location2);
            //**************************** Name  *******************************************************
			
			 //**************************** Name & Speed********************************************************

            var location3 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location3 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-red">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
               // '<i class="fa fa-bank fa-5x"></i>' +
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[0].date  + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Date</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-royal">' +
                //'<i class="fa fa-wifi fa-5x"></i>' +

                '<h3 style="color: yellow"><strong>Year</h3>' +
                '<h3> <strong>' + data[0].year  + '</strong><br> </h3>' +
               // '<i class="fa fa-barcode fa-5x"></i>' +
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location3").html("");
            $("#location3").append(location3);
            //**************************** Name  *******************************************************
 //**************************** Name & Speed********************************************************

            var location4 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location4 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-green">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
               // '<i class="fa fa-bank fa-5x"></i>' +
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[1].booked_seats + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Booked Seats</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-green">' +
                //'<i class="fa fa-wifi fa-5x"></i>' +

                '<h3 style="color: yellow"><strong>Price</h3>' +
                '<h3> <strong>' +  data[1].price  + '</strong><br> </h3>' +
                //'<i class="fa fa-barcode fa-5x"></i>' +
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location4").html("");
            $("#location4").append(location4);
            //**************************** Name  *******************************************************
			
			//**************************** Name & Speed********************************************************

            var location5 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location5 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-green">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
               // '<i class="fa fa-bank fa-5x"></i>' +
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[1].movie_date + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Movie Time</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-green">' +
                //'<i class="fa fa-wifi fa-5x"></i>' +

                '<h3 style="color: yellow"><strong>Screen Type</h3>' +
                '<h3> <strong>' +  data[1].screen  + '</strong><br> </h3>' +
                //'<i class="fa fa-barcode fa-5x"></i>' +
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location5").html("");
            $("#location5").append(location5);
            //**************************** Name  
			
/////////

var name3 = "";
            //for(var i=0;i<=Entities.length-1;i++){

            name3 += 
            '<div class="<col-md-6 col-sm-6 col-xs-6">' +
                '<div class="panel panel-primary text-center no-boder bg-color-green">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
                //'<i class="fa fa-cog fa-spin fa-5x fa-fw"></i>'+
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h1> <strong>' + 'Booking Service' + '</strong><br> </h1>' +
                
                '</div> ' +
                
                '<div class="panel-footer back-footer-green">' +
                '<h3 style="color: yellow"><strong>SpringBoot Application</h3>' +
                
                '</div>' +
                '</div>' +
                '</div>'
            //}

            $("#name3").html("");
            $("#name3").append(name3);



/////////

/////////

var name4 = "";
            //for(var i=0;i<=Entities.length-1;i++){

            name4 += 
            '<div class="<col-md-6 col-sm-6 col-xs-6">' +
                '<div class="panel panel-primary text-center no-boder bg-color-reddark">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
                //'<i class="fa fa-cog fa-spin fa-5x fa-fw"></i>'+
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h1> <strong>' + 'Payment Service' + '</strong><br> </h1>' +
                
                '</div> ' +
                
                '<div class="panel-footer back-footer-royalred">' +
                '<h3 style="color: yellow"><strong>NodeJS Application</h3>' +
                
                '</div>' +
                '</div>' +
                '</div>'
            //}

            $("#name4").html("");
            $("#name4").append(name4);



/////////

			//**************************** Name & Speed********************************************************

            var location6 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location6 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-reddark">' +
                '<div class="panel-body">' +
                
                '<h3> <strong>' + data[2].payment_mode + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>Payment Mode</h3>' +
                '</div> ' +
                '<div class="panel-footer back-footer-royalred">' +
         

                '<h3 style="color: yellow"><strong>Discount</h3>' +
                '<h3> <strong>' +  data[2].discount  + '</strong><br> </h3>' +
                
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location6").html("");
            $("#location6").append(location6);
            //**************************** Name  
			
			//**************************** Name & Speed********************************************************

            var location7 = "";
            //for(var i=0;i<=Entities.length-1;i++){
            location7 += '<div class="col-md-3 col-sm-12 col-xs-12">' +
                '<div class="panel panel-primary text-center no-boder bg-color-reddark">' +
                '<div class="panel-body">' +
                //'<i class="fa fa-dollar fa-5x"></i><br>' +
               // '<i class="fa fa-bank fa-5x"></i>' +
                //'<h3> <strong>'+Entities[0].name+'</strong><br> </h3>'+
                '<h3> <strong>' + data[2].pod_id + '</strong><br> </h3>' +
                '<h3 style="color: yellow"><strong>POD Name<strong></h3>' +
                '</div> ' +
				//'&nbsp' + '&nbsp' +'&nbsp' +
                '<div class="panel-footer back-footer-royalred">' +
                //'<i class="fa fa-wifi fa-5x"></i>' +

                '<h3 style="color: yellow"><strong>Hit Count</h3>' +
                '<h3> <strong>' +  data[2].count  + '</strong><br> </h3>' +
                //'<i class="fa fa-barcode fa-5x"></i>' +
                '</div>' +
                '</div>' +
                '</div>'
            //}
			
	
           

            $("#location7").html("");
            $("#location7").append(location7);
            //**************************** Name  
        },
        error: function(e) {
            alert("Refresh Page2222222");
        }
    });

}


