package com.book.tickets;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import io.opentracing.Tracer;

@RestController
public class BookingController {
private static final String RESPONSE_STRING_FORMAT = "booking-ticket-v1 => %s\n";
	
	private static final String RESPONSE_STRING_FORMAT_UI = "{\"booked_seats\":\"Seats C1,C2\",\"price\":\"$50\",\"movie_date\":\"April 26, 13:45 CST\",\"screen\":\"IMAX - 3D\",\"VERSION\":1} , %s\n";
	
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final RestTemplate restTemplate;

    @Value("${payment.api.url:http://payment:8080}")
    private String remoteURL;
    
    @Value("${payment.api.url.ui:http://payment:8080/ui}")
    private String UIremoteURL;

  
    public BookingController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public ResponseEntity<String> getBookings() {
        try {

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
    public ResponseEntity<String> getBookingUI() {
        try {
        	
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
