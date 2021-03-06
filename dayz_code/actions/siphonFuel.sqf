private["_vehicle","_curFuel","_newFuel","_timeLeft"];
_vehicle = 		cursorTarget;

// if ((count (crew _vehicle)) > 0) exitWith {cutText ["You may not sihpon fuel while someone is in the vehicle", "PLAIN DOWN"]};

_canSize = 		getNumber(configFile >> "cfgMagazines" >> "ItemJerrycan" >> "fuelQuantity");
_configVeh = 	configFile >> "cfgVehicles" >> TypeOf(_vehicle);
_capacity = 	getNumber(_configVeh >> "fuelCapacity");
_nameType = 	getText(_configVeh >> "displayName");
_curFuel = 		((fuel _vehicle) * _capacity);
_newFuel = 		(_curFuel - _canSize);

// calculate minimum needed fuel
_newFuel = (_newFuel / _capacity);

if (_newFuel > 0) then {

	player removeMagazine "ItemJerrycanEmpty";
	player addMagazine "ItemJerrycan";

	//disableSerialization;
	//call dayz_forceSave;

	player playActionNow "Medic";
	[player,"refuel",0,false] call dayz_zombieSpeak;

	_id = [player,20,true,(getPosATL player)] spawn player_alertZombies;

	sleep 6;

	//apply newFuel to vehicle on every peer
	//["dayzSetFuel",[_vehicle,_newFuel]] call broadcastRpcCallAll;

	dayzSetFuel = [_vehicle,_newFuel];
	if (local _vehicle) then {
		dayzSetFuel spawn local_setFuel;
	};
	publicVariable "dayzSetFuel";

	cutText [format["%1 has been drained for %2 litres of Fuel",_nameType,_canSize], "PLAIN DOWN"];
	
	
	
	sleep 1;

	call fnc_usec_medic_removeActions;
	r_action = false;

} else {
	cutText [format["%1 has no fuel.",_nameType], "PLAIN DOWN"];
};
