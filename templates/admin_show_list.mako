<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Shows</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="admin_header.mako"/>
    <div id="show-container" class="container">
      %for artist, concert in concert_list.iteritems():
        <table id="${artist}_table" class="table">
          <thead>
            <tr>${artist}</tr>
            <tr>
              <th>Date</th>
              <th>Venue</th>
              %if permission == 'edit': 
              <th>Edit</th>
              %elif permission =='view':  
              <th>Filetypes</th>
              %endif
            </tr>
          </thead>
          <tbody id="${artist}_table_content">
            %for c in concert:
              <tr>
                <td>${c['date']}</td>
                <td>${c['venue']}</td>
                <td><a href="${request.route_url('admin_edit_existing_show', concert_id=c['concert_id'])}">Edit</a></td>
              </tr>
            %endfor
          </tbody>
        </table>
      %endfor
    </div>
  <%include file="jquery.html"/>
</body>
</html>
