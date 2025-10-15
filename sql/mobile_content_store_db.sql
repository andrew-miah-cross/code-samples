-- 2010. Andrew M. Cross (andrew.miah.cross@gmail.com)

DROP DATABASE mobile_content_store_db;
CREATE DATABASE mobile_content_store_db;
USE mobile_content_store_db;

-- Sessions

CREATE TABLE tomcat_session_admin_t 
(
  sessionId     				VARCHAR(100) NOT NULL PRIMARY KEY,
  validSession  				CHAR(1) NOT NULL,
  maxInactive   				INT NOT NULL,
  lastAccess    				BIGINT NOT NULL,
  appName						VARCHAR(255),
  sessionData					mediumblob,
  KEY 							kappName(appName)
) ENGINE=INNODB;

CREATE TABLE tomcat_session_mclient_t 
(
  sessionId     				VARCHAR(100) NOT NULL PRIMARY KEY,
  validSession  				CHAR(1) NOT NULL,
  maxInactive   				INT NOT NULL,
  lastAccess    				BIGINT NOT NULL,
  appName						VARCHAR(255),
  sessionData					mediumblob,
  KEY 							kappName(appName)
) ENGINE=INNODB;

CREATE TABLE tomcat_session_store_t 
(
  sessionId     				VARCHAR(100) NOT NULL PRIMARY KEY,
  validSession  				CHAR(1) NOT NULL,
  maxInactive   				INT NOT NULL,
  lastAccess    				BIGINT NOT NULL,
  appName						VARCHAR(255),
  sessionData					mediumblob,
  KEY 							kappName(appName)
) ENGINE=INNODB;



-- Application
CREATE TABLE application_state_t 
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	databaseInitialized 		BOOLEAN,
	webDeliveryExpiryMinutes	INT,
	mobileClientStoreFrontType	VARCHAR(255),
	mobileClientTheme			VARCHAR(255)
) ENGINE=INNODB;


CREATE TABLE application_locale_t 
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	locale_id					BIGINT NOT NULL
) ENGINE=INNODB;


-- Caching
CREATE TABLE memcached_pool_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	ipAddress					VARCHAR(128),
	lastUp						DATETIME
) ENGINE=INNODB;

-- Mobile Client.

CREATE TABLE mclient_theme_t 
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	ref							VARCHAR(255),
	CONSTRAINT UNIQUE KEY		( ref ) 		
) ENGINE=INNODB;

CREATE TABLE mclient_theme__locale_t 
(
	mclient_theme_id			BIGINT,
	locale_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE mclient_session_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	sessionId					VARCHAR(255),
	loginTime					DATETIME,
	lastAccessedTime			DATETIME,
	authenticated				BOOLEAN,
	customer_id					BIGINT
) ENGINE=INNODB;


-- Localization and Resources

CREATE TABLE locale_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	language					CHAR(2),
	country						CHAR(2),
 	UNIQUE INDEX				( language,country )
) ENGINE=INNODB;

CREATE TABLE region_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	region						VARCHAR(64),
	INDEX						( region )
) ENGINE=INNODB;

CREATE TABLE currency_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nameGB						VARCHAR(32) NOT NULL,
	nameRef						VARCHAR(255) NOT NULL,
	INDEX 						colloquial_name( nameGB )
) ENGINE=INNODB;

CREATE TABLE region__region_composite_relation_t
(
	macro_region_id				BIGINT,
	micro_region_id				BIGINT
) ENGINE=INNODB;


-- Resources

CREATE TABLE textresource_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	deletedAt					DATETIME,
	ref							VARCHAR(255) NOT NULL,
	language					CHAR(2),
	country						CHAR(2),
	text						TEXT,
	INDEX						( ref ),
	INDEX						( ref,language ),
	INDEX						( ref,language,country,deletedAt ),
	UNIQUE INDEX				( deletedAt,ref,language,country )
) ENGINE=INNODB;

CREATE TABLE bitmapresource_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	deletedAt					DATETIME,
	ref							VARCHAR(255) NOT NULL,
	language					CHAR(2),
	country						CHAR(2),
	mimeType					VARCHAR(32),
	width						INT,
	height						INT,
	imageData					MEDIUMBLOB,
	INDEX						( ref ),
	INDEX						( ref,language ),
--	INDEX						( ref,language,country ),
	UNIQUE INDEX				( deletedAt,ref,language,country )
--	UNIQUE INDEX				( ref,width,height,language,country )
) ENGINE=INNODB;

CREATE TABLE binaryresource_t
(
	id 							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	deletedAt					DATETIME,
	ref							VARCHAR(255) NOT NULL,
	language					CHAR(2),
	country						CHAR(2),
	mimeType					VARCHAR(32),
	data						MEDIUMBLOB,
	INDEX						( ref ),
	INDEX						( ref,language ),
	UNIQUE INDEX				( deletedAt,ref,language,country )
) ENGINE=INNODB;


-- Vendors

CREATE TABLE vendor_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						VARCHAR(255),
	postalAddress				VARCHAR(255),
	contactNumber				VARCHAR(32),
	currency_id					BIGINT,
	taxCountry					CHAR(2),
	language					CHAR(2),
	country						CHAR(2),
	timezone					VARCHAR(64),
	deliverOriginalFilename		BOOLEAN,
	supportEmailAddress			VARCHAR(255),
	INDEX						( currency_id ),
	UNIQUE INDEX                ( name )
) ENGINE=INNODB;

CREATE TABLE vendor__product_t
(
	vendor_id					BIGINT,
	product_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE vendor_session_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	sessionId					VARCHAR(255),
	loginTime					DATETIME,
	lastAccessedTime			DATETIME,
	user_id						BIGINT,
	authenticated				BOOLEAN,
	language					CHAR(2),
	country						CHAR(2),
	INDEX						( user_id )
) ENGINE=INNODB;


CREATE TABLE merchant_account_type_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						ENUM( 'paypal','bank' )
) ENGINE=INNODB;


CREATE TABLE vendor__merchant_account_type_t 
(
	vendor_id							BIGINT,
	merchant_account_type_id			BIGINT
) ENGINE=INNODB;

CREATE TABLE merchant_account_paypal_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	vendor_id					BIGINT,
	emailAddress				VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE merchant_account_bank_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	vendor_id					BIGINT,
	number						TEXT,
	sortCode					TEXT,
	name						TEXT,
	address						TEXT
) ENGINE=INNODB;


CREATE TABLE user_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	vendor_id					BIGINT NOT NULL,
	failedLogins				INT,
	emailVerified				BOOLEAN,
	name						VARCHAR(255),
	emailAddress				VARCHAR(255),
	password					VARCHAR(255),
	dateRegistered				DATETIME,
	dateLastVisited				DATETIME,
	notifyByEmail				BOOLEAN,
	language					VARCHAR(2),
	country						VARCHAR(2),
	userTimezone				VARCHAR(32),
	webserviceKey				CHAR(32),
	active						BOOLEAN,
	invalidKeyRequests			INT,
	INDEX						( name ),
	UNIQUE INDEX				( emailAddress ),
	UNIQUE INDEX 				( webserviceKey ),
	INDEX						( vendor_id )
) ENGINE=INNODB;

CREATE TABLE role_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	role						VARCHAR(255),
	roleRef						VARCHAR(255),
	descriptionRef				VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE user__role_t
(
	user_id						BIGINT,
	role_id						BIGINT,
	INDEX						( user_id ),
	INDEX						( role_id )
) ENGINE=INNODB;

CREATE TABLE vendor__role_t
(
	vendor_id					BIGINT,
	role_id						BIGINT,
	INDEX						( vendor_id ),
	INDEX						( role_id )
) ENGINE=INNODB;

CREATE TABLE vendor__user_t 
(
	vendor_id					BIGINT,
	user_id						BIGINT,
	INDEX						( vendor_id ),
	INDEX						( user_id )
) ENGINE=INNODB;


CREATE TABLE user_event_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id						BIGINT,
	vendor_id					BIGINT,
	product_id					BIGINT,
	product_variant_id			BIGINT,
	product_version_id			BIGINT,
	action	 					TEXT,
	description					TEXT,
	eventDate					DATETIME,
	INDEX						( eventDate ),
	INDEX						( eventDate, product_id ),
	INDEX						( eventDate, product_version_id )
) ENGINE=INNODB;



-- Devices

CREATE TABLE device_t
(
	id							BIGINT AUTO_INCREMENT PRIMARY KEY,
	defaultUaProfile_id			BIGINT,
	oemName						VARCHAR(255),
	modelName					VARCHAR(255),
	releaseDate					DATETIME,
	INDEX						( oemName ),
	UNIQUE INDEX				( oemName,modelName )
) ENGINE=INNODB;

CREATE TABLE uaphrase_t 
(
	id							BIGINT AUTO_INCREMENT PRIMARY KEY,
	phrase						VARCHAR(255),
	UNIQUE INDEX				( phrase )
) ENGINE=INNODB;

CREATE TABLE device__uaphrase_t 
(
	device_id					BIGINT,
	uaphrase_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE mime_type_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	mimeType					VARCHAR(255),
	extension					VARCHAR(16),
	descriptionRef				VARCHAR(255),
	INDEX						( mimeType )
) ENGINE=INNODB;

CREATE TABLE useragent_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	uaprofile_id				BIGINT,
	userAgent					VARCHAR(255),
	device_id					BIGINT,
	inceptDate					DATETIME,
	INDEX						( device_id ),
	UNIQUE INDEX				( userAgent )
) ENGINE=INNODB;


CREATE TABLE uaprofile_t
(
 	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 	url							VARCHAR(255),
	profileXml					TEXT,
	processed					BOOLEAN,
	inceptDate					DATETIME,
	INDEX						( url )
) ENGINE=INNODB;

CREATE TABLE uaprofile_hw_platform_t
(
 	id							BIGINT PRIMARY KEY,
 	vendor						VARCHAR(255),
 	model						VARCHAR(255),
	screensize_w				INT,
	screensize_h				INT,
	bitsPerPixel				INT
) ENGINE=INNODB;

CREATE TABLE uaprofile_streaming_t
(
	id							BIGINT PRIMARY KEY,
	pssVersion					INT,
	width						INT,
	height						INT
) ENGINE=INNODB;

CREATE TABLE uaprofile_streaming_accept_t
(
	id							BIGINT,
	mimeType					VARCHAR(255),
	INDEX						( id,mimeType )
) ENGINE=INNODB;

CREATE TABLE uaprofile_ccpp_accept_t
(
	id							BIGINT,
	mimeType					VARCHAR(255),
	INDEX						( id,mimeType )
) ENGINE=INNODB;

CREATE TABLE uaprofile_retrieval_job_t
(
 	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	uaprofile_id				BIGINT NOT NULL,
	retrieved					BOOLEAN,
	retrievalRetries			INTEGER,
	lastRetrievalAttemptDate	DATETIME,
	UNIQUE INDEX				( uaprofile_id ),
	INDEX						( retrieved,retrievalRetries,lastRetrievalAttemptDate )
) ENGINE=INNODB;

-- Customer 

CREATE TABLE customer_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						VARCHAR(255) NOT NULL,
	username					VARCHAR(255) NOT NULL,
	emailAddress				VARCHAR(255) NOT NULL,
	emailAddressMD5				CHAR(32) NOT NULL,
	emailVerified				BOOLEAN,
	notifyByEmail				BOOLEAN,
	password					VARCHAR(255) NOT NULL,
	salt						VARCHAR(255),
	dateRegistered				DATETIME,
	dateLastVisited				DATETIME,
	blocked						BOOLEAN,
	language					VARCHAR(2),
	country						VARCHAR(2),
	distributionCountry			VARCHAR(2),
	customerTimezone			VARCHAR(255),
	device_id					BIGINT, 
	operator					VARCHAR(255),
	msisdn						VARCHAR(32),
	msisdnVerified				BOOLEAN,
	preferredPaymentMethod_id	BIGINT,
	preferredDeliveryMethod_id	BIGINT,
	promotionCredits 			INTEGER,
	oneFreeUntil				DATETIME,
	currency_id					BIGINT,
	loginFailures				INTEGER,
	UNIQUE INDEX				( emailAddress )
) ENGINE=INNODB;

CREATE TABLE customer__vendor_t
(
	customer_id					BIGINT,
	vendor_id					BIGINT

-- ... Any vendor specific customer data...
	
) ENGINE=INNODB;

CREATE TABLE customer_feedback_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customer_id					BIGINT,
	product_id					BIGINT,
	product_version_id			BIGINT,
	text						BLOB,
	rating						INTEGER,
	bug							BOOLEAN,
	inceptDate					DATETIME
) ENGINE=INNODB;


CREATE TABLE likes_customer__product_variant_t 
(
	customer_id					BIGINT,
	product_variant_id			BIGINT,
	INDEX						(customer_id,product_variant_id)
) ENGINE=INNODB;


CREATE TABLE customer_device_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customer_id					BIGINT,
	device_id					BIGINT,
	msisdn						VARCHAR(32) NOT NULL,
	msisdnVerified				BOOLEAN
) ENGINE=INNODB;

-- Billing

CREATE TABLE payment_method_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						VARCHAR(255),
	nameRef						VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE valid_domain_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE payment_method__valid_domain_t
