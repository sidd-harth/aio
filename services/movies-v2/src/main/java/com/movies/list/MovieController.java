package com.movies.list;

import io.opentracing.Tracer;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.actuate.endpoint.web.Link;
import org.springframework.http.*;
//import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
public class MovieController {
	private static final String RESPONSE_STRING_FORMAT = "movies-VERSION2 => %s\n";
	
	private static final String RESPONSE_STRING_FORMAT_UI = "[{\"name\":\"Avengers EndGame\",\"director\":\"Rusoo Brothers\",\"producer\":\"Kevin Feige\",\"production\":\"Marvel Studios\",\"date\":\"April 26\",\"written\":\"Stan Lee\",\"year\":\"2019\",\"distributed\":\"Walt Disney\",\"poster\":\"assets/img/v2.jpg\",\"VERSION\":2,\"bg-color\":\"background-color: white\"} , %s\n]";
	
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final RestTemplate restTemplate;

    @Value("${booking.api.url:http://booking:8080}")
    private String remoteURL;
    
    @Value("${booking.api.url.ui:http://booking:8080/ui}")
    private String UIremoteURL;

    @Autowired
    private Tracer tracer;

    public MovieController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public ResponseEntity<String> getMovies(@RequestHeader("User-Agent") String userAgent, @RequestHeader(value="x-api-key", required = false) String apikeyHeader) {
        try {
            /**
             * Set baggage
             */
		
	    tracer.activeSpan().setBaggageItem("user-agent", userAgent);
            if (apikeyHeader != null && !apikeyHeader.isEmpty()) {
                tracer.activeSpan().setBaggageItem("x-api-key", apikeyHeader);
	    }

            ResponseEntity<String> responseEntity = restTemplate.getForEntity(remoteURL, String.class);
            String response = responseEntity.getBody();
            return ResponseEntity.ok(String.format(RESPONSE_STRING_FORMAT, response.trim()));
        } catch (HttpStatusCodeException ex) {
            logger.warn("Exception trying to get the response from booking service.", ex);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(String.format(RESPONSE_STRING_FORMAT,
                            String.format("%d %s", ex.getRawStatusCode(), createHttpErrorResponseString(ex))));
        } catch (RestClientException ex) {
            logger.warn("Exception trying to get the response from booking service.", ex);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(String.format(RESPONSE_STRING_FORMAT, ex.getMessage()));
        }
    }
    
    
    @RequestMapping(value = "/ui", method = RequestMethod.GET, produces = "application/json")
    public ResponseEntity<String> getMoviesUI(@RequestHeader("User-Agent") String userAgent, @RequestParam(value="apikey", required = false) String apikey, @RequestHeader(value="x-api-key", required = false) String apikeyHeader) {
        try {
            /**
             * Set baggage
             */
			tracer.activeSpan().setBaggageItem("user-agent", userAgent);
            if (apikey != null && !apikey.isEmpty()) {
                tracer.activeSpan().setBaggageItem("apikey", apikey);
            }
			
            if (apikeyHeader != null && !apikeyHeader.isEmpty()) {
                tracer.activeSpan().setBaggageItem("apikey", apikeyHeader);
            }

            ResponseEntity<String> responseEntity = restTemplate.getForEntity(UIremoteURL, String.class);
            String response = responseEntity.getBody();
            return ResponseEntity.ok(String.format(RESPONSE_STRING_FORMAT_UI, response.trim()));
        } catch (HttpStatusCodeException ex) {
            logger.warn("Exception trying to get the response from booking service.", ex);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(String.format(RESPONSE_STRING_FORMAT_UI,
                            String.format("%d %s", ex.getRawStatusCode(), createHttpErrorResponseString(ex))));
        } catch (RestClientException ex) {
            logger.warn("Exception trying to get the response from booking service.", ex);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(String.format(RESPONSE_STRING_FORMAT_UI, ex.getMessage()));
        }
    }
    
    private String createHttpErrorResponseString(HttpStatusCodeException ex) {
        String responseBody = ex.getResponseBodyAsString().trim();
        if (responseBody.startsWith("null")) {
            return ex.getStatusCode().getReasonPhrase();
        }
        return responseBody;
    }

}
