public class ProjectCalloutServiceMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatus('OK');
        response.setStatusCode(201);        
        return response;
    }
}