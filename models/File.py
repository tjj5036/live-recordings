from pyramid.security import (Allow,
                              Everyone,
                              ALL_PERMISSIONS)
from math import log
import datetime
import hashlib
import os
import posixpath


UNIT_LIST = zip(['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'], [0, 0, 1, 2, 2, 2])
OS_ALT_SEP = list(
    sep for sep in [os.path.sep, os.path.altsep] if sep not in (None, '/'))


class FileUpload(object):
    """ Processes a file upload.
    """

    def __init__(self, recording_id, file_object, request):
        """ Inits the filename
        """
        self.filename = file_object.filename
        self.recording_id = recording_id
        self._id = ''
        self.valid = False
        self.size = ''
        self.visible = 'True'
        self.message = ''
        self.deleted = 'False'
        self.write_to_disk(request, file_object)

    def write_to_disk(self, request, file_object):
        """ Writes the file to disk.
        """
        rec_folder = self.safe_join(
            str(request.registry.settings['BASE_DIR']), self.recording_id)
        if not rec_folder:
            self.message = "Bad File!"
            return False
        if not os.path.exists(rec_folder):
            os.makedirs(rec_folder)

        dest_file = self.safe_join(rec_folder, self.filename)
        if not dest_file:
            self.message = "Bad File!"
            return False

        if (os.path.exists(dest_file) or request.db['file_locations'].find(
                {'location': dest_file}).count() != 0):
            self.message = "File Exists!"
            return False

        output_file = open(dest_file, 'wb')
        file_object.file.seek(0)

        while(1):
            data = file_object.file.read(2 << 16)
            if not data:
                break
            output_file.write(data)
        output_file.close()

        fn, file_ext = os.path.splitext(dest_file)
        file_md5 = hashlib.md5(open(dest_file).read()).hexdigest()
        byte_size = os.path.getsize(dest_file)
        self.size = self.sizeof_fmt(byte_size)

        result = request.db['file_locations'].insert({
            'filename': self.filename,
            'location': dest_file,
            'size': self.size,
            'location_dir': rec_folder,
            'uploadDate': datetime.datetime.now(),
            'length': byte_size,
            'visible': self.visible,
            'downloads': 0,
            'md5': file_md5,
            'rec_id': self.recording_id,
            'deleted': self.deleted,
            'type': file_ext})

        self._id = str(result) or ''
        self.valid = True
        return True

    def safe_join(self, base_dir, filename):
        """ Safely joins a file and a base directory.
        """
        filename = posixpath.normpath(filename)
        for sep in OS_ALT_SEP:
            if sep in filename:
                return None
        if os.path.isabs(filename) or filename.startswith('../'):
            return None
        return os.path.join(base_dir, filename)

    def sizeof_fmt(self, num):
        """ Human friendly file size.
        """
        if num > 1:
            exponent = min(int(log(num, 1024)), len(UNIT_LIST) - 1)
            quotient = float(num) / 1024**exponent
            unit, num_decimals = UNIT_LIST[exponent]
            format_string = '{:.%sf} {}' % (num_decimals)
            return format_string.format(quotient, unit)
        if num == 0:
            return '0 bytes'
        if num == 1:
            return '1 byte'


class RootFactory(object):
    """ Permissions.
    """
    __acl__ = [
        (Allow, Everyone, 'view'),
        (Allow, 'group:admins', ALL_PERMISSIONS),
        (Allow, 'group:setlist', 'setlist')]

    def __init__(self, request):
        pass  # pragma: no cover
