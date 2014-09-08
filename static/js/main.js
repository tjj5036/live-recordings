(function( live_recordings, $, undefined) {
    
    var hidden_tr_class = 'tr-concert-hidden';
    
    live_recordings.recordingRedirect = function() {
        $('tr').click(function() {
            window.location.href = $(this).find('a').attr('href');
        });
    };

    live_recordings.showNestedFiles = function() {
        $('.associated_files').on('click', function() {
            $(this).closest('div').find('.table-file-hidden').toggle();
        });
    };

    function applyFilters() {
        var media_types = $('#filtering').find('.filter_options').find(':checkbox:checked');
        $('table tr td:nth-child(3)').each(function() {
            
            var trparent = $(this).parent();
            var file_types = $(this).text().split(/\s+/);

            if (media_types.length == 0 && ($.trim(file_types) == '')) {
                trparent.addClass(hidden_tr_class);
            }

            media_types.each(function() {
                var i;
                var should_hide = true;
                for (i = 0; i < media_types.length; i++) {
                    if (this.value == file_types[i]) {
                        should_hide = false;
                        break;
                    }
                }
                if (should_hide) {
                    trparent.addClass(hidden_tr_class);
                } else {
                    trparent.removeClass(hidden_tr_class);
                }
            });
        });
    };

    live_recordings.showFilters = function() {
        $('#show_filters').on('click', function() {
            $('#concert_filter').toggle(); 
        });
        
        $('#has_files').on('click', function() {
            if ($("#has_files").is(":checked")) {
                $('#filtering').find('.filter_options').show();
                applyFilters();
            } else {
                $('table tr').each(function() {
                    $(this).removeClass(hidden_tr_class);
                });
                $('#filtering').find('.filter_options').hide();
            }
        });

        $('input[name="a_types[]"], input[name="v_types[]"]').on('click', function() {
            applyFilters();
        });

        $('tr').click(function() {
            var dest = $(this).find('a').attr('href');
            if (dest) {
                window.location.href = $(this).find('a').attr('href');
            }
        });

    };


} (window.live_recordings = window.live_recordings || {}, jQuery ));
