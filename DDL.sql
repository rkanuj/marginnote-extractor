create table main.ZACTIVITY
(
    Z_PK      INTEGER
        primary key,
    Z_ENT     INTEGER,
    Z_OPT     INTEGER,
    ZVISITED  INTEGER,
    ZTIME     TIMESTAMP,
    ZACTION   VARCHAR,
    ZAUTHOR   VARCHAR,
    ZINFO     VARCHAR,
    ZNEWTEXT  VARCHAR,
    ZNOTEID   VARCHAR,
    ZTOPICID  VARCHAR,
    ZNEWMEDIA BLOB
);

create index main.Z_Activity_action
    on main.ZACTIVITY (ZACTION);

create index main.Z_Activity_noteid
    on main.ZACTIVITY (ZNOTEID);

create index main.Z_Activity_time
    on main.ZACTIVITY (ZTIME);

create index main.Z_Activity_topicid
    on main.ZACTIVITY (ZTOPICID);

create table main.ZBOOK
(
    Z_PK            INTEGER
        primary key,
    Z_ENT           INTEGER,
    Z_OPT           INTEGER,
    ZLASTVISIT      TIMESTAMP,
    ZAUTHOR         VARCHAR,
    ZBOOKURL        VARCHAR,
    ZCURRENTTOPICID VARCHAR,
    ZFILE           VARCHAR,
    ZMD5            VARCHAR,
    ZMD5LONG        VARCHAR,
    ZPATH           VARCHAR,
    ZTHUMBNAIL      BLOB
);

create index main.Z_Book_md5
    on main.ZBOOK (ZMD5);

create index main.Z_Book_md5long
    on main.ZBOOK (ZMD5LONG);

create table main.ZBOOKCOMMENT
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZCOMMENTCLOSE    INTEGER,
    ZHASNOTES        INTEGER,
    ZLIKECOUNT       INTEGER,
    ZUNLIKECOUNT     INTEGER,
    ZUSERLIKE        INTEGER,
    ZDATE            TIMESTAMP,
    ZBOOKMARK        VARCHAR,
    ZBOOKMD5         VARCHAR,
    ZCACHEDLIKEID    VARCHAR,
    ZCOMMENTID       VARCHAR,
    ZCOMMENTTEXT     VARCHAR,
    ZMARKNOTEID      VARCHAR,
    ZNOTEFILENAME    VARCHAR,
    ZNOTELINKS       VARCHAR,
    ZPARENTCOMMENTID VARCHAR,
    ZTOPICID         VARCHAR,
    ZUSERID          VARCHAR
);

create index main.Z_BookComment_bookmd5
    on main.ZBOOKCOMMENT (ZBOOKMD5);

create index main.Z_BookComment_commentid
    on main.ZBOOKCOMMENT (ZCOMMENTID);

create index main.Z_BookComment_commenttext
    on main.ZBOOKCOMMENT (ZCOMMENTTEXT);

create index main.Z_BookComment_notelinks
    on main.ZBOOKCOMMENT (ZNOTELINKS);

create index main.Z_BookComment_parentcommentid
    on main.ZBOOKCOMMENT (ZPARENTCOMMENTID);

create index main.Z_BookComment_topicid
    on main.ZBOOKCOMMENT (ZTOPICID);

create index main.Z_BookComment_userid
    on main.ZBOOKCOMMENT (ZUSERID);

create table main.ZBOOKCONFIG
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZCURRPAGE        INTEGER,
    ZCURRPAGEOFF     INTEGER,
    ZSYNCMODE        INTEGER,
    ZUSNFTS          INTEGER,
    ZUSNPROPERTIES   INTEGER,
    ZCURRPAGEPERCENT FLOAT,
    ZFONTSCALE       FLOAT,
    ZCLOUDURL        VARCHAR,
    ZFONTNAME        VARCHAR,
    ZMD5             VARCHAR,
    ZMD5LONG         VARCHAR,
    ZOPTIONS         VARCHAR,
    ZTAGLIST         VARCHAR,
    ZTITLE           VARCHAR
);

create index main.Z_BookConfig_md5
    on main.ZBOOKCONFIG (ZMD5);

create index main.Z_BookConfig_md5long
    on main.ZBOOKCONFIG (ZMD5LONG);

