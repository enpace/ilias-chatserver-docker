/**
 * This program is free software and available under the MIT license.
 */

( function () {
	'use strict';
	var penv = process.env;
	var settings = {
		name: penv.ILIAS_CHAT_CLIENT_NAME,
		auth: {
			key: penv.ILIAS_CHAT_AUTH_KEY,
			secret: penv.ILIAS_CHAT_AUTH_SECRET
		},
		database: {
			type: "mysql",
			host: penv.ILIAS_CHAT_DB_HOST,
			port: penv.ILIAS_CHAT_DB_PORT,
			name: penv.ILIAS_CHAT_DB_NAME,
			user: penv.ILIAS_CHAT_DB_USER,
			pass: penv.ILIAS_CHAT_DB_PASS
		}
	};
	process.stdout.write( JSON.stringify( settings, null, 4 ) );
} () );