(
	payment_method_id			BIGINT,
	valid_domain_id				BIGINT
) ENGINE=INNODB;

CREATE TABLE paypal_payment_method_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payment_method_id			BIGINT,
	userId						VARCHAR(255),
	password					VARCHAR(255),
	signature					VARCHAR(255),
	applicationId				VARCHAR(255),
	sandboxEmailAddress			VARCHAR(255)
) ENGINE=INNODB;


CREATE TABLE customer_paypal_payment_method_t
(
	id									BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payment_method_id					BIGINT,
	customer_id							BIGINT,
	active								BOOLEAN,
	emailAddress						VARCHAR(255),
	preApprovalKey						VARCHAR(255),
	preApprovalDeactivationDate			DATETIME,
	preApprovalStart					DATETIME,
	preApprovalEnd						DATETIME,
	preApprovalMaxAmount				FLOAT,
	preApprovalMaxNumberOfPayments		INTEGER,
	preApprovalMaxTotalAmount			FLOAT,
	preApprovalCurrency_id				BIGINT,
	preApprovalPaymentsProcessed		INTEGER,
	preApprovalTotalPaymentTransferred 	FLOAT
) ENGINE=INNODB;

CREATE TABLE delivery_method_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name						VARCHAR(255),
	nameRef						VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE order_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payment_method_external_id	VARCHAR(255),
	product_id					BIGINT NOT NULL,
	product_version_id			BIGINT NOT NULL,
	device_id					BIGINT NOT NULL,
	customer_id					BIGINT NOT NULL,
	payment_method_id			BIGINT NOT NULL,
	delivery_method_id			BIGINT NOT NULL,
	currency_id					BIGINT NOT NULL,
	price						FLOAT,
	purchaseDate				DATETIME,
	state						INT,	
	complete					BOOLEAN,
	demographicProcessed		BOOLEAN,
	INDEX						( customer_id ),
	INDEX						( payment_method_id ),
	INDEX						( delivery_method_id ),
	INDEX						( demographicProcessed,purchaseDate )
) ENGINE=INNODB;


CREATE TABLE webdelivery_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	order_id					BIGINT,
	hash						CHAR(16),
	path						VARCHAR(255),
	validUntil					DATETIME
) ENGINE=INNODB;


CREATE TABLE webdelivery__product_binary_relation_t
(
	webdelivery_id				BIGINT,
	product_binary_id			BIGINT
) ENGINE=INNODB;

CREATE TABLE delivered_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customer_id					BIGINT NOT NULL,
	product_id					BIGINT NOT NULL,
	product_variant_id			BIGINT NOT NULL,
	product_version_id			BIGINT NOT NULL,
	device_id					BIGINT NOT NULL,
	dispatchDate				DATETIME,
	confirmed					BOOLEAN,
	hash						CHAR(16)
) ENGINE=INNODB;

-- Products

CREATE TABLE product_category_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	ref							VARCHAR(255),
	nameRef						VARCHAR( 255 ),
	UNIQUE INDEX				( nameRef ),
	UNIQUE INDEX				( ref )
) ENGINE=INNODB;


CREATE TABLE product_type_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nameRef						VARCHAR(255)
) ENGINE=INNODB;


CREATE TABLE product_type__mime_type_t
(
 	product_type_id				BIGINT,
 	mime_type_id				BIGINT
) ENGINE=INNODB; 

CREATE TABLE product_mime_type_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	product_type_id				BIGINT,
	mime_type_id				BIGINT,
	maxOccurrences				INTEGER,
	maxSizeInBytes				BIGINT
) ENGINE=INNODB;




CREATE TABLE product_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	uniqueHash					CHAR(32),
	code						VARCHAR(255),
	vendor_id					BIGINT NOT NULL,
	active						BOOLEAN,
	nameRef						VARCHAR(255),
	createdDate					DATETIME,
	averageRating				FLOAT,
	supportEmailAddress			VARCHAR(255),
	screenRating				ENUM( 'U','twelvePlus','eighteenPlus' ),
	backfill_frozen				BOOLEAN,
	backfill_freeze_date		DATETIME
) ENGINE=INNODB;

CREATE TABLE product__locale_t 
(
	product_id					BIGINT,
	locale_id					BIGINT,
	INDEX						( product_id,locale_id )
) ENGINE=INNODB;

-- (distribution countries)
CREATE TABLE product__region_t 
(
	product_id					BIGINT,
	region_id					BIGINT,
	INDEX						( product_id,region_id )
) ENGINE=INNODB;

CREATE TABLE product__product_category_t
(
	product_id					BIGINT,
	product_category_id			BIGINT
) ENGINE=INNODB;

CREATE TABLE product_variant_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nameRef						VARCHAR(255),
	active						BOOLEAN,
	activeSubmissionNumber		INT,
	device_taxonomy_id			BIGINT,
	product_id					BIGINT,
	product_type_id				BIGINT,
	inceptDate					DATETIME,
	likes						BIGINT,
	UNIQUE INDEX				( product_id, product_type_id )
) ENGINE=INNODB;

CREATE TABLE price_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	currency_id					BIGINT,
	price						FLOAT,
	INDEX						( price )
) ENGINE=INNODB;

CREATE TABLE product_variant__price_t
(
	product_variant_id			BIGINT,
	price_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE product_version_t
(
	id							BIGINT AUTO_INCREMENT PRIMARY KEY,
	product_id					BIGINT,
	product_variant_id			BIGINT,
	qaStatus					INT,
	submissionNumber			INT,
	versionMajor				FLOAT,
	versionMinor				FLOAT,
	active						BOOLEAN,
	inceptDate					DATETIME,
	INDEX						( active,inceptDate )
) ENGINE=INNODB;

CREATE TABLE product_version__locale_t
(
	product_version_id			BIGINT,
	locale_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE product_binary_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	product_version_id			BIGINT,
	mime_type_id				BIGINT,
	originalFilename			VARCHAR(255),
	body						LONGBLOB,
	UNIQUE 					 	( product_version_id,mime_type_id,originalFilename )
) ENGINE=INNODB;

CREATE TABLE product_search_index_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	textresource_id				BIGINT,
	language					CHAR(2),
	country						CHAR(2),
	product_id					BIGINT,
	word						VARCHAR(64),
	INDEX						( word )
) ENGINE=INNODB;

CREATE TABLE qa_tracking_t 
(	
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id						BIGINT,
	product_id					BIGINT,
	product_version_id			BIGINT,
	modificationDate			DATETIME,
	qaStatus					INT,
	INDEX						( product_id,qaStatus,modificationDate ),
	INDEX						( product_version_id,qaStatus,modificationDate ),
	INDEX						( user_id,qaStatus,modificationDate )
) ENGINE=INNODB;

CREATE TABLE product__user_listeners_t
(
	product_id					BIGINT,
	user_id						BIGINT
) ENGINE=INNODB;


-- Device Taxonomy

CREATE TABLE device_taxonomy_t
(
	id							BIGINT AUTO_INCREMENT PRIMARY KEY,
	vendor_id					BIGINT,
	product_type_id				BIGINT,
	nameRef						VARCHAR(255),
	shared						BOOLEAN
) ENGINE=INNODB;

CREATE TABLE device_class_t
(
	id							BIGINT AUTO_INCREMENT PRIMARY KEY,
	nameRef						VARCHAR(255),
	device_taxonomy_id			BIGINT,
	UNIQUE INDEX				(device_taxonomy_id,nameRef)
) ENGINE=INNODB;

CREATE TABLE device_class__device_t 
(
	device_class_id				BIGINT,
	device_id					BIGINT
) ENGINE=INNODB;

CREATE TABLE product_version_relation_t 
(
	product_version_id			BIGINT,
	device_id					BIGINT,
	device_class_id				BIGINT
) ENGINE=INNODB;


-- Promotions

CREATE TABLE promotion_type_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nameRef						VARCHAR(255),
	ref							VARCHAR(255)
) ENGINE=INNODB;

CREATE TABLE promotion_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nameRef						VARCHAR(255),
	descriptionRef				VARCHAR(255),
	promotion_type_id			BIGINT,
	active						BOOLEAN,
	gpsLatitude					FLOAT,
	gpsLongitude				FLOAT,
	gpsRadius					FLOAT,
	startDate					DATETIME,
	endDate						DATETIME,
	rank						INTEGER
) ENGINE=INNODB;

CREATE TABLE promotion__product_t
(
	promotion_id				BIGINT,
	product_id					BIGINT
) ENGINE=INNODB;


-- Demographics

CREATE TABLE demographic_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	hashedProductIds			CHAR(32),
	product_id					BIGINT,
	size						INTEGER,
	lastUpdated					DATETIME,
	INDEX						( hashedProductIds,product_id )
) ENGINE=INNODB;

CREATE TABLE customer_category_demographic_state_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customer_id					BIGINT,
	category_id					BIGINT,
	hash						CHAR(32),
	UNIQUE INDEX				( customer_id,category_id )
) ENGINE=INNODB;


-- eMail

CREATE TABLE queued_email_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	inceptDate					DATETIME,
	email_id					BIGINT NOT NULL,
	INDEX						( inceptDate )
) ENGINE=INNODB;

CREATE TABLE email_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	messageHashId				VARCHAR(32),
	deliveryStatus				ENUM('unsent','sent','undeliverable','bounced'),
	errorMessage				TEXT,
	vendor_id					BIGINT,		-- NOT NULL,
	destinationType				ENUM('user', 'customer' ),		
	user_id						BIGINT,
	customer_id					BIGINT,
	inceptDate					DATETIME,
	language					CHAR(2),
	country						CHAR(2),
	contentType					VARCHAR(255),
	senderEmailAddress			VARCHAR(255),
	senderName					VARCHAR(255),
	recipientEmailAddress		VARCHAR(255),
	recipientName				VARCHAR(255),
	subject						VARCHAR(255),
	body						TEXT,
	INDEX 						( deliveryStatus,inceptDate ),
	INDEX						( user_id,inceptDate ),
	INDEX						( customer_id,inceptDate )
) ENGINE=INNODB;

CREATE TABLE email_attachment_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	email_id					BIGINT NOT NULL,
	filename					VARCHAR(255),
	mimeType					VARCHAR(255),
	data						LONGBLOB
) ENGINE=INNODB;




-- Reporting

CREATE TABLE report_type_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	type						ENUM('productStatus','fiscal')
) ENGINE=INNODB;

INSERT INTO report_type_t VALUES ( NULL, 'productStatus' );
INSERT INTO report_type_t VALUES ( NULL, 'fiscal' );

CREATE TABLE report_subscription_t
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id						BIGINT,
	report_type_id				BIGINT,
	frequency					ENUM('asap','hourly','daily','weekly','monthly','annually')	
) ENGINE=INNODB;

-- Scheduled Imports

CREATE TABLE product_import_job_t 
(
	id							BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id						BIGINT,
	inceptDate					DATETIME,
	zipArchiveFilename			TEXT,
	deleteAfterwards			BOOLEAN,
	summary						TEXT,
	status						ENUM('waiting','done','failed'),
	schedule					ENUM('asap','nextDay')
) ENGINE=INNODB;

-- Constraints

ALTER TABLE customer_device_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t ( id ) ON DELETE SET NULL;
ALTER TABLE customer_device_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;

ALTER TABLE textresource_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );
ALTER TABLE bitmapresource_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );
ALTER TABLE binaryresource_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );
ALTER TABLE vendor_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );
ALTER TABLE user_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );


ALTER TABLE currency_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t( ref );

ALTER TABLE customer_paypal_payment_method_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE customer_paypal_payment_method_t ADD CONSTRAINT FOREIGN KEY ( payment_method_id ) REFERENCES payment_method_t ( id ) ON DELETE CASCADE;
ALTER TABLE customer_paypal_payment_method_t ADD CONSTRAINT FOREIGN KEY ( preApprovalCurrency_id ) REFERENCES currency_t ( id );

ALTER TABLE customer__vendor_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE customer__vendor_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;

ALTER TABLE customer_feedback_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE customer_feedback_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;
ALTER TABLE customer_feedback_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t( id ) ON DELETE CASCADE;

ALTER TABLE customer_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t ( id ) ON DELETE SET NULL;
ALTER TABLE customer_t ADD CONSTRAINT FOREIGN KEY ( preferredDeliveryMethod_id ) REFERENCES delivery_method_t(id) ON DELETE SET NULL;
ALTER TABLE customer_t ADD CONSTRAINT FOREIGN KEY ( preferredPaymentMethod_id ) REFERENCES payment_method_t(id) ON DELETE SET NULL;
ALTER TABLE customer_t ADD CONSTRAINT FOREIGN KEY ( currency_id ) REFERENCES currency_t(id) ON DELETE SET NULL;
ALTER TABLE customer_t ADD CONSTRAINT FOREIGN KEY ( language,country ) REFERENCES locale_t ( language,country );

ALTER TABLE customer_category_demographic_state_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t(id) ON DELETE CASCADE;
ALTER TABLE customer_category_demographic_state_t ADD CONSTRAINT FOREIGN KEY ( category_id ) REFERENCES product_category_t(id) ON DELETE CASCADE;

ALTER TABLE delivery_method_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t ( ref );

