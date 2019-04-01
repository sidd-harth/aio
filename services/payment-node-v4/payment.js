const http = require('http');
const util = require('util');
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const os = require("os");
const request = require('request');

const options = {
  host: 'httpbin.org',
  port: 80,
  path: '/get'
};

const responseStringFormat = "payment-service-v4 - pod-ip -  %s";
const responseStringFormatUI = "{\"payment_status\":\"Success\", \"payment_mode\":\"Paypal\"}";

var misbehave = false;
var count = 0;

app.use(bodyParser.json()); // Inject JSON parser

app.get('/', function (request, response) {
  console.log("Calling base uri");
  var hostname = os.hostname();
  if (misbehave) {
    response.sendStatus(503).end(util.format("recommendation misbehavior from %s\n", hostname));
  } else {
    count++;
    console.log("count is " + count);
    response.send(util.format(responseStringFormat, hostname, count));
  }
});

app.get('/ui', function (request, response) {

  console.log("Calling UI endpoint");
  var hostname = os.hostname();
  if (misbehave) {
    response.sendStatus(503).end(util.format("recommendation misbehavior from %s\n", hostname));
  } else {
    count++;
    console.log("count is " + count);
    //response.send(responseStringFormatUI);
    response.jsonp(200, {
      "payment_mode": "Paypal",
      "discount": "$8",
      "pod_id": hostname,
      "count": count,
      "VERSION": 4
    });
  }
});

app.get('/misbehave', function (request, response) {
  console.log("Calling Misbehave");
  misbehave = true;
  response.send(util.format(responseStringFormat, "Following requests to '/' will return a 503\n"));
});

app.get('/behave', function (request, response) {
  console.log("Calling Behave");
  misbehave = false;
  response.send(util.format(responseStringFormat, "Following requests to '/' will return a 200\n"));
});


app.get('/httpbin', function (req, res) {
  console.log("Calling HTTPbin");
  request({
    uri: 'http://httpbin.org/get'
  }).pipe(res);
});


app.listen(8080, function () {
  console.log('Payment Service v4 listening on port 8080')
});