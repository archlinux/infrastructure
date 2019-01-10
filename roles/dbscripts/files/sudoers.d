%dev ALL=(svn-packages) NOPASSWD:/usr/bin/svnserve
%dev ALL=(svn-packages) NOPASSWD:/usr/bin/svn
#%dev ALL=(svn-community) NOPASSWD:/usr/bin/svnserve
%tu ALL=(svn-community) NOPASSWD:/usr/bin/svnserve
%tu ALL=(svn-community) NOPASSWD:/usr/bin/svn

%dev ALL = (archive) NOPASSWD: /packages/db-archive
%tu  ALL = (archive) NOPASSWD: /community/db-archive

sourceballs ALL=(svn-community) NOPASSWD:/usr/bin/svn
sourceballs ALL=(svn-packages) NOPASSWD:/usr/bin/svn