ALTER TABLE delivered_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE delivered_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;
ALTER TABLE delivered_t ADD CONSTRAINT FOREIGN KEY ( product_variant_id ) REFERENCES product_variant_t ( id );
ALTER TABLE delivered_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t ( id );

ALTER TABLE demographic_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;

ALTER TABLE device_t ADD FOREIGN KEY ( defaultUaProfile_id ) REFERENCES uaprofile_t(id);

ALTER TABLE device_class_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);
ALTER TABLE device_class_t ADD CONSTRAINT FOREIGN KEY ( device_taxonomy_id ) REFERENCES device_taxonomy_t(id);

ALTER TABLE device_class__device_t ADD CONSTRAINT FOREIGN KEY ( device_class_id ) REFERENCES device_class_t(id) ON DELETE CASCADE;
ALTER TABLE device_class__device_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t(id) ON DELETE CASCADE;

ALTER TABLE device_taxonomy_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t(id) ON DELETE CASCADE;
ALTER TABLE device_taxonomy_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);
ALTER TABLE device_taxonomy_t ADD CONSTRAINT FOREIGN KEY ( product_type_id ) REFERENCES product_type_t (id) ON DELETE SET NULL; 

ALTER TABLE device__uaphrase_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t( id ) ON DELETE CASCADE;
ALTER TABLE device__uaphrase_t ADD CONSTRAINT FOREIGN KEY ( uaphrase_id ) REFERENCES uaphrase_t( id ) ON DELETE CASCADE;

ALTER TABLE likes_customer__product_variant_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t( id );
ALTER TABLE likes_customer__product_variant_t ADD CONSTRAINT FOREIGN KEY ( product_variant_id ) REFERENCES product_variant_t( id );

ALTER TABLE queued_email_t ADD CONSTRAINT FOREIGN KEY ( email_id ) REFERENCES email_t ( id );
ALTER TABLE email_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;
ALTER TABLE email_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t ( id ) ON DELETE CASCADE;
ALTER TABLE email_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE email_attachment_t ADD CONSTRAINT FOREIGN KEY ( email_id ) REFERENCES email_t ( id ) ON DELETE CASCADE;

ALTER TABLE merchant_account_bank_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;
ALTER TABLE merchant_account_paypal_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;

ALTER TABLE mime_type_t ADD CONSTRAINT FOREIGN KEY ( descriptionRef ) REFERENCES textresource_t ( ref ); 

ALTER TABLE mclient_session_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;

ALTER TABLE mclient_theme__locale_t ADD CONSTRAINT FOREIGN KEY ( mclient_theme_id ) REFERENCES mclient_theme_t ( id ) ON DELETE CASCADE;
ALTER TABLE mclient_theme__locale_t ADD CONSTRAINT FOREIGN KEY ( locale_id ) REFERENCES locale_t ( id ) ON DELETE CASCADE;  

ALTER TABLE order_t ADD CONSTRAINT FOREIGN KEY ( customer_id ) REFERENCES customer_t ( id ) ON DELETE CASCADE;
ALTER TABLE order_t ADD CONSTRAINT FOREIGN KEY ( delivery_method_id ) REFERENCES delivery_method_t ( id ) ON DELETE RESTRICT;
ALTER TABLE order_t ADD CONSTRAINT FOREIGN KEY ( payment_method_id ) REFERENCES payment_method_t ( id ) ON DELETE RESTRICT;
ALTER TABLE order_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t ( id ) ON DELETE RESTRICT;

ALTER TABLE payment_method_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t ( ref );

ALTER TABLE payment_method__valid_domain_t ADD CONSTRAINT FOREIGN KEY ( payment_method_id ) REFERENCES payment_method_t(id) ON DELETE CASCADE;
ALTER TABLE payment_method__valid_domain_t ADD CONSTRAINT FOREIGN KEY ( valid_domain_id ) REFERENCES valid_domain_t(id) ON DELETE CASCADE;

ALTER TABLE paypal_payment_method_t ADD CONSTRAINT	FOREIGN KEY ( payment_method_id ) REFERENCES payment_method_t ( id ) ON DELETE CASCADE;	

ALTER TABLE price_t ADD CONSTRAINT FOREIGN KEY ( currency_id ) REFERENCES currency_t ( id ) ON DELETE CASCADE;

ALTER TABLE product_mime_type_t ADD CONSTRAINT FOREIGN KEY ( mime_type_id ) REFERENCES mime_type_t( id ) ON DELETE CASCADE;

ALTER TABLE product_type__mime_type_t ADD CONSTRAINT FOREIGN KEY ( mime_type_id ) REFERENCES mime_type_t(id);
ALTER TABLE product_type__mime_type_t ADD CONSTRAINT FOREIGN KEY ( product_type_id ) REFERENCES product_type_t(id) ON DELETE CASCADE;

ALTER TABLE product__product_category_t ADD CONSTRAINT FOREIGN KEY ( product_category_id ) REFERENCES product_category_t(id) ON DELETE CASCADE;
ALTER TABLE product__product_category_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;

ALTER TABLE product_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t(id) ON DELETE CASCADE;
ALTER TABLE product_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);

ALTER TABLE product_type_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);

ALTER TABLE product_binary_t ADD CONSTRAINT FOREIGN KEY ( mime_type_id ) REFERENCES mime_type_t(id);
ALTER TABLE product_binary_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t(id) ON DELETE CASCADE;

ALTER TABLE product_search_index_t ADD CONSTRAINT FOREIGN KEY ( textresource_id ) REFERENCES textresource_t(id) ON DELETE CASCADE;
ALTER TABLE product_search_index_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;

ALTER TABLE product__region_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;
ALTER TABLE product__region_t ADD CONSTRAINT FOREIGN KEY ( region_id ) REFERENCES region_t ( id ) ON DELETE CASCADE;

ALTER TABLE product__locale_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;
ALTER TABLE product__locale_t ADD CONSTRAINT FOREIGN KEY ( locale_id ) REFERENCES locale_t ( id );

ALTER TABLE product_mime_type_t ADD CONSTRAINT FOREIGN KEY ( product_type_id ) REFERENCES product_type_t( id ) ON DELETE CASCADE;

ALTER TABLE product__user_listeners_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;
ALTER TABLE product__user_listeners_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t(id) ON DELETE CASCADE;

ALTER TABLE product_variant_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;
ALTER TABLE product_variant_t ADD CONSTRAINT FOREIGN KEY ( product_type_id ) REFERENCES product_type_t(id) ON DELETE CASCADE;
ALTER TABLE product_variant_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);

ALTER TABLE product_version_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;
ALTER TABLE product_version_t ADD CONSTRAINT FOREIGN KEY ( product_variant_id ) REFERENCES product_variant_t(id) ON DELETE CASCADE;

ALTER TABLE product_version__locale_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t ( id ) ON DELETE CASCADE;
ALTER TABLE product_version__locale_t ADD CONSTRAINT FOREIGN KEY ( locale_id ) REFERENCES locale_t ( id ) ON DELETE CASCADE;

ALTER TABLE product_variant__price_t ADD CONSTRAINT FOREIGN KEY ( product_variant_id ) REFERENCES product_variant_t(id) ON DELETE CASCADE;
ALTER TABLE product_variant__price_t ADD CONSTRAINT FOREIGN KEY ( price_id ) REFERENCES price_t(id) ON DELETE CASCADE;

ALTER TABLE product_version_relation_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t(id) ON DELETE CASCADE;
ALTER TABLE product_version_relation_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t(id)	ON DELETE CASCADE;
ALTER TABLE product_version_relation_t ADD CONSTRAINT FOREIGN KEY ( device_class_id ) REFERENCES device_class_t(id) ON DELETE CASCADE;

ALTER TABLE promotion_type_t ADD CONSTRAINT FOREIGN KEY ( nameRef ) REFERENCES textresource_t(ref);

ALTER TABLE promotion_t ADD CONSTRAINT FOREIGN KEY ( promotion_type_id ) REFERENCES promotion_type_t(id) ON DELETE CASCADE;

ALTER TABLE promotion__product_t ADD CONSTRAINT FOREIGN KEY ( promotion_id ) REFERENCES promotion_t(id) ON DELETE CASCADE;
ALTER TABLE promotion__product_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;

ALTER TABLE qa_tracking_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t ( id ) ON DELETE SET NULL;
ALTER TABLE qa_tracking_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t ( id ) ON DELETE CASCADE;
ALTER TABLE qa_tracking_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t ( id ) ON DELETE CASCADE;

ALTER TABLE region__region_composite_relation_t ADD CONSTRAINT FOREIGN KEY ( micro_region_id ) REFERENCES region_t( id );
ALTER TABLE region__region_composite_relation_t ADD CONSTRAINT FOREIGN KEY ( macro_region_id ) REFERENCES region_t( id );

ALTER TABLE report_subscription_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t( id ) ON DELETE CASCADE;
ALTER TABLE report_subscription_t ADD CONSTRAINT FOREIGN KEY ( report_type_id ) REFERENCES report_type_t( id ) ON DELETE CASCADE;

ALTER TABLE role_t ADD CONSTRAINT FOREIGN KEY ( roleRef ) REFERENCES textresource_t ( ref );
ALTER TABLE role_t ADD CONSTRAINT FOREIGN KEY ( descriptionRef ) REFERENCES textresource_t ( ref );

ALTER TABLE user__role_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t ( id ) ON DELETE CASCADE;
ALTER TABLE user__role_t ADD CONSTRAINT	FOREIGN KEY ( role_id ) REFERENCES role_t ( id ) ON DELETE CASCADE;	

ALTER TABLE user_event_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t(id) ON DELETE CASCADE;
ALTER TABLE user_event_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t(id) ON DELETE CASCADE;
ALTER TABLE user_event_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t(id) ON DELETE CASCADE;
ALTER TABLE user_event_t ADD CONSTRAINT FOREIGN KEY ( product_variant_id ) REFERENCES product_variant_t(id) ON DELETE CASCADE;
ALTER TABLE user_event_t ADD CONSTRAINT FOREIGN KEY ( product_version_id ) REFERENCES product_version_t(id) ON DELETE CASCADE;

ALTER TABLE user_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;

ALTER TABLE useragent_t ADD CONSTRAINT FOREIGN KEY ( device_id ) REFERENCES device_t ( id ) ON DELETE CASCADE;
ALTER TABLE useragent_t ADD CONSTRAINT FOREIGN KEY ( uaprofile_id ) REFERENCES uaprofile_t ( id ) ON DELETE SET NULL;

ALTER TABLE uaprofile_retrieval_job_t ADD CONSTRAINT FOREIGN KEY ( uaprofile_id ) REFERENCES uaprofile_t(id) ON DELETE CASCADE;

ALTER TABLE uaprofile_hw_platform_t 		ADD CONSTRAINT FOREIGN KEY ( id ) REFERENCES uaprofile_t( id ) ON DELETE CASCADE;
ALTER TABLE uaprofile_streaming_t 			ADD CONSTRAINT FOREIGN KEY ( id ) REFERENCES uaprofile_t( id ) ON DELETE CASCADE;
ALTER TABLE uaprofile_streaming_accept_t 	ADD CONSTRAINT FOREIGN KEY ( id ) REFERENCES uaprofile_t( id ) ON DELETE CASCADE;
ALTER TABLE uaprofile_ccpp_accept_t   		ADD CONSTRAINT FOREIGN KEY ( id ) REFERENCES uaprofile_t( id ) ON DELETE CASCADE;

ALTER TABLE vendor__merchant_account_type_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;
ALTER TABLE vendor__merchant_account_type_t 
	ADD CONSTRAINT FOREIGN KEY ( merchant_account_type_id ) REFERENCES merchant_account_type_t ( id ) ON DELETE CASCADE;

ALTER TABLE vendor__role_t ADD CONSTRAINT FOREIGN KEY ( role_id ) REFERENCES role_t ( id ) ON DELETE CASCADE;
ALTER TABLE vendor__role_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;

ALTER TABLE vendor_session_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t(id) ON DELETE CASCADE;

ALTER TABLE vendor__user_t ADD CONSTRAINT FOREIGN KEY ( user_id ) REFERENCES user_t ( id ) ON DELETE CASCADE;
ALTER TABLE vendor__user_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t ( id ) ON DELETE CASCADE;

ALTER TABLE vendor__product_t ADD CONSTRAINT FOREIGN KEY ( vendor_id ) REFERENCES vendor_t( id ) ON DELETE CASCADE;
ALTER TABLE vendor__product_t ADD CONSTRAINT FOREIGN KEY ( product_id ) REFERENCES product_t( id ) ON DELETE CASCADE;  

ALTER TABLE webdelivery_t ADD CONSTRAINT FOREIGN KEY ( order_id ) REFERENCES order_t ( id ) ON DELETE CASCADE;

ALTER TABLE webdelivery__product_binary_relation_t 
	ADD CONSTRAINT FOREIGN KEY ( webdelivery_id ) REFERENCES webdelivery_t ( id ) ON DELETE CASCADE;
ALTER TABLE webdelivery__product_binary_relation_t 
	ADD CONSTRAINT FOREIGN KEY ( product_binary_id ) REFERENCES product_binary_t ( id ) ON DELETE CASCADE;

