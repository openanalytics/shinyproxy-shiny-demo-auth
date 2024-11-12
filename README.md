# ShinyProxy Authentication demo

This repository explains how to retrieve the username and group of the current
user when deploying a Shiny app using ShinyProxy. The corresponding app can be
run in ShinyProxy and shows the available values.

![Screenshot](.github/screenshots/screenshot.png)

## Using environment variables

When ShinyProxy creates a container, it passes the username and groups to the
container using environment variables. This method is supported in all versions
of ShinyProxy. However, it does not work when using
[container pre-initialization and sharing](https://shinyproxy.io/documentation/configuration/#container-pre-initialization-and-sharing)
introduced in ShinyProxy 3.1.0.

Example code:

```R
Sys.getenv("SHINYPROXY_USERNAME")
Sys.getenv("SHINYPROXY_USERGROUPS")
```

See [`app.r`](example/app.r) for a complete example.

## Using HTTP headers

Starting with version 3.1.0, ShinyProxy adds the username (and groups) as HTTP
headers to every request sent to an app. This method is always supported, even
when
using [container pre-initialization and sharing](https://shinyproxy.io/documentation/configuration/#container-pre-initialization-and-sharing).

```R
session$request$HTTP_X_SP_USERID
session$request$HTTP_X_SP_USERGROUPS
```

See [`app.r`](example/app.r) for a complete example.

## Building the Docker image

To pull the image made in this repository from Docker Hub, use

```bash
sudo docker pull openanalytics/shinyproxy-shiny-demo-auth
```

The relevant Docker Hub repository can be found
at <https://hub.docker.com/r/openanalytics/shinyproxy-shiny-demo-auth>.

To build the image from the Dockerfile, navigate into the root directory of this
repository and run

```bash
sudo docker build -t openanalytics/shinyproxy-shiny-demo-auth .
```

Running the image for testing purposes outside ShinyProxy can be done using e.g.

```bash
sudo docker run -it -p 3838:3838 openanalytics/shinyproxy-shiny-demo-auth
```

## ShinyProxy Configuration

Create a ShinyProxy configuration file (see [application.yml](application.yml)
for a complete file), containing:

```yaml
proxy:
  specs:
    - id: shiny-auth
      container-image: openanalytics/shinyproxy-shiny-demo-auth
```

## UTF-8 characters

The HTTP standard specifies that
only [printable ASCII characters](https://www.ascii-code.com/characters/printable-characters)
are allowed in HTTP headers. Therefore, if a username contains any other
character, the app may fail to start. This can be solved by encoding the values
using [base64](https://en.wikipedia.org/wiki/Base64):

```yaml
proxy:
  specs:
    - id: shiny-auth
      container-image: openanalytics/shinyproxy-shiny-demo-auth
      add-default-http-headers: false
      http_headers:
        X-SP-UserId: "#{T(java.util.Base64).getEncoder().encodeToString(proxy.getRuntimeValue('SHINYPROXY_USERNAME').getBytes())}"
        X-SP-UserGroups: "#{proxy.getRuntimeValue('SHINYPROXY_USERGROUPS')}"
```

Next, in R this values must be decoded using
the [`base64enc`](https://cran.r-project.org/web/packages/base64enc/index.html)
library:

```R
rawToChar(base64enc::base64decode(session$request$HTTP_X_SP_USERID))
```

The next version of ShinyProxy will ignore these headers and log a warning,
see <https://github.com/openanalytics/shinyproxy/issues/533>.

## References

- [ShinyProxy.io](https://shinyproxy.io/)
- [All demos](https://shinyproxy.io/documentation/demos/)

**(c) Copyright Open Analytics NV, 2024.**
