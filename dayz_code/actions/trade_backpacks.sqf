private["_iarray","_part_out","_part_in","_qty_out","_qty_in","_qty"];
//		   [part_out,part_in, qty_out, qty_in,];

if(TradeInprogress) exitWith { cutText ["Trade already in progress." , "PLAIN DOWN"]; };
TradeInprogress = true;

_activatingPlayer = _this select 1;

_part_out = (_this select 3) select 0;
_part_in = (_this select 3) select 1;
_qty_out = (_this select 3) select 2;
_qty_in = (_this select 3) select 3;
_buy_o_sell = (_this select 3) select 4;
_textPartIn = (_this select 3) select 5;
_textPartOut = (_this select 3) select 6;
_traderID = (_this select 3) select 7;
_bos = 0;
_bulkqty = 0;

if(_buy_o_sell == "buy") then {
	_qty = {_x == _part_in} count magazines player;
} else {

	// SELL ONLY check if item is bulk 
	_bulkItem = "bulk_" + _part_in;
	_bulkqty = {_x == _bulkItem} count magazines player;

	diag_log format["DEBUG bulk: %1", _bulkItem];

	_bos = 1;
	_qty = 0;
	_bag = unitBackpack player;
	_class = typeOf _bag;
	if(_class == _part_in) then {
		_qty = 1;
	};
};

if (_bulkqty >= 1) then {
	
	
	// TODO: optimize for one db call only
	
	_part_in = "bulk_" + _part_in;
	player removeMagazine _part_in;

	//disableSerialization;
	//call dayz_forceSave;
	
	diag_log format["DEBUG remove magazine %1", _part_in];

	// increment trader for each
	for "_x" from 1 to 12 do {
		//["dayzTradeObject",[_activatingPlayer,_traderID,_bos]] call callRpcProcedure;
		dayzTradeObject = [_activatingPlayer,_traderID,_bos];
		publicVariableServer  "dayzTradeObject";
	
		waitUntil {!isNil "dayzTradeResult"};

		if(dayzTradeResult == "PASS") then {
			diag_log format["DEBUG Complete Trade: %1", dayzTradeResult];
		};
	};

	_qty_out = _qty_out * 12;

	// gold = 36 copper
	// gold = 6 silver
	// 

	if (_part_out == "ItemSilverBar" and _qty_out >= 30) then {
	
		// find number of gold
		_gold_out = _qty_out / 30;
			
		// whole number of gold bars
		_gold_qty_out = floor _gold_out;
			
		_part_out = "ItemGoldBar";
		for "_x" from 1 to _gold_qty_out do {
			player addMagazine _part_out;
		};

		// Find remainder 
		_partial_qty_out = (_gold_out - _gold_qty_out) * 30;
			
		// whole number of silver bars
		_silver_qty_out = floor _partial_qty_out;

		_part_out = "ItemSilverBar";
		for "_x" from 1 to _silver_qty_out do {
			player addMagazine _part_out;
		};

	} else {
		
		for "_x" from 1 to _qty_out do {
			player addMagazine _part_out;
		};
	};
	
	//disableSerialization;
	//call dayz_forceSave;

	cutText [format[("Traded %1 %2 for %3 %4"),_qty_in,_textPartIn,_qty_out,_textPartOut], "PLAIN DOWN"];

	dayzTradeResult = nil;


} else {


	if (_qty >= _qty_in) then {

		//["dayzTradeObject",[_activatingPlayer,_traderID,_bos]] call callRpcProcedure;
		dayzTradeObject = [_activatingPlayer,_traderID,_bos];
		publicVariableServer  "dayzTradeObject";
	

		diag_log format["DEBUG Starting to wait for answer: %1", dayzTradeObject];

		waitUntil {!isNil "dayzTradeResult"};

		diag_log format["DEBUG Complete Trade: %1", dayzTradeResult];

		if(dayzTradeResult == "PASS") then {

			if(_buy_o_sell == "buy") then {
				for "_x" from 1 to _qty_in do {
					player removeMagazine _part_in;
				};
				removeBackpack player;
				player addBackpack _part_out;
			} else {
				// Sell
				for "_x" from 1 to _qty_out do {
					player addMagazine _part_out;
				};	
				removeBackpack player;
				// player addBackpack _part_out;
			};

			//disableSerialization;
			//call dayz_forceSave;

			cutText [format[("Traded %1 %2 for %3 %4"),_qty_in,_textPartIn,_qty_out,_textPartOut], "PLAIN DOWN"];

			{player removeAction _x} forEach s_player_parts;s_player_parts = [];
			s_player_parts_crtl = -1;
	
		} else {
			cutText [format[("Insufficient Stock %1"),_textPartOut] , "PLAIN DOWN"];
		};
		dayzTradeResult = nil;
	
	} else {
		_needed =  _qty_in - _qty;
		cutText [format[("Need %1 More %2"),_needed,_textPartIn] , "PLAIN DOWN"];
	};
};

TradeInprogress = false;