ALTER TABLE vendor_t ADD CONSTRAINT	FOREIGN KEY ( currency_id ) REFERENCES currency_t ( id ) ON DELETE RESTRICT;


-- LOCALE DATA ----------------------------------------------------------------

INSERT INTO locale_t VALUES ( NULL,"ar","AE" );
INSERT INTO locale_t VALUES ( NULL,"ar","BH" );
INSERT INTO locale_t VALUES ( NULL,"ar","DZ" );
INSERT INTO locale_t VALUES ( NULL,"ar","EG" );
INSERT INTO locale_t VALUES ( NULL,"ar","IQ" );
INSERT INTO locale_t VALUES ( NULL,"ar","JO" );
INSERT INTO locale_t VALUES ( NULL,"ar","KW" );
INSERT INTO locale_t VALUES ( NULL,"ar","LB" );
INSERT INTO locale_t VALUES ( NULL,"ar","LY" );
INSERT INTO locale_t VALUES ( NULL,"ar","MA" );
INSERT INTO locale_t VALUES ( NULL,"ar","OM" );
INSERT INTO locale_t VALUES ( NULL,"ar","QA" );
INSERT INTO locale_t VALUES ( NULL,"ar","SA" );
INSERT INTO locale_t VALUES ( NULL,"ar","SD" );
INSERT INTO locale_t VALUES ( NULL,"ar","SY" );
INSERT INTO locale_t VALUES ( NULL,"ar","TN" );
INSERT INTO locale_t VALUES ( NULL,"ar","YE" );
INSERT INTO locale_t VALUES ( NULL,"be","BY" );
INSERT INTO locale_t VALUES ( NULL,"bg","BG" );
INSERT INTO locale_t VALUES ( NULL,"ca","ES" );
INSERT INTO locale_t VALUES ( NULL,"cs","CZ" );
INSERT INTO locale_t VALUES ( NULL,"da","DK" );
INSERT INTO locale_t VALUES ( NULL,"de","AT" );
INSERT INTO locale_t VALUES ( NULL,"de","CH" );
INSERT INTO locale_t VALUES ( NULL,"de","DE" );
INSERT INTO locale_t VALUES ( NULL,"de","LU" );
INSERT INTO locale_t VALUES ( NULL,"el","CY" );
INSERT INTO locale_t VALUES ( NULL,"el","GR" );
INSERT INTO locale_t VALUES ( NULL,"en","AU" );
INSERT INTO locale_t VALUES ( NULL,"en","CA" );
INSERT INTO locale_t VALUES ( NULL,"en","GB" );
INSERT INTO locale_t VALUES ( NULL,"en","IE" );
INSERT INTO locale_t VALUES ( NULL,"en","IN" );
INSERT INTO locale_t VALUES ( NULL,"en","MT" );
INSERT INTO locale_t VALUES ( NULL,"en","NZ" );
INSERT INTO locale_t VALUES ( NULL,"en","PH" );
INSERT INTO locale_t VALUES ( NULL,"en","SG" );
INSERT INTO locale_t VALUES ( NULL,"en","US" );
INSERT INTO locale_t VALUES ( NULL,"en","ZA" );
INSERT INTO locale_t VALUES ( NULL,"es","AR" );
INSERT INTO locale_t VALUES ( NULL,"es","BO" );
INSERT INTO locale_t VALUES ( NULL,"es","CL" );
INSERT INTO locale_t VALUES ( NULL,"es","CO" );
INSERT INTO locale_t VALUES ( NULL,"es","CR" );
INSERT INTO locale_t VALUES ( NULL,"es","DO" );
INSERT INTO locale_t VALUES ( NULL,"es","EC" );
INSERT INTO locale_t VALUES ( NULL,"es","ES" );
INSERT INTO locale_t VALUES ( NULL,"es","GT" );
INSERT INTO locale_t VALUES ( NULL,"es","HN" );
INSERT INTO locale_t VALUES ( NULL,"es","MX" );
INSERT INTO locale_t VALUES ( NULL,"es","NI" );
INSERT INTO locale_t VALUES ( NULL,"es","PA" );
INSERT INTO locale_t VALUES ( NULL,"es","PE" );
INSERT INTO locale_t VALUES ( NULL,"es","PR" );
INSERT INTO locale_t VALUES ( NULL,"es","PY" );
INSERT INTO locale_t VALUES ( NULL,"es","SV" );
INSERT INTO locale_t VALUES ( NULL,"es","US" );
INSERT INTO locale_t VALUES ( NULL,"es","UY" );
INSERT INTO locale_t VALUES ( NULL,"es","VE" );
INSERT INTO locale_t VALUES ( NULL,"et","EE" );
INSERT INTO locale_t VALUES ( NULL,"fi","FI" );
INSERT INTO locale_t VALUES ( NULL,"fr","BE" );
INSERT INTO locale_t VALUES ( NULL,"fr","CA" );
INSERT INTO locale_t VALUES ( NULL,"fr","CH" );
INSERT INTO locale_t VALUES ( NULL,"fr","FR" );
INSERT INTO locale_t VALUES ( NULL,"fr","LU" );
INSERT INTO locale_t VALUES ( NULL,"ga","IE" );
INSERT INTO locale_t VALUES ( NULL,"hi","IN" );
INSERT INTO locale_t VALUES ( NULL,"hr","HR" );
INSERT INTO locale_t VALUES ( NULL,"hu","HU" );
INSERT INTO locale_t VALUES ( NULL,"in","ID" );
INSERT INTO locale_t VALUES ( NULL,"is","IS" );
INSERT INTO locale_t VALUES ( NULL,"it","CH" );
INSERT INTO locale_t VALUES ( NULL,"it","IT" );
INSERT INTO locale_t VALUES ( NULL,"iw","IL" );
INSERT INTO locale_t VALUES ( NULL,"ja","JP" );
INSERT INTO locale_t VALUES ( NULL,"ko","KR" );
INSERT INTO locale_t VALUES ( NULL,"lt","LT" );
INSERT INTO locale_t VALUES ( NULL,"lv","LV" );
INSERT INTO locale_t VALUES ( NULL,"mk","MK" );
INSERT INTO locale_t VALUES ( NULL,"ms","MY" );
INSERT INTO locale_t VALUES ( NULL,"mt","MT" );
INSERT INTO locale_t VALUES ( NULL,"nl","BE" );
INSERT INTO locale_t VALUES ( NULL,"nl","NL" );
INSERT INTO locale_t VALUES ( NULL,"no","NO" );
INSERT INTO locale_t VALUES ( NULL,"pl","PL" );
INSERT INTO locale_t VALUES ( NULL,"pt","BR" );
INSERT INTO locale_t VALUES ( NULL,"pt","PT" );
INSERT INTO locale_t VALUES ( NULL,"ro","RO" );
INSERT INTO locale_t VALUES ( NULL,"ru","RU" );
INSERT INTO locale_t VALUES ( NULL,"sk","SK" );
INSERT INTO locale_t VALUES ( NULL,"sl","SI" );
INSERT INTO locale_t VALUES ( NULL,"sq","AL" );
INSERT INTO locale_t VALUES ( NULL,"sr","BA" );
INSERT INTO locale_t VALUES ( NULL,"sr","CS" );
INSERT INTO locale_t VALUES ( NULL,"sr","ME" );
INSERT INTO locale_t VALUES ( NULL,"sr","RS" );
INSERT INTO locale_t VALUES ( NULL,"sv","SE" );
INSERT INTO locale_t VALUES ( NULL,"th","TH" );
INSERT INTO locale_t VALUES ( NULL,"tr","TR" );
INSERT INTO locale_t VALUES ( NULL,"uk","UA" );
INSERT INTO locale_t VALUES ( NULL,"vi","VN" );
INSERT INTO locale_t VALUES ( NULL,"zh","CN" );
INSERT INTO locale_t VALUES ( NULL,"zh","HK" );
INSERT INTO locale_t VALUES ( NULL,"zh","SG" );
INSERT INTO locale_t VALUES ( NULL,"zh","TW" );

-- REGION DATA -----------------------------------------------------------------

DELIMITER // 
CREATE FUNCTION getRegionId (s VARCHAR(32)) 
RETURNS BIGINT 
DETERMINISTIC 
READS SQL DATA 
BEGIN 
	DECLARE idResult BIGINT; 
	SELECT id into idResult FROM region_t WHERE region_t.region=s LIMIT 1; 
	RETURN idResult; 
END
// 
DELIMITER ;

INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GLOBAL.name","en","GB","GLOBAL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.APAC.name","en","GB","ASIA PACIFIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AMERICAS.name","en","GB","AMERICAS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LATAM.name","en","GB","LATIN AMERICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NORAM.name","en","GB","NORTH AMERICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EMEA.name","en","GB","EUROPE, MIDDLE EAST & AFRICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EUROPE.name","en","GB","EUROPE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MIDDLE-EAST.name","en","GB","MIDDLE EAST" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AFRICA.name","en","GB","AFRICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AF.name","en","GB","AFGHANISTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AX.name","en","GB","ÅLAND ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AL.name","en","GB","ALBANIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DZ.name","en","GB","ALGERIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AS.name","en","GB","AMERICAN SAMOA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AD.name","en","GB","ANDORRA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AO.name","en","GB","ANGOLA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AI.name","en","GB","ANGUILLA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AQ.name","en","GB","ANTARCTICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AG.name","en","GB","ANTIGUA AND BARBUDA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AR.name","en","GB","ARGENTINA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AM.name","en","GB","ARMENIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AW.name","en","GB","ARUBA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AU.name","en","GB","AUSTRALIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AT.name","en","GB","AUSTRIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AZ.name","en","GB","AZERBAIJAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BS.name","en","GB","BAHAMAS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BH.name","en","GB","BAHRAIN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BD.name","en","GB","BANGLADESH" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BB.name","en","GB","BARBADOS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BY.name","en","GB","BELARUS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BE.name","en","GB","BELGIUM" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BZ.name","en","GB","BELIZE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BJ.name","en","GB","BENIN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BM.name","en","GB","BERMUDA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BT.name","en","GB","BHUTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BO.name","en","GB","BOLIVIA, PLURINATIONAL STATE OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BQ.name","en","GB","BONAIRE, SAINT EUSTATIUS AND SABA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BA.name","en","GB","BOSNIA AND HERZEGOVINA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BW.name","en","GB","BOTSWANA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BV.name","en","GB","BOUVET ISLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BR.name","en","GB","BRAZIL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IO.name","en","GB","BRITISH INDIAN OCEAN TERRITORY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BN.name","en","GB","BRUNEI DARUSSALAM" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BG.name","en","GB","BULGARIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BF.name","en","GB","BURKINA FASO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BI.name","en","GB","BURUNDI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KH.name","en","GB","CAMBODIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CM.name","en","GB","CAMEROON" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CA.name","en","GB","CANADA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CV.name","en","GB","CAPE VERDE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KY.name","en","GB","CAYMAN ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CF.name","en","GB","CENTRAL AFRICAN REPUBLIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TD.name","en","GB","CHAD" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CL.name","en","GB","CHILE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CN.name","en","GB","CHINA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CX.name","en","GB","CHRISTMAS ISLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CC.name","en","GB","COCOS (KEELING) ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CO.name","en","GB","COLOMBIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KM.name","en","GB","COMOROS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CG.name","en","GB","CONGO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CD.name","en","GB","CONGO, THE DEMOCRATIC REPUBLIC OF THE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CK.name","en","GB","COOK ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CR.name","en","GB","COSTA RICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CI.name","en","GB","COTE D'IVOIRE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HR.name","en","GB","CROATIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CU.name","en","GB","CUBA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CW.name","en","GB","CURACAO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CY.name","en","GB","CYPRUS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CZ.name","en","GB","CZECH REPUBLIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DK.name","en","GB","DENMARK" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DJ.name","en","GB","DJIBOUTI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DM.name","en","GB","DOMINICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DO.name","en","GB","DOMINICAN REPUBLIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EC.name","en","GB","ECUADOR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EG.name","en","GB","EGYPT" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SV.name","en","GB","EL SALVADOR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GQ.name","en","GB","EQUATORIAL GUINEA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ER.name","en","GB","ERITREA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EE.name","en","GB","ESTONIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ET.name","en","GB","ETHIOPIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FK.name","en","GB","FALKLAND ISLANDS (MALVINAS)" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FO.name","en","GB","FAROE ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FJ.name","en","GB","FIJI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FI.name","en","GB","FINLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FR.name","en","GB","FRANCE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GF.name","en","GB","FRENCH GUIANA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PF.name","en","GB","FRENCH POLYNESIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TF.name","en","GB","FRENCH SOUTHERN TERRITORIES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GA.name","en","GB","GABON" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GM.name","en","GB","GAMBIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GE.name","en","GB","GEORGIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.DE.name","en","GB","GERMANY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GH.name","en","GB","GHANA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GI.name","en","GB","GIBRALTAR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GR.name","en","GB","GREECE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GL.name","en","GB","GREENLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GD.name","en","GB","GRENADA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GP.name","en","GB","GUADELOUPE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GU.name","en","GB","GUAM" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GT.name","en","GB","GUATEMALA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GG.name","en","GB","GUERNSEY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GN.name","en","GB","GUINEA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GW.name","en","GB","GUINEA-BISSAU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GY.name","en","GB","GUYANA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HT.name","en","GB","HAITI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HM.name","en","GB","HEARD ISLAND AND MCDONALD ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VA.name","en","GB","HOLY SEE (VATICAN CITY STATE)" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HN.name","en","GB","HONDURAS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HK.name","en","GB","HONG KONG" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.HU.name","en","GB","HUNGARY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IS.name","en","GB","ICELAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IN.name","en","GB","INDIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ID.name","en","GB","INDONESIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IR.name","en","GB","IRAN, ISLAMIC REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IQ.name","en","GB","IRAQ" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IE.name","en","GB","IRELAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IM.name","en","GB","ISLE OF MAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IL.name","en","GB","ISRAEL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.IT.name","en","GB","ITALY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.JM.name","en","GB","JAMAICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.JP.name","en","GB","JAPAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.JE.name","en","GB","JERSEY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.JO.name","en","GB","JORDAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KZ.name","en","GB","KAZAKHSTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KE.name","en","GB","KENYA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KI.name","en","GB","KIRIBATI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KP.name","en","GB","KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KR.name","en","GB","KOREA, REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KW.name","en","GB","KUWAIT" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KG.name","en","GB","KYRGYZSTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LA.name","en","GB","LAO PEOPLE'S DEMOCRATIC REPUBLIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LV.name","en","GB","LATVIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LB.name","en","GB","LEBANON" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LS.name","en","GB","LESOTHO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LR.name","en","GB","LIBERIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LY.name","en","GB","LIBYAN ARAB JAMAHIRIYA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LI.name","en","GB","LIECHTENSTEIN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LT.name","en","GB","LITHUANIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LU.name","en","GB","LUXEMBOURG" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MO.name","en","GB","MACAO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MK.name","en","GB","MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MG.name","en","GB","MADAGASCAR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MW.name","en","GB","MALAWI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MY.name","en","GB","MALAYSIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MV.name","en","GB","MALDIVES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ML.name","en","GB","MALI" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MT.name","en","GB","MALTA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MH.name","en","GB","MARSHALL ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MQ.name","en","GB","MARTINIQUE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MR.name","en","GB","MAURITANIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MU.name","en","GB","MAURITIUS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.YT.name","en","GB","MAYOTTE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MX.name","en","GB","MEXICO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.FM.name","en","GB","MICRONESIA, FEDERATED STATES OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MD.name","en","GB","MOLDOVA, REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MC.name","en","GB","MONACO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MN.name","en","GB","MONGOLIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ME.name","en","GB","MONTENEGRO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MS.name","en","GB","MONTSERRAT" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MA.name","en","GB","MOROCCO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MZ.name","en","GB","MOZAMBIQUE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MM.name","en","GB","MYANMAR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NA.name","en","GB","NAMIBIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NR.name","en","GB","NAURU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NP.name","en","GB","NEPAL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NL.name","en","GB","NETHERLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AN.name","en","GB","NETHERLANDS ANTILLES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NC.name","en","GB","NEW CALEDONIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NZ.name","en","GB","NEW ZEALAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NI.name","en","GB","NICARAGUA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NE.name","en","GB","NIGER" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NG.name","en","GB","NIGERIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NU.name","en","GB","NIUE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NF.name","en","GB","NORFOLK ISLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MP.name","en","GB","NORTHERN MARIANA ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.NO.name","en","GB","NORWAY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.OM.name","en","GB","OMAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PK.name","en","GB","PAKISTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PW.name","en","GB","PALAU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PS.name","en","GB","PALESTINIAN TERRITORY, OCCUPIED" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PA.name","en","GB","PANAMA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PG.name","en","GB","PAPUA NEW GUINEA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PY.name","en","GB","PARAGUAY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PE.name","en","GB","PERU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PH.name","en","GB","PHILIPPINES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PN.name","en","GB","PITCAIRN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PL.name","en","GB","POLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PT.name","en","GB","PORTUGAL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PR.name","en","GB","PUERTO RICO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.QA.name","en","GB","QATARR" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.RE.name","en","GB","RÉUNION" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.RO.name","en","GB","ROMANIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.RU.name","en","GB","RUSSIAN FEDERATION" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.RW.name","en","GB","RWANDA SAINT BARTH" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.BL.name","en","GB","LEMY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SH.name","en","GB","SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.KN.name","en","GB","SAINT KITTS AND NEVIS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LC.name","en","GB","SAINT LUCIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.MF.name","en","GB","SAINT MARTIN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.PM.name","en","GB","SAINT PIERRE AND MIQUELON" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VC.name","en","GB","SAINT VINCENT AND THE GRENADINES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.WS.name","en","GB","SAMOA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SM.name","en","GB","SAN MARINO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ST.name","en","GB","SAO TOME AND PRINCIPE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SA.name","en","GB","SAUDI ARABIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SN.name","en","GB","SENEGAL" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.RS.name","en","GB","SERBIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SC.name","en","GB","SEYCHELLES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SL.name","en","GB","SIERRA LEONE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SG.name","en","GB","SINGAPORE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SK.name","en","GB","SLOVAKIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SI.name","en","GB","SLOVENIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SB.name","en","GB","SOLOMON ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SO.name","en","GB","SOMALIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ZA.name","en","GB","SOUTH AFRICA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GS.name","en","GB","SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ES.name","en","GB","SPAIN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.LK.name","en","GB","SRI LANKA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SD.name","en","GB","SUDAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SR.name","en","GB","SURINAME" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SJ.name","en","GB","SVALBARD AND JAN MAYEN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SZ.name","en","GB","SWAZILAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SE.name","en","GB","SWEDEN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.CH.name","en","GB","SWITZERLAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.SY.name","en","GB","SYRIAN ARAB REPUBLIC" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TW.name","en","GB","TAIWAN, PROVINCE OF CHINA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TJ.name","en","GB","TAJIKISTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TZ.name","en","GB","TANZANIA, UNITED REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TH.name","en","GB","THAILAND" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TL.name","en","GB","TIMOR-LESTE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TG.name","en","GB","TOGO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TK.name","en","GB","TOKELAU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TO.name","en","GB","TONGA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TT.name","en","GB","TRINIDAD AND TOBAGO" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TN.name","en","GB","TUNISIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TR.name","en","GB","TURKEY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TM.name","en","GB","TURKMENISTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TC.name","en","GB","TURKS AND CAICOS ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.TV.name","en","GB","TUVALU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.UG.name","en","GB","UGANDA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.UA.name","en","GB","UKRAINE" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.AE.name","en","GB","UNITED ARAB EMIRATES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.GB.name","en","GB","UNITED KINGDOM" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.US.name","en","GB","UNITED STATES" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.UM.name","en","GB","UNITED STATES MINOR OUTLYING ISLANDS" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.UY.name","en","GB","URUGUAY" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.UZ.name","en","GB","UZBEKISTAN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VU.name","en","GB","VANUATU" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VE.name","en","GB","VENEZUELA, BOLIVARIAN REPUBLIC OF" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VN.name","en","GB","VIET NAM" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VG.name","en","GB","VIRGIN ISLANDS, BRITISH" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.VI.name","en","GB","VIRGIN ISLANDS, U.S." );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.WF.name","en","GB","WALLIS AND FUTUNA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.EH.name","en","GB","WESTERN SAHARA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.YE.name","en","GB","YEMEN" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ZM.name","en","GB","ZAMBIA" );
INSERT INTO textresource_t VALUES( NULL,"1970-01-01 01:00:00","appstore.admin.locale.regions.ZW.name","en","GB","ZIMBABWE" );

