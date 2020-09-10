@IsTest
global class APICalloutServicesMockResponseGenerator implements HttpCalloutMock {
	global HttpResponse respond(HttpRequest request) {
		HttpResponse httpResponse = new HttpResponse();
		httpResponse.setHeader('Content-Type', 'application/json');
		httpResponse.setBody(getResponseString(request));
		httpResponse.setStatusCode(200);
		return httpResponse;
	}

	private String getResponseString(HttpRequest request) {
		if (request.getEndpoint().contains('APIEndpointGoesHere')) {
			return '{"success":true,"secretKey":"PDHE9Is7G3J9+soRTuW"}';
		}
		return '';
	}
}