create table main.ZBOOKNOTE
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZENDPAGE         INTEGER,
    ZMINDCLOSE       INTEGER,
    ZSTARTPAGE       INTEGER,
    ZTYPE            INTEGER,
    ZUSNFTS          INTEGER,
    ZUSNPROPERTIES   INTEGER,
    ZZINDEX          INTEGER,
    ZHIGHLIGHT_DATE  TIMESTAMP,
    ZNOTE_DATE       TIMESTAMP,
    ZAUTHOR          VARCHAR,
    ZBOOKMD5         VARCHAR,
    ZCHILDMAPNOTEID  VARCHAR,
    ZENDPOS          VARCHAR,
    ZEVERNOTEID      VARCHAR,
    ZGROUPNOTEID     VARCHAR,
    ZHIGHLIGHT_STYLE VARCHAR,
    ZHIGHLIGHT_TEXT  VARCHAR,
    ZMEDIA_LIST      VARCHAR,
    ZMINDLINKS       VARCHAR,
    ZMINDPOS         VARCHAR,
    ZNOTEID          VARCHAR,
    ZNOTES_TEXT      VARCHAR,
    ZNOTETITLE       VARCHAR,
    ZRECOGNIZE_MEDIA VARCHAR,
    ZRECOGNIZE_TEXT  VARCHAR,
    ZSTARTPOS        VARCHAR,
    ZTOPICID         VARCHAR,
    ZHIGHLIGHT_PIC   BLOB,
    ZHIGHLIGHTS      BLOB,
    ZNOTES           BLOB
);

create index main.Z_BookNote_bookmd5
    on main.ZBOOKNOTE (ZBOOKMD5);

create index main.Z_BookNote_childmapnoteid_topicid
    on main.ZBOOKNOTE (ZCHILDMAPNOTEID, ZTOPICID);

create index main.Z_BookNote_endpage_bookmd5
    on main.ZBOOKNOTE (ZENDPAGE, ZBOOKMD5);

create index main.Z_BookNote_evernoteid
    on main.ZBOOKNOTE (ZEVERNOTEID);

create index main.Z_BookNote_highlight_date
    on main.ZBOOKNOTE (ZHIGHLIGHT_DATE);

create index main.Z_BookNote_note_date
    on main.ZBOOKNOTE (ZNOTE_DATE);

create index main.Z_BookNote_noteid
    on main.ZBOOKNOTE (ZNOTEID);

create index main.Z_BookNote_startpage_bookmd5
    on main.ZBOOKNOTE (ZSTARTPAGE, ZBOOKMD5);

create index main.Z_BookNote_topicid
    on main.ZBOOKNOTE (ZTOPICID);

create index main.Z_BookNote_topicid_bookmd5
    on main.ZBOOKNOTE (ZTOPICID, ZBOOKMD5);

create index main.Z_BookNote_type_topicid
    on main.ZBOOKNOTE (ZTYPE, ZTOPICID);

create table main.ZBOOKNOTESYNC
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZENDPAGE         INTEGER,
    ZSTARTPAGE       INTEGER,
    ZENDPOS          VARCHAR,
    ZEVERNOTEID      VARCHAR,
    ZGROUPNOTEID     VARCHAR,
    ZHIGHLIGHT_STYLE VARCHAR,
    ZHIGHLIGHT_TEXT  VARCHAR,
    ZMINDLINKS       VARCHAR,
    ZMINDPOS         VARCHAR,
    ZNOTEID          VARCHAR,
    ZNOTETITLE       VARCHAR,
    ZSTARTPOS        VARCHAR,
    ZTOPICID         VARCHAR,
    ZHIGHLIGHT_PIC   BLOB,
    ZHIGHLIGHTS      BLOB,
    ZNOTES           BLOB
);

create index main.Z_BookNoteSync_noteid
    on main.ZBOOKNOTESYNC (ZNOTEID);

create table main.ZBOOKTAG
(
    Z_PK      INTEGER
        primary key,
    Z_ENT     INTEGER,
    Z_OPT     INTEGER,
    ZTAGCLOSE INTEGER,
    ZUSN      INTEGER,
    ZSYNCHASH VARCHAR,
    ZTAGID    VARCHAR,
    ZTAGLINKS VARCHAR,
    ZTAGNAME  VARCHAR
);

create index main.Z_BookTag_tagid
    on main.ZBOOKTAG (ZTAGID);