INSERT INTO region_t VALUES ( NULL,"GLOBAL" );	-- GLOBAL
INSERT INTO region_t VALUES ( NULL,"APAC" );	-- ASIA PACIFIC
-- INSERT INTO region_t VALUES ( NULL,"AMERICAS" );	-- AMERICAS
INSERT INTO region_t VALUES ( NULL,"LATAM" );	-- LATIN AMERICA
INSERT INTO region_t VALUES ( NULL,"NORAM" );	-- NORTH AMERICA
INSERT INTO region_t VALUES ( NULL,"EMEA" );	-- EUROPE, MIDDLE EAST & AFRICA
-- INSERT INTO region_t VALUES ( NULL,"EUROPE" );	-- EUROPE
-- INSERT INTO region_t VALUES ( NULL,"MIDDLE-EAST" );	-- MIDDLE EAST
-- INSERT INTO region_t VALUES ( NULL,"AFRICA" );	-- AFRICA
INSERT INTO region_t VALUES ( NULL,"AF" );	-- AFGHANISTAN
INSERT INTO region_t VALUES ( NULL,"AX" );	-- ÅLAND ISLANDS
INSERT INTO region_t VALUES ( NULL,"AL" );	-- ALBANIA
INSERT INTO region_t VALUES ( NULL,"DZ" );	-- ALGERIA
INSERT INTO region_t VALUES ( NULL,"AS" );	-- AMERICAN SAMOA
INSERT INTO region_t VALUES ( NULL,"AD" );	-- ANDORRA
INSERT INTO region_t VALUES ( NULL,"AO" );	-- ANGOLA
INSERT INTO region_t VALUES ( NULL,"AI" );	-- ANGUILLA
INSERT INTO region_t VALUES ( NULL,"AQ" );	-- ANTARCTICA
INSERT INTO region_t VALUES ( NULL,"AG" );	-- ANTIGUA AND BARBUDA
INSERT INTO region_t VALUES ( NULL,"AR" );	-- ARGENTINA
INSERT INTO region_t VALUES ( NULL,"AM" );	-- ARMENIA
INSERT INTO region_t VALUES ( NULL,"AW" );	-- ARUBA
INSERT INTO region_t VALUES ( NULL,"AU" );	-- AUSTRALIA
INSERT INTO region_t VALUES ( NULL,"AT" );	-- AUSTRIA
INSERT INTO region_t VALUES ( NULL,"AZ" );	-- AZERBAIJAN
INSERT INTO region_t VALUES ( NULL,"BS" );	-- BAHAMAS
INSERT INTO region_t VALUES ( NULL,"BH" );	-- BAHRAIN
INSERT INTO region_t VALUES ( NULL,"BD" );	-- BANGLADESH
INSERT INTO region_t VALUES ( NULL,"BB" );	-- BARBADOS
INSERT INTO region_t VALUES ( NULL,"BY" );	-- BELARUS
INSERT INTO region_t VALUES ( NULL,"BE" );	-- BELGIUM
INSERT INTO region_t VALUES ( NULL,"BZ" );	-- BELIZE
INSERT INTO region_t VALUES ( NULL,"BJ" );	-- BENIN
INSERT INTO region_t VALUES ( NULL,"BM" );	-- BERMUDA
INSERT INTO region_t VALUES ( NULL,"BT" );	-- BHUTAN
INSERT INTO region_t VALUES ( NULL,"BO" );	-- BOLIVIA, PLURINATIONAL STATE OF
INSERT INTO region_t VALUES ( NULL,"BQ" );	-- BONAIRE, SAINT EUSTATIUS AND SABA
INSERT INTO region_t VALUES ( NULL,"BA" );	-- BOSNIA AND HERZEGOVINA
INSERT INTO region_t VALUES ( NULL,"BW" );	-- BOTSWANA
INSERT INTO region_t VALUES ( NULL,"BV" );	-- BOUVET ISLAND
INSERT INTO region_t VALUES ( NULL,"BR" );	-- BRAZIL
INSERT INTO region_t VALUES ( NULL,"IO" );	-- BRITISH INDIAN OCEAN TERRITORY
INSERT INTO region_t VALUES ( NULL,"BN" );	-- BRUNEI DARUSSALAM
INSERT INTO region_t VALUES ( NULL,"BG" );	-- BULGARIA
INSERT INTO region_t VALUES ( NULL,"BF" );	-- BURKINA FASO
INSERT INTO region_t VALUES ( NULL,"BI" );	-- BURUNDI
INSERT INTO region_t VALUES ( NULL,"KH" );	-- CAMBODIA
INSERT INTO region_t VALUES ( NULL,"CM" );	-- CAMEROON
INSERT INTO region_t VALUES ( NULL,"CA" );	-- CANADA
INSERT INTO region_t VALUES ( NULL,"CV" );	-- CAPE VERDE
INSERT INTO region_t VALUES ( NULL,"KY" );	-- CAYMAN ISLANDS
INSERT INTO region_t VALUES ( NULL,"CF" );	-- CENTRAL AFRICAN REPUBLIC
INSERT INTO region_t VALUES ( NULL,"TD" );	-- CHAD
INSERT INTO region_t VALUES ( NULL,"CL" );	-- CHILE
INSERT INTO region_t VALUES ( NULL,"CN" );	-- CHINA
INSERT INTO region_t VALUES ( NULL,"CX" );	-- CHRISTMAS ISLAND
INSERT INTO region_t VALUES ( NULL,"CC" );	-- COCOS (KEELING) ISLANDS
INSERT INTO region_t VALUES ( NULL,"CO" );	-- COLOMBIA
INSERT INTO region_t VALUES ( NULL,"KM" );	-- COMOROS
INSERT INTO region_t VALUES ( NULL,"CG" );	-- CONGO
INSERT INTO region_t VALUES ( NULL,"CD" );	-- CONGO, THE DEMOCRATIC REPUBLIC OF THE
INSERT INTO region_t VALUES ( NULL,"CK" );	-- COOK ISLANDS
INSERT INTO region_t VALUES ( NULL,"CR" );	-- COSTA RICA
INSERT INTO region_t VALUES ( NULL,"CI" );	-- COTE D'IVOIRE
INSERT INTO region_t VALUES ( NULL,"HR" );	-- CROATIA
INSERT INTO region_t VALUES ( NULL,"CU" );	-- CUBA
INSERT INTO region_t VALUES ( NULL,"CW" );	-- CURACAO
INSERT INTO region_t VALUES ( NULL,"CY" );	-- CYPRUS
INSERT INTO region_t VALUES ( NULL,"CZ" );	-- CZECH REPUBLIC
INSERT INTO region_t VALUES ( NULL,"DK" );	-- DENMARK
INSERT INTO region_t VALUES ( NULL,"DJ" );	-- DJIBOUTI
INSERT INTO region_t VALUES ( NULL,"DM" );	-- DOMINICA
INSERT INTO region_t VALUES ( NULL,"DO" );	-- DOMINICAN REPUBLIC
INSERT INTO region_t VALUES ( NULL,"EC" );	-- ECUADOR
INSERT INTO region_t VALUES ( NULL,"EG" );	-- EGYPT
INSERT INTO region_t VALUES ( NULL,"SV" );	-- EL SALVADOR
INSERT INTO region_t VALUES ( NULL,"GQ" );	-- EQUATORIAL GUINEA
INSERT INTO region_t VALUES ( NULL,"ER" );	-- ERITREA
INSERT INTO region_t VALUES ( NULL,"EE" );	-- ESTONIA
INSERT INTO region_t VALUES ( NULL,"ET" );	-- ETHIOPIA
INSERT INTO region_t VALUES ( NULL,"FK" );	-- FALKLAND ISLANDS (MALVINAS)
INSERT INTO region_t VALUES ( NULL,"FO" );	-- FAROE ISLANDS
INSERT INTO region_t VALUES ( NULL,"FJ" );	-- FIJI
INSERT INTO region_t VALUES ( NULL,"FI" );	-- FINLAND
INSERT INTO region_t VALUES ( NULL,"FR" );	-- FRANCE
INSERT INTO region_t VALUES ( NULL,"GF" );	-- FRENCH GUIANA
INSERT INTO region_t VALUES ( NULL,"PF" );	-- FRENCH POLYNESIA
INSERT INTO region_t VALUES ( NULL,"TF" );	-- FRENCH SOUTHERN TERRITORIES
INSERT INTO region_t VALUES ( NULL,"GA" );	-- GABON
INSERT INTO region_t VALUES ( NULL,"GM" );	-- GAMBIA
INSERT INTO region_t VALUES ( NULL,"GE" );	-- GEORGIA
INSERT INTO region_t VALUES ( NULL,"DE" );	-- GERMANY
INSERT INTO region_t VALUES ( NULL,"GH" );	-- GHANA
INSERT INTO region_t VALUES ( NULL,"GI" );	-- GIBRALTAR
INSERT INTO region_t VALUES ( NULL,"GR" );	-- GREECE
INSERT INTO region_t VALUES ( NULL,"GL" );	-- GREENLAND
INSERT INTO region_t VALUES ( NULL,"GD" );	-- GRENADA
INSERT INTO region_t VALUES ( NULL,"GP" );	-- GUADELOUPE
INSERT INTO region_t VALUES ( NULL,"GU" );	-- GUAM
INSERT INTO region_t VALUES ( NULL,"GT" );	-- GUATEMALA
INSERT INTO region_t VALUES ( NULL,"GG" );	-- GUERNSEY
INSERT INTO region_t VALUES ( NULL,"GN" );	-- GUINEA
INSERT INTO region_t VALUES ( NULL,"GW" );	-- GUINEA-BISSAU
INSERT INTO region_t VALUES ( NULL,"GY" );	-- GUYANA
INSERT INTO region_t VALUES ( NULL,"HT" );	-- HAITI
INSERT INTO region_t VALUES ( NULL,"HM" );	-- HEARD ISLAND AND MCDONALD ISLANDS
INSERT INTO region_t VALUES ( NULL,"VA" );	-- HOLY SEE (VATICAN CITY STATE)
INSERT INTO region_t VALUES ( NULL,"HN" );	-- HONDURAS
INSERT INTO region_t VALUES ( NULL,"HK" );	-- HONG KONG
INSERT INTO region_t VALUES ( NULL,"HU" );	-- HUNGARY
INSERT INTO region_t VALUES ( NULL,"IS" );	-- ICELAND
INSERT INTO region_t VALUES ( NULL,"IN" );	-- INDIA
INSERT INTO region_t VALUES ( NULL,"ID" );	-- INDONESIA
INSERT INTO region_t VALUES ( NULL,"IR" );	-- IRAN, ISLAMIC REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"IQ" );	-- IRAQ
INSERT INTO region_t VALUES ( NULL,"IE" );	-- IRELAND
INSERT INTO region_t VALUES ( NULL,"IM" );	-- ISLE OF MAN
INSERT INTO region_t VALUES ( NULL,"IL" );	-- ISRAEL
INSERT INTO region_t VALUES ( NULL,"IT" );	-- ITALY
INSERT INTO region_t VALUES ( NULL,"JM" );	-- JAMAICA
INSERT INTO region_t VALUES ( NULL,"JP" );	-- JAPAN
INSERT INTO region_t VALUES ( NULL,"JE" );	-- JERSEY
INSERT INTO region_t VALUES ( NULL,"JO" );	-- JORDAN
INSERT INTO region_t VALUES ( NULL,"KZ" );	-- KAZAKHSTAN
INSERT INTO region_t VALUES ( NULL,"KE" );	-- KENYA
INSERT INTO region_t VALUES ( NULL,"KI" );	-- KIRIBATI
INSERT INTO region_t VALUES ( NULL,"KP" );	-- KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"KR" );	-- KOREA, REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"KW" );	-- KUWAIT
INSERT INTO region_t VALUES ( NULL,"KG" );	-- KYRGYZSTAN
INSERT INTO region_t VALUES ( NULL,"LA" );	-- LAO PEOPLE'S DEMOCRATIC REPUBLIC
INSERT INTO region_t VALUES ( NULL,"LV" );	-- LATVIA
INSERT INTO region_t VALUES ( NULL,"LB" );	-- LEBANON
INSERT INTO region_t VALUES ( NULL,"LS" );	-- LESOTHO
INSERT INTO region_t VALUES ( NULL,"LR" );	-- LIBERIA
INSERT INTO region_t VALUES ( NULL,"LY" );	-- LIBYAN ARAB JAMAHIRIYA
INSERT INTO region_t VALUES ( NULL,"LI" );	-- LIECHTENSTEIN
INSERT INTO region_t VALUES ( NULL,"LT" );	-- LITHUANIA
INSERT INTO region_t VALUES ( NULL,"LU" );	-- LUXEMBOURG
INSERT INTO region_t VALUES ( NULL,"MO" );	-- MACAO
INSERT INTO region_t VALUES ( NULL,"MK" );	-- MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"MG" );	-- MADAGASCAR
INSERT INTO region_t VALUES ( NULL,"MW" );	-- MALAWI
INSERT INTO region_t VALUES ( NULL,"MY" );	-- MALAYSIA
INSERT INTO region_t VALUES ( NULL,"MV" );	-- MALDIVES
INSERT INTO region_t VALUES ( NULL,"ML" );	-- MALI
INSERT INTO region_t VALUES ( NULL,"MT" );	-- MALTA
INSERT INTO region_t VALUES ( NULL,"MH" );	-- MARSHALL ISLANDS
INSERT INTO region_t VALUES ( NULL,"MQ" );	-- MARTINIQUE
INSERT INTO region_t VALUES ( NULL,"MR" );	-- MAURITANIA
INSERT INTO region_t VALUES ( NULL,"MU" );	-- MAURITIUS
INSERT INTO region_t VALUES ( NULL,"YT" );	-- MAYOTTE
INSERT INTO region_t VALUES ( NULL,"MX" );	-- MEXICO
INSERT INTO region_t VALUES ( NULL,"FM" );	-- MICRONESIA, FEDERATED STATES OF
INSERT INTO region_t VALUES ( NULL,"MD" );	-- MOLDOVA, REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"MC" );	-- MONACO
INSERT INTO region_t VALUES ( NULL,"MN" );	-- MONGOLIA
INSERT INTO region_t VALUES ( NULL,"ME" );	-- MONTENEGRO
INSERT INTO region_t VALUES ( NULL,"MS" );	-- MONTSERRAT
INSERT INTO region_t VALUES ( NULL,"MA" );	-- MOROCCO
INSERT INTO region_t VALUES ( NULL,"MZ" );	-- MOZAMBIQUE
INSERT INTO region_t VALUES ( NULL,"MM" );	-- MYANMAR
INSERT INTO region_t VALUES ( NULL,"NA" );	-- NAMIBIA
INSERT INTO region_t VALUES ( NULL,"NR" );	-- NAURU
INSERT INTO region_t VALUES ( NULL,"NP" );	-- NEPAL
INSERT INTO region_t VALUES ( NULL,"NL" );	-- NETHERLANDS
INSERT INTO region_t VALUES ( NULL,"AN" );	-- NETHERLANDS ANTILLES
INSERT INTO region_t VALUES ( NULL,"NC" );	-- NEW CALEDONIA
INSERT INTO region_t VALUES ( NULL,"NZ" );	-- NEW ZEALAND
INSERT INTO region_t VALUES ( NULL,"NI" );	-- NICARAGUA
INSERT INTO region_t VALUES ( NULL,"NE" );	-- NIGER
INSERT INTO region_t VALUES ( NULL,"NG" );	-- NIGERIA
INSERT INTO region_t VALUES ( NULL,"NU" );	-- NIUE
INSERT INTO region_t VALUES ( NULL,"NF" );	-- NORFOLK ISLAND
INSERT INTO region_t VALUES ( NULL,"MP" );	-- NORTHERN MARIANA ISLANDS
INSERT INTO region_t VALUES ( NULL,"NO" );	-- NORWAY
INSERT INTO region_t VALUES ( NULL,"OM" );	-- OMAN
INSERT INTO region_t VALUES ( NULL,"PK" );	-- PAKISTAN
INSERT INTO region_t VALUES ( NULL,"PW" );	-- PALAU
INSERT INTO region_t VALUES ( NULL,"PS" );	-- PALESTINIAN TERRITORY, OCCUPIED
INSERT INTO region_t VALUES ( NULL,"PA" );	-- PANAMA
INSERT INTO region_t VALUES ( NULL,"PG" );	-- PAPUA NEW GUINEA
INSERT INTO region_t VALUES ( NULL,"PY" );	-- PARAGUAY
INSERT INTO region_t VALUES ( NULL,"PE" );	-- PERU
INSERT INTO region_t VALUES ( NULL,"PH" );	-- PHILIPPINES
INSERT INTO region_t VALUES ( NULL,"PN" );	-- PITCAIRN
INSERT INTO region_t VALUES ( NULL,"PL" );	-- POLAND
INSERT INTO region_t VALUES ( NULL,"PT" );	-- PORTUGAL
INSERT INTO region_t VALUES ( NULL,"PR" );	-- PUERTO RICO
INSERT INTO region_t VALUES ( NULL,"QA" );	-- QATARR
INSERT INTO region_t VALUES ( NULL,"RE" );	-- RÉUNION
INSERT INTO region_t VALUES ( NULL,"RO" );	-- ROMANIA
INSERT INTO region_t VALUES ( NULL,"RU" );	-- RUSSIAN FEDERATION
INSERT INTO region_t VALUES ( NULL,"RW" );	-- RWANDA SAINT BARTH
INSERT INTO region_t VALUES ( NULL,"BL" );	-- LEMY
INSERT INTO region_t VALUES ( NULL,"SH" );	-- SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA
INSERT INTO region_t VALUES ( NULL,"KN" );	-- SAINT KITTS AND NEVIS
INSERT INTO region_t VALUES ( NULL,"LC" );	-- SAINT LUCIA
INSERT INTO region_t VALUES ( NULL,"MF" );	-- SAINT MARTIN
INSERT INTO region_t VALUES ( NULL,"PM" );	-- SAINT PIERRE AND MIQUELON
INSERT INTO region_t VALUES ( NULL,"VC" );	-- SAINT VINCENT AND THE GRENADINES
INSERT INTO region_t VALUES ( NULL,"WS" );	-- SAMOA
INSERT INTO region_t VALUES ( NULL,"SM" );	-- SAN MARINO
INSERT INTO region_t VALUES ( NULL,"ST" );	-- SAO TOME AND PRINCIPE
INSERT INTO region_t VALUES ( NULL,"SA" );	-- SAUDI ARABIA
INSERT INTO region_t VALUES ( NULL,"SN" );	-- SENEGAL
INSERT INTO region_t VALUES ( NULL,"RS" );	-- SERBIA
INSERT INTO region_t VALUES ( NULL,"SC" );	-- SEYCHELLES
INSERT INTO region_t VALUES ( NULL,"SL" );	-- SIERRA LEONE
INSERT INTO region_t VALUES ( NULL,"SG" );	-- SINGAPORE
INSERT INTO region_t VALUES ( NULL,"SK" );	-- SLOVAKIA
INSERT INTO region_t VALUES ( NULL,"SI" );	-- SLOVENIA
INSERT INTO region_t VALUES ( NULL,"SB" );	-- SOLOMON ISLANDS
INSERT INTO region_t VALUES ( NULL,"SO" );	-- SOMALIA
INSERT INTO region_t VALUES ( NULL,"ZA" );	-- SOUTH AFRICA
INSERT INTO region_t VALUES ( NULL,"GS" );	-- SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS
INSERT INTO region_t VALUES ( NULL,"ES" );	-- SPAIN
INSERT INTO region_t VALUES ( NULL,"LK" );	-- SRI LANKA
INSERT INTO region_t VALUES ( NULL,"SD" );	-- SUDAN
INSERT INTO region_t VALUES ( NULL,"SR" );	-- SURINAME
INSERT INTO region_t VALUES ( NULL,"SJ" );	-- SVALBARD AND JAN MAYEN
INSERT INTO region_t VALUES ( NULL,"SZ" );	-- SWAZILAND
INSERT INTO region_t VALUES ( NULL,"SE" );	-- SWEDEN
INSERT INTO region_t VALUES ( NULL,"CH" );	-- SWITZERLAND
INSERT INTO region_t VALUES ( NULL,"SY" );	-- SYRIAN ARAB REPUBLIC
INSERT INTO region_t VALUES ( NULL,"TW" );	-- TAIWAN, PROVINCE OF CHINA
INSERT INTO region_t VALUES ( NULL,"TJ" );	-- TAJIKISTAN
INSERT INTO region_t VALUES ( NULL,"TZ" );	-- TANZANIA, UNITED REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"TH" );	-- THAILAND
INSERT INTO region_t VALUES ( NULL,"TL" );	-- TIMOR-LESTE
INSERT INTO region_t VALUES ( NULL,"TG" );	-- TOGO
INSERT INTO region_t VALUES ( NULL,"TK" );	-- TOKELAU
INSERT INTO region_t VALUES ( NULL,"TO" );	-- TONGA
INSERT INTO region_t VALUES ( NULL,"TT" );	-- TRINIDAD AND TOBAGO
INSERT INTO region_t VALUES ( NULL,"TN" );	-- TUNISIA
INSERT INTO region_t VALUES ( NULL,"TR" );	-- TURKEY
INSERT INTO region_t VALUES ( NULL,"TM" );	-- TURKMENISTAN
INSERT INTO region_t VALUES ( NULL,"TC" );	-- TURKS AND CAICOS ISLANDS
INSERT INTO region_t VALUES ( NULL,"TV" );	-- TUVALU
INSERT INTO region_t VALUES ( NULL,"UG" );	-- UGANDA
INSERT INTO region_t VALUES ( NULL,"UA" );	-- UKRAINE
INSERT INTO region_t VALUES ( NULL,"AE" );	-- UNITED ARAB EMIRATES
INSERT INTO region_t VALUES ( NULL,"GB" );	-- UNITED KINGDOM
INSERT INTO region_t VALUES ( NULL,"US" );	-- UNITED STATES
INSERT INTO region_t VALUES ( NULL,"UM" );	-- UNITED STATES MINOR OUTLYING ISLANDS
INSERT INTO region_t VALUES ( NULL,"UY" );	-- URUGUAY
INSERT INTO region_t VALUES ( NULL,"UZ" );	-- UZBEKISTAN
INSERT INTO region_t VALUES ( NULL,"VU" );	-- VANUATU
INSERT INTO region_t VALUES ( NULL,"VE" );	-- VENEZUELA, BOLIVARIAN REPUBLIC OF
INSERT INTO region_t VALUES ( NULL,"VN" );	-- VIET NAM
INSERT INTO region_t VALUES ( NULL,"VG" );	-- VIRGIN ISLANDS, BRITISH
INSERT INTO region_t VALUES ( NULL,"VI" );	-- VIRGIN ISLANDS, U.S.
INSERT INTO region_t VALUES ( NULL,"WF" );	-- WALLIS AND FUTUNA
INSERT INTO region_t VALUES ( NULL,"EH" );	-- WESTERN SAHARA
INSERT INTO region_t VALUES ( NULL,"YE" );	-- YEMEN
INSERT INTO region_t VALUES ( NULL,"ZM" );	-- ZAMBIA
INSERT INTO region_t VALUES ( NULL,"ZW" );	-- ZIMBABWE

