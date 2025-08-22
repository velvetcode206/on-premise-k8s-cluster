package org.acme.getting.started;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GreetingService {

    public String greeting(String name) {
        return "Hello from Quarkus REST: " + name;
    }

}
