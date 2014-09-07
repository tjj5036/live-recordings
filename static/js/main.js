(function( live_recordings, $, undefined) {
    
    live_recordings.recordingRedirect = function() {
        /* Redirects to recording in table.
         * */
        $('tr').click(function() {
            window.location.href = $(this).find('a').attr('href');
        });
    };

    


} (window.live_recordings = window.live_recordings || {}, jQuery ));