-- GLOBAL 
SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="GLOBAL";
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AF" ) );	-- AFGHANISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AX" ) );	-- ÅLAND ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AL" ) );	-- ALBANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DZ" ) );	-- ALGERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AS" ) );	-- AMERICAN SAMOA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AD" ) );	-- ANDORRA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AO" ) );	-- ANGOLA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AI" ) );	-- ANGUILLA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AQ" ) );	-- ANTARCTICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AG" ) );	-- ANTIGUA AND BARBUDA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AR" ) );	-- ARGENTINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AM" ) );	-- ARMENIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AW" ) );	-- ARUBA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AU" ) );	-- AUSTRALIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AT" ) );	-- AUSTRIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AZ" ) );	-- AZERBAIJAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BS" ) );	-- BAHAMAS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BH" ) );	-- BAHRAIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BD" ) );	-- BANGLADESH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BB" ) );	-- BARBADOS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BY" ) );	-- BELARUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BE" ) );	-- BELGIUM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BZ" ) );	-- BELIZE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BJ" ) );	-- BENIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BM" ) );	-- BERMUDA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BT" ) );	-- BHUTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BO" ) );	-- BOLIVIA, PLURINATIONAL STATE OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BQ" ) );   -- BONAIRE, SAINT EUSTATIUS AND SABA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BA" ) );	-- BOSNIA AND HERZEGOVINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BW" ) );	-- BOTSWANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BV" ) );	-- BOUVET ISLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BR" ) );	-- BRAZIL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IO" ) );	-- BRITISH INDIAN OCEAN TERRITORY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BN" ) );	-- BRUNEI DARUSSALAM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BG" ) );	-- BULGARIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BF" ) );	-- BURKINA FASO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BI" ) );	-- BURUNDI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KH" ) );	-- CAMBODIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CM" ) );	-- CAMEROON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CA" ) );	-- CANADA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CV" ) );	-- CAPE VERDE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KY" ) );	-- CAYMAN ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CF" ) );	-- CENTRAL AFRICAN REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TD" ) );	-- CHAD
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CL" ) );	-- CHILE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CN" ) );	-- CHINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CX" ) );	-- CHRISTMAS ISLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CC" ) );	-- COCOS (KEELING) ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CO" ) );	-- COLOMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KM" ) );	-- COMOROS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CG" ) );	-- CONGO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CD" ) );	-- CONGO, THE DEMOCRATIC REPUBLIC OF THE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CK" ) );	-- COOK ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CR" ) );	-- COSTA RICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CI" ) );	-- COTE D'IVOIRE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HR" ) );	-- CROATIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CU" ) );	-- CUBA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CW" ) );	-- CURACAO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CY" ) );	-- CYPRUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CZ" ) );	-- CZECH REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DK" ) );	-- DENMARK
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DJ" ) );	-- DJIBOUTI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DM" ) );	-- DOMINICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DO" ) );	-- DOMINICAN REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EC" ) );	-- ECUADOR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EG" ) );	-- EGYPT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SV" ) );	-- EL SALVADOR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GQ" ) );	-- EQUATORIAL GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ER" ) );	-- ERITREA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EE" ) );	-- ESTONIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ET" ) );	-- ETHIOPIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FK" ) );	-- FALKLAND ISLANDS (MALVINAS)
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FO" ) );	-- FAROE ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FJ" ) );	-- FIJI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FI" ) );	-- FINLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FR" ) );	-- FRANCE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GF" ) );	-- FRENCH GUIANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PF" ) );	-- FRENCH POLYNESIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TF" ) );	-- FRENCH SOUTHERN TERRITORIES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GA" ) );	-- GABON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GM" ) );	-- GAMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GE" ) );	-- GEORGIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DE" ) );	-- GERMANY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GH" ) );	-- GHANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GI" ) );	-- GIBRALTAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GR" ) );	-- GREECE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GL" ) );	-- GREENLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GD" ) );	-- GRENADA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GP" ) );	-- GUADELOUPE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GU" ) );	-- GUAM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GT" ) );	-- GUATEMALA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GG" ) );	-- GUERNSEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GN" ) );	-- GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GW" ) );	-- GUINEA-BISSAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GY" ) );	-- GUYANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HT" ) );	-- HAITI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HM" ) );	-- HEARD ISLAND AND MCDONALD ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VA" ) );	-- HOLY SEE (VATICAN CITY STATE)
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HN" ) );	-- HONDURAS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HK" ) );	-- HONG KONG
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HU" ) );	-- HUNGARY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IS" ) );	-- ICELAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IN" ) );	-- INDIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ID" ) );	-- INDONESIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IR" ) );	-- IRAN, ISLAMIC REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IQ" ) );	-- IRAQ
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IE" ) );	-- IRELAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IM" ) );	-- ISLE OF MAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IL" ) );	-- ISRAEL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IT" ) );	-- ITALY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JM" ) );	-- JAMAICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JP" ) );	-- JAPAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JE" ) );	-- JERSEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JO" ) );	-- JORDAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KZ" ) );	-- KAZAKHSTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KE" ) );	-- KENYA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KI" ) );	-- KIRIBATI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KP" ) );	-- KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KR" ) );	-- KOREA, REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KW" ) );	-- KUWAIT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KG" ) );	-- KYRGYZSTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LA" ) );	-- LAO PEOPLE'S DEMOCRATIC REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LV" ) );	-- LATVIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LB" ) );	-- LEBANON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LS" ) );	-- LESOTHO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LR" ) );	-- LIBERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LY" ) );	-- LIBYAN ARAB JAMAHIRIYA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LI" ) );	-- LIECHTENSTEIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LT" ) );	-- LITHUANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LU" ) );	-- LUXEMBOURG
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MO" ) );	-- MACAO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MK" ) );	-- MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MG" ) );	-- MADAGASCAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MW" ) );	-- MALAWI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MY" ) );	-- MALAYSIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MV" ) );	-- MALDIVES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ML" ) );	-- MALI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MT" ) );	-- MALTA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MH" ) );	-- MARSHALL ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MQ" ) );	-- MARTINIQUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MR" ) );	-- MAURITANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MU" ) );	-- MAURITIUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "YT" ) );	-- MAYOTTE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MX" ) );	-- MEXICO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FM" ) );	-- MICRONESIA, FEDERATED STATES OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MD" ) );	-- MOLDOVA, REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MC" ) );	-- MONACO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MN" ) );	-- MONGOLIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ME" ) );	-- MONTENEGRO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MS" ) );	-- MONTSERRAT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MA" ) );	-- MOROCCO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MZ" ) );	-- MOZAMBIQUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MM" ) );	-- MYANMAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NA" ) );	-- NAMIBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NR" ) );	-- NAURU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NP" ) );	-- NEPAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NL" ) );	-- NETHERLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AN" ) );	-- NETHERLANDS ANTILLES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NC" ) );	-- NEW CALEDONIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NZ" ) );	-- NEW ZEALAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NI" ) );	-- NICARAGUA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NE" ) );	-- NIGER
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NG" ) );	-- NIGERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NU" ) );	-- NIUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NF" ) );	-- NORFOLK ISLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MP" ) );	-- NORTHERN MARIANA ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NO" ) );	-- NORWAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "OM" ) );	-- OMAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PK" ) );	-- PAKISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PW" ) );	-- PALAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PS" ) );	-- PALESTINIAN TERRITORY, OCCUPIED
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PA" ) );	-- PANAMA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PG" ) );	-- PAPUA NEW GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PY" ) );	-- PARAGUAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PE" ) );	-- PERU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PH" ) );	-- PHILIPPINES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PN" ) );	-- PITCAIRN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PL" ) );	-- POLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PT" ) );	-- PORTUGAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PR" ) );	-- PUERTO RICO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "QA" ) );	-- QATARR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RE" ) );	-- RÉUNION
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RO" ) );	-- ROMANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RU" ) );	-- RUSSIAN FEDERATION
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RW" ) );	-- RWANDA SAINT BARTH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BL" ) );	-- LEMY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SH" ) );	-- SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KN" ) );	-- SAINT KITTS AND NEVIS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LC" ) );	-- SAINT LUCIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MF" ) );	-- SAINT MARTIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PM" ) );	-- SAINT PIERRE AND MIQUELON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VC" ) );	-- SAINT VINCENT AND THE GRENADINES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "WS" ) );	-- SAMOA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SM" ) );	-- SAN MARINO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ST" ) );	-- SAO TOME AND PRINCIPE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SA" ) );	-- SAUDI ARABIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SN" ) );	-- SENEGAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RS" ) );	-- SERBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SC" ) );	-- SEYCHELLES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SL" ) );	-- SIERRA LEONE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SG" ) );	-- SINGAPORE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SK" ) );	-- SLOVAKIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SI" ) );	-- SLOVENIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SB" ) );	-- SOLOMON ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SO" ) );	-- SOMALIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZA" ) );	-- SOUTH AFRICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GS" ) );	-- SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ES" ) );	-- SPAIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LK" ) );	-- SRI LANKA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SD" ) );	-- SUDAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SR" ) );	-- SURINAME
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SJ" ) );	-- SVALBARD AND JAN MAYEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SZ" ) );	-- SWAZILAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SE" ) );	-- SWEDEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CH" ) );	-- SWITZERLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SY" ) );	-- SYRIAN ARAB REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TW" ) );	-- TAIWAN, PROVINCE OF CHINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TJ" ) );	-- TAJIKISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TZ" ) );	-- TANZANIA, UNITED REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TH" ) );	-- THAILAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TL" ) );	-- TIMOR-LESTE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TG" ) );	-- TOGO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TK" ) );	-- TOKELAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TO" ) );	-- TONGA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TT" ) );	-- TRINIDAD AND TOBAGO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TN" ) );	-- TUNISIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TR" ) );	-- TURKEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TM" ) );	-- TURKMENISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TC" ) );	-- TURKS AND CAICOS ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TV" ) );	-- TUVALU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UG" ) );	-- UGANDA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UA" ) );	-- UKRAINE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AE" ) );	-- UNITED ARAB EMIRATES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GB" ) );	-- UNITED KINGDOM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "US" ) );	-- UNITED STATES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UM" ) );	-- UNITED STATES MINOR OUTLYING ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UY" ) );	-- URUGUAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UZ" ) );	-- UZBEKISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VU" ) );	-- VANUATU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VE" ) );	-- VENEZUELA, BOLIVARIAN REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VN" ) );	-- VIET NAM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VG" ) );	-- VIRGIN ISLANDS, BRITISH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VI" ) );	-- VIRGIN ISLANDS, U.S.
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "WF" ) );	-- WALLIS AND FUTUNA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EH" ) );	-- WESTERN SAHARA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "YE" ) );	-- YEMEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZM" ) );	-- ZAMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZW" ) );	-- ZIMBABWE


