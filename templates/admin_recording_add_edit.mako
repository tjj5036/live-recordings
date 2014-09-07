<!DOCTYPE html>
<html lang="en">
  <head>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <title>Add / Edit Recordings</title>
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="admin_header.mako"/>
    <div id="form-container" class="container">
      <div class="row">

        <div class="col-xs-12 ">
          <legend> <a href="${request.route_url('render_recording', recording_id=recording['recording_url_id'])}">Recording Information</a></legend>
        </div>

        <form id='recording_form' role="form" action="#">
          <div class="col-xs-6 ">

            Recording ID:
            %if action == 'update':
            <label id="ID">${recording['_id']}</label>
            %else:
            <label id="ID">NA</label>
            %endif

            <div class="form-group">
              <label for='recording_url_id'>Recording URL ID</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="recording_url_id" placeholder="URL" value="${recording['recording_url_id'] if recording['recording_url_id'] else ''}">
              </div>
            </div>

            <div class="form-group">
              <label for='desc'>Description</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="desc" placeholder="Description" value="${recording['desc'] if recording['desc'] else ''}">
              </div>
            </div>

            <div class="form-group">
              <label for='taper'>Taper</label>
              <div class="input-group-sm">
                <input class="form-control" class="form-control" type="text" id="taper" placeholder="Taper" value="${recording['taper'] if recording['taper'] else ''}">
              </div>
            </div>

            <div class="form-group">
              <label for='source'>Source</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="source" placeholder="Source" value="${recording['source'] if recording['source'] else ''}">
              </div>
            </div>

            <label for='notes'>Notes</label>
            <textarea class="form-control" rows="5" id="notes" placeholder="Notes">${recording['notes'] if recording['notes'] else ''}</textarea>

            <label for='rtype'>Recording Type</label>
            <select id="rtype" class="form-control">
              <option value="Audience">Audience</option>
              <option value="Professional">Professional</option>
            </select>

              <label for='primary'>Primary</label>
                <select id="primary" class="form-control">
                  <option value="AVI">AVI</option>
                  <option value="MP4">MP4</option>
                  <option value="DVD">DVD</option>
                  <option value="MOD">MOD</option>
                  <option value="HD">HD</option>
                  <option value="FLV">FLV</option>
                  <option value="VIDEO-OTHER">VIDEO-OTHER</option>
                  <option value="MP3">MP3</option>
                  <option value="FLAC">FLAC</option>
                  <option value="OGG">OGG</option>
                  <option value="SHN">SHN</option>
                  <option value="WMA">WMA</option>
                  <option value="WMV">WMV</option>
                  <option value="AUDIO-OTHER">AUDIO-OTHER</option>
                </select>

            <div class="checkbox">
            <label for='status'>Deleted?</label>
              % if recording['deleted'] == 'True': 
                <input type="checkbox" id="status" checked=True}>
              %else:
                <input type="checkbox" id="status">
              %endif
            </div>

            <div class="checkbox">
            <label for='visible'>Visible?</label>
              % if recording['visible'] == 'True': 
                <input type="checkbox" id="visible" checked=True}>
              %else:
                <input type="checkbox" id="visible">
              %endif
            </div>

          </div> <!-- First Column Set -->

          <div class="col-xs-6">
            
            <label for='concerts'>Concert Options</label>
            <select class="form-control" id='concerts' multiple='multiple' name='concerts[]'>
              %for artist, concerts in c_list.iteritems():
                %for concert in concerts:
                  <option value="${concert['_id']}">${concert['date']} - ${concert['artist']}</option>    
                %endfor
              %endfor
            </select>

            <label for='concert_table'>Associated Concerts</label>
            <table id="concert_table" class="table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>ID</th>
                </tr>
              </thead>
              <tbody id="concert_table_values">
              </tbody>
            </table>
            
          </div> <!-- Second Column Set -->

          <div class="col-xs-12">
            <label for='file_table'>Associated Files</label>
            <table id="file" class="table">
              <thead>
                <tr>
                  <th>Filename</th>
                  <th>Size</th>
                  <th>Visible?</th>
                  <th>Deleted?</th>
                </tr>
              </thead>
              <tbody id="file_table_values">
                %for file in recording['files']:
                <tr>
                  <td><a href="${request.route_url('send_file', file_id=file['_id'])}">${file['filename']}</a></td>
                  <td>${file['size']}</td>
                  <td>
                  %if file['visible'] == 'True' :
                  <input type="checkbox" name="vfile${file['filename']}" value="${file['_id']}" checked='True'>
                  %else:
                  <input type="checkbox" name="vfile${file['filename']}" value="${file['_id']}">
                  %endif
                  </td>
                  <td>
                  %if file['deleted'] == 'True' :
                  <input type="checkbox" name="dfile${file['filename']}" value="${file['_id']}" checked='True'>
                  %else:
                  <input type="checkbox" name="dfile${file['filename']}" value="${file['_id']}">
                  %endif
                  </td>
                </tr>
                %endfor
              </tbody>
            </table>
          </div> <!-- Large Column Set -->


          <div id="submit_div" class="col-xs-12 col-md-8">
            <input type="submit" value="Submit" id="add_button" class="btn">
            <input type="submit" value="Delete" id="delete_button" class="btn">
            <label class="error" for="client_id_manual" id="name_error">You need to input an artist!</label><br>
          </div>

        </form>

      </div> <!--Recording Info  Row -->

      <div class="row">
        <div id="file-upload"  class="col-xs-12">
          <form enctype="multipart/form-data" action="" method="post" id="file_form" role="form">
            <legend> Upload Files </legend>

            <div class="form-group">
              <label for='pending_files'>File Selection:</label>
              <input id="pending_files" type="file" name="pending_files[]" multiple>
            </div>

            <div id="pending_files">
              <label>Pending Files:</label>
                <table id="pending_file_table">
                </table>
            </div>

            <input type="submit" value="Upload File(s)" id="add_file_button" class="btn">
          </form>
        </div> <!-- Large Column Set -->
      </div> <!-- File Upload Row -->

    </div> <!-- Container -->

  <%include file="jquery.html"/>
  <script>

  // Hides error by default
  $('.error').hide();
  
  
  $(document).ready(function(){
    
    /* Shows files that are about to be uploaded 
    */
    $("#pending_files").on('change', function() {
      $('#pending_file_table').empty();
      for (var i=0; i < $("#pending_files")[0].files.length; i++) {
        $("#pending_file_table").append(
          "<tr>" + 
          "<td>" + '<progress id="pfile'+i+'" value="0"  max="100"><span>%</span></progress>' +  "</td>" +
          '<td><div class="pfile_error"  id="perror'+i+'"></div></td>' + 
          "<td>"+ $("#pending_files")[0].files[i].name + "</td>" +
          "</tr>"
        );
      }
    });

    /* Uploads files 
    */
    $("#add_file_button").click(function(){
      event.preventDefault();
      for (var i=0; i < $("#pending_files")[0].files.length; i++) {
        (function (id) {
          formdata = new FormData();
          formdata.append("files[]", $("#pending_files")[0].files[id]);
          formdata.append("recording_id", $("#ID").text());
          $.ajax({
            type:"POST",
            url: "${request.route_url('admin_upload_file')}",
            data: formdata,
            xhr: function() {
              xhrcustom = $.ajaxSettings.xhr();
              if (xhrcustom.upload) {
                xhrcustom.upload.addEventListener('progress', function(evt) {
                  if (evt.lengthComputable) {
                    var percentComplete = (evt.loaded / evt.total) * 100;
                    $('#pfile'+(id)).attr('value',percentComplete);
                  } else {
                    console.log('unable to complete');
                  }
                });
                xhrcustom.upload.addEventListener('load', function(evt) {
                  console.log("File uploaded!");
                });
              }
              return xhrcustom;
            },
            processData: false,
            contentType: false,
            success:function(result){
              if (result.valid == true) {
                $('#pfile'+(id)).closest('tr').remove();
                var vfile = '';
                var dfile = '';
                if (result.visible == 'True') {
                  vfile = 'checked="True"';
                }
                if (result.deleted == 'True') {
                  dfile = 'checked="True"';
                }
                $("#file_table_values").append(
                  '<tr><td><a href="' + result.url + '">' + result.filename + "</a></td>" + "<td>" + result.size + "</td>" +
                  '<td><input type="checkbox" name="vfile' + result.filename + '" value="' + result._id + '" ' + vfile + '></td>' + 
                  '<td><input type="checkbox" name="dfile' + result.filename + '" value="' + result._id + '" ' + dfile + '></td>' + 
                  "</tr>"
                );
              } else {
                $("div#perror"+(id)).text(result.message);
              }
            },
          });
        })(i);
      }
    });
  });

  
  /* Adds an existing concert to the recording -> concert associativity list
  */
  $("#concerts").dblclick(function () {
    $("#concerts option:selected").each(function () {
      concert_id  = $(this).val();
      concert_name = $(this).text();
      $("#concert_table_values").append('<tr ondblclick="delete_row(this)"><td>'+concert_name+'</td><td>'+concert_id+'</td></tr>')
    });
  });

  /* Removies recording -> concert associativity table row 
  Note that this does not change actual data */
  function delete_row(xrow) {
    $(xrow).closest("tr").remove();
  }
  
  /* Builds recording -> concert associativity table
  */
  %if 'concert_ids' in recording:
    jQuery(window).load(function() {
      %for concert in recording['concert_ids']:
        concert = ('${concert}');
        concert_name = $("#concerts option[value="+concert+"]").text();
        $("#concert_table_values").append('<tr ondblclick="delete_row(this)"><td>'+concert_name+'</td><td>${concert}</td></tr>')
      %endfor
    });
  %endif
  
  /* Sets the recording type if this is an existing recording
  */
  %if 'rtype' in recording:
    jQuery(window).load(function() {
      rtype = '${recording["rtype"]}'
      $('#rtype option[value="'+rtype+'"]').attr('selected', true);
    });
  %endif
  
  /* Sets the primary file type if this is an existing recording
  */
  %if 'primary' in recording:
    jQuery(window).load(function() {
      primary = '${recording["primary"]}'
      $('#primary option[value="'+primary+'"]').attr('selected', true);
    });
  %endif


  $(document).ready(function(){

    /* "Deletes" the given recording */
    $("#delete_button").click(function(){
      event.preventDefault();
      $.ajax({
        type:"POST",
        url: "${request.route_url('admin_delete_recording')}",
        data: {
          _id : $("#ID").text(),
        },
        success:function(result){
          if (result.action == 'success') {
            alert("Recording successfully deleted!");
            window.location.replace("${request.route_url('admin_list_recording')}");
          }
        }
      });
    });

    /* Adds or updates an existing concert */
    $("#add_button").click(function(){
      event.preventDefault();
      var concert_ids = new Array();
      var available = $("#status").is(":checked");
      var visible = $("#visible").is(":checked");
      $("#concert_table_values tr").each(function(){
        concert_ids.push($(this).find("td:nth-child(2)").html());
      });
      concert_ids = JSON.stringify(concert_ids);
      $.ajax({
        type:"POST",
        url: "${request.route_url('admin_add_recording')}",
        data:{ 
          id : $("#ID").text(),
          recording_url_id : $("#recording_url_id").val(),
          desc : $("#desc").val(),
          taper : $("#taper").val(),
          source : $("#source").val(),
          notes : $("#notes").val(),
          deleted : available,
          visible : visible,
          rtype : $("#rtype").val(),
          primary : $("#primary").val(),
          concert_ids : concert_ids, 
        },
        success:function(result){
          console.log(result.action);
          if (result.action == 'success') {
            alert("Recording Added Successfully!");
          }
          return false;
        }
      });
    });
    
    /* Updates file visibility 
    */
    $('[name^="vfile"]').change(function(event) {
      var is_checked = $(this).is(':checked');
      var file_id = $(this).val();
      $.ajax({
        type:"POST",
        url: "${request.route_url('admin_set_file_visibility')}",
        data: {
          _id : file_id,
          visible:is_checked
        },
        success:function(result){
          if (result.action == 'success') {
            return true;
          }
          console.log("Unable to change visibility!");
          return false;
        }
      });
    });

    /* Updates file visibility 
    */
    $('[name^="dfile"]').change(function(event) {
      var is_checked = $(this).is(':checked');
      var file_id = $(this).val();
      console.log(is_checked + file_id);
      $.ajax({
        type:"POST",
        url: "${request.route_url('admin_delete_file')}",
        data: {
          _id : file_id,
          deleted : is_checked
        },
        success:function(result){
          if (result.action == 'success') {
            return true;
          }
          console.log("Unable to change visibility!");
          return false;
        }
      });
    });

  });
  </script>
  </body>
</html>
