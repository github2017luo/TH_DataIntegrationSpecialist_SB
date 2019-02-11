public class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
   public HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(500);
        return response;
    } 
}