-- EMEA
SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="EMEA";
		-- EUROPE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AL" ) );	-- ALBANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AD" ) );	-- ANDORRA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AM" ) );	-- ARMENIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AT" ) );	-- AUSTRIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AZ" ) );	-- AZERBAIJAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BY" ) );	-- BELARUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BE" ) );	-- BELGIUM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BA" ) );	-- BOSNIA AND HERZEGOVINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BG" ) );	-- BULGARIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HR" ) );	-- CROATIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CY" ) );	-- CYPRUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CZ" ) );	-- CZECH REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DK" ) );	-- DENMARK
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EE" ) );	-- ESTONIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FO" ) );	-- FAROE ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FI" ) );	-- FINLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FR" ) );	-- FRANCE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GE" ) );	-- GEORGIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DE" ) );	-- GERMANY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GI" ) );	-- GIBRALTAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GR" ) );	-- GREECE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GG" ) );	-- GUERNSEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HU" ) );	-- HUNGARY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IS" ) );	-- ICELAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IE" ) );	-- IRELAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IM" ) );	-- ISLE OF MAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IT" ) );	-- ITALY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JE" ) );	-- JERSEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KZ" ) );	-- KAZAKHSTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LV" ) );	-- LATVIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LI" ) );	-- LIECHTENSTEIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LT" ) );	-- LITHUANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LU" ) );	-- LUXEMBOURG
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MK" ) );	-- MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MT" ) );	-- MALTA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MD" ) );	-- MOLDOVA, REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MC" ) );	-- MONACO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ME" ) );	-- MONTENEGRO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NL" ) );	-- NETHERLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NO" ) );	-- NORWAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PL" ) );	-- POLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PT" ) );	-- PORTUGAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RO" ) );	-- ROMANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RU" ) );	-- RUSSIAN FEDERATION
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SJ" ) );	-- SVALBARD AND JAN MAYEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SM" ) );	-- SAN MARINO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RS" ) );	-- SERBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SK" ) );	-- SLOVAKIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SI" ) );	-- SLOVENIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ES" ) );	-- SPAIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SE" ) );	-- SWEDEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CH" ) );	-- SWITZERLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UA" ) );	-- UKRAINE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GB" ) );	-- UNITED KINGDOM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VA" ) );	-- HOLY SEE (VATICAN CITY STATE)

	-- MIDDLE EAST
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TR" ) );	-- TURKEY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UA" ) );	-- UKRAINE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BH" ) );	-- BAHRAIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KW" ) );	-- KUWAIT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "OM" ) );	-- OMAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "QA" ) );	-- QATARR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SA" ) );	-- SAUDI ARABIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AE" ) );	-- UNITED ARAB EMIRATES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "YE" ) );	-- YEMEN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IQ" ) );	-- IRAQ
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IL" ) );	-- ISRAEL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JO" ) );	-- JORDAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LB" ) );	-- LEBANON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SY" ) );	-- SYRIAN ARAB REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IR" ) );	-- IRAN, ISLAMIC REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EG" ) );	-- EGYPT

	-- AFRICA 
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DZ" ) );	-- ALGERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AO" ) );	-- ANGOLA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BJ" ) );	-- BENIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BW" ) );	-- BOTSWANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BF" ) );	-- BURKINA FASO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BI" ) );	-- BURUNDI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CM" ) );	-- CAMEROON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CV" ) );	-- CAPE VERDE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CF" ) );	-- CENTRAL AFRICAN REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TD" ) );	-- CHAD
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KM" ) );	-- COMOROS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CI" ) );	-- COTE D'IVOIRE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CD" ) );	-- CONGO, THE DEMOCRATIC REPUBLIC OF THE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DJ" ) );	-- DJIBOUTI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EG" ) );	-- EGYPT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GQ" ) );	-- EQUATORIAL GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ER" ) );	-- ERITREA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ET" ) );	-- ETHIOPIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GA" ) );	-- GABON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GM" ) );	-- GAMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GH" ) );	-- GHANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GN" ) );	-- GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GW" ) );	-- GUINEA-BISSAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KE" ) );	-- KENYA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LS" ) );	-- LESOTHO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LR" ) );	-- LIBERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LY" ) );	-- LIBYAN ARAB JAMAHIRIYA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MG" ) );	-- MADAGASCAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MW" ) );	-- MALAWI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ML" ) );	-- MALI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MR" ) );	-- MAURITANIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MU" ) );	-- MAURITIUS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MA" ) );	-- MOROCCO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MZ" ) );	-- MOZAMBIQUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NA" ) );	-- NAMIBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NE" ) );	-- NIGER
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NG" ) );	-- NIGERIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CD" ) );	-- CONGO, THE DEMOCRATIC REPUBLIC OF THE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RE" ) );	-- RÉUNION
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "RW" ) );	-- RWANDA SAINT BARTH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SH" ) );	-- SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ST" ) );	-- SAO TOME AND PRINCIPE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SN" ) );	-- SENEGAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SC" ) );	-- SEYCHELLES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SL" ) );	-- SIERRA LEONE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SO" ) );	-- SOMALIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZA" ) );	-- SOUTH AFRICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SD" ) );	-- SUDAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SZ" ) );	-- SWAZILAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TZ" ) );	-- TANZANIA, UNITED REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TG" ) );	-- TOGO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TN" ) );	-- TUNISIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UG" ) );	-- UGANDA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZM" ) );	-- ZAMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ZW" ) );	-- ZIMBABWE

-- APAC
SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="APAC";
	-- ASIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AF" ) );	-- AFGHANISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BD" ) );	-- BANGLADESH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "IN" ) );	-- INDIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MV" ) );	-- MALDIVES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NP" ) );	-- NEPAL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PK" ) );	-- PAKISTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LK" ) );	-- SRI LANKA

	-- EAST ASIA, SOUTHEAST ASIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BT" ) );	-- BHUTAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BN" ) );	-- BRUNEI DARUSSALAM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KH" ) );	-- CAMBODIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CN" ) );	-- CHINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "ID" ) );	-- INDONESIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JP" ) );	-- JAPAN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LA" ) );	-- LAO PEOPLE'S DEMOCRATIC REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MY" ) );	-- MALAYSIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MM" ) );	-- MYANMAR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PH" ) );	-- PHILIPPINES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SG" ) );	-- SINGAPORE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KP" ) );	-- KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TH" ) );	-- THAILAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VN" ) );	-- VIET NAM
	-- PACIFIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AU" ) );	-- AUSTRALIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CK" ) );	-- COOK ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FM" ) );	-- MICRONESIA, FEDERATED STATES OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NU" ) );	-- NIUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KI" ) );	-- KIRIBATI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NR" ) );	-- NAURU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NZ" ) );	-- NEW ZEALAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "WS" ) );	-- SAMOA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PW" ) );	-- PALAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PG" ) );	-- PAPUA NEW GUINEA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MH" ) );	-- MARSHALL ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VU" ) );	-- VANUATU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SB" ) );	-- SOLOMON ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TO" ) );	-- TONGA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TV" ) );	-- TUVALU
	-- OTHERS ALSO INCLUDED IN APAC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AS" ) );	-- AMERICAN SAMOA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FJ" ) );	-- FIJI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PF" ) );	-- FRENCH POLYNESIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GU" ) );	-- GUAM
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HK" ) );	-- HONG KONG
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MO" ) );	-- MACAO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MN" ) );	-- MONGOLIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NC" ) );	-- NEW CALEDONIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KR" ) );	-- KOREA, REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MP" ) );	-- NORTHERN MARIANA ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TW" ) );	-- TAIWAN, PROVINCE OF CHINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TL" ) );	-- TIMOR-LESTE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TK" ) );	-- TOKELAU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "WF" ) );	-- WALLIS AND FUTUNA


-- LATAM
SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="LATAM";
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AI" ) );	-- ANGUILLA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AG" ) );	-- ANTIGUA AND BARBUDA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AR" ) );	-- ARGENTINA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "AW" ) );	-- ARUBA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BS" ) );	-- BAHAMAS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BB" ) );	-- BARBADOS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BZ" ) );	-- BELIZE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BO" ) );	-- BOLIVIA, PLURINATIONAL STATE OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BQ" ) );   -- BONAIRE, SAINT EUSTATIUS AND SABA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BR" ) );	-- BRAZIL
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VG" ) );	-- VIRGIN ISLANDS, BRITISH
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KY" ) );	-- CAYMAN ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CL" ) );	-- CHILE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CO" ) );	-- COLOMBIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CR" ) );	-- COSTA RICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CU" ) );	-- CUBA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CW" ) );	-- CURACAO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DM" ) );	-- DOMINICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "DO" ) );	-- DOMINICAN REPUBLIC
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "EC" ) );	-- ECUADOR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SV" ) );	-- EL SALVADOR
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "FK" ) );	-- FALKLAND ISLANDS (MALVINAS)
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GF" ) );	-- FRENCH GUIANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GD" ) );	-- GRENADA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GP" ) );	-- GUADELOUPE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GT" ) );	-- GUATEMALA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GY" ) );	-- GUYANA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HT" ) );	-- HAITI
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "HN" ) );	-- HONDURAS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "JM" ) );	-- JAMAICA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MQ" ) );	-- MARTINIQUE
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MX" ) );	-- MEXICO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MS" ) );	-- MONTSERRAT
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "NI" ) );	-- NICARAGUA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PA" ) );	-- PANAMA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PY" ) );	-- PARAGUAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PE" ) );	-- PERU
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PR" ) );	-- PUERTO RICO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "KN" ) );	-- SAINT KITTS AND NEVIS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "LC" ) );	-- SAINT LUCIA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MF" ) );	-- SAINT MARTIN
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "PM" ) );	-- SAINT PIERRE AND MIQUELON
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VC" ) );	-- SAINT VINCENT AND THE GRENADINES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GS" ) );	-- SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "SR" ) );	-- SURINAME
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TT" ) );	-- TRINIDAD AND TOBAGO
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "TC" ) );	-- TURKS AND CAICOS ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "BL" ) );	-- LEMY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UY" ) );	-- URUGUAY
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VE" ) );	-- VENEZUELA, BOLIVARIAN REPUBLIC OF
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "VI" ) );	-- VIRGIN ISLANDS, U.S.

-- NORAM
SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="NORAM";
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "CA" ) );	-- CANADA
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "GL" ) );	-- GREENLAND
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "US" ) );	-- UNITED STATES
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "UM" ) );	-- UNITED STATES MINOR OUTLYING ISLANDS
INSERT INTO region__region_composite_relation_t VALUES ( @MACROID, getRegionId( "MX" ) );	-- MEXICO


-- AMERICAS
-- SELECT @MACROID:=region_t.id FROM region_t WHERE region_t.region="AMERICAS";


-- Merchant Account Types

INSERT INTO merchant_account_type_t VALUES ( NULL,'paypal' );
INSERT INTO merchant_account_type_t VALUES ( NULL,'bank' );


-- Locales currently supported by the application.
INSERT INTO application_locale_t VALUES ( NULL,(SELECT id FROM locale_t WHERE language="en" AND country="GB" ) );


