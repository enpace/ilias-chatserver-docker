/**
 * This program is free software and available under the MIT license.
 */

( function () {
	'use strict';
	var penv = process.env;
	var settings = {
		protocol: "http",
		port: penv.ILIAS_CHAT_PORT,
		address: penv.ILIAS_CHAT_ADDRESS,
		log: penv.ILIAS_CHAT_LOG_DIR + "/chat.log",
		error_log: penv.ILIAS_CHAT_LOG_DIR + "/chat_errors.log",
		deletion_mode: penv.ILIAS_CHAT_DELETION_MODE,
		deletion_unit: penv.ILIAS_CHAT_DELETION_UNIT,
		deletion_value: penv.ILIAS_CHAT_DELETION_VALUE,
		deletion_time: penv.ILIAS_CHAT_DELETION_TIME
	};
	process.stdout.write( JSON.stringify( settings, null, 4 ) );
} () );