create index main.Z_BookTag_taglinks
    on main.ZBOOKTAG (ZTAGLINKS);

create index main.Z_BookTag_tagname
    on main.ZBOOKTAG (ZTAGNAME);

create table main.ZEPUBRANGE
(
    Z_PK        INTEGER
        primary key,
    Z_ENT       INTEGER,
    Z_OPT       INTEGER,
    ZVIEWHEIGHT INTEGER,
    ZVIEWWIDTH  INTEGER,
    ZFONTSIZE   FLOAT,
    ZVERSION    FLOAT,
    ZBOOKMD5    VARCHAR,
    ZFONTNAME   VARCHAR,
    ZRANGEDATA  BLOB
);

create index main.Z_EpubRange_bookmd5
    on main.ZEPUBRANGE (ZBOOKMD5);

create table main.ZMEDIA
(
    Z_PK       INTEGER
        primary key,
    Z_ENT      INTEGER,
    Z_OPT      INTEGER,
    ZMD5       VARCHAR,
    ZDATA      BLOB,
    ZTHUMBNAIL BLOB
);

create index main.Z_Media_md5
    on main.ZMEDIA (ZMD5);

create table main.ZSETTING
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZLASTSYNCUSN     INTEGER,
    ZBOOKOPENING     VARCHAR,
    ZLASTBOOKMD5     VARCHAR,
    ZLASTTOPICTITLE  VARCHAR,
    ZLASTLINKSYNINFO BLOB,
    ZLASTPROMPTINFO  BLOB,
    ZUISTATUS        BLOB
);

create table main.ZTOPIC
(
    Z_PK              INTEGER
        primary key,
    Z_ENT             INTEGER,
    Z_OPT             INTEGER,
    ZISCHINA          INTEGER,
    ZISLINK           INTEGER,
    ZPRIVATEFORUM     INTEGER,
    ZSYNCDIRTY        INTEGER,
    ZSYNCMODE         INTEGER,
    ZTOPICFLAGS       INTEGER,
    ZUSNFTS           INTEGER,
    ZUSNPROPERTIES    INTEGER,
    ZDATE             TIMESTAMP,
    ZHISTORYDATE      TIMESTAMP,
    ZLASTVISIT        TIMESTAMP,
    ZAUTHOR           VARCHAR,
    ZBOOKLIST         VARCHAR,
    ZEVERNOTEID       VARCHAR,
    ZEXPORTEVERNOTEID VARCHAR,
    ZFORUMID          VARCHAR,
    ZFORUMOWNER       VARCHAR,
    ZHASHTAGS         VARCHAR,
    ZLOCALBOOKMD5     VARCHAR,
    ZMINDLINKS        VARCHAR,
    ZTAGLIST          VARCHAR,
    ZTITLE            VARCHAR,
    ZTOPICID          VARCHAR,
    ZDELNOTES         BLOB,
    ZTHUMBNAILS       BLOB
);

create index main.Z_Topic_localbookmd5
    on main.ZTOPIC (ZLOCALBOOKMD5);

create index main.Z_Topic_topicid
    on main.ZTOPIC (ZTOPICID);

create table main.ZUSER
(
    Z_PK             INTEGER
        primary key,
    Z_ENT            INTEGER,
    Z_OPT            INTEGER,
    ZEMAILVERIFIED   INTEGER,
    ZHASPROFILE      INTEGER,
    ZTIMESTAMP       TIMESTAMP,
    ZDISPLAYNAME     VARCHAR,
    ZEMAIL           VARCHAR,
    ZFACEBOOKFRIENDS VARCHAR,
    ZFACEBOOKID      VARCHAR,
    ZUSERID          VARCHAR,
    ZUSERNAME        VARCHAR,
    ZPROFILEMEDIUM   BLOB,
    ZPROFILESMALL    BLOB
);

create table main.Z_METADATA
(
    Z_VERSION INTEGER
        primary key,
    Z_UUID    VARCHAR(255),
    Z_PLIST   BLOB
);

create table main.Z_MODELCACHE
(
    Z_CONTENT BLOB
);

create table main.Z_PRIMARYKEY
(
    Z_ENT   INTEGER
        primary key,
    Z_NAME  VARCHAR,
    Z_SUPER INTEGER,
    Z_MAX   INTEGER
);
