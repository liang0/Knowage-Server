--- START ---
ALTER TABLE SBI_I18N_MESSAGES RENAME TO SBI_I18N_MESSAGES_OLD;

CREATE TABLE SBI_I18N_MESSAGES AS 
SELECT ROW_NUMBER() OVER() AS ID, T.*
FROM SBI_I18N_MESSAGES_OLD T;

DROP TABLE SBI_I18N_MESSAGES_OLD;

ALTER TABLE SBI_I18N_MESSAGES ADD CONSTRAINT PK_SBI_I18N_MESSAGES PRIMARY KEY (ID);
ALTER TABLE SBI_I18N_MESSAGES ADD CONSTRAINT FK_SBI_I18N_MESSAGES FOREIGN KEY (LANGUAGE_CD) REFERENCES SBI_DOMAINS (VALUE_ID);
ALTER TABLE SBI_I18N_MESSAGES ADD CONSTRAINT SBI_I18N_MESSAGES_UNIQUE UNIQUE (LANGUAGE_CD, LABEL, ORGANIZATION);

INSERT INTO hibernate_sequences VALUES ('SBI_I18N_MESSAGES',
                                                            (SELECT COALESCE(MAX(m.ID) + 1, 1) FROM SBI_I18N_MESSAGES m));
COMMIT;                                                         
--- END ---

ALTER TABLE SBI_DATA_SET ADD CONSTRAINT XAK2SBI_DATA_SET UNIQUE (NAME, VERSION_NUM, ORGANIZATION);

ALTER TABLE SBI_ATTRIBUTE ADD COLUMN (LOV_ID INTEGER NULL,ALLOW_USER SMALLINT DEFAULT '1',MULTIVALUE SMALLINT DEFAULT '0',SYNTAX SMALLINT NULL,
									  VALUE_TYPE_ID INTEGER NULL, VALUE_TYPE_CD VARCHAR(20), VALUE_TYPE VARCHAR(50));
