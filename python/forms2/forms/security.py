from pyramid.security import ALL_PERMISSIONS
from pyramid.security import Allow
from pyramid.security import Authenticated

class ViewACL(object):
    __name__ = 'viewacl'
    __parent__ = None
    __acl__ = [
	       (Allow,Authenticated,'create'),
               (Allow,'manager',ALL_PERMISSIONS),
               ]
    
    def __init__(self, request):
        self.request = request
