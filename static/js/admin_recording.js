(function( live_recordings, $, undefined) {
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

} (window.live_recordings = window.live_recordings || {}, jQuery ));

