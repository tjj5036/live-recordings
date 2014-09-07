<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Login</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="pyramid web application" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>

  <body>
    <%include file="user_header.mako"/>
    <div id="login_form" class="container">
      <form id="login_form" action="${request.path}" method="post" role="form" class-"form-horizontal well">
        <legend>Log In</legend>
        <fieldset>
          <input name="_csrf" type="hidden" value="${request.session.get_csrf_token()}">
          <input type="hidden" name="next" value="${next}"/>

          <div class="form-group"> 
            <input type="text" name="login" placeholder="Username"/>
          </div>

          <div class="form-group"> 
            <input type="password" name="password" placeholder="Password"/>
          </div>

          <input type="submit" class="btn-primary" name="form.submit" value="Login"/>
        </fieldset>
      </form>
      ${message}
    </div>
  <%include file="jquery.html"/>
  </body>
</html>
