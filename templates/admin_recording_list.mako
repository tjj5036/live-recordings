<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Recordings</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" rel="stylesheet">
  </head>
  <body>
    <%include file="admin_header.mako"/>
    <div id="show-container" class="container">
      <table id="recording_table" class="table">
        <thead>
          <tr>
            <th>Description</th>
            <th>Primary Media Type</th>
            %if permission == 'edit': 
              <th>Edit</th>
            %elif permission =='view':  
              <th>Filetypes</th>
            %endif
            <th>Deleted?</th>
          </tr>
        </thead>
        <tbody id="$recording_table_content">
          %for recording in recording_list:
            <tr>
              <td>${recording['desc']}</td>
              <td>${recording['primary']}</td>
              <td><a href="${request.route_url('admin_edit_existing_recording', recording_id=recording['recording_url_id'])}">Edit</a></td>
              <td>${recording['deleted']}</td>
            </tr>
          %endfor
        </tbody>
      </table>
    </div>
    <%include file="jquery.html"/>
  </body>
</html>