ALTER TABLE SBI_ATTRIBUTE ADD CONSTRAINT FK_LOV FOREIGN KEY (LOV_ID) REFERENCES SBI_LOV(LOV_ID);
ALTER TABLE SBI_ATTRIBUTE ADD CONSTRAINT ENUM_TYPE CHECK (VALUE_TYPE IN('STRING','DATE','NUM');

ALTER TABLE SBI_ATTRIBUTE ALTER COLUMN DESCRIPTION VARCHAR(500) NULL;

ALTER TABLE SBI_EVENTS_LOG ADD COLUMN EVENT_TYPE VARCHAR(50) DEFAULT 'SCHEDULER' NOT NULL;

UPDATE SBI_EVENTS_LOG SET EVENT_TYPE = (
CASE HANDLER 
	WHEN 'it.eng.spagobi.events.handlers.DefaultEventPresentationHandler' THEN 'SCHEDULER'
	WHEN 'it.eng.spagobi.events.handlers.CommonjEventPresentationHandler' THEN 'COMMONJ'
	WHEN 'it.eng.spagobi.events.handlers.TalendEventPresentationHandler' THEN 'ETL'
	WHEN 'it.eng.spagobi.events.handlers.WekaEventPresentationHandler' THEN 'DATA_MINING'
END
);
commit;

ALTER TABLE SBI_EVENTS_LOG DROP COLUMN HANDLER;

ALTER TABLE SBI_OUTPUT_PARAMETER ALTER COLUMN FORMAT_VALUE VARCHAR(30);

CREATE TABLE SBI_METAMODEL_PAR (
       METAMODEL_PAR_ID           INTEGER NOT NULL ,
       PAR_ID               INTEGER NOT NULL,
       METAMODEL_ID             INTEGER NOT NULL,
       LABEL                VARCHAR(40) NOT NULL,
       REQ_FL               SMALLINT NULL,
       MOD_FL               SMALLINT NULL,
       VIEW_FL              SMALLINT NULL,
       MULT_FL              SMALLINT NULL,
       PROG                 INTEGER NOT NULL,
       PARURL_NM            VARCHAR(20) NULL,
       PRIORITY             INTEGER NULL,
       COL_SPAN             INTEGER NULL DEFAULT 1,
       THICK_PERC           INTEGER NULL DEFAULT 0,
       USER_IN              VARCHAR(100) NOT NULL,
       USER_UP              VARCHAR(100),
       USER_DE              VARCHAR(100),
       TIME_IN              TIMESTAMP NOT NULL,
       TIME_UP              TIMESTAMP NULL DEFAULT NULL,
       TIME_DE              TIMESTAMP NULL DEFAULT NULL,
       SBI_VERSION_IN       VARCHAR(10),
       SBI_VERSION_UP       VARCHAR(10),
       SBI_VERSION_DE       VARCHAR(10),
       META_VERSION         VARCHAR(100),
       ORGANIZATION         VARCHAR(20),     
       PRIMARY KEY (METAMODEL_PAR_ID)
) 

ALTER TABLE SBI_METAMODEL_PAR 					ADD CONSTRAINT FK_METAMODEL_PAR_1 					FOREIGN KEY (METAMODEL_ID) 				REFERENCES SBI_META_MODELS (ID);	
ALTER TABLE SBI_METAMODEL_PAR 					ADD CONSTRAINT FK_METAMODEL_PAR_2 					FOREIGN KEY (PAR_ID) 				REFERENCES SBI_PARAMETERS (PAR_ID);

CREATE TABLE SBI_METAMODEL_PARUSE (
		PARUSE_ID			INTEGER NOT NULL,
		METAMODEL_PAR_ID         INTEGER NOT NULL,
		USE_ID              INTEGER NOT NULL,
		METAMODEL_PAR_FATHER_ID   INTEGER NOT NULL,
		FILTER_OPERATION    VARCHAR(20) NOT NULL,
		PROG 				INTEGER NOT NULL,
		FILTER_COLUMN       VARCHAR(30) NOT NULL,
		PRE_CONDITION 		VARCHAR(10),
	    POST_CONDITION 		VARCHAR(10),
	    LOGIC_OPERATOR 		VARCHAR(10),
        USER_IN             VARCHAR(100) NOT NULL,
        USER_UP             VARCHAR(100),
        USER_DE             VARCHAR(100),
        TIME_IN             TIMESTAMP NOT NULL,
        TIME_UP             TIMESTAMP NULL DEFAULT NULL,
        TIME_DE             TIMESTAMP NULL DEFAULT NULL,
        SBI_VERSION_IN      VARCHAR(10),
        SBI_VERSION_UP      VARCHAR(10),
        SBI_VERSION_DE      VARCHAR(10),
        META_VERSION        VARCHAR(100),
        ORGANIZATION        VARCHAR(20),    
	    PRIMARY KEY(PARUSE_ID)
)

ALTER TABLE SBI_METAMODEL_PARUSE					ADD CONSTRAINT FK_SBI_METAMODEL_PARUSE_1 					FOREIGN KEY (METAMODEL_PAR_ID) 			REFERENCES SBI_METAMODEL_PAR (METAMODEL_PAR_ID) 	ON DELETE RESTRICT;
ALTER TABLE SBI_METAMODEL_PARUSE 					ADD CONSTRAINT FK_SBI_METAMODEL_PARUSE_2 					FOREIGN KEY (USE_ID) 				REFERENCES SBI_PARUSE (USE_ID) 			ON DELETE RESTRICT;
ALTER TABLE SBI_METAMODEL_PARUSE 					ADD CONSTRAINT FK_SBI_METAMODEL_PARUSE_3 					FOREIGN KEY (METAMODEL_PAR_FATHER_ID)		REFERENCES SBI_METAMODEL_PAR (METAMODEL_PAR_ID) 	ON DELETE RESTRICT;

CREATE TABLE SBI_METAMODEL_PARVIEW (
	PARVIEW_ID 			INTEGER NOT NULL,	
    METAMODEL_PAR_ID 	INTEGER NOT NULL,
    METAMODEL_PAR_FATHER_ID  INTEGER NOT NULL,
    OPERATION  			VARCHAR(20) NOT NULL,
    COMPARE_VALUE  		VARCHAR(200) NOT NULL,
    VIEW_LABEL  		VARCHAR(50),
    PROG INTEGER,
       USER_IN              VARCHAR(100) NOT NULL,
       USER_UP              VARCHAR(100),
       USER_DE              VARCHAR(100),
       TIME_IN              TIMESTAMP NOT NULL,
       TIME_UP              TIMESTAMP NULL DEFAULT NULL,
       TIME_DE              TIMESTAMP NULL DEFAULT NULL,
       SBI_VERSION_IN       VARCHAR(10),
       SBI_VERSION_UP       VARCHAR(10),
       SBI_VERSION_DE       VARCHAR(10),
       META_VERSION         VARCHAR(100),
       ORGANIZATION         VARCHAR(20),    
  PRIMARY KEY (PARVIEW_ID)
)

ALTER TABLE SBI_METAMODEL_PARVIEW 				ADD CONSTRAINT FK_SBI_METAMODEL_PARVIEW_1 				FOREIGN KEY (METAMODEL_PAR_ID) 			REFERENCES SBI_METAMODEL_PAR (METAMODEL_PAR_ID) 	ON DELETE RESTRICT;
ALTER TABLE SBI_METAMODEL_PARVIEW 				ADD CONSTRAINT FK_SBI_METAMODEL_PARVIEW_2 				FOREIGN KEY (METAMODEL_PAR_FATHER_ID)		REFERENCES SBI_METAMODEL_PAR (METAMODEL_PAR_ID) 	ON DELETE RESTRICT;

---END---

ALTER TABLE SBI_METAMODEL_PAR 
CHANGE COLUMN REQ_FL SMALLINT SET DEFAULT '0' ,
CHANGE COLUMN MOD_FL SMALLINT SET DEFAULT '0' ,
CHANGE COLUMN VIEW_FL SMALLINT SET DEFAULT '1' ,
CHANGE COLUMN MULT_FL SMALLINT SET DEFAULT '0' ;

ALTER TABLE SBI_OBJ_PAR 
CHANGE COLUMN REQ_FL SMALLINT SET DEFAULT '0' ,
CHANGE COLUMN MOD_FL SMALLINT SET DEFAULT '0' ,
CHANGE COLUMN VIEW_FL SMALLINT SET DEFAULT '1' ,
CHANGE COLUMN MULT_FL SMALLINT SET DEFAULT '0' ;



---END---


--- START ---

ALTER TABLE SBI_FEDERATION_DEFINITION ADD COLUMN OWNER VARCHAR(100) NULL AFTER DEGENERATED;

---END---

DELETE FROM SBI_ROLE_TYPE_USER_FUNC WHERE ROLE_TYPE_ID = (SELECT VALUE_ID FROM SBI_DOMAINS WHERE VALUE_CD = 'TEST_ROLE') AND USER_FUNCT_ID IN (SELECT USER_FUNCT_ID FROM SBI_USER_FUNC  WHERE  NAME IN ('TIMESPAN', 'FUNCTIONSCATALOGMANAGEMENT','MANAGECROSSNAVIGATION','EVENTSMANAGEMENT'));
COMMIT;